# Plan-Review

## Ergebnis

**Status:** Offene Aufgaben vorhanden

Geprüft gegen Commit `ad92cdc` (Implementation), Basis `08279a24` (Diff `08279a24..HEAD`: 51 Dateien, +10103/−22).

## Umgesetzte Planelemente

### `Newtonsoft.Json`-Sicherheitsupdate (13.0.3)

- [x] `Addons/scraper.Trakttv.Data/packages.config` — `version="13.0.3"` (vorher 12.0.3)
- [x] `Addons/generic.Interface.Trakttv/packages.config` — `version="13.0.3"` (vorher 12.0.3)
- [x] `version="13.0.3"` in den übrigen 7 `packages.config` (`KodiAPI`, `EmberMediaManager`, `EmberAPI`, `scraper.TMDB.Trailer`, `scraper.TMDB.Poster`, `scraper.TMDB.Data`, `scraper.Data.OMDb`)
- [x] `<Reference Include="Newtonsoft.Json, Version=13.0.0.0">` + `<HintPath>` `Newtonsoft.Json.13.0.3` in `scraper.Data.Trakttv.vbproj` und `generic.Interface.Trakttv.vbproj`
- [x] `<HintPath>` `Newtonsoft.Json.13.0.3` in den übrigen 7 Projektdateien (Grep: alle 9 Projektdateien zeigen auf `13.0.3`, alle `<Reference>` auf `13.0.0.0`)
- [x] Binding-Redirects `0.0.0.0-13.0.0.0`/`13.0.0.0` in `scraper.Trakttv.Data/app.config` und `generic.Interface.Trakttv/app.config`; Grep-Verifikation: **kein** Redirect im Repo zeigt mehr auf `12.0.0.0`
- [x] `nuget restore "Ember Media Manager.sln"` im Review erneut ausgeführt — befundfrei, keine NU190x-Warnungen (Voraussetzung für das blockierende Gate 2 erfüllt)

### GitHooks (`.githooks/`) + `.gitattributes`

- [x] `.githooks/install-hooks.cmd` — setzt `core.hooksPath .githooks`
- [x] `.githooks/install-hooks.sh` — POSIX-Variante
- [x] `.githooks/pre-commit` — ruft `translation-check.py` via `python "$(dirname "$0")/translation-check.py"`
- [x] `.githooks/pre-push` — `nuget restore` + NU190x-Auswertung, **blockierend** (Exit 1 bei Befund und bei Restore-Fehler) — Spiegel des blockierenden Gate 2
- [x] `.githooks/translation-check.py` — Referenz-Variante (Localizer-Scan + .resx-Paketkonsistenz + Header-Validierung); `--all`-Lauf im Review: **befundfrei** (Exit 0, 142 .resx) → Verbatim-Übernahme ist der per Plan festgelegte korrekte Pfad
- [x] `.gitattributes`-Eintrag `.githooks/* text eol=lf` inkl. Kommentarblock — im selben Commit `ad92cdc` wie die `.githooks/`-Dateien; alle Hook-Dateien mit LF-Enden eingecheckt; bestehende VS-`merge`/`diff`-Einträge unangetastet
- [x] Hook-Aktivierung: `core.hooksPath = .githooks` im lokalen Klon gesetzt

### Composite Actions (`.github/actions/`)

- [x] `security-scan/action.yml` — Inputs `solution-path` (Default `Ember Media Manager.sln`), `artifact-name`, `fail-on-vulnerabilities` (**Default `'true'`**); `nuget restore` + `NU190\d`-Auswertung (`::error` + Exit 1 bei `'true'`, sonst `::warning`) + Log-Artefakt via `actions/upload-artifact@v7`
- [x] `build-and-package/action.yml` — Inputs `release-version`/`release-tag`; `microsoft/setup-msbuild@v2` + `nuget restore` + `msbuild Release|x64`; Kopie `EmberMM - Release - x64\*` → `publish/`; `version.json`; Verify (`publish/Ember Media Manager.exe` + `version.json`); `Compress-Archive` → `release.zip`; `update.json` mit version/releaseNotes/publishedAt/assets (sha256, sizeBytes, assetUrl); **kein** NSIS-Installer-Schritt

### Release-Tooling (Root-Artefakte)

- [x] `package.json` — `name: "ember-media-manager"` (angepasst), `semantic-release`-DevDependencies + Script `release`
- [x] `package-lock.json` — `name`-Felder an `package.json` angeglichen (`ember-media-manager`)
- [x] `release.config.js` — `branches: ["master"]`, `tagFormat: "v${version}"`, Plugin-Set mit `successComment: false`/`failComment: false`, `RESOLVE_DRY_RUN`-Umschaltung
- [x] `scripts/resolve-release-version.mjs` — `AUTOMATIC_RELEASE_BRANCHES = ["master"]`, `expectedReleaseAssetNames() = ["release.zip", "update.json"]`, Klassifikation `automatic`/`manual`/`upload-existing`

