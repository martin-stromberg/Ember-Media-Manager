← [Back to overview](index.md)

# CI/CD & Git Hooks — Technical flow

## Overview

The pipeline is implemented entirely as repository files: shell/Python hooks under `.githooks/` (activated via `core.hooksPath`), seven GitHub Actions workflows under `.github/workflows/`, two shared composite actions under `.github/actions/`, and a semantic-release toolchain (`package.json`, `release.config.js`, `scripts/resolve-release-version.mjs`). All workflows build with the repo-pinned `.nuget\NuGet.exe` plus MSBuild on `windows-latest`; there is no `dotnet` CLI usage because the solution uses the legacy `packages.config` project format.

## Local hooks

### 1. Activation

`.githooks/install-hooks.cmd` / `.githooks/install-hooks.sh` run `git config --local core.hooksPath .githooks`. `.gitattributes` pins `.githooks/* text eol=lf` so the shell hooks keep LF line endings even with `core.autocrlf=true`.

### 2. `pre-commit`

The hook locates a Python interpreter by trying `python`, `python3` and `py -3` in order (fallback for machines without a `python` alias), then executes `.githooks/translation-check.py` on the staged files. The script performs three checks:

1. `IStringLocalizer` key scan of staged `.cs`/`.razor`/`.cshtml` files — a no-op in this repository (VB.NET WinForms codebase).
2. `.resx` package consistency (neutral + language variants must expose the same keys) — a no-op here because there are no satellite `Name.<culture>.resx` files.
3. `.resx` header validation (`resmimetype`, `reader`, `writer`) — the check that can actually fire in this repository.

Any finding exits with code 1 and aborts the commit. `translation-check.py --all` scans the whole repository instead of staged files.

### 3. `pre-push`

The hook runs `.nuget\NuGet.exe restore "Ember Media Manager.sln"` and greps the output for `NU190[1-4]` warnings (the actual vulnerability severities; `NU1900` and `NU1905+` are audit-infrastructure warnings and are deliberately not matched). A finding — or a failed restore — aborts the push with exit 1, mirroring the blocking server-side gate. Platform handling: on Windows (MINGW/MSYS/Cygwin) NuGet.exe runs directly; on Linux/macOS it runs via `mono` if available; if neither applies — or `NuGet.exe` is missing — the scan is skipped with a warning and exit 0 (the CI gate still applies server-side).

## GitHub Actions workflows

### `pr-staging-ci.yml` — "PR CI for Staging"

Triggers on `pull_request` (`opened`/`synchronize`/`reopened`) targeting `staging`. Concurrency group `pr-staging-<PR number>` cancels superseded runs.

- Job `detect-backmerge` (ubuntu): checks whether `origin/master`'s tip is a merge parent of the synthetic PR merge commit, or whether the tree is identical to `origin/master`; emits output `is_backmerge`.
- Job `static-checks` (windows, 15 min, skipped on back-merge): `microsoft/setup-msbuild@v2` → composite action `./.github/actions/security-scan` with `fail-on-vulnerabilities: 'true'` (Gate 2) → `msbuild ... -p:Configuration=Debug -p:Platform=x86` (Gate 3, no `TreatWarningsAsErrors`).
- Job `build-and-test` (windows, 20 min, parallel, skipped on back-merge): `nuget restore` → `msbuild ... -p:Configuration=Release -p:Platform=x64 -flp:logfile=build.log` → uploads `build-log-pr` artifact (14 days). Reference gates 4/5 (tests, 70 % coverage) are intentionally dropped — no executable test suite exists.
- Job `back-merge-skip`: confirmation step when `is_backmerge == 'true'`.

### `staging-ci.yml` — "Pre-Release" (display name)

Triggers on `push` to `staging`. Runs the same `detect-backmerge`, `static-checks` (artifact `vulnerable-packages-staging`) and `build-and-test` (artifact `build-log-staging`) jobs, then additionally:

