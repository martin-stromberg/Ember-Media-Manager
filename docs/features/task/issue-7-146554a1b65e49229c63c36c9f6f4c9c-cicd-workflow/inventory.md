# Bestandsaufnahme: CI/CD-Workflow (Issue #7)

Bestandsaufnahme des Fork-Repositorys `martin-stromberg/Ember-Media-Manager` (Fork von `DanCooper/Ember-MM-Newscraper`) bezogen auf die Anforderung, lokale GitHooks und einen GitHub-Actions-CI-Workflow nach dem Vorbild des Referenz-Repositorys `martin-stromberg/Softwareschmiede` einzuführen. Analysiert wurden der Automatisierungs-Ist-Zustand, die Build-Toolchain, der Test-Ausgangszustand sowie die Referenzimplementierung.

## Zusammenfassung

- **Keinerlei CI/CD- oder Hook-Infrastruktur vorhanden**: Es gibt weder `.github/` noch `.githooks/` im Repository; `core.hooksPath` ist nicht gesetzt; es existieren keine YAML-Workflows, kein `.editorconfig`, kein `scripts/`-Verzeichnis und keine anderen CI-Systeme (AppVeyor, Travis, Azure Pipelines). Alle neuen Artefakte wären rein additive Dateien.
- **Branching vorhanden**: Default-Branch ist `master` (nicht `main`), dazu `staging` (1 Commit voraus, enthält `master` vollständig) und der Task-Branch. Kein `upstream`-Remote konfiguriert, keine Git-Tags vorhanden.
- **Build-Toolchain ist legacy, aber dokumentiert und lauffähig**: `Ember Media Manager.sln` (VS2017-Format) mit 33 Einträgen = 32 Projekte (30 VB.NET, 2 C#: `KodiAPI`, `TVDB`) + 1 Solution-Folder. Klassisches `packages.config`-NuGet-Modell mit `.nuget/NuGet.exe` 6.14.0; `Directory.Build.props` liefert .NET-4.8-Referenzassemblys per `FrameworkPathOverride`. Restore (`nuget restore`, 58 Pakete) wurde erfolgreich verifiziert — NuGet 6.14 meldet dabei bereits `NU1903`-Vulnerability-Warnungen für `packages.config`-Projekte (Befund: `Newtonsoft.Json` 12.0.3, GHSA-5crp-9r3c-p9vr).
- **Nicht-eingebundene Projektdateien**: `EmberAPI_Test/EmberAPI_Test.vbproj`, `Trakttv/Trakttv.csproj`, `Addons/scraper.EmberCore.XML/scraper.EmberCore.XML.vbproj` und `Addons/scraper.TVDB.Poster/scraper.TVDB.Data.vbproj` sind **nicht** Teil der Solution.
- **Test-Ausgangszustand: keine ausführbaren Tests.** Das einzige Testprojekt `EmberAPI_Test` (MSTest v1, 10 Testklassen, ~204 `TestMethod`-Attribute) baut nicht: Die referenzierte Projektdatei `..\UnitTests\UnitTests.vbproj` fehlt im Repository (MSB9008) und liefert 203 Kompilierfehler `BC30002` („Der Typ `UnitTest` ist nicht definiert"). Details und Nachweise: [Tests](inventory/tests.md).
- **Referenz-Repository vollständig inventarisiert**: `martin-stromberg/Softwareschmiede` enthält exakt das in der Anforderung genannte Set — 7 Workflows, 2 Composite Actions (`security-scan`, `build-and-package`), 5 GitHook-Dateien sowie die nötigen Root-Artefakte (`package.json`/`release.config.js` für semantic-release, `scripts/resolve-release-version.mjs`). Technologie-Basis dort: .NET 10, `Softwareschmiede.slnx`, `dotnet`-CLI — durchgängig nicht 1:1 auf das Legacy-Format übertragbar. Details: [Referenz Softwareschmiede](inventory/referenz-softwareschmiede.md).
- **Pattern-Collection nicht abrufbar**: `https://github.com/martin-stromberg/Pattern-Collection` sowie `CI-Workflows/instructions.md` liefern HTTP 404 (privat oder nicht vorhanden). Die Original-Vorgabe ist damit nicht einsehbar; Inventar-Befund dokumentiert.
- **Versionierung/Release heute**: manuell — `changes.log` (datumsbasiert), `AssemblyInfo` (`1.11.1.0` in `EmberMediaManager`), `BuildSetup/` (NSIS-Installer-Skripte mit hartcodierter `EMM_REVISION=1.12.0`, Transifex-Download via `tx.exe`). Kein semantic-release, keine Tags.

## Details

- [CI/CD-Ist-Zustand und Git-Konfiguration](inventory/ci-cd-ist-zustand.md)
- [Build-Toolchain, Solution und Versionierung](inventory/build-toolchain.md)
- [Referenz-Repository Softwareschmiede (und Pattern-Collection-Befund)](inventory/referenz-softwareschmiede.md)
- [Tests und Test-Ausgangszustand](inventory/tests.md)
