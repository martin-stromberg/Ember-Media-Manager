# Übersetzte Anforderung: CI/CD-Workflow (Issue #7)

## Fachliche Zusammenfassung

Das Fork-Repository (`martin-stromberg/Ember-Media-Manager`, Fork von `DanCooper/Ember-MM-Newscraper`) soll um eine zweistufige Qualitätssicherung erweitert werden: (1) lokale GitHooks, die Prüfungen bereits vor Commit/Push auf dem Entwicklerrechner ausführen, und (2) ein GitHub-Actions-basierter CI-Workflow gemäß der Vorgabe aus `martin-stromberg/Pattern-Collection` (`CI-Workflows/instructions.md`). Als Referenzimplementierung dient das Repository `martin-stromberg/Softwareschmiede`, dessen Aufbau möglichst 1:1 übernommen werden soll. Randbedingung: Das Basis-/Upstream-Repository bleibt unangetastet — alle Änderungen erfolgen ausschließlich additiv im Fork, sodass der Diff zum Upstream minimal bleibt.

## Betroffene Klassen und Komponenten

Es sind keine Datenmodell-, Logik- oder UI-Klassen betroffen. Betroffen sind ausschließlich neue Infrastruktur-Artefakte im Repository-Root:

### Neu zu erstellende Artefakte

- `.githooks/` (neu, Referenz: Softwareschmiede):
  - `install-hooks.cmd` / `install-hooks.sh` — einmalige Aktivierung pro Klon via `git config core.hooksPath .githooks`
  - `pre-commit` — lokale Prüfungen vor dem Commit (in Softwareschmiede: `translation-check.py` für `.resx`-Lokalisierungskonsistenz; Übertragbarkeit auf Ember prüfen, da das dortige Skript auf `IStringLocalizer`-Muster in `.cs`/`.razor`-Dateien zugeschnitten ist)
  - `pre-push` — spiegelt den Format-/Lint-Schritt der PR-CI lokal
- `.github/workflows/` (neu, Referenz-Set aus Softwareschmiede):
  - `pr-staging-ci.yml` — CI bei Pull Requests gegen `staging` (Back-Merge-Erkennung, `static-checks`-Job, `build-and-test`-Job)
  - `staging-ci.yml` — CI bei Push auf `staging` (gleiche Gates plus Versions-/Release-Kette)
  - `verify-pr-source.yml` — erlaubt PRs gegen den Hauptbranch nur von `staging`
  - `sync-staging-with-main.yml` — automatischer Back-Merge-PR Hauptbranch → `staging` nach Promotion
  - `staging-to-main-promotion.yml` — Promotion-PR `staging` → Hauptbranch nach erfolgreicher Staging-CI
  - `security-scan.yml` — wöchentlicher geplanter Vulnerability-Scan der NuGet-Abhängigkeiten
  - `release.yml` — Release-Erzeugung auf dem Hauptbranch
- `.github/actions/security-scan/` (neu) — Composite Action für den Paket-Vulnerability-Scan (in `pr-staging-ci.yml`, `staging-ci.yml` und `security-scan.yml` wiederverwendet)
- ggf. `.editorconfig` (neu) — falls das Format-Gate (`dotnet format --verify-no-changes`) übernommen werden soll

### Bestehende Artefakte (nur lesend relevant, nicht zu ändern)

