# Tests und Test-Ausgangszustand

## Test-Ausgangszustand vor der Umsetzung

- **Zeitpunkt:** 2026-09-20, 15:34–15:40 Uhr +0200 (13:34–13:40 UTC)
- **Branch und Commit-ID:** `task/issue-7-146554a1b65e49229c63c36c9f6f4c9c-cicd-workflow` @ `08279a2435c68ee37c2fc857eaa0f6fc3a6c07a2` („Backmerge (#6)", identisch mit `staging`-Tip)
- **Uncommittete Änderungen im getesteten Stand:** nur untracked Dateien: `.agents/` und `docs/features/task/issue-7-…-cicd-workflow/` (diese Dokumentation); durch die Läufe erzeugte, gitignorierte Verzeichnisse `packages/` und `EmberMM - Debug - x86/`
- **Testumgebung und Runtime-/SDK-Versionen:** Windows, Visual Studio Community 2026 (18.10.1), MSBuild 18.10.1.42706, `vstest.console.exe` vorhanden, NuGet CLI 6.14.0.116 (`.nuget/NuGet.exe`), dotnet SDK 10.0.401, Python 3.13.14, Git 2.53.0.windows.2
- **Ermittelte Testsuiten und Quellen der Testbefehle:** Es existiert genau eine Testsuite: `EmberAPI_Test/` (MSTest v1, Legacy-`.vbproj`). Sie ist **nicht** Teil der `Ember Media Manager.sln` (Projekt-GUID `{BFDAF0E3-…}` nicht in der `.sln` enthalten) und es gibt keinen dokumentierten oder automatisierten Testbefehl. `README.md` sagt ausdrücklich: „It is currently **not part of the solution** and does not build … There are no executable automated tests at the moment." Als Testbefehl wurde daher der Projekt-Build mit MSBuild (Voraussetzung für `vstest.console.exe`) angesetzt; `dotnet test` unterstützt das Legacy-Format nicht.

### Testläufe

| Lauf | Befehl inkl. Filter | Arbeitsverzeichnis | Exit-Code | Erfolgreich | Fehlgeschlagen | Übersprungen | Nachweis |
|------|--------------------|--------------------|-----------|-------------|----------------|--------------|----------|
| 1 – NuGet-Restore (Voraussetzung) | `.nuget\NuGet.exe restore "Ember Media Manager.sln"` | Repo-Root | 0 | – (kein Testlauf; 58 Pakete installiert, NU1903-Warnung `Newtonsoft.Json` 12.0.3) | – | – | [nuget-restore.log](test-results/nuget-restore.log) |
| 2 – Testprojekt-Build | `MSBuild.exe EmberAPI_Test/EmberAPI_Test.vbproj -p:Configuration=Debug -p:Platform=x86 -v:m` | Repo-Root | 1 | 0 Tests | Build-Fehler, **keine Tests ausgeführt** | alle | [msbuild-emberapi_test.log](test-results/msbuild-emberapi_test.log) |

Ein `vstest.console.exe`-Lauf war nicht möglich, da keine Test-Assembly erzeugt wurde (Build schlug fehl).

### Nachgewiesene bestehende Testfehler

Keine **Testfehler** nachgewiesen — es wurden keine Tests ausgeführt. Stattdessen liegt ein nachgewiesener **Build-/Setup-Fehler** des Testprojekts vor:

| Befund | Suite / Dateipfad | Fehlerbild / Fehlermeldung | Lauf und Nachweis |
|--------|-------------------|----------------------------|-------------------|
| Fehlende Projektreferenz | `EmberAPI_Test/EmberAPI_Test.vbproj` (Zeilen 183–186) | `warning MSB9008: Das referenzierte Projekt ..\UnitTests\UnitTests.vbproj ist nicht vorhanden` — das Verzeichnis `UnitTests/` existiert nicht im Repository | Lauf 2, [Log](test-results/msbuild-emberapi_test.log) |
| Kompilierfehler | `EmberAPI_Test/Test_clsAPIStringUtils.vb` u. a. | **203 × `error BC30002: Der Typ "UnitTest" ist nicht definiert`** — der Typ `UnitTest` (u. a. als Attribut `<UnitTest>` neben `<TestMethod>` verwendet) stammt vermutlich aus dem fehlenden `UnitTests`-Projekt | Lauf 2, [Log](test-results/msbuild-emberapi_test.log) |
| Assembly-Konflikt | `EmberAPI_Test` | `warning MSB3277`: `NLog` 3.1.0.0 (Testprojekt-`packages.config`) vs. 4.0.0.0 (transitiv über `EmberAPI`, `NLog` 4.7.14) | Lauf 2, [Log](test-results/msbuild-emberapi_test.log) |

Positiv-Befund aus Lauf 2: Die Projektreferenz `EmberAPI` **baut erfolgreich** (`EmberAPI -> EmberMM - Debug - x86\EmberAPI.dll`); auch die GAC-Referenz `Microsoft.VisualStudio.QualityTools.UnitTestFramework` (MSTest v1) wird von VS 2026 aufgelöst — der Build scheitert ausschließlich am fehlenden `UnitTests`-Projekt bzw. dem `UnitTest`-Typ.

### Testlücken und Ausführungsprobleme

- **Keine ausführbaren Tests im Repository.** Die einzige Suite `EmberAPI_Test` ist nicht CI-tauglich: nicht in der Solution, fehlende Projektreferenz `..\UnitTests\UnitTests.vbproj`, MSTest-v1-GAC-Referenz (VS2010-Ära), NLog-Versionskonflikt, `<RestorePackages>true</RestorePackages>` über das Legacy-`NuGet.targets`.
- Umfang der nicht ausführbaren Tests: 10 Testklassen mit insgesamt ~204 `<TestMethod>`-Attributen (siehe unten; einige Methoden tragen zusätzlich das nicht auflösbare `<UnitTest>`-Attribut).
- Für die CI-Anforderung bedeutet das: Referenz-Gates „Tests ausführen" (Gate 4) und „Coverage ≥ 70 %" (Gate 5) haben aktuell **keine ausführbare Grundlage** in diesem Repository.

## Testklassen

Alle in `EmberAPI_Test/` (Datei jeweils `EmberAPI_Test/<Name>.vb`), MSTest v1 (`Microsoft.VisualStudio.TestTools.UnitTesting`):

### `Test_clsAPICommon` (~40 Testmethoden)
- `Functions_CheckIfWindows`, `Functions_ConvertFromUnixTimestamp_Valid`/`_NotValid`, `Functions_ConvertToUnixTimestamp`, `Functions_DGVDoubleBuffer`, `Functions_EmberAPIVersion`, `Functions_GetExtraModifier`, `Functions_GetSeasonDirectoryFromShowPath`, `Functions_HasModifier`, `Functions_IsSeasonDirectory`, `Functions_ListToStringWithSeparator_*` (mehrere Fälle), `Functions_PNLDoubleBuffer`, `Functions_Quantize_*`, `Functions_ReadStreamToEnd` u. a. — Hilfsfunktionen der `EmberAPI`

### `Test_clsAPIErrorLog` (~14 Testmethoden)
- Fehlerprotokollierung der `EmberAPI`

### `Test_clsAPIFileUtils` (~10 Testmethoden)
- Datei-/Pfad-Hilfsfunktionen

### `Test_clsAPIHTTP` (~8 Testmethoden)
- HTTP-Hilfsfunktionen

### `Test_clsAPIImageUtils` (~44 Testmethoden)
- Bildverarbeitungs-Hilfsfunktionen

### `Test_clsAPIImages` (~2 Testmethoden)
- `Images`-Klasse

### `Test_clsAPINumUtils` (~2 Testmethoden)
- Numerische Hilfsfunktionen

### `Test_clsAPIStringUtils` (~65 Testmethoden)
- String-Hilfsfunktionen; enthält die meisten `<UnitTest>`-Attribut-Verwendungen (Herkunft des BC30002-Fehlerschwerpunkts)

### `Test_clsTrailers` (~6 Testmethoden)
- Trailer-Handling

### `Test_clsYouTube` (~13 Testmethoden)
- YouTube-Scraper-Logik

## Hilfsmethoden / Hilfsklassen

### `ImageFeedback` (`ImageFeedback.vb`, `ImageFeedback.Designer.vb`, `.resx`)
- WinForms-Dialog zur visuellen Kontrolle von Bildvergleichen in Tests (SubType `Form`)

### `PixelRuler` (`PixelRuler.vb`, `PixelRuler.Designer.vb`, `.resx`)
- UserControl zum Pixel-Abmessen von Testbildern (SubType `UserControl`)

### `UnitTest`-Typ (fehlend)
- Wird in den Testdateien als Attribut (`<UnitTest>`) verwendet; Definition lag vermutlich im nicht mehr vorhandenen Projekt `..\UnitTests\UnitTests.vbproj` (Projekt-GUID `{8160971E-1B33-4D0F-9355-2F8D3E833288}`)

### Testdaten
- `EmberAPI_Test/Resources/`: `TestPattern.png`, `TestPattern_Med.png`, `TestPattern_Med_Vert.png`, `TestPattern_Vert.png`, `Genre.jpg`
- `EmberAPI_Test/app.config`, `packages.config` (nur `NLog` 3.1.0.0)
