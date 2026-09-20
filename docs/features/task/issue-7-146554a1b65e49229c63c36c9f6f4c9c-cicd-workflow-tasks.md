# Tasks: CI/CD-Workflow (Issue #7)

| # | Bereich | Aufgabe | Status | Testnachweis |
|---|---------|---------|--------|--------------|
| 1 | Paketupdate | `Newtonsoft.Json` `12.0.3` → `13.0.3` in `Addons/scraper.Trakttv.Data/packages.config` | Offen | — |
| 2 | Paketupdate | `Newtonsoft.Json` `12.0.3` → `13.0.3` in `Addons/generic.Interface.Trakttv/packages.config` | Offen | — |
| 3 | Paketupdate | `Newtonsoft.Json` `13.0.1` → `13.0.3` in den übrigen `packages.config` (`KodiAPI`, `EmberMediaManager`, `EmberAPI`, `Addons/scraper.TMDB.Trailer`, `Addons/scraper.TMDB.Poster`, `Addons/scraper.TMDB.Data`, `Addons/scraper.Data.OMDb`) | Offen | — |
| 4 | Paketupdate | `<Reference>`-Version `12.0.0.0` → `13.0.0.0` + `<HintPath>` → `Newtonsoft.Json.13.0.3` in `scraper.Data.Trakttv.vbproj` und `generic.Interface.Trakttv.vbproj` | Offen | — |
| 5 | Paketupdate | `<HintPath>` `Newtonsoft.Json.13.0.1` → `Newtonsoft.Json.13.0.3` in den übrigen 7 Projektdateien (`KodiAPI.csproj`, `EmberMediaManager.vbproj`, `EmberAPI.vbproj`, `scraper.Trailer.TMDB.vbproj`, `scraper.Image.TMDB.vbproj`, `scraper.Data.TMDB.vbproj`, `scraper.Data.OMDb.vbproj`) | Offen | — |
| 6 | Paketupdate | Binding-Redirect `oldVersion="0.0.0.0-12.0.0.0" newVersion="12.0.0.0"` → `…-13.0.0.0`/`13.0.0.0` in `scraper.Trakttv.Data/app.config` und `generic.Interface.Trakttv/app.config`; per Grep verifizieren, dass kein weiterer Redirect auf `12.0.0.0` zeigt | Offen | — |
| 7 | Paketupdate | Lokal verifizieren: `nuget restore` ohne NU190x-Warnung + `msbuild Release\|x64` erfolgreich | Offen | — |
| 8 | GitHooks | `.gitattributes` um `.githooks/* text eol=lf` inkl. Referenz-Kommentarblock ergänzen (dritte deklarierte Ausnahme der Additiv-Regel; im selben Commit wie die `.githooks/`-Dateien — wirkt beim Checkout auf LF) | Offen | — |
| 9 | GitHooks | `.githooks/install-hooks.cmd` anlegen (unverändert aus Referenz) | Offen | — |
| 10 | GitHooks | `.githooks/install-hooks.sh` anlegen (unverändert aus Referenz) | Offen | — |
| 11 | GitHooks | `.githooks/translation-check.py` aus Referenz übernehmen (Localizer-Scan + .resx-Konsistenz + Header-Validierung) | Offen | — |
| 12 | GitHooks | `.githooks/pre-commit` anlegen (ruft `translation-check.py`) | Offen | — |
| 13 | GitHooks | `.githooks/pre-push` anlegen (`nuget restore` + NU190x-Auswertung, **blockierend** bei Befund — Spiegel des blockierenden Gates) | Offen | — |
| 14 | GitHooks | Hooks lokal verifizieren: `python .githooks/translation-check.py --all` ausführen; befundfrei → `install-hooks.cmd` aktivieren; bei `.resx`-Bestandsbefunden → Befundliste dokumentieren und Skript auf die vom Commit berührten `.resx`-Pakete eingrenzen (festgelegte Entscheidung im Plan), dann `install-hooks.cmd` + Probe-Commit | Offen | — |
| 15 | Composite Actions | `.github/actions/security-scan/action.yml` anlegen (`nuget restore` + NU190x-Parsing + Log-Artefakt; Inputs `solution-path`, `artifact-name`, `fail-on-vulnerabilities` mit Default `'true'`) | Offen | — |
| 16 | Composite Actions | `.github/actions/build-and-package/action.yml` anlegen (MSBuild `Release\|x64` → `publish/` → `version.json` → `release.zip` + `update.json`; kein NSIS-Installer) | Offen | — |
| 17 | Release-Tooling | `package.json` anlegen (semantic-release-Dependencies aus Referenz, `name` angepasst) | Offen | — |
| 18 | Release-Tooling | `package-lock.json` aus Referenz kopieren und `name`-Felder an `package.json` angleichen | Offen | — |
| 19 | Release-Tooling | `release.config.js` anlegen (`branches: ["master"]`, Plugin-Set wie Referenz) | Offen | — |
| 20 | Release-Tooling | `scripts/resolve-release-version.mjs` anlegen (`AUTOMATIC_RELEASE_BRANCHES = ["master"]`, Assets `release.zip` + `update.json`) | Offen | — |
| 21 | Workflows | `.github/workflows/pr-staging-ci.yml` anlegen (`master`-Mapping, `nuget`/`msbuild`-Toolchain, Gates 2+3 mit `fail-on-vulnerabilities: 'true'`, Release-x64-Build-Job) | Offen | — |
| 22 | Workflows | `.github/workflows/staging-ci.yml` anlegen (Anzeigename „Pre-Release"; gleiche Gates inkl. blockierendem Security-Scan + `version`-/`prerelease`-Jobs) | Offen | — |
| 23 | Workflows | `.github/workflows/verify-pr-source.yml` anlegen (PRs gegen `master` nur von `staging`) | Offen | — |
| 24 | Workflows | `.github/workflows/sync-staging-with-main.yml` anlegen (Back-Merge-PR `master` → `staging`) | Offen | — |
| 25 | Workflows | `.github/workflows/staging-to-main-promotion.yml` anlegen (Draft-PR `staging` → `master` nach „Pre-Release"-Erfolg) | Offen | — |
| 26 | Workflows | `.github/workflows/security-scan.yml` anlegen (wöchentlicher Cron + `workflow_dispatch`, `fail-on-vulnerabilities: 'true'`) | Offen | — |
| 27 | Workflows | `.github/workflows/release.yml` anlegen (Trigger `master`/`v*.*.*`; Release-Gate = Restore + Debug-Build; drei Release-Pfade wie Referenz) | Offen | — |
| 28 | Doku | README-Abschnitt „Continuous Integration / Git Hooks" ergänzen (Hook-Aktivierung, Workflow-Überblick) — deklarierte Ausnahme der Additiv-Regel | Offen | — |
| 29 | GitHub-Konfiguration | Seed-Tag `v1.12.0` auf `master`-Tip setzen und nach `origin` pushen — **vor dem ersten Merge der Workflow-Dateien auf `staging`** (der Merge triggert den ersten „Pre-Release"-Lauf; Tag zeigt auf alten Tip ohne `release.yml` → kein Release-Lauf durch den Tag-Push) | Offen | — |
| 30 | GitHub-Konfiguration | Branch-Protection für `staging`/`master` einrichten + Actions-Permissions prüfen (manuell, außerhalb Repo) | Offen | — |
| 31 | Verifikation | Live-Verifikation: PR gegen `staging` öffnen, Workflow-Lauf und Gate-Verhalten prüfen (Gate 2 befundfrei/grün); nach Merge „Pre-Release"/Promotion-Kette beobachten (erwartete RC-Version auf Basis `v1.12.0`) | Offen | — |
