# Plan-Review

## Ergebnis

**Status:** Offene Aufgaben vorhanden

3. Review-Lauf. Geprüft gegen den Gesamtdiff `08279a24..HEAD` (Basis `staging`-Merge-Base `08279a24`; Implementierung in `ad92cdc`, Code-Review-Fixes in `65fa7eed`, Portabilitäts-Fix in `4e39a1ff`; 51 Dateien, +10179/−22). Alle repo-internen Planelemente sind vollständig umgesetzt; die drei verbleibenden offenen Aufgaben (Tasks 29–31) sind ausschließlich manuelle GitHub-/Remote-Schritte außerhalb des Repo-Inhalts.

**Delta zu Lauf 2:** Einzige Änderung seitdem ist `.githooks/pre-push` in Commit `4e39a1ff` (`git diff 65fa7eed..HEAD`: 1 Datei, +37/−1). Die Änderung behebt den Portabilitäts-Befund aus `review-code.2.md` und ist plan-konform — Details unten bei `pre-push`.

## Umgesetzte Planelemente

### `Newtonsoft.Json`-Sicherheitsupdate (13.0.3)

- [x] `Addons/scraper.Trakttv.Data/packages.config` — `version="13.0.3"` (vorher 12.0.3)
- [x] `Addons/generic.Interface.Trakttv/packages.config` — `version="13.0.3"` (vorher 12.0.3)
- [x] `version="13.0.3"` in den übrigen 7 `packages.config` (`KodiAPI`, `EmberMediaManager`, `EmberAPI`, `scraper.TMDB.Trailer`, `scraper.TMDB.Poster`, `scraper.TMDB.Data`, `scraper.Data.OMDb`) — alle 9 Einträge per Grep verifiziert (Lauf 2, seitdem unverändert)
- [x] `<Reference Include="Newtonsoft.Json, Version=13.0.0.0">` + `<HintPath>` `Newtonsoft.Json.13.0.3` in `scraper.Data.Trakttv.vbproj` und `generic.Interface.Trakttv.vbproj`
- [x] `<HintPath>` `Newtonsoft.Json.13.0.3` in den übrigen 7 Projektdateien — alle 9 Projektdateien zeigen auf `13.0.3`, alle `<Reference>` auf `13.0.0.0`
- [x] Binding-Redirects `0.0.0.0-13.0.0.0`/`13.0.0.0` in `scraper.Trakttv.Data/app.config` und `generic.Interface.Trakttv/app.config`; Grep-Verifikation (Lauf 2): **kein** `*.config` im Repo referenziert mehr `12.0.0.0`
- [x] `.nuget\NuGet.exe restore "Ember Media Manager.sln"` in Lauf 2 ausgeführt — befundfrei, keine NU190x-Warnungen (Voraussetzung für das blockierende Gate 2 erfüllt)

### GitHooks (`.githooks/`) + `.gitattributes`

- [x] `.githooks/install-hooks.cmd` — setzt `core.hooksPath .githooks`
- [x] `.githooks/install-hooks.sh` — POSIX-Variante (Modus 100755)
- [x] `.githooks/pre-commit` — ruft `translation-check.py`; Fallback `python` → `python3` → `py -3` mit klarer Fehlermeldung, plus Inline-Dokumentation, welche der drei Prüfungen in diesem Repo wirksam sind (Modus 100755)
- [x] `.githooks/pre-push` — `nuget restore` + NU190x-Auswertung, **blockierend** (Exit 1 bei Befund und bei Restore-Fehler); Muster `NU190[1-4]` (Zeile 59), NU1900/NU1905+ kommentiert ausgenommen (Modus 100755). **Iteration-3-Ergänzung verifiziert (Commit `4e39a1ff`):** Plattform-Erkennung — `uname`-Check führt `NuGet.exe` unter Windows (MINGW/MSYS/CYGWIN/Windows_NT) direkt aus, auf anderen Plattformen via `mono` falls vorhanden; ohne lauffähige Toolchain oder fehlender `NuGet.exe` wird der lokale Scan mit Warnhinweis übersprungen (Exit 0). Das ist die von `review-code.2.md` empfohlene graceful degradation und plan-konform: Der Plan verlangt den Hook als lokalen Spiegel des blockierenden Gates — wo die Toolchain ausführbar ist, bleibt die Blockierung bei NU190x-Befund/Restore-Fehler exakt erhalten; wo sie nicht ausführbar ist, wäre ein harter Push-Blocker ein Defekt, und das blockierende Gate bleibt serverseitig in der CI wirksam (im Skript kommentiert, Zeilen 11–17)
- [x] `.githooks/translation-check.py` — Referenz-Variante (Localizer-Scan + .resx-Paketkonsistenz + Header-Validierung); `--all`-Lauf in Lauf 2: **befundfrei** (Exit 0, 142 .resx) → Verbatim-Übernahme bleibt der per Plan festgelegte korrekte Pfad
- [x] `.gitattributes`-Eintrag `.githooks/* text eol=lf` inkl. Kommentarblock (Zeile 8) — im selben Commit `ad92cdc` wie die `.githooks/`-Dateien; bestehende VS-`merge`/`diff`-Einträge unangetastet
- [x] Hook-Aktivierung: `core.hooksPath = .githooks` im lokalen Klon gesetzt (verifiziert)

