# Referenz-Repository `martin-stromberg/Softwareschmiede`

Inventar der Referenzimplementierung (öffentlich abrufbar, Branch `main`, abgerufen am 2026-09-20 via `raw.githubusercontent.com` bzw. GitHub-Weboberfläche). Technologie-Basis der Referenz: **.NET 10, `Softwareschmiede.slnx`, `dotnet`-CLI, PackageReference, WPF-App** — sämtliche Build-/Test-/Format-/Scan-Schritte laufen über `dotnet`, was für Ember (Legacy-`.vbproj`, `packages.config`, .NET Framework 4.8) nicht 1:1 übertragbar ist.

## `.githooks/` (5 Dateien)

| Datei | Inhalt |
|-------|--------|
| `install-hooks.cmd` | `git config --local core.hooksPath .githooks` + `pause` (Windows) |
| `install-hooks.sh` | identisch, POSIX-Shell, ohne `pause` |
| `pre-commit` | `#!/bin/sh`, `set -e`, ruft `python "$(dirname "$0")/translation-check.py"` |
| `pre-push` | `#!/usr/bin/env sh`, spiegelt das Format-Gate der PR-CI: `dotnet restore Softwareschmiede.slnx` + `dotnet format Softwareschmiede.slnx --verify-no-changes --no-restore` |
| `translation-check.py` | Python-3-Skript (siehe unten) |

### `translation-check.py` — drei Prüfungen

1. **Fehlende Lokalisierungskeys**: scannt gestagte (`--all` = alle) `.cs`/`.razor`/`.cshtml`-Dateien nach `IStringLocalizer`-Indexer-Verwendungen (`localizer["key"]`, auch `GetRequiredService<IStringLocalizer<...>>()["key"]`) und prüft, ob jeder Key in mindestens einer `.resx` definiert ist.
2. **Resx-Paket-Konsistenz**: gruppiert `.resx`-Dateien pro Verzeichnis nach Basisnamen (neutral + Sprachvarianten `xx`/`xx-YY`) und meldet Keys, die in einer Schwester-Sprachdatei fehlen.
3. **Resx-Header-Validierung**: prüft `resheader` `resmimetype` (= `text/microsoft-resx`), `reader` (`System.Resources.ResXResourceReader`), `writer` (`System.Resources.ResXResourceWriter`).

Ausschlüsse: `.git`, `bin`, `obj`, `TestResults`, `node_modules`, `.vs`, `packages`. Exit 1 bei Befunden.

**Übertragbarkeits-Befund für Ember**: Prüfung 1 ist C#/`IStringLocalizer`-spezifisch — im Ember-Repo existiert **kein** Vorkommen von `IStringLocalizer` (490 `.vb`-, 540 `.cs`-Dateien; Lokalisierung läuft über Transifex-`Langs`-Dateien, nicht über Localizer-Indexer). Prüfungen 2+3 sind generisch auf die **142 vorhandenen `.resx`-Dateien** anwendbar.

## `.github/workflows/` (7 Workflows)

### `pr-staging-ci.yml` — „PR CI for Staging"

- Trigger: `pull_request` → `staging` (`opened`, `synchronize`, `reopened`); Concurrency `pr-staging-<PR-Nr>` mit `cancel-in-progress`
- Permissions: `contents: read`, `checks: write`
- Jobs:
  - `detect-backmerge` (ubuntu-latest): erkennt automatische Back-Merge-PRs — prüft, ob `origin/main`-Tip Merge-Parent des synthetischen PR-Merge-Commits ist **oder** der Tree identisch zu `origin/main` (`git diff --quiet`); Output `is_backmerge`
  - `static-checks` (windows-latest, 15 min, nur bei `is_backmerge != 'true'`): `actions/checkout@v7`, `actions/setup-dotnet@v6` (10.0.x), `dotnet restore`, **Gate 1** `dotnet format --verify-no-changes`, **Gate 2** Composite Action `./.github/actions/security-scan`, **Gate 3** `dotnet build -c Debug -p:TreatWarningsAsErrors=true`
  - `build-and-test` (windows-latest, 20 min, parallel zu static-checks): Build der beiden Testprojekte, `dotnet test` mit `--filter "Category!=OsInterface"` + XPlat-Code-Coverage (blockierend, **Gate 4**), `Category=OsInterface` mit `continue-on-error: true`, ReportGenerator 5.5.11, **Gate 5**: 70 %-Line-Coverage-Schwelle via `Summary.txt`-Parsing (pwsh), Upload von Coverage-Report und `.trx` als Artefakte (`actions/upload-artifact@v7`, 14 Tage)
  - `back-merge-skip` (ubuntu-latest): Bestätigungs-Job bei erkanntem Back-Merge

