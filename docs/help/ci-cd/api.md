← [Back to overview](index.md)

# CI/CD & Git Hooks — API

## Overview

The pipeline exposes no HTTP endpoints. Its programmatic interfaces are the two composite actions under `.github/actions/`, the version-resolution script `scripts/resolve-release-version.mjs`, the localization checker `.githooks/translation-check.py`, and the workflow triggers themselves.

## Authentication

All workflows authenticate with the built-in `GITHUB_TOKEN`/`github.token`; no additional secrets are required. Permissions are declared per workflow (`contents`, `checks`, `pull-requests`, `issues`; `verify-pr-source.yml` uses `permissions: {}`, `security-scan.yml` only `contents: read`).

## Rate limiting

None beyond the standard GitHub Actions / GitHub API quotas.

## Composite action `security-scan`

**File:** `.github/actions/security-scan/action.yml`

**Description:** Runs `.nuget\NuGet.exe restore <solution-path>`, tees the output to `vulnerable-packages-scan.log`, and fails on `NU190[1-4]` warnings depending on `fail-on-vulnerabilities`. Uploads the log via `actions/upload-artifact@v7` (14-day retention). Used by `pr-staging-ci.yml`, `staging-ci.yml` and `security-scan.yml`.

**Inputs:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `solution-path` | string | No (default `Ember Media Manager.sln`) | Solution to restore and scan |
| `artifact-name` | string | No (default `vulnerable-packages-scan`) | Name of the uploaded scan-log artifact |
| `fail-on-vulnerabilities` | string | No (default `'true'`) | `'true'` fails the step on NU190x findings; `'false'` emits `::warning` |

**Outputs:** none (artifact upload only).

**Example:**

```yaml
- uses: ./.github/actions/security-scan
  with:
    solution-path: Ember Media Manager.sln
    artifact-name: vulnerable-packages-pr
    fail-on-vulnerabilities: 'true'
```

**Failures:**

| Condition | Behavior |
|-----------|----------|
| `nuget restore` exit ≠ 0 | `::error`, exit with restore's code |
| `NU190[1-4]` in output, input `'true'` | `::error`, exit 1 |
| `NU190[1-4]` in output, input `'false'` | `::warning`, exit 0 |

## Composite action `build-and-package`

**File:** `.github/actions/build-and-package/action.yml`

**Description:** Provisions MSBuild, restores and builds `Release|x64`, copies `EmberMM - Release - x64\*` to `publish/`, writes `publish/version.json`, verifies the output, creates `release.zip`, and generates the update manifest `update.json` (SHA-256, size, asset URL). Used by `staging-ci.yml` (prerelease job) and `release.yml`. The NSIS installer is deliberately not part of the pipeline.

**Inputs:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `release-version` | string | No (default `''`) | Version without leading `v` (e.g. `1.2.3-rc.1`); written into `version.json`/`update.json` |
| `release-tag` | string | No (default `''`) | Tag (e.g. `v1.2.3` / `v1.2.3-rc.1`); builds the asset download URL |

**Outputs (files):** `release.zip`, `update.json`, `publish/version.json`.

**Failures:** throws if `publish/Ember Media Manager.exe` or `publish/version.json` is missing.

## Script `resolve-release-version.mjs`

**File:** `scripts/resolve-release-version.mjs` — invoked as `node scripts/resolve-release-version.mjs` in `release.yml`; needs `GITHUB_TOKEN` in the environment and `npm ci` beforehand.

**Classification:** tag ref `vX.Y.Z` → `manual`; branch push on `master` (`AUTOMATIC_RELEASE_BRANCHES`) → `automatic` (version via semantic-release dry-run, `RESOLVE_DRY_RUN=true` selects `dryRunPlugins` in `release.config.js`). Other refs throw.

**GITHUB_OUTPUT values:**

| Name | Description |
|------|-------------|
| `released` | `'true'` when a release action is required |
| `release_kind` | `automatic` / `manual` |
| `release_action` | `create` / `upload-existing` (repair of missing assets on an existing release) |
| `version` | Resolved version without leading `v` |
| `tag` | Resolved tag (`vX.Y.Z`) |

**Expected assets:** `expectedReleaseAssetNames()` → `["release.zip", "update.json"]`.

## Script `translation-check.py`

**File:** `.githooks/translation-check.py` — invoked by the `pre-commit` hook (staged files) or manually.

| Invocation | Behavior |
|------------|----------|
| `translation-check.py` | Checks staged files only |
| `translation-check.py --all` | Scans the entire repository |

Checks: `IStringLocalizer` key existence (`.cs`/`.razor`/`.cshtml`), `.resx` package key consistency across language variants, `.resx` header validation (`resmimetype`/`reader`/`writer`). Exit 1 on any finding.

## Workflow triggers

| Workflow | Trigger |
|----------|---------|
| `pr-staging-ci.yml` | `pull_request` → `staging` (opened/synchronize/reopened) |
| `staging-ci.yml` ("Pre-Release") | `push` → `staging` |
| `verify-pr-source.yml` | `pull_request` → `master` (all types) |
| `sync-staging-with-main.yml` | `push` → `master` |
| `staging-to-main-promotion.yml` | `workflow_run` "Pre-Release" completed on `staging` |
| `security-scan.yml` | `schedule` `0 4 * * 1` + `workflow_dispatch` |
| `release.yml` | `push` → `master` and tags `v*.*.*` |