### Composite Actions (`.github/actions/`)

- [x] `security-scan/action.yml` — Inputs `solution-path` (Default `Ember Media Manager.sln`), `artifact-name`, `fail-on-vulnerabilities` (**Default `'true'`**); `nuget restore` + Auswertung (`::error` + Exit 1 bei `'true'`, sonst `::warning`) + Log-Artefakt via `actions/upload-artifact@v7`; `Select-String -Pattern 'NU190[1-4]'` (Zeile 46) mit Begründungskommentar
- [x] `build-and-package/action.yml` — Inputs `release-version`/`release-tag`; `microsoft/setup-msbuild@v2` + `nuget restore` + `msbuild Release|x64`; Kopie `EmberMM - Release - x64\*` → `publish/`; `version.json`; Verify (`publish/Ember Media Manager.exe` + `version.json`); `Compress-Archive` → `release.zip`; `update.json` mit version/releaseNotes/publishedAt/assets (sha256, sizeBytes, assetUrl); **kein** NSIS-Installer-Schritt

### Release-Tooling (Root-Artefakte)

- [x] `package.json` — `name: "ember-media-manager"` (angepasst), `semantic-release`-DevDependencies + Script `release`
- [x] `package-lock.json` — `name`-Felder an `package.json` angeglichen (`ember-media-manager`)
- [x] `release.config.js` — `branches: ["master"]`, `tagFormat: "v${version}"`, Plugin-Set mit `successComment: false`/`failComment: false`, `RESOLVE_DRY_RUN`-Umschaltung; Kommentar „staging->master promotion PR" (Zeile 28)
- [x] `scripts/resolve-release-version.mjs` — `AUTOMATIC_RELEASE_BRANCHES = ["master"]`, `expectedReleaseAssetNames() = ["release.zip", "update.json"]`, Klassifikation `automatic`/`manual`/`upload-existing`; „master"-Benennung in Kommentaren korrekt (Zeilen 6, 216)

### Workflows (`.github/workflows/`)

- [x] `pr-staging-ci.yml` — `pull_request` auf `staging` (opened/synchronize/reopened), Concurrency `pr-staging-<PR-Nr>` mit Abbruch; `detect-backmerge` (Merge-Parent + Tree-Vergleich gegen `origin/master`); `static-checks` (windows-latest, `setup-msbuild`, Security-Scan mit `fail-on-vulnerabilities: 'true'`, Gate 3 `msbuild Debug|x86` ohne TWAE); `build-and-test` (parallel, `nuget restore` + `msbuild Release|x64` + Build-Log-Artefakt); `back-merge-skip`; Kommentare dokumentieren Gate-1-/4-/5-Wegfall
- [x] `staging-ci.yml` — Anzeigename **`Pre-Release`**; gleiche Gate-Jobs (Artefaktname `…-staging`); `version`-Job (Node 24, `npm ci`, `semantic-release --dry-run --branches staging`, RC-Nummer via `git tag --list "v<version>-rc.*"`); `prerelease`-Job (`build-and-package` + `gh release create --prerelease --generate-notes`)
- [x] `verify-pr-source.yml` — `pull_request` auf `master`, `permissions: {}`, `exit 1` bei `head_ref != "staging"`; `github.head_ref` über `env: HEAD_REF` gebunden (Zeilen 17–21), Script-Injection-Härtung mit dokumentierter Referenzabweichung
- [x] `sync-staging-with-main.yml` — `push` auf `master`, Concurrency ohne Abbruch, `rev-list HEAD..origin/master --count`, Label `automated-backmerge`, PR `master` → `staging` nur wenn kein offener existiert, „Create a merge commit"-Hinweis; Anzeigename „Backmerge Master to Staging"; Dateiname/Concurrency-Gruppe behalten bewusst das Referenz-„main" (inline dokumentiert, keine Branch-Kopplung)
- [x] `staging-to-main-promotion.yml` — `workflow_run` auf `"Pre-Release"` (completed, branches `[staging]`), Bedingung `conclusion == 'success'`, Tree-Vergleich mit `origin/master`, **Draft**-PR `staging` → `master` mit Label `automated-promotion`; `workflows: ["Pre-Release"]`-Kopplung korrekt
- [x] `security-scan.yml` — `schedule` `cron: '0 4 * * 1'` + `workflow_dispatch`, windows-latest, Composite Action mit `fail-on-vulnerabilities: 'true'`; `permissions: contents: read` (Zeilen 21–22, dokumentierte Härtung über die Referenz hinaus)
- [x] `release.yml` — Trigger `push` `branches: [master]` + `tags: ['v*.*.*']`, Concurrency `release` ohne Abbruch; Node 24 + `npm ci` + `resolve-release-version.mjs`; Release-Gate = `nuget restore` + `msbuild Debug|x86` (Test-Gates ersetzt, kommentiert); drei Release-Pfade (`npm run release` / `gh release create --generate-notes` / `gh release upload --clobber` mit `git checkout --detach <tag>`)

