# CI/CD und Release-Prozess

Alle Pfade relativ zum Repository-Root. Keine dieser Dateien schreibt aktuell eine Version in `AssemblyInfo.vb`.

## `.github/actions/build-and-package/action.yml`

Composite Action, gemeinsam genutzt von `staging-ci.yml` (Job `prerelease`) und `release.yml` (Job `release`).

**Inputs** (Z. 13–21):

| Input | Default | Verwendung |
|-------|---------|------------|
| `release-version` | `''` | Version ohne führendes `v`; wird in `publish/version.json` und `update.json` geschrieben |
| `release-tag` | `''` | Release-Tag (`v1.2.3` / `v1.2.3-rc.1`); für `version.json`, `update.json` und die Asset-Download-URL |

**Schrittfolge** (`runs.using: composite`, alle `shell: pwsh`):

| Schritt | Zeilen | Aktion |
|---------|--------|--------|
| `Setup MSBuild` | 26–27 | `microsoft/setup-msbuild@v2` |
| `Restore dependencies` | 29–31 | `.\.nuget\NuGet.exe restore "Ember Media Manager.sln"` |
| `Build (Release x64)` | 33–35 | `msbuild "Ember Media Manager.sln" -p:Configuration=Release -p:Platform=x64` |
| `Copy build output to publish` | 37–49 | `EmberMM - Release - x64\*` → `publish/` |
| `Write version manifest` | 51–72 | schreibt `publish/version.json` (`version`, `tagName`, `commit`, `createdAtUtc`); Fallback `v0.0.0` bei leerem Tag |
| `Verify publish output` | 74–82 | prüft `publish/Ember Media Manager.exe` + `version.json` |
| `Create Release ZIP` | 84–86 | `Compress-Archive publish/*` → `release.zip` |
| `Create update manifest` | 88–126 | schreibt `update.json` (Version, SHA-256, Größe, Asset-URL) |

**Befund:** Es gibt keinen Schritt, der die Assembly-Attribute stempelt. `release-version` steht als Input bereits zur Verfügung, wird aber erst nach dem Build in Manifestdateien geschrieben. Ein Stempel-Schritt müsste zwischen „Restore dependencies" und „Build (Release x64)" liegen.

## `.github/workflows/release.yml`

Trigger: Push auf `master` und Tags `v*.*.*` (Z. 3–6). Ein Job `release` auf `windows-latest`, `concurrency.group: release` ohne Cancel (Z. 15–17).

| Schritt | Zeilen | Relevanz für Versionsnummer |
|---------|--------|------------------------------|
| `Checkout` | 27–31 | `fetch-depth: 0`, `fetch-tags: true` (für semantic-release) |
| `Setup Node.js` / `npm ci` | 33–43 | Node 24 für `resolve-release-version.mjs` |
| `Resolve release version` | 45–55 | `node scripts/resolve-release-version.mjs`; Outputs: `released`, `reason`, `version`, `tag`, `release_kind`, `release_action` |
| `Check out release tag for asset repair` | 57–80 | nur Repair-Pfad (`release_action == 'upload-existing'`): checkt den getaggten Commit aus |
| `Restore solution` | 82–85 | nur bei `release_action == 'create'` |
| `Release gate - build (Debug x86)` | 87–99 | Compile-Gate statt Tests (Kommentar Z. 88–96: `EmberAPI_Test` nicht baubar); kein Stamping nötig, kein Auslieferungsartefakt |
| `Upload release-gate build log` | 101–107 | Artefakt `build-log-release` |
| `Build and package` | 109–114 | ruft `./.github/actions/build-and-package` mit `release-version`/`release-tag` aus `steps.version.outputs` |
| `Create automatic GitHub release` | 116–131 | `npm run release` (semantic-release) mit `RELEASE_ASSET_PATH=release.zip`, `RELEASE_MANIFEST_PATH=update.json` |
| `Create manual-tag GitHub release` | 133–143 | `gh release create` für manuelle Tags |
| `Upload missing assets to existing release` | 145–152 | `gh release upload --clobber` im Repair-Pfad |

## `.github/workflows/staging-ci.yml` (`name: Pre-Release`)

Trigger: Push auf `staging` (Z. 8–11).

| Job | Zeilen | Relevanz |
|-----|--------|----------|
| `detect-backmerge` | 22–59 | überspringt CI bei purem master→staging-Backmerge |
| `static-checks` | 61–91 | Security-Scan (NU190x) + `msbuild ... -p:Configuration=Debug -p:Platform=x86` |
| `build-and-test` | 93–125 | `msbuild ... -p:Configuration=Release -p:Platform=x64`; Kommentar Z. 111–115: Test-Gates entfallen, da `EmberAPI_Test` nicht baubar |
| `version` | 127–196 | `semantic-release --dry-run --no-ci --branches staging` → `version`; `rc` (Z. 182–196) zählt vorhandene `vX.Y.Z-rc.*`-Tags und erzeugt `rc_tag=vX.Y.Z-rc.N` sowie `rc_version=X.Y.Z-rc.N` |
| `prerelease` | 198–224 | ruft `build-and-package` mit `release-version: rc_version`, `release-tag: rc_tag` (Z. 208–212); danach `gh release create --prerelease` |