- Job `version` (ubuntu, needs all gates, skipped on back-merge): Node 24 via `actions/setup-node@v7`, `npm ci`, then `npx semantic-release --dry-run --no-ci --branches staging` (the `--branches` override is deliberate — `release.config.js` only lists `master`). Parses "The next release version is X.Y.Z" → outputs `changed`, `version`; the RC number is `count(git tag --list "v<version>-rc.*") + 1` → outputs `rc_tag` (`vX.Y.Z-rc.N`) and `rc_version` (`X.Y.Z-rc.N`).
- Job `prerelease` (windows, only when `changed == 'true'`): composite action `./.github/actions/build-and-package` with `release-version`/`release-tag` — stamps `X.Y.Z-rc.N` into the assembly attributes (see "Version stamping" below) → `gh release create <rc_tag> release.zip update.json --prerelease --generate-notes`.

### `verify-pr-source.yml` — "Verify PR Source"

Triggers on any `pull_request` targeting `master`; `permissions: {}`. Single step fails (`exit 1` + `::error`) unless `github.head_ref == "staging"` — enforced via an `env` binding instead of inline interpolation (script-injection hardening).

### `sync-staging-with-main.yml` — "Backmerge Master to Staging"

Triggers on `push` to `master` (`cancel-in-progress: false`). Checks out `staging`, counts `git rev-list HEAD..origin/master`; if behind, creates label `automated-backmerge` and a PR `master → staging` (unless one is already open). The PR body requires "Create a merge commit" (not rebase) so the release tag stays reachable from `staging`.

### `staging-to-main-promotion.yml` — "Promote staging to master"

Triggers on `workflow_run` of the workflow **display name** `"Pre-Release"` (`types: [completed]`, `branches: [staging]`); the job requires `conclusion == 'success'`. Checks out `workflow_run.head_sha`, compares the tree to `origin/master` (identical tree = back-merge, no promotion) and counts `origin/master..HEAD`. If ahead: creates label `automated-promotion` and a **draft** PR `staging → master` for manual maintainer merge.

### `security-scan.yml` — "Security Scan"

Triggers on `schedule: '0 4 * * 1'` (Mondays 04:00 UTC) and `workflow_dispatch`; `permissions: contents: read`. Single job on windows: checkout → composite action `./.github/actions/security-scan` (`fail-on-vulnerabilities: 'true'`, artifact `vulnerable-packages-scan`).

### `release.yml` — "Release"

Triggers on `push` to `master` and on tags `v*.*.*`; serialized via `concurrency: release` (`cancel-in-progress: false`); single job on windows (30 min):

