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

## Release fails: tag "uses a prerelease identifier that cannot be stamped" or component out of range

**Symptom:** `release.yml` fails in the "Resolve release version" step for a manually pushed tag, with an error about a prerelease identifier or a component outside `0-65534`.

**Cause:** Only `vX.Y.Z` and `vX.Y.Z-rc.N` tags can be mapped onto the four-part numeric assembly version (`X.Y.Z.0` / `X.Y.Z.N`), and each component is capped at 65534. A tag like `v1.2.3-beta.1` is valid SemVer — it passes the generic `VERSION_PATTERN` — but has no assembly mapping, so it is rejected here instead of failing mid-run in the "Stamp assembly version" step or shipping a wrongly stamped build.

**Solution:**
1. Push only `vX.Y.Z` or `vX.Y.Z-rc.N` tags for manual releases (all components ≤ 65534).
2. For any other version shape, let the automatic `master` path derive the version via semantic-release.

## Build fails in "Stamp assembly version": "does not match the accepted format X.Y.Z or X.Y.Z-rc.N"

**Symptom:** The `build-and-package` composite action aborts before "Build (Release x64)" with that message.

**Cause:** The `release-version` input was set to a value that is not `X.Y.Z` or `X.Y.Z-rc.N` (a leading `v` is tolerated and stripped). Normally unreachable for tags — `resolve-release-version.mjs` rejects unmappable tags earlier — so this indicates a caller passing a hand-crafted `release-version`.

**Solution:**
1. Check what the calling workflow passed as `release-version` (`staging-ci.yml` passes `rc_version`, `release.yml` passes the resolved `version`).
2. Fix the value to `X.Y.Z`/`X.Y.Z-rc.N`, or leave it empty to skip stamping entirely.

## Build fails in "Verify publish output" with a version mismatch

**Symptom:** The build and copy succeeded, but "Verify publish output" throws — e.g. `Ember Media Manager.exe FileVersion '...' does not match expected '...'` (same for `AssemblyVersion`, `ProductVersion`, or `EmberAPI.dll`).

**Cause:** One of the regex replacements in "Stamp assembly version" did not match — most likely the attribute line format in an `AssemblyInfo.vb` changed (the step expects `<Assembly: AssemblyVersion("x.y.z.r")>` on its own line). PowerShell `-replace` is silent on no-match, which is exactly what this verification exists to catch: an unstamped or partially stamped artifact must never ship.

**Solution:**
1. Open `EmberMediaManager/My Project/AssemblyInfo.vb` and `EmberAPI/My Project/AssemblyInfo.vb` and restore the expected line format for `AssemblyVersion`, `AssemblyFileVersion` and `AssemblyInformationalVersion` — or update the regex patterns in the stamp step to match the new format.
2. Re-run the workflow; the log of "Stamp assembly version" prints the stamped values per file for comparison.

## Installed build shows "Version 0.0.0"

**Symptom:** The About dialog, splash screen or version menu entry of a build shows "Version 0.0.0" — and the file properties show `0.0.0.0`.

**Cause:** The artifact was built without a `release-version` input — a local build or a CI run outside the release path. The checked-in placeholder `0.0.0.0` is deliberate: it makes unstamped artifacts recognizable instead of letting them pose as a concrete release version.

**Solution:** No action needed — this is expected for non-release builds. Only builds produced by the `prerelease`/`release` pipeline jobs carry the stamped release version; install `release.zip` from a GitHub release for a properly versioned build.
