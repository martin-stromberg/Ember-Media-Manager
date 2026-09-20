# Umsetzungsplan: CI/CD-Workflow (Issue #7)

## Übersicht

Das Fork-Repository erhält eine zweistufige Qualitätssicherung nach dem Vorbild der Referenz `martin-stromberg/Softwareschmiede`: (1) lokale GitHooks unter `.githooks/` (aktivierbar per `core.hooksPath`) und (2) ein GitHub-Actions-Workflow-Set unter `.github/` mit PR-CI für `staging`, Staging-CI inkl. Versions-/Prerelease-Kette, PR-Quellen-Verifizierung, Back-Merge- und Promotion-Automatisierung, wöchentlichem Security-Scan und Release-Workflow. Zwingende Anpassungen gegenüber der Referenz: Hauptbranch `master` statt `main`, Legacy-Toolchain (`nuget restore` + MSBuild statt `dotnet`-CLI) und Wegfall der nicht erfüllbaren Gates (Format, Tests, Coverage). Zusätzlich wird `Newtonsoft.Json` auf eine nicht-vulnerable Version aktualisiert — eine bewusste, vom Anwender entschiedene minimale Upstream-Abweichung (Sicherheitsfix), die das von Anfang an blockierend geschaltete Security-Gate ermöglicht. Zwei weitere deklarierte Ausnahmen der Additiv-Regel: ein `eol=lf`-Eintrag für `.githooks/` in `.gitattributes` (unvermeidlich — ohne ihn schlagen die Shell-Hooks bei `core.autocrlf=true` fehl) und ein kurzer README-Abschnitt zur Hook-Aktivierung (Dokumentation der Anforderungsumsetzung).

## Designentscheidungen

