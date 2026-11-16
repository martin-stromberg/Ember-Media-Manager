# Bestandsaufnahme: Abhängigkeiten und Projektdateien

## `scraper.Data.IMDB` (Hauptmodul)

- Projekt: `Addons\scraper.IMDB.Data\scraper.Data.IMDB.vbproj` — klassisches `.vbproj`, `TargetFrameworkVersion v4.8` (Z. 14), Ausgabe `Modules\scraper.data.imdb\`.
- `packages.config` (`Addons\scraper.IMDB.Data\packages.config`):
  - `HtmlAgilityPack` **1.11.42** (net451) — einzige Zugriffsschicht auf IMDb (`HtmlWeb.Load`-Aufrufe in `clsScrapeIMDB.vb`).
  - `NLog` 4.7.14 (net48).
- Assembly-Referenzen (vbproj Z. 122–146): `HtmlAgilityPack`, `NLog`, `System.*` (u. a. `System.Net` nicht explizit — HTTP läuft über HtmlAgilityPack); `ProjectReference` auf `..\..\EmberAPI\EmberAPI.vbproj` (Z. 258–262).
- **Nicht vorhanden:** `TMDbLib`, `Newtonsoft.Json`, `System.Net.Http`-Paket — sämtliche für `TMDbClient` nötigen Referenzen fehlen im Projekt.
- `app.config` (`Addons\scraper.IMDB.Data\app.config`): nur `assemblyBinding`-Umleitungen.

## `scraper.Data.TMDB` (Referenzmodul)

- Projekt: `Addons\scraper.TMDB.Data\scraper.Data.TMDB.vbproj` — `TargetFrameworkVersion v4.8`.
- `packages.config` (`Addons\scraper.TMDB.Data\packages.config`):
  - `TMDbLib` **1.9.1** (net48) — `TMDbClient`, `SearchMovieAsync`, `SearchTvShowAsync`, `GetMovieAsync`, `GetTvShowAsync`, `FindAsync` (`clsScrapeTMDB.vb`).
  - `Newtonsoft.Json` 13.0.3, `NLog` 4.7.14, `System.Net.Http` 4.3.4 (mit `requireReinstallation="true"`), `System.IO` 4.3.0, `System.Runtime` 4.3.1, `System.Security.Cryptography.*` 4.3.x — Transitiv-/Kompatibilitätspakete für TMDbLib (netstandard1.0).
- Paket-Inhalt bestätigt: `packages\TMDbLib.1.9.1\lib\netstandard1.0\TMDbLib.xml` dokumentiert u. a. `FindExternalSource.Imdb`, `Movie.ImdbId`, `TvShowMethods.ExternalIds`, `ExternalIds.ImdbId` — die für IMDb-ID-Auflösung benötigten API-Member sind in dieser Version vorhanden.

## `scraper.Data.OMDb` (Alternative)

- Projekt: `Addons\scraper.Data.OMDb\scraper.Data.OMDb.vbproj`.
- `packages.config`: `MovieCollection.OpenMovieDatabase` **3.0.1** (net48), `Newtonsoft.Json` 13.0.3, `NLog` 4.7.14.
- `MovieCollection.OpenMovieDatabase.xml` (net451-Lib) dokumentiert `SearchMoviesAsync`/`SearchMovieAsync`/`SearchMovieByImdbIdAsync`; im Modul wird nur `SearchMovieByImdbIdAsync` genutzt (`clsScrapeOMDb.vb:84`).

## `EmberAPI` (Framework)

- Projekt: `EmberAPI\EmberAPI.vbproj` — `TargetFrameworkVersion v4.8`; enthält `clsAPIInterfaces.vb`, `clsAPIModules.vb`, `clsAPIMediaContainers.vb`, `clsAPIStringUtils.vb`, `clsAPICommon.vb`, `clsAPIAdvancedSettings.vb`.
- `Directory.Build.props` (Repo-Root) liefert .NET-Framework-4.8-Referenzassemblies per NuGet (`Microsoft.NETFramework.ReferenceAssemblies`) — Voraussetzung für den Build ohne installiertes Targeting Pack.

## `EmberAPI_Test` (Testprojekt — defekt, siehe [Tests](tests.md))

- Projekt: `EmberAPI_Test\EmberAPI_Test.vbproj` — **nicht** in `Ember Media Manager.sln` enthalten.
- `ProjectReference` auf `..\UnitTests\UnitTests.vbproj` (Z. 183–185) — Verzeichnis `UnitTests\` existiert nicht im Repository.
- Referenz auf `Microsoft.VisualStudio.QualityTools.UnitTestFramework` 10.0/10.1 (GAC, MSTest v1) (Z. 80, 97) plus `CodedUITestFramework` (Z. 210).

## Lösung/Build

- `Ember Media Manager.sln` (Repo-Root) — enthält `EmberMediaManager`, `EmberAPI`, alle Addon-Projekte, **nicht** `EmberAPI_Test`.
- Dokumentierte Build-Kommandos (`README.md` Z. 34–70, CI `.github\workflows\pr-staging-ci.yml` Z. 96–120):
  - `.nuget\NuGet.exe restore "Ember Media Manager.sln"`
  - `msbuild "Ember Media Manager.sln" -p:Configuration=Release -p:Platform=x64` bzw. CI: `-p:Configuration=Debug -p:Platform=x86`.
