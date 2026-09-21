# Bestandsaufnahme: Tests und Test-Ausgangszustand

## Test-Ausgangszustand vor der Umsetzung

- **Zeitpunkt (mit Zeitzone):** 2026-09-21, ca. 19:45–19:55 Uhr (UTC+02:00, Europe/Berlin)
- **Branch und Commit-ID:** `task/issue-23-b7ffd7bda3864f86931d16fb5ed5404d-versionsnummer`, Commit `f3038a7ac76d60a2bdf7c795868a2024a8fd28f0` (committed 2026-09-21T19:09:29+02:00)
- **Uncommittete Änderungen im getesteten Stand:** nur ungetrackte Verzeichnisse `.agents/` und `docs/features/task/issue-23-b7ffd7bda3864f86931d16fb5ed5404d-versionsnummer/` (diese Bestandsaufnahme selbst). Die durch die Baseline-Läufe erzeugten Artefakte (`packages/`, `EmberMM - Debug - x86/`, `EmberAPI/obj/` u. a.) sind per `.gitignore` ausgeblendet und verändern den getesteten Quellstand nicht.
- **Testumgebung und Runtime-/SDK-Versionen:** Windows 11, Git-Bash (MINGW); `dotnet` SDK 10.0.401; MSBuild 18.10.1.42706 (`C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe`, Visual Studio Community 18); Node.js v24.15.0; npm 11.10.0; PowerShell 7.6.6; .NET Framework 4.8-Referenzassemblys via `Directory.Build.props` + NuGet-Paket `Microsoft.NETFramework.ReferenceAssemblies.net48`.
- **Ermittelte Testsuiten und Quellen der Testbefehle:**
  - `README.md` (Abschnitt „Tests"): einziges Testprojekt `EmberAPI_Test` ist „not part of the solution and does not build" — „There are no executable automated tests at the moment".
  - `.github/workflows/staging-ci.yml` (Z. 111–115) und `pr-staging-ci.yml` (Z. 113–118): CI-Kommentar belegt, dass Test-Gates bewusst entfallen, weil `EmberAPI_Test` nicht Teil der Solution ist und nicht baut (fehlendes `UnitTests`-Projekt, MSTest-v1-GAC-Referenz).
  - `release.yml` (Z. 87–99): als Sicherheitsnetz dient nur ein Compile-Gate (`msbuild` Debug x86), keine Tests.
  - `package.json`: kein `test`-Skript; für `scripts/resolve-release-version.mjs` existieren keine Testdateien (`*.test.mjs`/`*.spec.*` nicht vorhanden).
  - `Ember Media Manager.sln`: enthält 33 Projekt-Einträge (inkl. Solution-Folder `Addons`); `EmberAPI_Test` und `UnitTests` sind nicht darin.

## Testläufe

Arbeitsverzeichnis aller Kommandos: Repository-Root `D:\Repositories\softwareschmiede\b7ffd7bd-a386-4f86-931d-16fb5ed5404d`.

| Lauf | Befehl inkl. Filter | Arbeitsverzeichnis | Exit-Code | Erfolgreich | Fehlgeschlagen | Übersprungen | Nachweis |
|------|---------------------|--------------------|-----------|-------------|----------------|--------------|----------|
| 1 | `./.nuget/NuGet.exe restore "Ember Media Manager.sln"` | Repo-Root | 0 | — (Restore, kein Testlauf) | — | — | [nuget-restore.log](test-results/nuget-restore.log) |
| 2 | `dotnet test "Ember Media Manager.sln"` | Repo-Root | 0 | 0 | 0 | unbekannt — kein Testprojekt entdeckt/ausgeführt | [dotnet-test.log](test-results/dotnet-test.log) |
| 3 | `MSBuild.exe EmberAPI_Test\EmberAPI_Test.vbproj -p:Configuration=Debug -p:Platform=x86 -v:m` | Repo-Root | 1 | 0 | 0 (kein Test lief) | gesamte Suite nicht ausführbar (Build-Fehler) | [msbuild-emberapi-test-x86.log](test-results/msbuild-emberapi-test-x86.log) |

Anmerkungen zu den Läufen:

- **Lauf 1** (Voraussetzung): Restore erfolgreich, „Installiert: 58 Paket(e) auf packages.config projects". NuGet meldete auch Vulnerability-Metadata-Downloads, keine NU1901–1904-Fehler im Log.
- **Lauf 2**: `dotnet test` ist auf dem Legacy-Format nicht funktionsfähig — die Ausgabe besteht nur aus der Restore-Phase („Keine Aktion erforderlich. Keines der angegebenen Projekte enthält wiederherzustellende Pakete."). Es wurde kein Test kompiliert, entdeckt oder ausgeführt; Exit-Code 0 ist kein Testnachweis.
- **Lauf 3**: `EmberAPI_Test` kompiliert nicht. Das eingebundene Dependency-Projekt `EmberAPI` baute dabei erfolgreich (`EmberMM - Debug - x86\EmberAPI.dll` wurde erzeugt); nur die Testquellen schlagen fehl.

## Nachgewiesene bestehende Testfehler

Keine — es wurde kein einziger Test ausgeführt (Lauf 3 scheitert an der Kompilierung, nicht an Assertions). Es existiert daher weder ein nachgewiesener `Failed`-Test noch ein TRX-/Report-Artefakt.

## Testlücken und Ausführungsprobleme

- **Gesamtes Testprojekt `EmberAPI_Test` nicht ausführbar** (12 `[TestClass]` / 204 `[TestMethod]`). Build-Fehler in Lauf 3: **203× `BC30002` „Der Typ … ist nicht definiert"** — davon 141× `UnitTest`, 41× `IntegrationTest`, 20× `InteractiveTest`, 1× `Trailers`. Ursache: `ProjectReference` auf `..\UnitTests\UnitTests.vbproj` (`EmberAPI_Test/EmberAPI_Test.vbproj` Z. 183–186); das Verzeichnis `UnitTests/` fehlt im Repository (MSBuild-Warnung `MSB9008`: „Das referenzierte Projekt ..\UnitTests\UnitTests.vbproj ist nicht vorhanden"). Zusätzlich GAC-Referenz auf `Microsoft.VisualStudio.QualityTools.UnitTestFramework` 10.0 (MSTest v1, Z. 80) sowie NLog-Versionskonflikt (MSB3277, 3.1.0.0 vs. 4.0.0.0).
- Für den betroffenen Bereich dieser Anforderung (Versionsstempelung im Build, `AssemblyInfo.vb`, `Master.Version`, Update-Check) existieren **keine** Testmethoden. Lediglich `EmberAPI_Test/Test_clsAPICommon.vb` Z. 132–141 (`Functions_EmberAPIVersion`) prüft thematisch nah, dass `Functions.EmberAPIVersion()` einen vierteiligen Versionsstring liefert — nicht kompilierbar/ausführbar.
- Keine JS-/Node-Tests für `scripts/resolve-release-version.mjs` oder die Workflow-Logik; CI-YAML wird nicht lokal getestet.

## Testklassen (Quelltext-Inventar, nicht ausführbar)

Projekt `EmberAPI_Test` (MSTest v1, `<TestClass>`/`<TestMethod>`-Attribute):

| Datei | TestClasses | TestMethods |
|-------|-------------|-------------|
| `EmberAPI_Test/Test_clsAPICommon.vb` | 1 | 40 |
| `EmberAPI_Test/Test_clsAPIErrorLog.vb` | 1 | 14 |
| `EmberAPI_Test/Test_clsAPIFileUtils.vb` | 3 | 10 |
| `EmberAPI_Test/Test_clsAPIHTTP.vb` | 1 | 8 |
| `EmberAPI_Test/Test_clsAPIImageUtils.vb` | 1 | 44 |
| `EmberAPI_Test/Test_clsAPIImages.vb` | 1 | 2 |
| `EmberAPI_Test/Test_clsAPINumUtils.vb` | 1 | 2 |
| `EmberAPI_Test/Test_clsAPIStringUtils.vb` | 1 | 65 |
| `EmberAPI_Test/Test_clsTrailers.vb` | 1 | 6 |
| `EmberAPI_Test/Test_clsYouTube.vb` | 2 | 13 |
| **Summe** | **12** | **204** |

Relevant für diese Anforderung:

### `Test_clsAPICommon` (`EmberAPI_Test/Test_clsAPICommon.vb`)

- `Functions_EmberAPIVersion` (Z. 132–141) — prüft, dass `Functions.EmberAPIVersion()` einen String mit genau 4 durch `.` getrennten Teilen liefert. **Hinweis für die Umsetzung:** würde `AssemblyFileVersion` von `EmberAPI` z. B. auf einen SemVer-String mit Suffix gestempelt, würde dieser Test (sofern repariert) das Viererteiler-Format weiter verlangen.

Keine weiteren Testklassen berühren `Master.Version`, `AssemblyInfo.vb` oder den Release-Prozess.

## Hilfsmethoden

- Fehlendes Projekt `UnitTests/` (nicht im Repo) — stellte offenbar die Attribut-Typen `UnitTest`, `IntegrationTest`, `InteractiveTest` und eine Klasse `Trailers` bereit, die sämtliche Testdateien importieren (`Imports UnitTests`, z. B. `Test_clsAPIImageUtils.vb` Z. 26). Ohne dieses Hilfsprojekt ist keine Testmethode kompilierbar.
