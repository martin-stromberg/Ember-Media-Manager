# Tests — Bestandsaufnahme

## Test-Ausgangszustand vor der Umsetzung

- Zeitpunkt (mit Zeitzone): 2026-09-20 19:50 +0200 (Nachweis: [baseline.txt](test-results/baseline.txt))
- Branch und Commit-ID: `task/issue-8-168e4a79c1c24dadb014bdd3fb7c170d-suche-nach-filmen-und-serien-l`, `452c71bb1defc6f161b3274b9dc1301a58e094ca` ("fix: NRE beim Start — SQLite.Interop.dll ins Ausgabeverzeichnis deployen (#13)")
- Uncommittete Änderungen im getesteten Stand: keine Änderungen an getrackten Dateien; untracked: `.agents/`, `docs/features/task/issue-8-168e4a79c1c24dadb014bdd3fb7c170d-suche-nach-filmen-und-serien-l/` (diese Dokumentation)
- Testumgebung und Runtime-/SDK-Versionen: Windows; MSBuild 18.10.1.42706 (VS 18 Community, `C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe`); .NET Framework 4.8.1 installiert (Registry `Release` = 0x82405); `vstest.console.exe` vorhanden unter `…\Common7\IDE\CommonExtensions\Microsoft\TestWindow\vstest.console.exe` und `…\Common7\IDE\Extensions\TestPlatform\vstest.console.exe`
- Ermittelte Testsuiten und Quellen der Testbefehle: Einziges Testprojekt im Repo ist `EmberAPI_Test` (`EmberAPI_Test\EmberAPI_Test.vbproj`, VB.NET, MSTest v1 / `Microsoft.VisualStudio.QualityTools.UnitTestFramework`, Target .NET 4.8). Es ist **nicht** Mitglied von `Ember Media Manager.sln`. Es gibt keine Testskripte; die CI (`.github/workflows/staging-ci.yml`, Job `build-and-test`, Z. 111–116) führt keine Tests aus und begründet das explizit: „the only test project (EmberAPI_Test) is not part of the solution and does not build (missing UnitTests project, MSTest-v1 GAC reference)". Der Testbefehl wurde daher als direkter Projekt-Build + geplantem `vstest.console.exe`-Lauf ermittelt.

### Testläufe

| Lauf | Befehl inkl. Filter | Arbeitsverzeichnis | Exit-Code | Erfolgreich | Fehlgeschlagen | Übersprungen | Nachweis |
|------|--------------------|--------------------|-----------|-------------|----------------|--------------|----------|
| 1 — Buildversuch Testprojekt (Debug\|Any CPU) | `MSBuild.exe "EmberAPI_Test\EmberAPI_Test.vbproj" -p:Configuration=Debug -p:Platform="Any CPU" -v:m -nologo` | Repo-Root | 1 | 0 (kein Test ausgeführt) | 0 | unbekannt | [msbuild-emberapi_test-anycpu.log](test-results/msbuild-emberapi_test-anycpu.log) |
| 2 — Buildversuch Testprojekt (Debug\|x86) | `MSBuild.exe "EmberAPI_Test\EmberAPI_Test.vbproj" -p:Configuration=Debug -p:Platform=x86 -v:m -nologo` | Repo-Root | 1 | 0 (kein Test ausgeführt) | 0 | unbekannt | [msbuild-emberapi_test-x86.log](test-results/msbuild-emberapi_test-x86.log) |

Erläuterung: Beide Läufe sind **Buildversuche**, da ohne kompilierte `EmberAPI_Test.dll` kein `vstest.console.exe`-Lauf möglich ist. Lauf 1 scheitert, weil das Projekt keine Konfiguration `Debug|Any CPU` definiert (nur x86/x64; `error: Eigenschaft "BaseOutputPath/OutputPath" ist nicht festgelegt`). Lauf 2 kompiliert `EmberAPI` erfolgreich (nur Warnungen), scheitert dann an `EmberAPI_Test` selbst: `warning MSB9008: Das referenzierte Projekt ..\UnitTests\UnitTests.vbproj ist nicht vorhanden` und 203× `error BC30002: Der Typ "UnitTest" ist nicht definiert`. Das Hilfsprojekt `UnitTests` (Namespace `UnitTests`, Basistyp `UnitTest` für parametrisierte Testdaten) existiert nicht im Repository; alle 10 Testdateien enthalten `Imports UnitTests`.

### Nachgewiesene bestehende Testfehler

Es wurden **keine** Testfehler nachgewiesen — kein Test konnte ausgeführt werden, da die Testassembly nicht erzeugt werden kann. Für spätere Arbeiten gilt: Der Ausgangszustand sämtlicher Tests ist **unbekannt**, nicht „preexisting failed" und nicht „grün".

### Testlücken und Ausführungsprobleme

