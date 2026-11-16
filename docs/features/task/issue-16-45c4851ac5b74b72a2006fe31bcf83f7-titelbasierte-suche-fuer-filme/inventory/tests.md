# Bestandsaufnahme: Tests und Test-Ausgangszustand

## Ausgangszustand (vor jeder Code-/Test-/Konfigurationsänderung)

| Merkmal | Wert |
|---------|------|
| Zeitpunkt der Baseline-Messung | 2026-09-20, ca. 21:33–21:45 Uhr (UTC+02:00, Europe/Berlin) |
| Branch | `task/issue-16-45c4851ac5b74b72a2006fe31bcf83f7-titelbasierte-suche-fuer-filme` |
| Commit | `48b5739a1477c1f2581feb86d262f480cba3d5f6` |
| Uncommitted Changes | nur `?? .agents/` und `?? docs/features/task/issue-16-…/` (ungetrackt). Build-Ausgaben (`EmberMM - Debug - x86`, `packages/…`) sind über `.gitignore` (`EmberMM*/`, Z. 5) ausgeblendet und erscheinen nicht als Änderung |
| Betriebssystem | Windows 10/11 (Build 10.0.26200), `win`/`MINGW`-Shell |
| .NET SDK | `dotnet --version` → **10.0.401** |
| MSBuild | **18.10.1.42706** (`C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe`, Visual Studio Community 18); `dotnet`-MSBuild 18.9.11 |
| .NET Framework | v4.8 installiert (Registry); Referenzassemblies zusätzlich über `Directory.Build.props` → `Microsoft.NETFramework.ReferenceAssemblies` per NuGet |
| Test-Runner | `vstest.console.exe` unter Visual-Studio-`TestWindow`-Pfaden vorhanden; **kein ausführbares Test-Assembly** (siehe unten) |

## Identifizierte Testbefehle / Projektstandard

Quellen: `README.md` (Z. 34–70), `.github\workflows\pr-staging-ci.yml` (Z. 96–120).

- Build: `.nuget\NuGet.exe restore "Ember Media Manager.sln"`, dann `msbuild "Ember Media Manager.sln" -p:Configuration=Release -p:Platform=x64` (Doku) bzw. `-p:Configuration=Debug -p:Platform=x86` (CI).
- Tests: **kein funktionierender Testbefehl definiert.** CI führt keine Tests aus; `EmberAPI_Test` ist laut CI-Kommentar bewusst nicht Teil der Solution (fehlendes `UnitTests`-Hilfsprojekt, MSTest-v1/GAC-Abhängigkeiten). Es gibt kein Skript, kein `dotnet test`-fähiges Projekt.

## Durchgeführte Läufe

Arbeitsverzeichnis aller Kommandos: Repository-Root `D:\Repositories\softwareschmiede\45c4851a-c5b7-4b72-a200-6fe31bcf83f7`.