## `scripts/resolve-release-version.mjs`

Node-ESM-Skript (357 Zeilen), nur von `release.yml` aufgerufen.

| Element | Zeilen | Zweck |
|---------|--------|-------|
| `VERSION_PATTERN` | 18 | SemVer-Regex für `X.Y.Z` mit optionalem Pre-Release-Suffix |
| `NEXT_RELEASE_PATTERN` | 19 | parst „The next release version is X.Y.Z" aus dem Dry-Run-Output |
| `AUTOMATIC_RELEASE_BRANCHES` | 22 | nur `master` |
| `parseManualTag()` | 24–35 | `vX.Y.Z`-Tag → Version ohne `v` |
| `parseNextReleaseVersion()` | 37–41 | entfernt ANSI-Codes, extrahiert Version |
| `classifyWorkflowRef()` | 43–53 | `tag` → `manual`, Branch `master` → `automatic` |
| `expectedReleaseAssetNames()` | 59–61 | `release.zip`, `update.json` |
| `releaseHasExpectedAsset()` | 63–68 | Asset-Vollständigkeitsprüfung |
| `runSemanticReleaseDryRun()` | 78–105 | `node_modules/semantic-release/bin/semantic-release.js --dry-run` mit `RESOLVE_DRY_RUN=true` |
| `incompleteReleases()` | 220–229 | nur stabile Releases ohne Assets (Pre-Releases explizit ausgenommen) |
| `resolveReleaseVersion()` | 254–345 | Hauptlogik; schreibt Outputs nach `$GITHUB_OUTPUT` |

Die gelieferte `version` ist der unveränderte SemVer-String (inkl. evtl. `-rc.N` bei Pre-Releases — kommt aus `staging-ci.yml` als `rc_version`, nicht aus diesem Skript).

## `release.config.js` / `package.json`

- `release.config.js` (Z. 44–47): `branches: ["master"]`, `tagFormat: "v${version}"`; Plugins: `commit-analyzer`, `release-notes-generator`, `@semantic-release/github` (Assets aus `RELEASE_ASSET_PATH`/`RELEASE_MANIFEST_PATH`, `successComment`/`failComment: false`). Bei `RESOLVE_DRY_RUN=true` nur `commit-analyzer` (`dryRunPlugins`, Z. 42). **Kein Plugin schreibt Dateien ins Repo zurück** (kein `@semantic-release/git`/`exec`).
- `package.json`: `"version": "0.0.0"`, einziges Skript `"release": "semantic-release"`; Dev-Dependencies nur semantic-release-Stack. Kein `test`-Skript.

## Weitere Workflows (nicht versionsrelevant)

- `.github/workflows/pr-staging-ci.yml` — PR-Gate gegen `staging`: gleiche Checks (`static-checks`, `build-and-test`), kein Versioning, ruft `build-and-package` nicht auf.
- `.github/workflows/staging-to-main-promotion.yml` — erstellt Draft-PR staging→master nach erfolgreichem Pre-Release-Lauf.
- `.github/workflows/sync-staging-with-main.yml` — Backmerge-PR master→staging, damit Release-Tags für RC-Zählung erreichbar bleiben.
- `.github/workflows/verify-pr-source.yml`, `.github/workflows/security-scan.yml`, `.github/actions/security-scan/action.yml` — Quell-Branch-Prüfung bzw. NU190x-Scan via `nuget restore`.

## `BuildSetup/` (NSIS-Installer)

`1.4_InstallerScript.nsi` + `0_BuildSetup_x64.bat`/`0_BuildSetup_x86.bat`, `tx.exe` (Transifex), `makensis`-Abhängigkeit. **Bewusst nicht Teil der CI-Pipeline** (Kommentar in `action.yml` Z. 9–11).

- `0_BuildSetup_x64.bat` enthält `SET EMM_REVISION=1.12.0` — eine hartkodierte Versionsnummer, die nur in den Installer-Dateinamen einfließt (`EMM_SETUPFILE="Ember Media Manager 1.12.0 x64.exe"`). Gleiches für die x86-Variante.
- Das NSI-Skript selbst enthält keine Versionsnummer; die Uninstall-Registry-Einträge (Z. 173–191) setzen `DisplayName`/`Publisher` u. a., aber **kein** `DisplayVersion`.