### Workflows (`.github/workflows/`)

- [x] `pr-staging-ci.yml` — `pull_request` auf `staging` (opened/synchronize/reopened), Concurrency `pr-staging-<PR-Nr>` mit Abbruch; `detect-backmerge` (Merge-Parent + Tree-Vergleich gegen `origin/master`); `static-checks` (windows-latest, `setup-msbuild`, Security-Scan mit `fail-on-vulnerabilities: 'true'`, Gate 3 `msbuild Debug|x86` ohne TWAE); `build-and-test` (parallel, `nuget restore` + `msbuild Release|x64` + Build-Log-Artefakt); `back-merge-skip`; Kommentare dokumentieren Gate-1-/4-/5-Wegfall
- [x] `staging-ci.yml` — Anzeigename **`Pre-Release`**; gleiche Gate-Jobs (Artefaktname `…-staging`); `version`-Job (Node 24, `npm ci`, `semantic-release --dry-run --branches staging`, RC-Nummer via `git tag --list "v<version>-rc.*"`); `prerelease`-Job (`build-and-package` + `gh release create --prerelease --generate-notes`)
- [x] `verify-pr-source.yml` — `pull_request` auf `master`, `permissions: {}`, `exit 1` bei `head_ref != "staging"`
- [x] `sync-staging-with-main.yml` — `push` auf `master`, Concurrency ohne Abbruch, `rev-list HEAD..origin/master --count`, Label `automated-backmerge`, PR `master` → `staging` nur wenn kein offener existiert, „Create a merge commit"-Hinweis
- [x] `staging-to-main-promotion.yml` — `workflow_run` auf `"Pre-Release"` (completed, branches `[staging]`), Bedingung `conclusion == 'success'`, Tree-Vergleich mit `origin/master`, **Draft**-PR `staging` → `master` mit Label `automated-promotion`
- [x] `security-scan.yml` — `schedule` `cron: '0 4 * * 1'` + `workflow_dispatch`, windows-latest, Composite Action mit `fail-on-vulnerabilities: 'true'`
- [x] `release.yml` — Trigger `push` `branches: [master]` + `tags: ['v*.*.*']`, Concurrency `release` ohne Abbruch; Node 24 + `npm ci` + `resolve-release-version.mjs`; Release-Gate = `nuget restore` + `msbuild Debug|x86` (Test-Gates ersetzt, kommentiert); drei Release-Pfade (`npm run release` / `gh release create --generate-notes` / `gh release upload --clobber` mit `git checkout --detach <tag>`)

### Doku

- [x] `README.md` — Abschnitt „Continuous Integration / Git Hooks" (Zeilen 76–87): Hook-Aktivierung via `install-hooks.*` + Workflow-Überblick

## Offene Aufgaben

- [ ] `Seed-Tag v1.12.0` (Task 29, Plan-Schritt 13) — fehlt vollständig: weder lokal (`git tag -l` leer) noch auf `origin` (`git ls-remote --tags origin` ohne Einträge) vorhanden. **Zeitkritisch:** muss auf `origin` liegen, **bevor** die Workflow-Dateien erstmals auf `staging` gemergt werden — sonst ermittelt der erste „Pre-Release"-Lauf `v1.0.0-rc.1` statt `v1.12.x-rc.1`.
- [ ] `Branch-Protection staging/master + Actions-Permissions` (Task 30, Plan-Schritt 14) — manueller Schritt außerhalb des Repos, noch nicht ausführbar/nachweisbar (erforderliche Check-Namen entstehen erst durch die ersten Workflow-Läufe).
- [ ] `Live-Verifikation` (Task 31, Plan-Schritt 15) — PR gegen `staging`, Gate-Verhalten und „Pre-Release"/Promotion-Kette können erst nach Merge bzw. nach Task 29 beobachtet werden.

## Hinweise

- **Abhängigkeitsreihenfolge:** Task 29 (Seed-Tag) muss vor dem ersten Merge des Task-Branches auf `staging` abgeschlossen werden; Task 31 hängt von 29 ab, Task 30 ist sinnvoll nach dem ersten Merge (bekannte Check-Namen).
- **MSBuild-Verifikation (Task 7):** In dieser Review-Umgebung ist kein MSBuild installiert (`vswhere` ohne Treffer) — der `Release|x64`-Kompiliernachweis konnte nicht erneut erbracht werden. `nuget restore` ist befundfrei und alle Referenz-/Pfad-Änderungen sind konsistent; der endgültige Build-Nachweis entsteht über den CI-Job `build-and-test` im Rahmen von Task 31.
- **`verify-pr-source.yml` / `sync-staging-with-main.yml` / `staging-to-main-promotion.yml`** verwenden den YAML-Schlüssel `"on"` gequotet — funktional korrekt (vermeidet YAML-1.1-Boolean-Falle), entspricht der Referenz-Schreibweise.
- **Kein `upstream`-Remote** konfiguriert (Plan-Seiteneffekt, kein Manko).