- **Infrastrukturfehler (blockiert die gesamte Suite):** Referenziertes Projekt `..\UnitTests\UnitTests.vbproj` fehlt im Repo → 203 Kompilierfehler `BC30002`, keine `EmberAPI_Test.dll` (Nachweis: [msbuild-emberapi_test-x86.log](test-results/msbuild-emberapi_test-x86.log), Z. 34 MSB9008; `find` im Repo ergab keine `UnitTests`-Dateien).
- **Weitere Infrastrukturdefizite:** `EmberAPI_Test` ist nicht in `Ember Media Manager.sln` enthalten; das Projekt definiert nur die Plattformen x86/x64 (kein AnyCPU, Nachweis: [msbuild-emberapi_test-anycpu.log](test-results/msbuild-emberapi_test-anycpu.log)); die Suite nutzt MSTest v1 mit GAC-Referenz `Microsoft.VisualStudio.QualityTools.UnitTestFramework, Version=10.0.0.0`. Die CI dokumentiert denselben Befund (`.github/workflows/staging-ci.yml:111–116`).
- **Umfang:** 0 von ~194 `<TestMethod>`-Markierungen (grep-Zählung über die 10 Testdateien; davon können auch Hilfs-/Setup-Methoden betroffen sein) ausgeführt. Nicht ausgeführte Tests sind weder Erfolg noch Beleg für Fehler.
- **Fachliche Testlücke:** Kein einziger Test betrifft das IMDb-Modul (`SearchMovie`, `SearchTVShow`, `SearchResults_*`, `GetSearchMovieInfo`, `dlgIMDBSearchResults_*`). Die Suite testet ausschließlich `EmberAPI`-Hilfsklassen.

## Testklassen

Alle in `EmberAPI_Test\`, Namespace `EmberAPI_Test`, MSTest (`<TestClass>`/`<TestMethod>`):

### `Test_clsAPIStringUtils_StringUtils` (`Test_clsAPIStringUtils.vb`, Z. 30)
65 `<TestMethod>`-Treffer; relevant für die Anforderung: `StringUtils_ComputeLevenshtein` (Z. 318 — prüft `StringUtils.ComputeLevenshtein`, das die Lev-≤-5-Heuristik in `GetSearchMovieInfo` nutzt) sowie `StringUtils_FilterYear`/`StringUtils_FilterYear_NothingParameter` (Z. 963–1001 — `FilterYear` wird in `SearchMovie` verwendet). Kein Test für `GetIMDBIDFromString`. Übrige Tests: `AlphaNumericOnly`, `GenreFilter`, `CleanStackingMarkers`, `CleanURL`, `Decode`/`Encode`, `FilterName`, `FilterTokens`, `FilterTVEpName`, `FilterTVShowName`, `HtmlEncode`, `IsStacked`, `isValidURL`, `ProperCase`, `StringToSize`, `TruncateURL`, `CleanFileName`, `ShortenOutline`, `RemovePunctuation`.

### `Test_clsAPICommon_Functions` (`Test_clsAPICommon.vb`, Z. 30)
40 `<TestMethod>`-Treffer — Tests für `EmberAPI.Functions`.

### `Test_clsAPIImageUtils` (`Test_clsAPIImageUtils.vb`, Z. 31)
44 `<TestMethod>`-Treffer — Bild-Utilities.

### `Test_clsAPIErrorLog` (`Test_clsAPIErrorLog.vb`, Z. 38)
14 `<TestMethod>`-Treffer — `ErrorLogger`/`clsAPIErrorLog` inkl. `TestSetup`/`TestCleanup`.

### `Test_clsYouTube_Scraper` / `Test_clsYouTube_VideoLinkItemCollection` (`Test_clsYouTube.vb`, Z. 30/146)
13 `<TestMethod>`-Treffer — YouTube-Scraper/Link-Sammlung.

### `Test_clsAPIFileUtils_Common` / `Test_clsAPIFileUtils_Delete` / `Test_clsAPIFileUtils_FileSorter` (`Test_clsAPIFileUtils.vb`, Z. 31/201/239)
10 `<TestMethod>`-Treffer — Datei-Utilities.

### `Test_clsAPIHTTP` (`Test_clsAPIHTTP.vb`, Z. 30)
8 `<TestMethod>`-Treffer — `EmberAPI.HTTP`-Wrapper.

### `Test_clsTrailers` (`Test_clsTrailers.vb`, Z. 29)
6 `<TestMethod>`-Treffer — Trailer-Verwaltung.

### `Test_clsAPIImages` (`Test_clsAPIImages.vb`, Z. 30) / `Test_clsAPINumUtils` (`Test_clsAPINumUtils.vb`, Z. 29)
Je 2 `<TestMethod>`-Treffer — `Images`-Klasse bzw. `NumUtils`.

## Hilfsmethoden / Testinfrastruktur

### `UnitTests.UnitTest` (nicht im Repo vorhanden)
- Von allen Testdateien via `Imports UnitTests` referenziert; der Typ `UnitTest` wird in den Tests als Container/Basistyp für Testdatenstrukturen genutzt (z. B. `Test_clsAPIStringUtils.vb` — 203 Verwendungsstellen). Das Projekt `UnitTests.vbproj` fehlt vollständig — Ursache des Buildabbruchs.
- `EmberAPI_Test` enthält zusätzlich interne Hilfsstrukturen, z. B. `Friend Structure LevenshteinData` (`Test_clsAPIStringUtils.vb:304`) und `TestData`-Klassen mit `Public Sub New(...)` für parametrisierte Fälle.
- UI-Helfer `ImageFeedback` (Form) und `PixelRuler` (UserControl) dienen der visuellen Kontrolle von Bildtests, sind keine Testklassen.