| Komponente / Bereich | Gewählter Ansatz | Begründung |
|----------------------|-----------------|------------|
| Gesamtumfang | Vollständiges Referenz-Set: 7 Workflows, 2 Composite Actions, 5 GitHook-Dateien plus die referenzseitigen Root-Artefakte (`package.json`, `package-lock.json`, `release.config.js`, `scripts/resolve-release-version.mjs`) | Akzeptanzkriterium verlangt Orientierung an Softwareschmiede mit möglichst wenig Abweichung; `Pattern-Collection`/`CI-Workflows/instructions.md` ist nicht abrufbar (HTTP 404, bekannter Befund), Softwareschmiede gilt als vollständige Umsetzung der Vorgabe. |
| Hauptbranch-Mapping | `main` → `master` in allen Triggern, `git fetch`/`rev-parse`-Referenzen, PR-Bases (`verify-pr-source`, `sync-staging-with-main`, `staging-to-main-promotion`, `release.yml`) und `release.config.js` (`branches: ["master"]`) | Default-Branch des Forks ist `master`; `staging` existiert bereits und enthält `master` vollständig. Umbenennung des Default-Branch würde Upstream-Diff und Historie belasten — reine Namensersetzung ist die minimalinvasive Variante. |
| Build-Toolchain in allen Workflows | `.nuget\NuGet.exe restore "Ember Media Manager.sln"` (im Repo eingecheckte NuGet 6.14) + `microsoft/setup-msbuild@v2` + `msbuild` auf `windows-latest` | `dotnet restore/build/test` unterstützen weder Legacy-`.vbproj` noch `packages.config`. `windows-latest` liefert VS Build Tools; `Directory.Build.props` (`FrameworkPathOverride` auf das referenzierte `Microsoft.NETFramework.ReferenceAssemblies.net48`-Paket) macht den Build ohne .NET-4.8-Developer-Pack lauffähig — lokal bereits verifiziert. Solution-Name enthält Leerzeichen → überall quoten. |
| Gate 1 (Format-Check `dotnet format --verify-no-changes`) | Entfällt; keine `.editorconfig`-Einführung | `dotnet format` ist auf dem Legacy-Projektformat (.NET Framework 4.8, nicht SDK-Style, überwiegend VB.NET) nicht anwendbar. Auch die Referenz besitzt keine `.editorconfig`; eine Konfigurationsdatei ohne durchsetzbares Gate hätte keinen Nutzen. |
| Gate 2 (Security-Scan) | Composite Action `.github/actions/security-scan` wird auf `packages.config` umimplementiert: führt `.nuget\NuGet.exe restore` aus, parst die Ausgabe auf `NU190x`-Warnungen (NuGet 6.14 meldet Vulnerabilities für `packages.config` bereits beim Restore — im Inventar verifiziert), schreibt Scan-Log-Artefakt. Input `fail-on-vulnerabilities` wird mit Default `'true'` angelegt; **alle Aufrufstellen (`pr-staging-ci`, `staging-ci`, `security-scan.yml`) fahren von Anfang an blockierend** | `dotnet list package --vulnerable` ist PackageReference-only; NU190x-Auswertung ist die nächstliegende native Alternative. Der heutige NU1903-Befund (`Newtonsoft.Json` 12.0.3, GHSA-5crp-9r3c-p9vr) wird in diesem Issue per Paketupdate behoben (Anwender-Entscheidung) — damit kann das Gate von Tag 1 an hart schalten, ohne rot zu starten. Der Input bleibt als Schalter erhalten (Referenzstruktur). |
| `Newtonsoft.Json`-Sicherheitsupdate | Alle `Newtonsoft.Json`-Referenzen werden einheitlich auf **13.0.3** aktualisiert: 9 `packages.config`-Einträge (2× `12.0.3`, 7× `13.0.1`), die zugehörigen `<HintPath>`-Einträge in 9 Projektdateien, die `<Reference Include>`-Assembly-Version `12.0.0.0` → `13.0.0.0` in den zwei Trakttv-Projektdateien sowie die zwei Binding-Redirects `newVersion="12.0.0.0"` → `"13.0.0.0"` | Bewusste, fachlich notwendige Ausnahme vom Akzeptanzkriterium „Upstream unangetastet" — vom Anwender als Sicherheitsfix in diesem Issue entschieden. Einheitliche Version vermeidet zwei Paketordner (`Newtonsoft.Json.12.0.3`/`.13.0.1`/`.13.0.3`) und gemischte File-Versionen in den Addon-Ausgaben. `Newtonsoft.Json` 13.0.x behält die AssemblyVersion `13.0.0.0` → alle übrigen Redirects (`oldVersion="0.0.0.0-13.0.0.0" newVersion="13.0.0.0"`) bleiben gültig und werden nicht angefasst. Verifiziert: nur `Addons/scraper.Trakttv.Data/app.config` und `Addons/generic.Interface.Trakttv/app.config` redirecten noch auf `12.0.0.0`. |
| Gate 3 (Static Analysis) | `msbuild "Ember Media Manager.sln" -p:Configuration=Debug -p:Platform=x86` **ohne** `TreatWarningsAsErrors` | TWAE auf einer Legacy-VB.NET-Codebasis mit voraussichtlich hoher Warnungszahl wäre von Tag 1 an rot und nicht upstream-neutral behebbar. Das Gate prüft damit „Solution kompiliert fehlerfrei" — die verbleibende belastbare Aussage der Referenz-Stufe. `Debug\|x86` entspricht dem im Inventar verifizierten lokalen Build. |
| Job `build-and-test` | Job-ID und parallele Jobstruktur bleiben erhalten; Inhalt: `nuget restore` + `msbuild -p:Configuration=Release -p:Platform=x64` + Upload des Build-Logs als Artefakt. Test-, Coverage- und ReportGenerator-Schritte entfallen (mit erklärendem Kommentar im YAML) | Es existieren keine ausführbaren Tests (`EmberAPI_Test` baut nicht: fehlendes `UnitTests`-Projekt, 203× BC30002, MSTest-v1-GAC-Referenz — nicht Teil dieses Issues). Gates 4 (Tests) und 5 (70 %-Coverage) haben keine Grundlage. Der Release-x64-Build deckt die auslieferbare Konfiguration ab und ist damit kein redundantes Duplikat des Debug-Builds in `static-checks`. Reparatur von `EmberAPI_Test` ist ausdrücklich nicht Teil der Anforderung. |
| `detect-backmerge` | 1:1 aus Referenz übernommen, nur `origin/main` → `origin/master` | Reine Shell-/Git-Logik (Merge-Parent-Prüfung + Tree-Vergleich), technologieunabhängig. |
| `version`-/`prerelease`-Jobs in `staging-ci.yml` | 1:1 übernommen (semantic-release-Dry-Run mit `--branches staging`-Override, RC-Numerierung via `git tag --list "v<version>-rc.*"`, `gh release create --prerelease`), Abhängigkeiten über die Root-Artefakte `package.json`/`package-lock.json`/`release.config.js` bereitgestellt; **Seed-Tag `v1.12.0` auf den `master`-Tip wird manuell gesetzt und muss auf `origin` liegen, bevor die Workflow-Dateien erstmals auf `staging` gemergt werden** (Anwender-Entscheidung, siehe Konfigurationsänderungen und Schritt 13) | Führt die Referenz-Versionskette unverändert ein. Ohne Seed-Tag würde semantic-release `1.0.0` ermitteln — unterhalb des aktuellen Stands (`1.11.1.0`/`EMM_REVISION=1.12.0`); `v1.12.0` passt zu `EMM_REVISION` in `BuildSetup/`. Konsequenz: künftige Versionsvergabe folgt Conventional Commits — bewusste Prozessübernahme aus der Referenz (bisherige manuelle Versionierung via `changes.log`/`AssemblyInfo`/`EMM_REVISION` bleibt unangetastet, wird durch die Tags ergänzt). |
| Composite Action `build-and-package` | Struktur der Referenz beibehalten (Inputs `release-version`/`release-tag`, `version.json`, Verify-Schritt, `Compress-Archive` → `release.zip`, `update.json` im selben Schema), Build-Schritt ersetzt: `nuget restore` + `msbuild Release\|x64`, anschließend Kopie von `EmberMM - Release - x64\*` nach `publish/`; Verify prüft `publish/Ember Media Manager.exe` (AssemblyName lt. `EmberMediaManager.vbproj`) | Ember ist keine `dotnet publish`-fähige App; das Ausgabeverzeichnis `EmberMM - Release - x64` ist der dokumentierte Build-Output. Der NSIS-Installer (`BuildSetup/`) wird **nicht** Teil der Release-Pipeline — entschiedene Nicht-Anforderung (würde `tx.exe`/Transifex-Credentials als neues Secret und `makensis` erfordern); `release.zip` mit dem portablen Build-Ergebnis bleibt das einzige Release-Asset neben `update.json`. |
| `release.yml` | Übernommen mit Anpassungen: Trigger `push` auf `master` + Tags `v*.*.*`; Release-Gate-Tests ersetzt durch `nuget restore` + `msbuild Debug\|x86` (keine Tests vorhanden); die drei Release-Pfade (automatisch via `npm run release`/semantic-release, manueller Tag via `gh release create --generate-notes`, Asset-Reparatur via `gh release upload --clobber`) bleiben identisch | Bewahrt das referenzseitige Release-Auflösungsmodell (`scripts/resolve-release-version.mjs`: `automatic`/`manual`/`upload-existing`). |
| `pre-commit` + `translation-check.py` | Unverändert aus der Referenz kopiert; **festgelegter Umgang mit Bestandsbefunden:** Vor der Hook-Aktivierung läuft `translation-check.py --all` als Verifikation. Befundfrei → Skript bleibt verbatim. Melden die Prüfungen 2/3 Bestandsbefunde (bei WinForms-`.resx` wahrscheinlich: Sprachvarianten enthalten nur übersetzte Keys, die neutrale Datei alle Designer-Keys), werden (a) die Befunde dokumentiert und (b) das Skript minimal für Ember eingegrenzt: Paket-Konsistenz- und Header-Prüfung nur noch auf die `.resx`-Pakete/Dateien, die ein Commit tatsächlich staged (inkl. deren Paket-Geschwister) | Prüfung 1 (`IStringLocalizer`-Scan auf `.cs`/`.razor`/`.cshtml`) ist im Ember-Repo ein No-Op (kein einziges `IStringLocalizer`-Vorkommen). Prüfungen 2+3 sind generisch, laufen aber im Referenz-Skript **immer auf allen** `.resx`-Dateien — nicht nur gestagten; mit Bestandsbefunden würde verbatim jeder Commit blockieren. Das Beheben der Befunde ist verworfen (würde alle Designer-Keys in jede Sprachdatei duplizieren = massiver Upstream-Diff); „Hook trotz Befunden aktivieren" ist verworfen (blockiert jeden Commit). Die Eingrenzung hält den Schutz für neue/geänderte Übersetzungen aufrecht und bleibt die minimale dokumentierte Abweichung. |
| `pre-push` | Spiegelt analog zur Referenz den Security-Gate lokal: `.nuget\NuGet.exe restore "Ember Media Manager.sln"` + NU190x-Auswertung; ein Befund **bricht den Push ab** (Exit 1) — Spiegel des von Anfang an blockierenden CI-Gate-Modus | Das referenzseitig gespiegelte Format-Gate entfällt (s. o.); ein kompletter MSBuild-Lauf wäre als Hook zu langsam. Der Restore-Scan ist in Sekunden ausführbar und verhindert, dass ein lokaler Verstoß überhaupt gepusht wird. |
| `install-hooks.cmd` / `install-hooks.sh` | Unverändert kopiert (`git config --local core.hooksPath .githooks`) | Technologieunabhängig. |
| Workflow-Anzeigename „Pre-Release" | Beibehalten | `staging-to-main-promotion.yml` triggert per `workflow_run` auf den **Anzeigenamen**; Kopplung wie in der Referenz im selben Commit konsistent halten. |
| Sonstige Workflow-Details | `permissions`-Blöcke, `concurrency`-Gruppen, Timeouts, Action-Pins (`actions/checkout@v7`, `actions/setup-node@v7`, `actions/upload-artifact@v7`), Cron `0 4 * * 1`, Label-Namen (`automated-backmerge`, `automated-promotion`), PR-Texte und Merge-Hinweise unverändert übernehmen | Maximale Referenznähe; keine Ember-spezifischen Abhängigkeiten. `setup-dotnet` entfällt überall (keine dotnet-CLI-Nutzung), stattdessen `microsoft/setup-msbuild@v2` in Jobs mit MSBuild-Bedarf. |

