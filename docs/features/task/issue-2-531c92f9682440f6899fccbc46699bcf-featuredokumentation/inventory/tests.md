# Tests — Bestand und Ausgangszustand

## Test-Ausgangszustand vor der Umsetzung

- **Zeitpunkt:** 2026-09-19 (lokale Zeit, UTC+2)
- **Branch und Commit:** `task/issue-2-531c92f9682440f6899fccbc46699bcf-featuredokumentation` @ `4e6f571e9efb7b99b3c0f05a39e451daef5930de` (= `origin/staging`)
- **Uncommittete Änderungen im getesteten Stand:** keine getrackten Änderungen; untracked: `.agents/`, `AGENTS.md`, `docs/features/task/issue-2-…-featuredokumentation/` (Lifecycle-Arbeitsartefakte dieser Anforderung)
- **Testumgebung:** Windows, MSBuild 18.10.1 (Visual Studio 18 Community), .NET Framework 4.8-Referenzassemblys via NuGet, NuGet.exe 6.14.0
- **Ermittelte Testsuiten:** einziges Testprojekt `EmberAPI_Test/EmberAPI_Test.vbproj` (MSTest, `Microsoft.VisualStudio.QualityTools.UnitTestFramework` 10.0/10.1). Keine weiteren Testprojekte, keine CI-Workflows (`.github/workflows` nicht vorhanden).

## TestlÃ¤ufe

| Lauf | Befehl inkl. Filter | Arbeitsverzeichnis | Exit-Code | Erfolgreich | Fehlgeschlagen | Übersprungen | Nachweis |
|------|--------------------|--------------------|-----------|-------------|----------------|--------------|----------|
| 1 | `.nuget\NuGet.exe restore "Ember Media Manager.sln"` + `MSBuild.exe EmberAPI_Test/EmberAPI_Test.vbproj -p:Configuration=Release -p:Platform=x64 -v:m` | Repository-Stamm | 1 | — | — | — | [msbuild-emberapi_test-release-x64.txt](test-results/msbuild-emberapi_test-release-x64.txt) |

Es konnte **kein Testlauf** (`vstest.console`) ausgeführt werden, da das Testprojekt nicht kompiliert und keine Test-Assembly erzeugt wird. Die Kernbibliothek `EmberAPI.dll` wurde im selben Lauf fehlerfrei gebaut (`EmberMM - Release - x64\EmberAPI.dll`).

## Nachgewiesene bestehende Testfehler

Keine Testfehler nachweisbar — es wurde kein Test ausgeführt (siehe unten). Aussagen über einzelne Testergebnisse sind nicht möglich.

## Testlücken und Ausführungsprobleme

**Build-/Setup-Fehler (kein Testfehlschlag):**

| Problem | Details |
|---------|---------|
| `EmberAPI_Test` ist nicht Mitglied der Solution | `grep` auf `Ember Media Manager.sln` findet keinen Testprojekt-Eintrag — das Projekt wird beim Solution-Build gar nicht erst gebaut |
| Fehlende Projektreferenz `..\UnitTests\UnitTests.vbproj` | `EmberAPI_Test.vbproj` enthält `ProjectReference Include="..\UnitTests\UnitTests.vbproj"` und die Testdateien `Imports UnitTests`; das `UnitTests`-Projekt existiert nicht im Repository |
| Folgefehler | ~200× `error BC30002: Der Typ "UnitTest" ist nicht definiert` (u. a. `Test_clsAPIStringUtils.vb`), siehe Build-Log |
| Legacy-Referenzen | Verweise auf `Microsoft.VisualStudio.QualityTools.UnitTestFramework` v10.0/v10.1 und `CodedUITestFramework` v10.0 (VS-2010-Ära) |

**Ausführbare Tests: keine vorhanden.** Für diese reine Dokumentationsanforderung werden auch keine neuen Tests benötigt (kein geänderter Codepfad, kein Benutzerfluss — Begründung im Plan).

## Testklassen (Bestand im Testprojekt)

Anzahl `TestMethod`-Attribute je Datei:

### `Test_clsAPIStringUtils` (65 Methoden)
- String-Helfer: `StringUtils` (Levenshtein, Filtering, Größenformate u. a.)

### `Test_clsAPIImageUtils` (44 Methoden)
- `ImageUtils`, `ImageComparison` — Bildvergleiche/-maße

### `Test_clsAPICommon` (40 Methoden)
- `Common`, `Functions`, `Containers`, `Structures` — gemeinsame Helfer

### `Test_clsYouTube` (13 Methoden)
- `YouTube` — Link-Parsing/-Auflösung

### `Test_clsAPIErrorLog` (14 Methoden)
- Fehler-Logging

### `Test_clsAPIFileUtils` (10 Methoden)
- `FileUtils` — Dateioperationen

### `Test_clsAPIHTTP` (8 Methoden)
- `HTTP` — Download-Handling

### `Test_clsTrailers` (6 Methoden)
- Trailer-Verarbeitung

### `Test_clsAPINumUtils` (2 Methoden)
- `NumUtils` — Zahlenformate

### `Test_clsAPIImages` (2 Methoden)
- `Images` — Bildverwaltung

Zusätzlich enthält das Projekt die manuellen Hilfsfenster `ImageFeedback` und `PixelRuler` (keine Testklassen).