- `Ember Media Manager.sln` — Solution im VS2017-Format mit 33 Projekten (überwiegend VB.NET-WinForms, zwei C#-Projekte: `KodiAPI`, `TVDB`), Zielframework .NET Framework 4.8, Legacy-Projektformat (nicht SDK-Style)
- `Directory.Build.props` — stellt .NET-4.8-Referenzassemblys über `Microsoft.NETFramework.ReferenceAssemblies.net48` per `FrameworkPathOverride` bereit; ein Build benötigt daher kein installiertes .NET-4.8-Developer-Pack, aber MSBuild/Visual Studio Build Tools auf einem Windows-Runner
- `.nuget/NuGet.exe`, `.nuget/NuGet.targets`, `NuGet.Config` sowie `packages.config` in allen Projekten — klassisches NuGet-Restore-Modell (`nuget restore`, kein `dotnet restore`)
- `EmberAPI_Test/EmberAPI_Test.vbproj` — MSTest-Testprojekt, aktuell **nicht** Teil der Solution, referenziert `Microsoft.VisualStudio.QualityTools.UnitTestFramework` (GAC, VS2010) und ein nicht existierendes `UnitTests`-Projekt → in dieser Form nicht CI-tauglich
- Branching: Default-Branch ist `master` (nicht `main` wie in Softwareschmiede), dazu `staging` und Task-Branches `task/issue-*`

### Tests

Keine neuen Testklassen erforderlich. Ob bzw. wie `EmberAPI_Test` in die CI eingebunden werden kann, ist eine offene Frage (siehe unten).

## Implementierungsansatz

1. **GitHooks**: Verzeichnis `.githooks/` analog zu Softwareschmiede anlegen; Aktivierung über `core.hooksPath`. Inhalte aus `Pattern-Collection` übernehmen (soweit abrufbar), sonst an der Softwareschmiede-Variante orientieren und auf Ember-Gegebenheiten anpassen (VB.NET, .NET Framework, `packages.config`).
2. **CI-Workflows**: Das Workflow-Set aus Softwareschmiede möglichst unverändert übernehmen. Zwingende Anpassungen:
   - Branch-Name `main` → `master` (Default-Branch des Forks) in allen Triggern und Back-Merge-/Promotion-Logiken.
   - Toolchain ersetzen: `dotnet restore`/`dotnet build`/`dotnet test` (.slnx, .NET 10) → `nuget restore` + MSBuild auf `windows-latest`; Testausführung falls gewünscht über `vstest.console.exe` (MSTest), da `dotnet test` Legacy-.vbproj nicht unterstützt.
   - Format-Gate (`dotnet format`) ist auf das Legacy-Projektformat nicht anwendbar — Entscheidung offen, ob es entfällt oder durch Einführung einer `.editorconfig` ersetzt wird.
   - Security-Scan: `dotnet list package --vulnerable` unterstützt `packages.config` nicht — alternative Umsetzung oder Weglassen klären.
   - Coverage-Gate (70 %-Zeilenabdeckung via ReportGenerator) ist ohne lauffähige Tests nicht erreichbar — vermutlich entfällt es.
3. **Upstream-Neutralität**: Alle Änderungen sind rein additive Dateien unter `.githooks/` und `.github/`; keine bestehende Quell- oder Projektdatei wird modifiziert, sodass `git diff upstream` nur neue Pfade enthält. Damit ist das Akzeptanzkriterium „Basis-Repository bleibt unangetastet" erfüllt und die Abweichung zum Upstream minimal.

## Konfiguration

- **Lokal**: einmalige Hook-Aktivierung pro Klon über `.githooks/install-hooks.cmd` bzw. `install-hooks.sh` (setzt `core.hooksPath`); keine Anwendungseinstellungen betroffen.
- **GitHub Actions**: Workflow-Permissions werden in den YAML-Dateien deklariert (Referenz: `contents: read/write`, `checks: write`, `pull-requests: write`, `issues: write`); es werden voraussichtlich keine zusätzlichen Secrets benötigt (`GITHUB_TOKEN` genügt). Ggf. Branch-Protection-Regeln für `staging`/`master` auf GitHub-Seite ergänzen (außerhalb des Repository-Inhalts).

## Offene Fragen

1. **Pattern-Collection nicht abrufbar**: `https://github.com/martin-stromberg/Pattern-Collection` (inkl. `CI-Workflows/instructions.md`) liefert HTTP 404 — das Repository ist privat oder nicht vorhanden. Die konkreten GitHooks und die CI-Vorgabe sind daher nicht im Original einsehbar. Annahme: Softwareschmiede ist bereits eine vollständige Umsetzung dieser Vorgabe; die Orientierung daran erfüllt die Absicht. Zu klären: Zugang zum Pattern-Collection-Repo oder schriftliche Bestätigung der Annahme.
2. **Branch-Name `master` vs. `main`**: Sollen die Workflows auf `master` gemappt werden, oder soll der Default-Branch in `main` umbenannt werden, um die Abweichung zur Referenz zu minimieren?
3. **Format-Gate**: Soll eine `.editorconfig` eingeführt und `dotnet format` (soweit für Legacy-VB.NET nutzbar) übernommen werden, oder entfällt das Gate? Eine `.editorconfig` wäre ebenfalls eine additive Datei ohne Upstream-Konflikt.
4. **Testausführung in CI**: `EmberAPI_Test` ist nicht Teil der Solution, referenziert ein fehlendes `UnitTests`-Projekt und eine GAC-MSTest-Referenz. Soll das Testprojekt im Rahmen dieses Issues repariert/eingebunden werden, oder beschränkt sich die CI vorerst auf Build- und Static-Checks?
5. **Security-Scan unter `packages.config`**: Die Referenz nutzt `dotnet list package --vulnerable` (PackageReference-only). Alternative für `packages.config` (z. B. NuGet-Tooling, OWASP Dependency-Check) oder Weglassen?
6. **Umfang der Workflow-Kette**: Soll das volle Set übernommen werden (PR-CI, Staging-CI, PR-Source-Verifizierung, Back-Merge, Promotion, Release, Security-Scan) oder nur der CI-Teil (PR-CI + Staging-CI)? `release.yml` setzt u. a. `semantic-release`/Node.js voraus — eine neue Toolchain-Abhängigkeit, die zum bisherigen Ember-Versionierungsschema (`changes.log`, `BuildSetup`) passt oder nicht, ist zu entscheiden.
7. **pre-commit-Inhalt**: Das Softwareschmiede-`pre-commit`-Skript prüft `IStringLocalizer`-/.resx-Konsistenz in C#/.razor-Dateien — für ein VB.NET-WinForms-Projekt weitgehend irrelevant. Welche lokale Prüfung ist für Ember gewünscht (z. B. .resx-Header-/Konsistenzprüfung ohne Localizer-Scan, Whitespace-/Encoding-Checks)?