## Programmabläufe

### PR-CI gegen `staging` (`pr-staging-ci.yml`)

1. `pull_request` (`opened`/`synchronize`/`reopened`) auf `staging` triggert den Workflow; Concurrency `pr-staging-<PR-Nr>` bricht Vorläufe ab.
2. Job `detect-backmerge` (ubuntu-latest): checkout mit `fetch-depth: 0`, `git fetch origin master:refs/remotes/origin/master`; prüft, ob `origin/master`-Tip Merge-Parent des synthetischen PR-Merge-Commits ist **oder** der Tree identisch zu `origin/master` (`git diff --quiet`) → Output `is_backmerge`.
3. Bei `is_backmerge == 'true'`: nur Job `back-merge-skip` läuft (Bestätigung); `static-checks` und `build-and-test` werden übersprungen.
4. Job `static-checks` (windows-latest, parallel): checkout → `microsoft/setup-msbuild@v2` → Composite Action `./.github/actions/security-scan` (führt intern `nuget restore` aus, Gate 2, blockierend via `fail-on-vulnerabilities: 'true'`) → Gate 3: `msbuild "Ember Media Manager.sln" -p:Configuration=Debug -p:Platform=x86`.
5. Job `build-and-test` (windows-latest, parallel, kein `needs` zwischen den Gate-Jobs): checkout → `setup-msbuild` → `nuget restore` → `msbuild -p:Configuration=Release -p:Platform=x64` → Build-Log-Artefakt.

Beteiligte Artefakte: `.github/workflows/pr-staging-ci.yml`, `.github/actions/security-scan/action.yml`, `.nuget/NuGet.exe`, `Directory.Build.props`

### Push-CI auf `staging` mit Versions-/Prerelease-Kette (`staging-ci.yml`, Anzeigename „Pre-Release")

1. `push` auf `staging`; gleiche Gate-Jobs wie PR-CI (`detect-backmerge`, `static-checks`, `build-and-test` mit Artefaktnamen `…-staging`).
2. Job `version` (ubuntu-latest, `needs` alle Gate-Jobs, nur bei `is_backmerge != 'true'`): checkout mit Tags, `actions/setup-node@v7` (Node 24), `npm ci`, `npx semantic-release --dry-run --no-ci --branches staging` → parst „The next release version is X.Y.Z" → Outputs `changed`, `version`; RC-Nummer = Anzahl vorhandener Tags `v<version>-rc.*` + 1 → `rc_tag` (`vX.Y.Z-rc.N`).
3. Job `prerelease` (windows-latest, nur bei `changed == 'true'`): Composite Action `./.github/actions/build-and-package` (Release-x64-Build → `release.zip` + `update.json`) → `gh release create <rc_tag> --prerelease --generate-notes` mit beiden Assets.

Beteiligte Artefakte: `.github/workflows/staging-ci.yml`, `.github/actions/security-scan/action.yml`, `.github/actions/build-and-package/action.yml`, `package.json`, `package-lock.json`, `release.config.js`

### PR-Quellen-Verifizierung (`verify-pr-source.yml`)

1. `pull_request` auf `master` (alle Typen), `permissions: {}`.
2. Einziger Schritt: `exit 1` mit Fehlermeldung, wenn `github.head_ref != "staging"` — erzwingt den Flow Feature-Branch → `staging` → `master`.

### Automatischer Back-Merge (`sync-staging-with-main.yml`)

1. `push` auf `master`; Concurrency ohne Abbruch (`cancel-in-progress: false`).
2. Checkout `staging` (fetch-depth 0), `git fetch origin master`, `git rev-list HEAD..origin/master --count`.
3. Bei `commits_behind != '0'`: Label `automated-backmerge` anlegen (`gh label create --force`), PR `master` → `staging` via `gh pr create` — nur wenn kein offener existiert. PR-Text weist auf „Create a merge commit" hin (Tag-Erreichbarkeit).

### Promotion `staging` → `master` (`staging-to-main-promotion.yml`)

1. `workflow_run` auf Anzeigename `"Pre-Release"`, `types: [completed]`, `branches: [staging]`; Job-Bedingung `conclusion == 'success'`.
2. Checkout des `workflow_run.head_sha`; Tree-Vergleich mit `origin/master` (identischer Tree = Back-Merge → keine Promotion), sonst `git rev-list origin/master..HEAD --count`.
3. Bei `commits_ahead != '0'`: Label `automated-promotion` + **Draft-PR** `staging` → `master` (manueller Merge durch Maintainer).

### Release auf `master` (`release.yml`)

1. `push` auf `master` **oder** Tag `v*.*.*`; serialisiert (`concurrency: release`, kein Abbruch).
2. Checkout mit Tags, Node 24, `npm ci`, `node scripts/resolve-release-version.mjs` → klassifiziert: `automatic` (Branch-Push, Version via semantic-release-Dry-Run) / `manual` (gepushter `vX.Y.Z`-Tag) / `upload-existing` (Asset-Reparatur bei vorhandenem Release) → Outputs `released`, `release_kind`, `release_action`, `version`, `tag`.
3. Bei `release_action == 'create'`: `nuget restore` + `msbuild Debug|x86` als Release-Gate (statt der referenzseitigen Test-Gates).
4. Bei `released == 'true'`: Composite Action `build-and-package` → `release.zip` + `update.json`.
5. Release-Erzeugung: `release_kind == 'automatic'` → `npm run release` (semantic-release erzeugt Tag + GitHub-Release + Asset-Upload via `release.config.js`); `'manual'` → `gh release create $tag release.zip update.json --generate-notes`; `'upload-existing'` → vorher `git checkout --detach $tag`, dann `gh release upload $tag --clobber`.

Beteiligte Artefakte: `.github/workflows/release.yml`, `scripts/resolve-release-version.mjs`, `release.config.js`, `.github/actions/build-and-package/action.yml`