| # | Kommando | Exit-Code | Ergebnis | Nachweis |
|---|----------|-----------|----------|----------|
| 1 | `.nuget\NuGet.exe restore "Ember Media Manager.sln"` | 0 | Restore erfolgreich; `UnitTests\UnitTests.vbproj` wird übersprungen („nicht gefunden") | [nuget-restore.log](test-results/nuget-restore.log) |
| 2 | `MSBuild.exe Addons\scraper.IMDB.Data\scraper.Data.IMDB.vbproj -p:Configuration=Debug -p:Platform=x86 -v:m` | 0 | Build erfolgreich → `EmberMM - Debug - x86\Modules\scraper.data.imdb\scraper.Data.IMDB.dll`; Warnung MSB3884 (fehlende `MinimumRecommendedRules.ruleset`, `EmberAPI.vbproj`) | [msbuild-scraper-imdb.log](test-results/msbuild-scraper-imdb.log) |
| 3 | `MSBuild.exe Addons\scraper.TMDB.Data\scraper.Data.TMDB.vbproj -p:Configuration=Debug -p:Platform=x86 -v:m` | 0 | Build erfolgreich → `scraper.Data.TMDB.dll`; gleiche MSB3884-Warnung | [msbuild-scraper-tmdb.log](test-results/msbuild-scraper-tmdb.log) |
| 4 | `MSBuild.exe Addons\scraper.IMDB.Data\scraper.Data.IMDB.vbproj Addons\scraper.TMDB.Data\scraper.Data.TMDB.vbproj -p:Configuration=Debug -p:Platform=x86 -v:m` | 1 | **Aufruffehler** MSB1008 („Es darf nur ein Projekt angegeben werden") — kein Produkt-/Testfehler, durch Läufe 2+3 abgedeckt | [msbuild-scraper-imdb-tmdb.log](test-results/msbuild-scraper-imdb-tmdb.log) |
| 5 | `MSBuild.exe EmberAPI_Test\EmberAPI_Test.vbproj` (ohne Config/Platform) | 1 | Konfigurationsfehler: „BaseOutputPath/OutputPath" nicht festgelegt (Configuration=Debug, Platform=AnyCPU nicht im Projekt definiert) — Aufruf-/Konfigurationsproblem, kein Testfehler | [msbuild-emberapi-test.log](test-results/msbuild-emberapi-test.log) |
| 6 | `MSBuild.exe EmberAPI_Test\EmberAPI_Test.vbproj -p:Configuration=Debug -p:Platform=x86 -v:m` | 1 | **Kompilierungsfehler:** 203× `BC30002` „Der Typ 'UnitTest' ist nicht definiert" (u. a. `Test_clsAPIStringUtils.vb` Z. 1461, 1502, 1511, 1520, 1529) — Infrastruktur-/Build-Fehler, kein einziger Test wurde ausgeführt | [msbuild-emberapi-test-x86.log](test-results/msbuild-emberapi-test-x86.log) |
| 7 | `dotnet test` (Restore/Discovery auf Solution/Testprojekt) | — | „Keine Aktion erforderlich" / kein testbares Projekt; `UnitTests.vbproj` wird beim Restore übersprungen | [dotnet-test.log](test-results/dotnet-test.log) |

## Ergebniszusammenfassung

- **Ausgeführte Tests: 0.** Es existiert **keine** Aussage über Test-Erfolg/-Misserfolg — der Runner kam nie zur Ausführung.
- **Nachgewiesene Testfehler: keine** (kein `Failed`-Test, kein TRX/Report erzeugbar).
- **Infrastruktur-/Build-Fehler:** `EmberAPI_Test` kompiliert nicht (203× `BC30002`); Ursache: `ProjectReference` auf `..\UnitTests\UnitTests.vbproj` (`EmberAPI_Test.vbproj:183–185`), Verzeichnis `UnitTests\` fehlt im Repository; Testquellen importieren `UnitTests` (z. B. `Test_clsAPIStringUtils.vb:26`). Zusätzlich MSTest-v1-Referenzen auf `Microsoft.VisualStudio.QualityTools.UnitTestFramework` 10.0/10.1 (GAC), die auf modernen VS-Installationen unvollständig sind.
- **Nicht ausführbar/übersprungen:** gesamtes `EmberAPI_Test`-Projekt (12 `[TestClass]`, 204 `[TestMethod]`); nicht Teil von `Ember Media Manager.sln`; in CI explizit ausgeschlossen.
- Erfolgreiche Projektkompilierungen (`scraper.Data.IMDB`, `scraper.Data.TMDB`, `EmberAPI`) sind **keine** Testnachweise.

## Bestehende Testklassen (Quelltext-Inventar, nicht ausführbar)

Projekt `EmberAPI_Test` (MSTest v1, Attribut-Syntax `<TestClass>`/`<TestMethod>`):

| Datei | TestClasses | TestMethods |
|-------|-------------|-------------|
| `EmberAPI_Test\Test_clsAPICommon.vb` | 1 | 40 |
| `EmberAPI_Test\Test_clsAPIErrorLog.vb` | 1 | 14 |
| `EmberAPI_Test\Test_clsAPIFileUtils.vb` | 3 | 10 |
| `EmberAPI_Test\Test_clsAPIHTTP.vb` | 1 | 8 |
| `EmberAPI_Test\Test_clsAPIImageUtils.vb` | 1 | 44 |
| `EmberAPI_Test\Test_clsAPIImages.vb` | 1 | 2 |
| `EmberAPI_Test\Test_clsAPINumUtils.vb` | 1 | 2 |
| `EmberAPI_Test\Test_clsAPIStringUtils.vb` | 1 | 65 |
| `EmberAPI_Test\Test_clsTrailers.vb` | 1 | 6 |
| `EmberAPI_Test\Test_clsYouTube.vb` | 2 | 13 |
| **Summe** | **12** | **204** |

Relevant für diese Anforderung: `Test_clsAPIStringUtils.vb` deckt u. a. `ComputeLevenshtein`, `FilterYear`, `GetIMDBIDFromString` ab (Hilfsfunktionen der Suchheuristik) — aber ohne das fehlende `UnitTests`-Hilfsprojekt nicht kompilierbar. Es existieren **keine** Tests für `scraper.Data.IMDB`, `scraper.Data.TMDB` oder `scraper.Data.OMDb`.
