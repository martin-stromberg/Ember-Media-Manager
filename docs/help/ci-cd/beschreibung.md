← [Back to overview](index.md)

# CI/CD & Git Hooks — Description

## Purpose

Every change to Ember Media Manager is checked automatically — first locally on the developer's machine, then again on GitHub — before it can reach a release. This protects contributors from pushing commits with known-vulnerable dependencies or broken localization files, and it automates the otherwise manual work of versioning, building and publishing releases.

## How it works

The system has two layers:

**Local Git hooks (per clone, opt-in).** After a one-time activation, Git runs two checks on the developer's machine:

- Before every commit, localization resource files are validated (for example required `.resx` headers), so malformed resource files never enter the history.
- Before every push, all NuGet dependencies are scanned for known security vulnerabilities. A finding aborts the push, so the problem is fixed locally instead of failing later in the cloud.

**GitHub Actions workflows (always active once present on a branch).** The repository follows a `feature branch → staging → master` flow:

- A pull request against `staging` runs a NuGet vulnerability scan and two full builds of the solution. Automated back-merge pull requests are detected and skip these redundant checks.
- A push to `staging` runs the same checks and additionally calculates the next version from the commit history. If the version changed, a pre-release (`vX.Y.Z-rc.N`) with a downloadable build is published automatically.
- After a successful staging run, a draft pull request `staging → master` is opened for a maintainer to review and merge. Pull requests that target `master` directly from any other branch are rejected.
- A push to `master` automatically opens a back-merge pull request `master → staging` and produces the release: the version is derived from the commits, a tagged GitHub release is created and the build artifacts (`release.zip` and `update.json`) are attached. Releases can also be triggered by pushing a `vX.Y.Z` tag manually.
- Once a week (Mondays 04:00 UTC) all NuGet dependencies are re-scanned, so newly disclosed vulnerabilities are caught even when nothing changed.

## Examples

- A contributor activates the hooks once, then commits normally. If a `.resx` file is malformed, the commit is refused with an explanation instead of breaking the build for everyone later.
- A contributor opens a pull request to `staging`. Within minutes, GitHub reports whether the dependencies are clean and the solution compiles in both the Debug and Release configurations.
- After the pull request is merged, a pre-release such as `v1.13.0-rc.1` appears automatically on the releases page, including a ready-to-run `release.zip`.
- A maintainer merges the draft promotion pull request; the new release (for example `v1.13.0`) is published on `master` without any manual packaging, and `staging` is automatically kept in sync.

## Limitations

- The hooks must be activated once per clone; they do not run automatically after a fresh checkout.
- The pre-commit check needs a working Python 3 installation on the developer machine. The pre-push dependency scan runs on Windows; on Linux/macOS it is skipped with a warning unless Mono is available — the server-side check still applies.
- There are no automated test or code-coverage gates: the only test project (`EmberAPI_Test`) is not part of the solution and does not compile. Builds are the release gate until a working test suite exists.
- No code-formatting gate is enforced — the legacy project format does not support the usual formatting checks.
- The NSIS installer build is not part of the pipeline; release artifacts contain the portable build output only.
- Some automations (scheduled scan, promotion trigger) only run once the workflow files are present on the `master` branch.
