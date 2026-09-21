# Bestandsaufnahme: Interfaces

## `Interfaces.ScraperModule_Data_Movie`
Datei: `EmberAPI\clsAPIInterfaces.vb` (Z. 58–97)

Vertrag für Film-Daten-Scraper; implementiert von `IMDB_Data` (`IMDB_Data.vb:26`), `TMDB_Data` und `OMDb_Data`.

| Member | Signatur | Implementierung in `IMDB_Data` |
|--------|----------|--------------------------------|
| `GetMovieStudio` | `Function(ByRef DBMovie As Structures.DBMovie, ByRef sStudio As List(Of String)) As ModuleResult` (Z. 80) | Delegiert an `Scraper.GetMovieStudios`; benötigt `UniqueIDs.IMDbId` (`IMDB_Data.vb:414–425`) |
| `GetTMDbIdByIMDbId` | `Function(imdbId As String, ByRef tmdbId As Integer) As ModuleResult` (Z. 81) | **Leerer Stub** (`IMDB_Data.vb:427–429`); funktionale Referenz: `TMDB_Data.vb:602–616` (`FindAsync(FindExternalSource.Imdb)`) |
| `Init` | `Sub(ByVal sAssemblyName As String)` (Z. 82) | `Init_Movie` (`IMDB_Data.vb:128–131`) |
| `InjectSetupScraper` | `Function() As Containers.SettingsPanel` (Z. 83) | `frmSettingsHolder_Movie`, Order 110 (`IMDB_Data.vb:138–186`) |
| `SaveSetupScraper` | `Sub(ByVal DoDispose As Boolean)` (Z. 84) | Überträgt Panel in `ConfigScrape*`/`_SpecialSettings` + `SaveSettings_Movie` (`IMDB_Data.vb:345–370`) |
| `Scraper_Movie` | `Function(ByRef oDBElement, ByRef ScrapeModifiers, ByRef ScrapeType, ByRef ScrapeOptions) As ModuleResult_Data_Movie` (Z. 93) | `Scraper_Movie` (`IMDB_Data.vb:437–488`); Dialog `dlgIMDBSearchResults_Movie`, `Cancelled`-Rückgabe |
| `ScraperOrderChanged` | `Sub()` (Z. 79) | Delegiert an Panel (`IMDB_Data.vb:579–581`) |
| `ScraperEnabled` | Property `Boolean` (Z. 73) | `ScraperEnabled_Movie` (`IMDB_Data.vb:80`) |
| `ModuleName` / `ModuleVersion` | ReadOnly Properties (Z. 71–72) | Z. 68–77 |
| `ModuleSettingsChanged`, `ScraperEvent`, `ScraperSetupChanged`, `SetupNeedsRestart` | Events (Z. 62–65) | `*_Movie`-Events (Z. 53–56); `ScraperSetupChanged`-Weiterleitung an `ModulesManager` |

## `Interfaces.ScraperModule_Data_TV`
Datei: `EmberAPI\clsAPIInterfaces.vb` (Z. 140–193)

Vertrag für Serien-Daten-Scraper; implementiert von `IMDB_Data` (`IMDB_Data.vb:27`), `TMDB_Data`, `OMDb_Data`.

| Member | Signatur | Implementierung in `IMDB_Data` |
|--------|----------|--------------------------------|
| `Scraper_TVShow` | `Function(ByRef oDBTV, ByRef ScrapeModifiers, ByRef ScrapeType, ByRef ScrapeOptions) As ModuleResult_Data_TVShow` (Z. 173) | `Scraper_TV` (Z. 496–550); Dialog `dlgIMDBSearchResults_TV`, `Cancelled`-Rückgabe |
| `Scraper_TVEpisode` | `Function(ByRef oDBElement, ByVal ScrapeOptions) As ModuleResult_Data_TVEpisode` (Z. 181) | Z. 552–573 (IMDb-ID-basiert, kein Dialog) |
| `Scraper_TVSeason` | `Function(ByRef oDBElement, ByVal ScrapeOptions) As ModuleResult_Data_TVSeason` (Z. 189) | Z. 575–577 (Stub, `Result = Nothing`) |
| `Init` / `InjectSetupScraper` / `SaveSetupScraper` / `ScraperOrderChanged` | Z. 161–164 | `Init_TV` (Z. 133–136), `frmSettingsHolder_TV` (Z. 188–231), `SaveSetupScraper_TV` (Z. 382–412), Z. 583–585 |
| `ScraperEnabled` | Property `Boolean` (Z. 155) | `ScraperEnabled_TV` (Z. 89) |
| `ModuleName` / `ModuleVersion` | ReadOnly Properties (Z. 153–154) | gemeinsame Implementierung mit Movie-Vertrag (Z. 68–77) |
| `ModuleSettingsChanged`, `ScraperEvent`, `ScraperSetupChanged`, `SetupNeedsRestart` | Events (Z. 144–147) | `*_TV`-Events (Z. 59–62) |

## `Interfaces.ScraperModule_Data_MovieSet`
Datei: `EmberAPI\clsAPIInterfaces.vb` (Z. 99–138)

Nur von `TMDB_Data` implementiert (`Scraper_MovieSet` Z. 699, `GetCollectionID`); `IMDB_Data` und `OMDb_Data` implementieren dieses Interface **nicht**.

## Rückgabestrukturen
`Interfaces.ModuleResult`, `ModuleResult_Data_Movie`, `ModuleResult_Data_TVShow` (sowie `_MovieSet`/`_TVEpisode`/`_TVSeason`): `EmberAPI\clsAPIInterfaces.vb` Z. 398–534 — Felder `breakChain`/`Cancelled`/`Result`, siehe [Datenmodell](models.md).

## Interface-Implementierer (Übersicht)
- `IMDB_Data` (`Addons\scraper.IMDB.Data\IMDB_Data.vb:26–27`): `ScraperModule_Data_Movie`, `ScraperModule_Data_TV`.
- `TMDB_Data` (`Addons\scraper.TMDB.Data\TMDB_Data.vb`): `ScraperModule_Data_Movie`, `ScraperModule_Data_MovieSet`, `ScraperModule_Data_TV`.
- `OMDb_Data` (`Addons\scraper.Data.OMDb\OMDb_Data.vb`): `ScraperModule_Data_Movie`, `ScraperModule_Data_TV`.

## Aufrufkette (Querverweis)
`ModulesManager.ScrapeData_Movie` (`EmberAPI\clsAPIModules.vb:915`) iteriert `externalScrapersModules_Data_Movie` und ruft `ProcessorModule.Scraper_Movie` auf (Z. 947); `ModulesManager.ScrapeData_TVShow` (Z. 1215) ruft `Scraper_TVShow` (Z. 1258). `ret.Cancelled` → Abbruch der gesamten Kette (Z. 949 bzw. 1260) — siehe [Logik](logic.md).
