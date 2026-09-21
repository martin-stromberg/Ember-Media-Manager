← [Back to overview](index.md)

# CI/CD & Git Hooks — Business Rules

## Staging-first flow

**Description:** Changes reach `master` only via `staging`; direct feature-branch PRs to `master` are rejected. This guarantees every released commit has passed the full staging validation chain.

**Conditions:**
- Pull request targets `master`.

**Behavior:**
- If `github.head_ref == "staging"`: the check passes.
- Otherwise: the job fails with `::error::PRs against master are only allowed from staging`.

**Implementation:** `verify-pr-source.yml`, job `verify-source` — `permissions: {}`, head ref bound via `env` (script-injection hardening).

## Back-merge detection

**Description:** Automated back-merge PRs (`master → staging`) must not burn CI minutes or trigger a new pre-release — their tree is already released content.

**Conditions:**
- `origin/master` tip is a merge parent of the PR merge commit / pushed commit, **or**
- the tree is identical to `origin/master` (`git diff --quiet`).

**Behavior:**
- `is_backmerge == 'true'` → `static-checks`, `build-and-test`, `version`, `prerelease` are all skipped; only `back-merge-skip` runs.
- Otherwise → full gate chain.

**Implementation:** job `detect-backmerge` in `pr-staging-ci.yml` and `staging-ci.yml`; tree-compare fallback in `staging-to-main-promotion.yml` (identical tree → `commits_ahead=0`, no promotion PR).

## NU190x severity filtering

**Description:** Only real vulnerability findings may block; transient audit-infrastructure warnings must not.

**Conditions:**
- `nuget restore` output contains `NU190[1-4]` (low/moderate/high/critical severities).
- `NU1900` (audit source unreachable) and `NU1905+` are deliberately not matched.

**Behavior:**
- Finding + `fail-on-vulnerabilities == 'true'` → `::error`, exit 1 (all current call sites).
- Finding + `'false'` → `::warning`, exit 0.
- On non-Windows clones without `mono`, the local `pre-push` scan degrades to a warning + exit 0; the server-side gate remains blocking.

**Implementation:** `.github/actions/security-scan/action.yml`; mirrored locally by `.githooks/pre-push` (same regex and exit semantics).

## Release classification

**Description:** One script decides what kind of release a `release.yml` run represents, preventing duplicate releases and enabling asset repair.

**Conditions:**
- `refType == "tag"` → must match `vX.Y.Z` (else the run fails).
- `refType == "branch"` → must be `master` (else the run fails).
- A GitHub release for the resolved tag already exists → check whether `release.zip` **and** `update.json` are present, uploaded and non-empty.

**Behavior:**
- No existing release → `release_action = 'create'` (build gate + package + publish).
- Existing release, assets missing → `release_action = 'upload-existing'` (checks out the tagged commit, rebuilds only the missing assets, `gh release upload --clobber`).
- Existing release, assets complete → `released = 'false'`, nothing happens.

**Implementation:** `scripts/resolve-release-version.mjs` (`classifyWorkflowRef`, `releaseHasExpectedAsset`, `expectedReleaseAssetNames`).

## Versioning via Conventional Commits + RC chain

**Description:** Release versions are derived from commit messages by semantic-release; staging produces RC pre-releases of the next computed version.

**Conditions:**
- `staging-ci.yml` job `version` runs `semantic-release --dry-run --branches staging`; `release.config.js` itself only lists `master` (staging is overridden per-invocation so the computed `X.Y.Z` has no prerelease identifier baked in).
- RC tag = `v<version>-rc.<count of existing v<version>-rc.* tags + 1>`.
- Seed tag `v1.12.0` on `master` must exist on `origin` before the first staging run, otherwise versioning starts at `1.0.0`.

**Behavior:**
- No version change → `changed = 'false'`, no pre-release.
- Version changed → `vX.Y.Z-rc.N` pre-release with `release.zip` + `update.json`.
- Merge to `master` → stable `vX.Y.Z` release.

**Implementation:** `staging-ci.yml` jobs `version`/`prerelease`; `release.config.js` (`branches`, `tagFormat: "v${version}"`, dry-run plugin switch via `RESOLVE_DRY_RUN`).

## Assembly version stamping

**Description:** The published executable must display the same version as its GitHub release. Because the legacy non-SDK `.vbproj` files ignore MSBuild version properties, the release version is regex-stamped into the `AssemblyInfo.vb` attributes of the CI working copy during the build — it is deliberately not committed back (the release tag points at the already-merged commit).

**Conditions:**
- Only applies when the `build-and-package` input `release-version` is set; empty input → step skipped, files untouched.
- `release-version` must match `X.Y.Z` or `X.Y.Z-rc.N` after stripping a leading `v` — stricter than the SemVer pattern used at tag resolution, because only those two shapes map onto a four-part numeric assembly version.
- Each version component must be ≤ 65534 (assembly version component limit).

**Behavior:**
- `X.Y.Z` → `AssemblyVersion`/`AssemblyFileVersion` = `X.Y.Z.0`; `X.Y.Z-rc.N` → `X.Y.Z.N` (RC number as the revision component).
- `AssemblyInformationalVersion` always receives the full SemVer string (`X.Y.Z` / `X.Y.Z-rc.N`), visible via `FileVersionInfo.ProductVersion`.
- Stamped files: `EmberMediaManager` and `EmberAPI` — the ~30 add-on assemblies keep their own `ModuleVersion` and are not stamped.
- Checked-in placeholder is `0.0.0.0` (plus empty `AssemblyInformationalVersion`), so unstamped builds are recognizable instead of faking a concrete release version.
- "Verify publish output" compares the built artifacts' attributes against the stamp step's outputs and fails the build on any mismatch — a silently non-matching regex replace must never ship an unstamped artifact.
- Asset repair (`release_action == 'upload-existing'`): `build-and-package` is loaded from the tagged commit — tags created before this change produce assets with the version checked in at that tag (consistent with the already published release); newer tags are stamped automatically.

**Implementation:** step "Stamp assembly version" (`id: stamp-version`) and "Verify publish output" in `.github/actions/build-and-package/action.yml`; early tag validation via `STAMPABLE_VERSION_PATTERN`/`MAX_ASSEMBLY_VERSION_COMPONENT` in `scripts/resolve-release-version.mjs`; placeholders in `EmberMediaManager/My Project/AssemblyInfo.vb` and `EmberAPI/My Project/AssemblyInfo.vb`.

## Merge-commit requirement for back-merge PRs

**Description:** The automated `master → staging` PR must be merged with "Create a merge commit", never rebase/squash — otherwise the release tag is unreachable from `staging` and the next version calculation breaks.

**Implementation:** enforced socially via the PR body text in `sync-staging-with-main.yml`; detection relies on merge-parent checks in `detect-backmerge`.

## Dropped reference gates

**Description:** Three gates of the reference pipeline intentionally do not exist here:

- Gate 1 (`dotnet format`) — not applicable to the legacy non-SDK `packages.config`/VB.NET project format; no `.editorconfig` was introduced.
- Gates 4/5 (test execution, 70 % coverage) — `EmberAPI_Test` is not part of the solution and does not compile; the `Release|x64` build covers the shippable configuration instead. Comments in the workflows document the gap so the gates can be re-added once the test project is repaired.
- `TreatWarningsAsErrors` — would fail from day one on the legacy codebase's existing warnings.