### `staging-ci.yml` — „Pre-Release" (Anzeigename!)

- Trigger: `push` → `staging`; Concurrency `staging-ci`; Permissions `contents: write`, `checks: write`
- Jobs: `detect-backmerge`, `static-checks`, `build-and-test` — identisch zu `pr-staging-ci.yml` (andere Artefaktnamen)
- Zusätzlich:
  - `version` (ubuntu-latest): `setup-node@v7` (Node 24), `npm ci`, `npx semantic-release --dry-run --no-ci --branches staging` → nächste Version aus `release.config.js`; RC-Nummer via `git tag --list "v<version>-rc.*"` → Outputs `changed`, `version`, `rc_tag` (`vX.Y.Z-rc.N`), `rc_version`
  - `prerelease` (windows-latest, nur bei `changed == 'true'`): Composite Action `./.github/actions/build-and-package` (baut `release.zip` + `update.json`), dann `gh release create <rc_tag> --prerelease --generate-notes`

### `verify-pr-source.yml` — „Verify PR Source"

- Trigger: `pull_request` → `main`; `permissions: {}` (leer)
- Einziger Schritt: schlägt fehl (`exit 1`), wenn `github.head_ref != "staging"` — erzwingt den Flow Feature → `staging` → `main`

### `sync-staging-with-main.yml` — „Backmerge Main to Staging"

- Trigger: `push` → `main`; Concurrency `sync-staging-with-main`, `cancel-in-progress: false`
- Permissions: `contents: read`, `pull-requests: write`, `issues: write`
- Checkout `staging` (fetch-depth 0), `git fetch origin main`, zählt `git rev-list HEAD..origin/main --count`; bei Bedarf: Label `automated-backmerge` anlegen (`gh label create --force`) und PR `main` → `staging` via `gh pr create` (nur wenn noch keiner offen). Kommentar im File: Muss mit „Create a merge commit" gemergt werden, damit Release-Tag von `staging` aus erreichbar bleibt.

### `staging-to-main-promotion.yml` — „Promote staging to main"

- Trigger: `workflow_run` auf Workflow-**Anzeigename** `"Pre-Release"`, `types: [completed]`, `branches: [staging]`; Job-Bedingung `conclusion == 'success'`
- Permissions: `contents: read`, `pull-requests: write`, `issues: write`
- Checkout des `workflow_run.head_sha`; wenn `main` hinter `staging` und Tree nicht identisch → Label `automated-promotion` + **Draft-PR** `staging` → `main` (manueller Merge durch Maintainer)

### `security-scan.yml` — „Security Scan"

- Trigger: `schedule` `cron: '0 4 * * 1'` (montags 04:00 UTC) + `workflow_dispatch`
- windows-latest: checkout, setup-dotnet 10, `dotnet restore`, Composite Action `./.github/actions/security-scan`
- Kommentar: Der PR-Zeitpunkt-Scan wurde bewusst hier entfernt und läuft als Gate 2 in den CI-Workflows (Single-Source über die Composite Action)

### `release.yml` — „Release"