### Doku

- [x] `README.md` — Abschnitt „Continuous Integration / Git Hooks": Hook-Aktivierung via `install-hooks.*` + Workflow-Überblick

## Offene Aufgaben

- [ ] `Seed-Tag v1.12.0` (Task 29, Plan-Schritt 13) — fehlt vollständig: weder lokal (`git tag -l "v*"` leer) noch auf `origin` (`git ls-remote --tags origin` ohne Einträge) vorhanden — in diesem Lauf erneut verifiziert. **Zeitkritisch:** muss auf `origin` liegen, **bevor** die Workflow-Dateien erstmals auf `staging` gemergt werden — sonst ermittelt der erste „Pre-Release"-Lauf `v1.0.0-rc.1` statt `v1.12.x-rc.1`. Manueller Remote-Schritt, außerhalb des Repo-Inhalts.
- [ ] `Branch-Protection staging/master + Actions-Permissions` (Task 30, Plan-Schritt 14) — manueller Schritt außerhalb des Repos, noch nicht ausführbar/nachweisbar (erforderliche Check-Namen entstehen erst durch die ersten Workflow-Läufe).
- [ ] `Live-Verifikation` (Task 31, Plan-Schritt 15) — PR gegen `staging`, Gate-Verhalten und „Pre-Release"/Promotion-Kette können erst nach Merge bzw. nach Task 29 beobachtet werden.

## Hinweise

- **Abhängigkeitsreihenfolge:** Task 29 (Seed-Tag) muss vor dem ersten Merge des Task-Branches auf `staging` abgeschlossen werden; Task 31 hängt von 29 ab, Task 30 ist sinnvoll nach dem ersten Merge (bekannte Check-Namen).
- **Alle Code-Review-Befunde (`review-code.1.md`/`review-code.2.md`) sind behoben:** Iteration 2 in Commit `65fa7eed` (env-Indirektion `verify-pr-source.yml`, `NU190[1-4]`-Muster, `permissions: contents: read`, Python-Fallback `pre-commit`, „master"-Benennung); der `pre-push`-Portabilitäts-Befund aus `review-code.2.md` in Commit `4e39a1ff` (Plattform-Erkennung + graceful skip). Der `translation-check.py`-Befund (tote Prüfungen 1+2) bleibt plan-konform gelöst: Skript verbatim, Wirksamkeits-Einschränkung als Kommentar in `pre-commit` dokumentiert.
- **MSBuild-Verifikation (Task 7):** Der `Release|x64`-Kompiliernachweis wurde in dieser Review-Umgebung nicht geführt; der endgültige Build-Nachweis entsteht über den CI-Job `build-and-test` im Rahmen von Task 31.
- **`verify-pr-source.yml` / `sync-staging-with-main.yml` / `staging-to-main-promotion.yml`** verwenden den YAML-Schlüssel `"on"` gequotet — funktional korrekt (vermeidet YAML-1.1-Boolean-Falle), entspricht der Referenz-Schreibweise.
- **Kein `upstream`-Remote** konfiguriert (Plan-Seiteneffekt, kein Manko).
