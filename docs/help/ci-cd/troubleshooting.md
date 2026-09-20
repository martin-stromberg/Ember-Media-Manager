# CI/CD & Git Hooks — Troubleshooting

## Hooks do not run at all

**Symptom:** Commits and pushes succeed without any hook output.

**Cause:** `core.hooksPath` is not set for this clone — the install script was never run, or it ran in a different clone/worktree.

**Solution:**
1. Run `.githooks\install-hooks.cmd` (Windows) or `./.githooks/install-hooks.sh` (Git Bash).
2. Verify with `git config --local core.hooksPath` → must print `.githooks`.

## `pre-commit: no working Python interpreter found`

**Symptom:** Every commit aborts with that message.

**Cause:** The hook tried `python`, `python3` and `py -3` and none produced a version.

**Solution:**
1. Install Python 3 and ensure one of the three launchers is on `PATH` inside Git Bash.
2. Retry the commit; no re-activation of the hooks is needed.

## `pre-push` fails: "nuget restore fehlgeschlagen"

**Symptom:** Push aborts after the restore output is printed.

**Cause:** `.nuget\NuGet.exe restore` exited non-zero — typically unreachable package sources, corrupt `NuGet.Config` credentials, or a broken `packages.config` entry.

**Solution:**
1. Run `.nuget\NuGet.exe restore "Ember Media Manager.sln"` manually and fix the reported error.
2. Push again — the hook re-runs the scan.

> **Note:** On Linux/macOS without `mono` the hook skips the scan with a warning instead of failing; the CI gate still applies.

## `pre-push` fails: "Vulnerable NuGet-Pakete gefunden"

**Symptom:** Push aborts with a NU190x finding.

**Cause:** A dependency version in some `packages.config` matches a published vulnerability advisory (NuGet 6.14 audits at restore time).

**Solution:**
1. Update the affected package to a non-vulnerable version in `packages.config`, the project `<HintPath>`/`<Reference Include>` and, if the assembly version changed, the binding redirects in the relevant `app.config` files.
2. Verify the restore runs clean, then push.

## Hooks fail with bizarre shell errors (`\r`, "command not found" on empty lines)

**Symptom:** `pre-commit`/`pre-push` or `install-hooks.sh` crash immediately under Git Bash.

**Cause:** The files were checked out with CRLF line endings — the `.gitattributes` entry `.githooks/* text eol=lf` is missing or was added after the files were checked out.

**Solution:**
1. Ensure `.gitattributes` contains the `.githooks/* text eol=lf` entry.
2. Re-normalize: `git rm --cached -r .githooks && git reset` (or delete and re-checkout the files) so they are written with LF endings.

## First "Pre-Release" run creates `v1.0.0-rc.1`

**Symptom:** The RC version on `staging` starts at `1.0.0` instead of continuing the current version line.

**Cause:** No `v*` tag exists on `master`; semantic-release falls back to `1.0.0`.

**Solution:**
1. Push the seed tag `v1.12.0` onto the `master` tip **before** the workflow files are merged to `staging`.
2. If a wrong `v1.0.0-rc.*` tag/release was already created, delete the GitHub pre-release and the tag and re-run.

## Promotion PR is never created

**Symptom:** "Pre-Release" succeeded on `staging` but no `staging → master` draft PR appeared.

**Cause (most likely):** `staging-to-main-promotion.yml` triggers on `workflow_run` of the **display name** `"Pre-Release"`. If `staging-ci.yml`'s `name:` field was renamed without updating the `workflows:` array in the same commit, the trigger silently never fires. Additionally, `workflow_run` triggers only evaluate the workflow file on the **default branch** — the automation is inactive until the files reach `master`. An identical tree to `master` (pure back-merge state) also deliberately produces no PR.

**Solution:**
1. Keep `staging-ci.yml` `name:` and the `workflows: ["Pre-Release"]` array in sync.
2. Confirm the workflow file exists on `master` and the run concluded with `success`.
3. Check `git rev-list origin/master..origin/staging --count` — zero means no promotion is due.

## Release workflow did not run on a push/tag

**Symptom:** A merge to `master` or a `v*.*.*` tag produced no release run.

**Cause:** `push`-triggered workflows require the workflow file on the pushed ref; the tag trigger evaluates the file at the tagged commit. A tag on an old commit (without `release.yml`) starts nothing. `schedule`/`workflow_dispatch` of `security-scan.yml` likewise only work from the default branch.

**Solution:**
1. Ensure `release.yml` exists on `master` before merging/tagging.
2. For a manual release, push the tag only after the workflows are on `master` — or accept that the merge itself already produced the release via the `automatic` path.

## Release run succeeded but the release has no assets

**Symptom:** The GitHub release exists, but `release.zip`/`update.json` are missing.

**Cause:** A previous run was interrupted between release creation and asset upload.

**Solution:**
1. Re-trigger `release.yml` (e.g. re-push the tag). `resolve-release-version.mjs` detects the existing release, checks out the tagged commit and repairs the missing assets via the `upload-existing` path — no duplicate release is created.

## semantic-release step fails with "Resource not accessible by integration"

**Symptom:** The release was published, but the job fails at the final comment step.

**Cause:** `@semantic-release/github` tries to comment on PRs associated with the released commit; the default `GITHUB_TOKEN` lacks that permission.

**Solution:** Already mitigated — `release.config.js` sets `successComment: false`/`failComment: false`. If the error reappears, verify those options were not removed.