- Trigger: `push` → `main` **und** Tags `v*.*.*`; Permissions `contents: write`; Concurrency `release`, `cancel-in-progress: false`
- windows-latest, 30 min: checkout (`fetch-tags`), Node 24, .NET 10, `npm ci`
- `scripts/resolve-release-version.mjs` (Node-Skript) klassifiziert den Lauf: `automatic` (Push auf main, Version via semantic-release-dry-run), `manual` (gepushter `vX.Y.Z`-Tag) oder `release_action: upload-existing` (Asset-Reparatur bei vorhandenem Release)
- Bei `create`: `dotnet restore`, `dotnet build -c Debug`, Release-Gate-Tests (regular blockierend, OsInterface `continue-on-error`), Artefakt-Upload
- `build-and-package` Composite Action → `release.zip`, `update.json`
- Release-Erzeugung: automatisch via `npm run release` (semantic-release-Plugin-Pipeline aus `release.config.js`), manuell via `gh release create --generate-notes`, Asset-Reparatur via `gh release upload --clobber`

## `.github/actions/` (2 Composite Actions)

### `security-scan/action.yml`

- Inputs: `solution-path` (Default `Softwareschmiede.slnx`), `artifact-name`
- Führt `dotnet list <sln> package --vulnerable --include-transitive` aus, schreibt Log, schlägt bei „has the following vulnerable packages"/„Severity" mit `::error` + Exit 1 fehl; lädt Scan-Log als Artefakt hoch
- **Befund**: `dotnet list package --vulnerable` unterstützt nur PackageReference — für `packages.config` nicht nutzbar. NuGet 6.14 zeigt NU1903-Warnungen bereits beim `nuget restore` (im Ember-Repo verifiziert, siehe [build-toolchain.md](build-toolchain.md)).

### `build-and-package/action.yml`

- Inputs: `release-version`, `release-tag`
- `dotnet publish` der WPF-App (`win-x64`, self-contained, Release, `/p:ReleaseTag=...`), benennt exe um, schreibt `publish/version.json` (version/tagName/commit/createdAtUtc), verifiziert Publish-Output (inkl. Plugin-DLLs), `Compress-Archive` → `release.zip`, erzeugt `update.json`-Update-Manifest (version, releaseNotes, publishedAt, assets[] mit assetName/assetUrl/sha256/sizeBytes)

## Weitere referenzseitige Root-Artefakte (Abhängigkeiten der Workflows)

| Datei | Zweck |
|-------|-------|
| `package.json` / `package-lock.json` | npm-Dependencies für `semantic-release` (`npm ci` in `version`-/`release`-Jobs) |
| `release.config.js` | semantic-release-Konfig: `branches: ["main"]`, `tagFormat: "v${version}"`, Plugins `@semantic-release/commit-analyzer`, `release-notes-generator`, `@semantic-release/github` mit `successComment: false`, `failComment: false`; bei `RESOLVE_DRY_RUN=true` nur `commit-analyzer` |
| `scripts/resolve-release-version.mjs` | Versions-/Release-Auflösung für `release.yml` |
| `Softwareschmiede.slnx` | Solution im neuen XML-Format |
| `docs/`, `changes.log`, `CHANGELOG.md`, `CONTRIBUTING.md`, `SECURITY.md` | Doku; bemerkenswert: Softwareschmiede führt ebenfalls ein `changes.log` |

**Keine `.editorconfig`** im Softwareschmiede-Root vorhanden (das Format-Gate läuft dort auf `dotnet format`-Defaults).

## Befund: `martin-stromberg/Pattern-Collection` nicht abrufbar

- `https://github.com/martin-stromberg/Pattern-Collection` → **HTTP 404**
- `https://github.com/martin-stromberg/Pattern-Collection/blob/main/CI-Workflows/instructions.md` → **HTTP 404**

Das Repository ist privat oder nicht vorhanden; die in der Anforderung referenzierte Original-Vorgabe (`CI-Workflows/instructions.md`, GitHooks) ist nicht einsehbar. Die Softwareschmiede-Kommentare verweisen intern auf `ci-target-schema.md`/`ci-inventory.md` (Dokumente mit „Entscheidungen"), die vermutlich aus dieser Pattern-Collection abgeleitet sind — sie liegen im Softwareschmiede-Repo selbst jedoch nicht im Root (ggf. unter `docs/`).
