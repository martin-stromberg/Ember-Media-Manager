← [Back to overview](index.md)

# CI/CD & Git Hooks — Installation and Configuration

## Prerequisites

- Git (hooks run through Git's own hook mechanism; on Windows the shell hooks execute under Git Bash).
- Python 3 on `PATH` (as `python`, `python3` or the `py` launcher) for the `pre-commit` hook.
- The repository clone itself — `.nuget\NuGet.exe` (NuGet 6.14) ships in the repo, so the dependency scan needs no separate NuGet installation. On Linux/macOS, `mono` is required to run `NuGet.exe`; without it the `pre-push` scan is skipped with a warning.
- For the server-side workflows: nothing beyond the default `GITHUB_TOKEN`. Version/release jobs additionally need `package.json`/`package-lock.json` in the repo root and Node 24 (provisioned on the runner via `actions/setup-node@v7`).

## Installation steps

1. Activate the hooks once per clone:
   ```
   .githooks\install-hooks.cmd    :: Windows
   ./.githooks/install-hooks.sh   # Linux/macOS (Git Bash)
   ```
   This sets `git config --local core.hooksPath .githooks`.
2. Optionally verify the localization check up front: `python .githooks/translation-check.py --all`.
3. Commit and push normally — the hooks run automatically.

## Configuration

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `core.hooksPath` | local git config | not set | Set to `.githooks` by the install scripts; required for the hooks to run |
| `fail-on-vulnerabilities` | composite action input | `'true'` | Blocking vs. warn-only mode of the security scan; all call sites use `'true'` |
| `branches` | `release.config.js` | `["master"]` | semantic-release release branches; `staging` RCs are computed via a `--branches staging` override in `staging-ci.yml` instead |
| `AUTOMATIC_RELEASE_BRANCHES` | `scripts/resolve-release-version.mjs` | `["master"]` | Branch pushes that trigger an automatic release |
| `cron '0 4 * * 1'` | `security-scan.yml` | — | Weekly scan, Mondays 04:00 UTC |
| Labels `automated-backmerge` / `automated-promotion` | GitHub labels | created on demand by the workflows (`--force`) | Mark the automated PRs |

## Repository-side setup (maintainers, outside the repo content)

1. **Seed tag:** push tag `v1.12.0` on the `master` tip to `origin` **before** the workflow files first land on `staging` — the first "Pre-Release" run reads the tag list, and without a seed tag semantic-release would start at `1.0.0`.
2. **Branch protection:** protect `staging` and `master` on GitHub so the checks are actually enforceable.
3. Be aware that `push`-triggered workflows only become active once the workflow file exists on the triggering branch, and `schedule`/`workflow_run` triggers only run in the context of the default branch `master`.

## Environment variables

| Variable | Required | Example | Description |
|----------|----------|---------|-------------|
| `GITHUB_TOKEN` / `GH_TOKEN` | Yes (CI) | — | Provided by Actions; used by semantic-release, `gh` CLI calls and `resolve-release-version.mjs` |
| `RELEASE_ASSET_PATH` | automatic releases | `release.zip` | Asset path consumed by `release.config.js` |
| `RELEASE_MANIFEST_PATH` | automatic releases | `update.json` | Manifest asset path consumed by `release.config.js` |
| `RELEASE_VERSION` | automatic releases | `1.13.0` | Version passed to the release step |
| `RESOLVE_DRY_RUN` | internal | `true` | Switches `release.config.js` to the dry-run plugin set |

## Verification

- `git config --local core.hooksPath` prints `.githooks`.
- A test commit with a deliberately malformed staged `.resx` file is refused by `pre-commit`.
- `git push` prints `pre-push: Security-Scan bestanden - keine NU190x-Befunde.` (or the localized equivalent output of the hook).
- On GitHub, a PR against `staging` shows the "PR CI for Staging" checks; merging to `staging` produces a `vX.Y.Z-rc.N` pre-release.