1. Checkout with tags, Node 24, `npm ci`.
2. `node scripts/resolve-release-version.mjs` classifies the ref — `automatic` (branch push, version via semantic-release dry-run), `manual` (pushed `vX.Y.Z` tag) — then checks the GitHub release for the resolved tag and whether all expected assets (`release.zip`, `update.json`) are uploaded → outputs `released`, `release_kind`, `release_action` (`create`/`upload-existing`), `version`, `tag`.
3. For `upload-existing`: checks out the release tag detached so rebuilt assets match the tagged commit.
4. For `create`: `nuget restore` + `msbuild Debug|x86` as the release gate (replaces the reference's test gates; guards against races between staging validation and merge/tag) + `build-log-release` artifact.
5. For `released == 'true'`: composite action `./.github/actions/build-and-package` — stamps the resolved version into the assembly attributes (see "Version stamping" below) → `release.zip` + `update.json`.
6. Publish: `automatic` → `npm run release` (semantic-release creates tag, GitHub release and uploads assets per `release.config.js`); `manual` → `gh release create $tag release.zip update.json --generate-notes`; `upload-existing` → `gh release upload $tag --clobber`. Note for the repair path: `build-and-package` is loaded from the **tagged** commit, so stamps/verifies only run for tags created after the stamping change was introduced; repaired assets for older tags keep the version checked in at that tag.

### `build-and-package` — version stamping and verification

The composite action `.github/actions/build-and-package/action.yml` stamps the release version into the assemblies before compiling, because the legacy non-SDK `.vbproj` files ignore MSBuild version properties — the version attributes exist only in `AssemblyInfo.vb`:

- Step "Stamp assembly version" (between "Restore dependencies" and "Build (Release x64)", `id: stamp-version`): reads `inputs.release-version`; an empty value logs "no release version - skipping stamp" and exits successfully. Otherwise a leading `v` is stripped and the value must match `X.Y.Z` or `X.Y.Z-rc.N` (stricter than `VERSION_PATTERN` in `resolve-release-version.mjs`, which accepts arbitrary SemVer prerelease identifiers), with each component capped at 65534. SemVer `X.Y.Z` maps to assembly version `X.Y.Z.0`, `X.Y.Z-rc.N` to `X.Y.Z.N`. The step then regex-replaces `AssemblyVersion`, `AssemblyFileVersion` and `AssemblyInformationalVersion` in `EmberMediaManager/My Project/AssemblyInfo.vb` and `EmberAPI/My Project/AssemblyInfo.vb` (written back as UTF-8 with BOM) and exports the derived values as step outputs `assembly_version`/`product_version`. The stamped files stay in the CI working copy — no commit back to the repository.
- Step "Verify publish output": when `release-version` is set, it compares `FileVersionInfo.FileVersion`, `[Reflection.AssemblyName]::GetAssemblyName(...).Version` and `FileVersionInfo.ProductVersion` of `publish/Ember Media Manager.exe` — plus `FileVersion`/`AssemblyVersion` of `publish/EmberAPI.dll` — against the stamp step's outputs. This catches a silently non-matching `-replace` (e.g. a changed attribute line format in `AssemblyInfo.vb`): `AssemblyVersion` drives the version displayed in the program, so an unverified stamp could ship an executable showing "Version 0.0.0" with a green build.
- The checked-in `AssemblyInfo.vb` files carry the placeholder `0.0.0.0` and an empty `AssemblyInformationalVersion`, so local/non-release builds are recognizable as unstamped artifacts. The ~30 add-on assemblies keep their own `ModuleVersion` and are not stamped.

Runtime effect: `My.Application.Info.Version` (→ `Master.Version` in `EmberAPI/clsAPIMaster.vb`) of a released build shows the release version — displayed in `dlgAbout`, `frmSplash`, the `mnuVersion` menu entry, the start log and as "Ember Application" in `dlgVersions`; `Functions.EmberAPIVersion()` reports the stamped `EmberAPI` file version as "Ember API".

## Diagram

```mermaid
flowchart TD
    A[feature branch] -->|PR to staging| B[pr-staging-ci: security scan + builds]
    B -->|merge| C[staging-ci "Pre-Release": gates + version job]
    C -->|version changed| D[vX.Y.Z-rc.N pre-release with assets]
    C -->|success| E[staging-to-main-promotion: draft PR staging to master]
    E -->|manual merge| F[release.yml on master]
    F -->|automatic| G[semantic-release: tag + GitHub release + assets]
    F -->|manual v*.*.* tag| H[gh release create]
    G --> I[sync-staging-with-main: back-merge PR master to staging]
    H --> I
    I -->|merge commit| C
```

## Error handling

- `nuget restore` failures fail the calling step/job immediately (hooks: exit 1; action: `::error` + exit code).
- `NU190[1-4]` findings fail `security-scan` when `fail-on-vulnerabilities: 'true'` (default at all call sites), otherwise degrade to `::warning`.
- `resolve-release-version.mjs` throws on non-`vX.Y.Z` tags and on branch refs outside `AUTOMATIC_RELEASE_BRANCHES`, failing the release job before anything is published. Manual tags are additionally validated against the stampable subset: only `vX.Y.Z` and `vX.Y.Z-rc.N` are accepted, with each component capped at 65534 — a tag like `v1.2.3-beta.1` (valid SemVer, but not mappable to a four-part assembly version) fails in "Resolve release version" instead of mid-run in the stamp step.
- `build-and-package` "Stamp assembly version" fails the build when `release-version` is set but does not match `X.Y.Z`/`X.Y.Z-rc.N` or contains a component > 65534.
- `build-and-package` aborts if `publish/Ember Media Manager.exe` or `publish/version.json` is missing after the copy step; with `release-version` set, "Verify publish output" additionally fails on any mismatch of `FileVersion`/`AssemblyVersion`/`ProductVersion` between the built artifacts and the stamped values.
- The `verify-pr-source` workflow runs with empty permissions; a non-staging head ref produces an `::error` annotation and fails the required check.