### Wöchentlicher Security-Scan (`security-scan.yml`)

1. `schedule` `cron: '0 4 * * 1'` (montags 04:00 UTC) + `workflow_dispatch`.
2. windows-latest: checkout → Composite Action `./.github/actions/security-scan` (Restore + NU190x-Auswertung, blockierend + Log-Artefakt).

### Lokale Hooks (`.githooks/`)

1. Einmalig pro Klon: `install-hooks.cmd` (Windows) bzw. `install-hooks.sh` setzt `git config --local core.hooksPath .githooks`.
2. `pre-commit`: `python "$(dirname "$0")/translation-check.py"` → prüft gestagte `.cs`-Dateien auf `IStringLocalizer`-Keys (in Ember No-Op), Konsistenz von `.resx`-Sprachvarianten und `.resx`-Header; Exit 1 bei Befunden.
3. `pre-push`: `.nuget\NuGet.exe restore "Ember Media Manager.sln"`, wertet NU190x-Warnungen aus und **bricht den Push bei Befunden ab** (Spiegel des blockierenden Gate 2 der PR-CI).

## Neue Artefakte

Keine Klassen betroffen — ausschließlich neue Infrastruktur-Dateien (alle additiv):

| Datei | Typ | Zweck |
|-------|-----|-------|
| `.githooks/install-hooks.cmd` | Skript | Einmalige Hook-Aktivierung unter Windows (`core.hooksPath`) |
| `.githooks/install-hooks.sh` | Skript | Einmalige Hook-Aktivierung unter POSIX-Shells |
| `.githooks/pre-commit` | Git-Hook (sh) | Ruft `translation-check.py` vor jedem Commit |
| `.githooks/pre-push` | Git-Hook (sh) | Spiegelt den Security-Scan-Gate lokal (Restore + NU190x, blockierend) |
| `.githooks/translation-check.py` | Python-Skript | .resx-Konsistenz-/Header-Prüfung (+ Localizer-Scan, hier No-Op) — unverändert aus Referenz |
| `.github/actions/security-scan/action.yml` | Composite Action | `nuget restore` + NU190x-Auswertung + Log-Artefakt; Inputs `solution-path`, `artifact-name`, `fail-on-vulnerabilities` (Default `'true'`) |
| `.github/actions/build-and-package/action.yml` | Composite Action | Release-x64-MSBuild → `publish/` → `version.json` → `release.zip` + `update.json`; Inputs `release-version`, `release-tag` |
| `.github/workflows/pr-staging-ci.yml` | Workflow | PR-CI gegen `staging` (Back-Merge-Erkennung, `static-checks`, `build-and-test`) |
| `.github/workflows/staging-ci.yml` | Workflow („Pre-Release") | Push-CI auf `staging` + `version`-/`prerelease`-Kette |
| `.github/workflows/verify-pr-source.yml` | Workflow | Erzwingt PRs gegen `master` nur von `staging` |
| `.github/workflows/sync-staging-with-main.yml` | Workflow | Back-Merge-PR `master` → `staging` nach Push auf `master` |
| `.github/workflows/staging-to-main-promotion.yml` | Workflow | Draft-Promotion-PR `staging` → `master` nach erfolgreicher „Pre-Release" |
| `.github/workflows/security-scan.yml` | Workflow | Wöchentlicher geplanter Vulnerability-Scan + `workflow_dispatch` |
| `.github/workflows/release.yml` | Workflow | Release-Erzeugung auf `master` / `v*.*.*`-Tags inkl. Asset-Reparatur |
| `package.json` | npm-Manifest | `semantic-release`-Toolchain (`devDependencies`, Script `release`) — aus Referenz, `name` angepasst |
| `package-lock.json` | npm-Lockfile | Reproduzierbares `npm ci` in `version`-/`release`-Jobs — aus Referenz, `name`-Felder angepasst |
| `release.config.js` | semantic-release-Konfig | `branches: ["master"]`, `tagFormat: "v${version}"`, Plugin-Set inkl. `successComment: false`/`failComment: false`, `RESOLVE_DRY_RUN`-Umschaltung |
| `scripts/resolve-release-version.mjs` | Node-Skript | Release-Klassifikation (`automatic`/`manual`/`upload-existing`) für `release.yml`; `AUTOMATIC_RELEASE_BRANCHES = ["master"]`, `expectedReleaseAssetNames = ["release.zip", "update.json"]` |
| `.gitattributes` (Änderung, deklarierte Ausnahme) | Git-Konfiguration | Neuer Eintrag `.githooks/* text eol=lf` inkl. Referenz-Kommentarblock — erzwingt LF-Zeilenenden für die Shell-Hooks |
| `README.md` (Änderung, deklarierte Ausnahme) | Doku | Kurzer neuer Abschnitt: Hook-Aktivierung (`.githooks/install-hooks.*`) + Hinweis auf CI-Workflows |

## Änderungen an bestehenden Klassen

Keine Quellcode-Klassen betroffen. Abweichend vom ursprünglichen Grundsatz „nur additive Dateien" gibt es drei entschiedene Ausnahmen:

### `Newtonsoft.Json`-Sicherheitsupdate (vom Anwender entschiedene Upstream-Abweichung)

Zielversion einheitlich **13.0.3** (nicht-vulnerable, stabile 13.0.x; behebt NU1903/GHSA-5crp-9r3c-p9vr). Betroffene Dateien:

| Datei | Änderung |
|-------|----------|
| `Addons/scraper.Trakttv.Data/packages.config` | `version="12.0.3"` → `"13.0.3"` |
| `Addons/generic.Interface.Trakttv/packages.config` | `version="12.0.3"` → `"13.0.3"` |
| `KodiAPI/packages.config`, `EmberMediaManager/packages.config`, `EmberAPI/packages.config`, `Addons/scraper.TMDB.Trailer/packages.config`, `Addons/scraper.TMDB.Poster/packages.config`, `Addons/scraper.TMDB.Data/packages.config`, `Addons/scraper.Data.OMDb/packages.config` | `version="13.0.1"` → `"13.0.3"` (Harmonisierung auf eine Paketversion) |
| `Addons/scraper.Trakttv.Data/scraper.Data.Trakttv.vbproj`, `Addons/generic.Interface.Trakttv/generic.Interface.Trakttv.vbproj` | `<Reference Include="Newtonsoft.Json, Version=12.0.0.0, …">` → `Version=13.0.0.0`; `<HintPath>` `Newtonsoft.Json.12.0.3` → `Newtonsoft.Json.13.0.3` (`lib\net45`) |
| `KodiAPI/KodiAPI.csproj`, `EmberMediaManager/EmberMediaManager.vbproj`, `EmberAPI/EmberAPI.vbproj`, `Addons/scraper.TMDB.Trailer/scraper.Trailer.TMDB.vbproj`, `Addons/scraper.TMDB.Poster/scraper.Image.TMDB.vbproj`, `Addons/scraper.TMDB.Data/scraper.Data.TMDB.vbproj`, `Addons/scraper.Data.OMDb/scraper.Data.OMDb.vbproj` | `<HintPath>` `Newtonsoft.Json.13.0.1` → `Newtonsoft.Json.13.0.3` (`<Reference>`-Version `13.0.0.0` bleibt) |
| `Addons/scraper.Trakttv.Data/app.config`, `Addons/generic.Interface.Trakttv/app.config` | Binding-Redirect `oldVersion="0.0.0.0-12.0.0.0" newVersion="12.0.0.0"` → `oldVersion="0.0.0.0-13.0.0.0" newVersion="13.0.0.0"` |

Binding-Redirect-Prüfung (im Plan verankert, im Umsetzungsschritt zu verifizieren): `Newtonsoft.Json` 13.0.x behält die AssemblyVersion `13.0.0.0`; alle übrigen `app.config`/`App.config` mit `Newtonsoft.Json`-Redirect zielen bereits auf `newVersion="13.0.0.0"` mit `oldVersion`-Range ab `0.0.0.0` (deckt 12.x ab) → **keine weiteren Redirect-Änderungen nötig**. Der `packages\`-Ordner ist per `.gitignore` ausgenommen (Package Restore) — keine Paketdateien werden eingecheckt.

### `.gitattributes` (deklarierte Ausnahme — unvermeidlicher minimaler Eingriff)

- **Neuer Eintrag** (1:1 aus `Softwareschmiede/.gitattributes` übernommen, inkl. Kommentarblock): `.githooks/* text eol=lf` — erzwingt LF-Zeilenenden für alle Dateien unter `.githooks/`. Ohne den Eintrag werden `pre-commit`, `pre-push` und `install-hooks.sh` bei `core.autocrlf=true` (in diesem Klon gesetzt) mit CRLF ausgecheckt, und die Shebang-Zeile schlägt bei der Ausführung über Git Bash fehl — das Akzeptanzkriterium „lokale GitHooks" wäre auf Windows-Klonen nicht erreichbar.
- **Referenz-Abgleich (via `raw.githubusercontent.com/martin-stromberg/Softwareschmiede/main/.gitattributes`):** `.githooks/* text eol=lf` ist der **einzige aktive** Zusatz-Eintrag neben `* text=auto` — es gibt dort keine Einträge für `scripts/*.mjs` oder andere Skript-Pfade (`resolve-release-version.mjs` wird per `node` ausgeführt, nicht per Shebang). Die Ember-`.gitattributes` enthält bereits eigene VS-spezifische `merge`/`diff`-Einträge (`*.sln merge=union` u. a.) — diese bleiben unangetastet; es wird ausschließlich der `.githooks/`-Block ergänzt.
- **Commit-Reihenfolge:** Der Eintrag muss **im selben Commit wie die `.githooks/`-Dateien** (oder früher) landen — `.gitattributes` wirkt beim Checkout, nur so erhalten die Hook-Dateien direkt LF-Enden.

### `README.md` (deklarierte Doku-Ausnahme — Teil der Anforderungsumsetzung)

- **Neuer Abschnitt** „Continuous Integration / Git Hooks" — Hook-Aktivierung und Workflow-Überblick. Die Änderung ist als deklarierte Ausnahme der Additiv-Regel einzuordnen: Sie dokumentiert die geforderte Hook-Aktivierung und gehört damit zur Anforderungsumsetzung; sie wurde implizit vom Anwender akzeptiert (Doku-Schritte sind Teil des Lifecycle).

## Datenbankmigrationen

Keine.

## Validierungsregeln

Die Gates selbst sind die Validierungen der Anforderung:

| Feld / Objekt | Regel | Fehlerfall |
|---------------|-------|------------|
| PR gegen `master` (`verify-pr-source.yml`) | `github.head_ref == "staging"` | `exit 1` mit `::error`-Meldung |
| NuGet-Abhängigkeiten (`security-scan`-Action, Gate 2) | Keine `NU190x`-Warnungen im `nuget restore`-Output | `::error` + Exit 1 (blockierend, `fail-on-vulnerabilities: 'true'`) — nach dem `Newtonsoft.Json`-Update ist der Restore befundfrei |
| Solution-Build (Gate 3 + `build-and-test`) | `msbuild` Exit 0 für `Debug\|x86` bzw. `Release\|x64` | Job schlägt fehl |
| Gestagte Commits (`pre-commit`) | `translation-check.py` Exit 0 (.resx-Header/-Konsistenz) | Commit wird abgebrochen |
| Push (`pre-push`) | Keine NU190x-Befunde im Restore-Output | Push wird abgebrochen (Spiegel des blockierenden CI-Modus) |
| Release-Klassifikation (`resolve-release-version.mjs`) | Tag muss `vX.Y.Z`-Muster erfüllen; Ref-Typ `branch` nur für `master` | Skript wirft Fehler, Job schlägt fehl |

## Konfigurationsänderungen

| Eintrag | Typ | Standardwert | Zweck |
|---------|-----|--------------|-------|
| `Newtonsoft.Json`-Version | `packages.config`-Einträge + `<HintPath>`/`<Reference>` + Binding-Redirects | `12.0.3`/`13.0.1` → `13.0.3` | Behebt NU1903 (GHSA-5crp-9r3c-p9vr); Voraussetzung für den blockierenden Gate-Modus |
| `core.hooksPath = .githooks` | Lokale Git-Konfiguration (pro Klon, via `install-hooks.*`) | nicht gesetzt | Aktiviert die eingecheckten Hooks |
| Workflow-`permissions` | YAML je Workflow | wie Referenz (`contents`, `checks`, `pull-requests`, `issues`; `verify-pr-source` leer) | Minimalrechte für `GITHUB_TOKEN`; keine zusätzlichen Secrets nötig |
| `fail-on-vulnerabilities` (Input der `security-scan`-Action) | String `'true'`/`'false'` | `'true'` | Gate 2 ist von Anfang an blockierend; der Schalter bleibt für künftige Sonderfälle erhalten |
| Cron `0 4 * * 1` | `schedule`-Trigger in `security-scan.yml` | — | Wöchentlicher Scan montags 04:00 UTC |
| Git-Tag `v1.12.0` auf `master`-Tip | Git-/GitHub-Konfiguration (manuell, außerhalb Repo-Inhalt) | nicht gesetzt | Seed-Version für semantic-release; muss auf `origin` liegen, **bevor** die Workflow-Dateien erstmals auf `staging` gemergt werden — der Merge-Push triggert sofort den ersten „Pre-Release"-Lauf, dessen `version`-Job die Tags auswertet; ohne Tag ermittelt semantic-release `1.0.0` (siehe Schritt 13) |
| Branch-Protection `staging`/`master` | GitHub-Repo-Einstellung (außerhalb Repo-Inhalt) | nicht gesetzt | Damit die Gates tatsächlich erzwingbar sind; manueller Schritt (siehe Umsetzungsreihenfolge) |

## Seiteneffekte und Risiken

- **`Newtonsoft.Json`-Update (12.0.3/13.0.1 → 13.0.3):** Bewusste, minimal gehaltene Abweichung vom Upstream-Diff — vom Anwender als fachlich notwendiger Sicherheitsfix in diesem Issue entschieden. Die API ist innerhalb 12.x→13.x kompatibel (Breaking Changes betreffen .NET-Framework-4.8-Konsumenten nicht); die geänderte AssemblyVersion `12.0.0.0` → `13.0.0.0` der zwei Trakttv-Projekte wird durch die angepassten Binding-Redirects abgesichert. Laufzeit-Risiko: gering — die Hauptanwendung lädt bereits heute 13.x (`newVersion="13.0.0.0"`), die Trakttv-Addons wurden bislang per Redirect auf die geladene 12er-Assembly gebunden und binden sich künftig analog auf 13.0.0.0. Verifikation: `nuget restore` muss nach dem Update **ohne** NU190x-Warnung durchlaufen; Release-x64-Build dient als Kompiliernachweis.
- **Keine lauffähigen Tests:** Gates „Tests ausführen" und „Coverage ≥ 70 %" der Referenz entfallen; die Workflows tragen erklärende Kommentare, damit die Lücke dokumentiert ist und bei späterer Reparatur von `EmberAPI_Test` nachgezogen werden kann.
- **Workflow-Aktivierung je Trigger-Typ:** `pull_request`-Workflows (`pr-staging-ci`, `verify-pr-source`) laufen aus dem Workflow-File des synthetischen PR-Merge-Commits — sie sind daher **bereits mit dem einführenden PR aktiv** und benötigen keine Vorab-Präsenz auf dem Basisbranch. `push`-Trigger (`staging-ci` auf `staging`, `sync-staging-with-main` und `release` bei Branch-Push auf `master`) benötigen die Datei auf dem jeweiligen Branch; der Tag-Trigger `v*.*.*` in `release.yml` wertet das Workflow-File am getaggten Commit aus. `schedule`/`workflow_dispatch` (`security-scan.yml`) und `workflow_run` (`staging-to-main-promotion`) laufen nur im Kontext des Default-Branch `master` — diese Automatismen sind erst nach dem Merge auf `master` aktiv. Bis dahin laufen also nicht alle Automatismen — das ist GitHub-Verhalten, kein Planfehler.
- **Seed-Tag-Reihenfolge:** `v1.12.0` muss auf `origin` liegen, **bevor** die Workflow-Dateien erstmals auf `staging` gemergt werden — der Merge-Push triggert bereits den ersten „Pre-Release"-Lauf, dessen `version`-Job die Tag-Liste auswertet; ohne Tag entstehen `v1.0.0-rc.*`-Tags/-Releases, die händisch bereinigt werden müssten. Da der Tag auf den **alten** `master`-Tip zeigt (Tree ohne `release.yml`), löst der Tag-Push selbst keinen Release-Lauf aus. Anders wäre es bei einem Tag auf einen Commit **mit** `release.yml`: Der Tag-Trigger `v*.*.*` würde einen `manual`-Release-Lauf mit stabilem GitHub-Release `v1.12.0` inkl. Assets starten — diese Konstellation wird durch die vorgegebene Reihenfolge „Tag vor erstem Merge" (Schritt 13) ausgeschlossen.
- **`.resx`-Bestandsbefunde möglich:** Prüfungen 2+3 von `translation-check.py` laufen im Referenz-Skript **auf allen** `.resx`-Dateien (142 Stück), nicht nur auf gestagten — bei WinForms-Sprachvarianten (enthalten typischerweise nur übersetzte Keys) sind Konsistenzbefunde wahrscheinlich, und sie würden **jeden** Commit blockieren. Festgelegter Pfad: `--all`-Verifikation in Schritt 3; bei Befunden Befundliste dokumentieren und das Skript auf die vom Commit berührten `.resx`-Pakete eingrenzen (siehe Designentscheidung) — Behebung der Bestandsbefunde ist verworfen (massiver Upstream-Diff).
- **`pre-push` blockiert ab Aktivierung:** Da der Hook NU190x-Befunde hart abbricht, muss das `Newtonsoft.Json`-Update **vor oder zusammen mit** der Hook-Aktivierung erfolgen — sonst blockiert der eigene Push. Deshalb steht das Paketupdate als Schritt 1.
- **npm/Node als neue Toolchain-Abhängigkeit:** `version`-/`prerelease`-/`release`-Jobs benötigen `package.json`/`package-lock.json` im Repo-Root und Node 24 auf dem Runner (`actions/setup-node@v7`). Das ist die größte bewusste Abweichung vom bisherigen Ember-Werkzeugkasten — übernommen, weil die Anforderung die volle Referenzkette inkl. `release.yml` verlangt.
- **Laufzeitkosten:** 32 Legacy-Projekte per MSBuild auf `windows-latest` dauern mehrere Minuten pro Job; Timeouts werden analog zur Referenz gesetzt (`static-checks` 15 min, `build-and-test`/`release` 20–30 min).
- **Kein `upstream`-Remote konfiguriert:** Für die spätere Upstream-Diff-Betrachtung („minimaler Diff") ist das irrelevant für die Dateien selbst, aber für Reviews ggf. nachzurüsten — reine Klient-Konfiguration, kein Repo-Inhalt.
- **Nicht eingebundene Projektdateien** (`EmberAPI_Test`, `Trakttv`, `scraper.EmberCore.XML`, `scraper.TVDB.Data`) werden von der CI nicht gebaut und vom Paketupdate nicht berührt (keine `Newtonsoft.Json`-Referenz in deren `packages.config`) — entspricht dem dokumentierten Solution-Umfang; kein Seiteneffekt.

## Umsetzungsreihenfolge

1. **`Newtonsoft.Json`-Sicherheitsupdate auf 13.0.3**
   - Voraussetzungen: Keine.
   - Beschreibung: In den 9 `packages.config`-Dateien den `Newtonsoft.Json`-Eintrag auf `version="13.0.3"` setzen (2× von `12.0.3`, 7× von `13.0.1` — Liste siehe „Änderungen an bestehenden Klassen"). In den 9 Projektdateien den `<HintPath>` auf `..\packages\Newtonsoft.Json.13.0.3\lib\net45\Newtonsoft.Json.dll` (bzw. `..\..\packages\…` in den Addons) umstellen; in `scraper.Data.Trakttv.vbproj` und `generic.Interface.Trakttv.vbproj` zusätzlich `<Reference Include>` auf `Version=13.0.0.0`. In `scraper.Trakttv.Data/app.config` und `generic.Interface.Trakttv/app.config` den Binding-Redirect auf `oldVersion="0.0.0.0-13.0.0.0" newVersion="13.0.0.0"` anheben; per Grep verifizieren, dass kein weiterer Redirect auf `12.0.0.0` zeigt. Danach `.nuget\NuGet.exe restore "Ember Media Manager.sln"` ausführen — muss ohne NU190x-Warnung durchlaufen — und `msbuild -p:Configuration=Release -p:Platform=x64` als Kompiliernachweis. **Muss vor dem ersten Workflow-Lauf bzw. vor der Aktivierung des blockierenden `pre-push`-Hooks gemergt sein.**

2. **`.gitattributes`: EOL-Schutz für `.githooks/`**
   - Voraussetzungen: Keine. **Muss im selben Commit wie die `.githooks/`-Dateien (Schritt 3) oder früher committet werden** — `.gitattributes` wirkt beim Checkout; nur so werden die Hook-Dateien direkt mit LF-Enden ausgecheckt.
   - Beschreibung: An die bestehende `.gitattributes` den Referenz-Eintrag anhängen (1:1 aus `Softwareschmiede/.gitattributes` übernommen, inkl. Kommentarblock — Abgleich via `raw.githubusercontent.com` durchgeführt: `.githooks/* text eol=lf` ist der einzige aktive Zusatz-Eintrag; Einträge für `scripts/*.mjs` o. ä. existieren in der Referenz nicht und sind nicht nötig, da das Node-Skript per `node` statt per Shebang läuft). Dritte deklarierte Ausnahme der Additiv-Regel (unvermeidlicher minimaler Eingriff — ohne ihn schlägt die Shebang-Zeile der Shell-Hooks unter Git Bash bei `core.autocrlf=true` fehl). Bestehende VS-spezifische `merge`/`diff`-Einträge bleiben unangetastet.

3. **`.githooks/` anlegen**
   - Voraussetzungen: Schritt 2 (selbes Commit wie die `.gitattributes`-Ergänzung); Schritt 1 empfohlen (sonst blockiert `pre-push` sofort); Python 3 und Git lokal vorhanden, lt. Inventar Python 3.13.14 / Git 2.53.
   - Beschreibung: `install-hooks.cmd`, `install-hooks.sh`, `pre-commit` und `translation-check.py` unverändert aus der Referenz übernehmen (Raw-URLs `raw.githubusercontent.com/martin-stromberg/Softwareschmiede/main/.githooks/…`); `pre-push` mit gleichem Aufbau, aber `.nuget\NuGet.exe restore "Ember Media Manager.sln"` + NU190x-Auswertung mit Exit 1 bei Befund statt `dotnet format`. Anschließend lokale Verifikation **vor** der Hook-Aktivierung: `python .githooks/translation-check.py --all` einmalig laufen lassen. **Festgelegter Umgang mit dem Ergebnis:** befundfrei → Skript bleibt verbatim, `install-hooks.cmd` ausführen. `.resx`-Bestandsbefunde vorhanden → Befundliste dokumentieren (Prüfprotokoll/Commit-Hinweis) und das Skript wie in den Designentscheidungen festgelegt auf die vom Commit berührten `.resx`-Pakete eingrenzen (dokumentierte Ember-Abweichung); Behebung der Bestandsbefunde ist verworfen. Danach `install-hooks.cmd` ausführen und Probe-Commit.

4. **Composite Action `security-scan`**
   - Voraussetzungen: Keine.
   - Beschreibung: `.github/actions/security-scan/action.yml` anlegen — Inputs `solution-path` (Default `Ember Media Manager.sln`), `artifact-name`, `fail-on-vulnerabilities` (**Default `'true'`**); führt `.nuget\NuGet.exe restore <solution>` aus, tee-t die Ausgabe in `vulnerable-packages-scan.log`, wertet `NU190\d`-Muster aus (`::error` + Exit 1 bei `'true'`, sonst `::warning`), lädt das Log via `actions/upload-artifact@v7` hoch.

5. **Composite Action `build-and-package`**
   - Voraussetzungen: Keine.
   - Beschreibung: `.github/actions/build-and-package/action.yml` anlegen — Inputs `release-version`/`release-tag`; `microsoft/setup-msbuild@v2`, `nuget restore`, `msbuild -p:Configuration=Release -p:Platform=x64`, Kopie `EmberMM - Release - x64\*` → `publish/`, `version.json` schreiben, Verify (`publish/Ember Media Manager.exe` + `version.json` vorhanden), `Compress-Archive` → `release.zip`, `update.json` im Referenzschema (version/releaseNotes/publishedAt/assets mit sha256/sizeBytes/assetUrl). Kein NSIS-Installer-Schritt (entschiedene Nicht-Anforderung).

6. **semantic-release-Root-Artefakte**
   - Voraussetzungen: Keine (alle Dateien aus der Referenz kopierbar; kein lokales Node/npm nötig, da der Lockfile mitkopiert wird).
   - Beschreibung: `package.json` (Dependencies unverändert, `name` auf das Projekt anpassen), `package-lock.json` aus der Referenz kopieren und die `name`-Felder an `package.json` angleichen (damit `npm ci` konsistent bleibt), `release.config.js` mit `branches: ["master"]` übernehmen, `scripts/resolve-release-version.mjs` mit `AUTOMATIC_RELEASE_BRANCHES = ["master"]` und `expectedReleaseAssetNames = ["release.zip", "update.json"]` übernehmen.

7. **Workflow `pr-staging-ci.yml`**
   - Voraussetzungen: Schritt 4 (`security-scan`-Action muss existieren).
   - Beschreibung: Referenzdatei übernehmen; `main` → `master`; `setup-dotnet`/`dotnet …` ersetzen durch `setup-msbuild`/`nuget restore`/`msbuild`; Format-Gate (Gate 1) entfernen; Security-Scan-Aufruf mit `fail-on-vulnerabilities: 'true'`; Test-/Coverage-Schritte (Gates 4/5) durch Release-x64-Build + Build-Log-Artefakt ersetzen; Kommentare die Abweichungen dokumentieren.

8. **Workflow `staging-ci.yml` (Anzeigename „Pre-Release")**
   - Voraussetzungen: Schritte 4, 5 und 6.
   - Beschreibung: Wie Schritt 7, zusätzlich `version`-Job (Node 24, `npm ci`, `semantic-release --dry-run --branches staging`, RC-Tag-Ermittlung) und `prerelease`-Job (`build-and-package` + `gh release create --prerelease --generate-notes`); Security-Scan-Aufruf mit `fail-on-vulnerabilities: 'true'`.

9. **Workflows `verify-pr-source.yml`, `sync-staging-with-main.yml`, `staging-to-main-promotion.yml`**
   - Voraussetzungen: Keine (logisch gekoppelt an Schritt 8: Der `workflow_run`-Trigger referenziert den Anzeigenamen „Pre-Release" und muss im selben Commit konsistent sein).
   - Beschreibung: Jeweils nahezu verbatim übernehmen; `main` → `master` in Triggern, `git fetch`, `gh pr create --base`, Label-Texten und Fehlermeldungen.

10. **Workflow `security-scan.yml`**
    - Voraussetzungen: Schritt 4.
    - Beschreibung: Referenz übernehmen; `setup-dotnet`/`dotnet restore` entfallen (die Action führt den Restore selbst aus); `solution-path: "Ember Media Manager.sln"`, `artifact-name: vulnerable-packages-scan`, `fail-on-vulnerabilities: 'true'`.

11. **Workflow `release.yml`**
    - Voraussetzungen: Schritte 5 und 6.
    - Beschreibung: Referenz übernehmen; Trigger `branches: [master]` + `tags: ['v*.*.*']`; `setup-dotnet` entfällt, `setup-msbuild` ergänzen; Restore/Build via `nuget`/`msbuild`; die vier Release-Gate-Test-Schritte entfallen (Kommentar verweist auf fehlende Testsuite); die drei Release-Pfade (`npm run release`, `gh release create`, `gh release upload --clobber`) unverändert.

12. **README-Abschnitt ergänzen**
    - Voraussetzungen: Schritt 3 (dokumentiert die Hook-Installation).
    - Beschreibung: Kurzer Abschnitt „Continuous Integration / Git Hooks": einmalige Aktivierung via `.githooks/install-hooks.cmd` bzw. `.sh`, Überblick über die Workflows. Eine der drei entschiedenen Ausnahmen von der Additiv-Regel — als Teil der Anforderungsumsetzung (Dokumentation der Hook-Aktivierung) deklariert und vom Anwender implizit akzeptiert.

13. **Seed-Tag `v1.12.0` setzen — vor dem ersten Merge der Workflow-Dateien (manuell, außerhalb des Repos)**
    - Voraussetzungen: Keine Repo-Voraussetzung. **Zeitliche Bedingung: Der Tag muss auf `origin` liegen, bevor der Task-Branch erstmals auf `staging` gemergt wird** — der Merge-Push triggert sofort den ersten „Pre-Release"-Lauf, dessen `version`-Job die Tag-Liste auswertet. Erfolgt idealerweise direkt nach dem Push des Task-Branches / vor dessen Merge.
    - Beschreibung: `git tag v1.12.0 <master-tip>` + `git push origin v1.12.0` — setzt die Basisversion für semantic-release (passt zu `EMM_REVISION=1.12.0` in `BuildSetup/`; Tag ist von `staging` aus erreichbar, da `staging` `master` vollständig enthält). **Seiteneffekt dokumentiert:** Da der Tag auf den alten `master`-Tip zeigt (Tree ohne `release.yml`), löst der Tag-Push **keinen** Release-Lauf aus — GitHub wertet das Workflow-File am getaggten Commit aus. Hingegen würde ein `v*.*.*`-Tag auf einen Commit **mit** `release.yml` sofort einen `manual`-Release-Lauf mit stabilem GitHub-Release auslösen; die Reihenfolge „Tag vor erstem Merge" schließt diese Konstellation aus und ist deshalb fest vorgegeben.

14. **GitHub-Konfiguration (manuell, außerhalb des Repos)**
    - Voraussetzungen: Schritte 1–12 sind committet; Schritt 13 abgeschlossen. Sinnvoll nach dem ersten Merge auf `staging`/`master`, damit die Required-Check-Namen bekannt sind.
    - Beschreibung: (a) Branch-Protection für `staging` und `master` einrichten (Required Checks = die Gate-Jobs; für `master` zusätzlich „Verify PR Source"). (b) Sicherstellen, dass GitHub Actions im Fork erlaubt sind.

15. **Live-Verifikation**
    - Voraussetzungen: Schritte 1–12 committet und auf dem Task-Branch gepusht; Schritt 13 (Seed-Tag) liegt auf `origin`, **bevor** der PR gemergt wird.
    - Beschreibung: PR des Task-Branches gegen `staging` öffnen → `PR CI for Staging` läuft sofort aus dem PR-Merge-Commit (`pull_request`-Workflows benötigen keine Vorab-Präsenz auf dem Basisbranch): `is_backmerge=false`, beide Gate-Jobs grün (Gate 2 befundfrei dank Schritt 1). Nach Merge auf `staging`: „Pre-Release"-Lauf (erwartete erste Version `v1.12.x-rc.1` auf Basis des Seed-Tags) und ggf. Promotion-PR beobachten. Lokal: Hook-Aktivierung und Probe-Commit/Push.

## Tests

### Neue Tests

Keine. Die Änderung betrifft ausschließlich CI/CD-Infrastruktur plus einen mechanischen Paketversion-Bump; es existiert keine Testinfrastruktur für Workflow-Dateien im Repository, und die einzige vorhandene Testsuite (`EmberAPI_Test`) baut nicht (nachgewiesen in `inventory/tests.md`). Der Funktionsnachweis erfolgt über die Live-Ausführung der Workflows (Umsetzungsschritt 15), den lokalen Hook-Verifikationsschritt (Umsetzungsschritt 3) sowie den befundfreien `nuget restore` + Release-x64-Build nach dem Paketupdate (Umsetzungsschritt 1).

### Betroffene bestehende Tests

Keine.

### E2E-Tests (primärer Funktionsnachweis)

Keine erforderlich — Begründung: Die Anforderung berührt keinen Benutzerfluss der Anwendung. Es gibt keine UI- oder nutzeraktionserreichbare Funktionalität in `Ember Media Manager`, die sich ändert; sämtliche neuen Artefakte wirken außerhalb der Anwendung (Git-Hooks auf Entwicklerrechnern, GitHub-Actions-Läufe), und das Paketupdate ändert kein Anwendungsverhalten (API-kompatible Version, Assembly-Binding per Redirect abgesichert). Zusätzlich existiert im Repository kein E2E-Test-Framework und keine ausführbare Testbasis. Der nächstliegende „End-to-End"-Nachweis ist die beobachtete Ausführung der Pipeline selbst (PR → Gates → Staging-CI → Promotion/Back-Merge), die als Umsetzungsschritt 15 verankert ist.

## Offene Punkte

Keine.
