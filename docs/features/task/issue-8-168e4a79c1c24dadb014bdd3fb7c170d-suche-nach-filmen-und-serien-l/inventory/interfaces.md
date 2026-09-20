# Interfaces — Bestandsaufnahme

## `Interfaces.ScraperModule_Data_Movie`
Datei: `EmberAPI\clsAPIInterfaces.vb` (Z. 58 ff.)

Von `IMDB_Data` implementiert (`IMDB_Data.vb:26`). Contract zwischen `ModulesManager` und Daten-Scrapern für Filme.

| Methode | Parameter | Rückgabewert | Zweck |
|---------|-----------|--------------|-------|
| `Init` | `sAssemblyName As String` | — | Modul initialisieren |
| `InjectSetupScraper` | — | `Containers.SettingsPanel` | Settings-Panel liefern |
| `SaveSetupScraper` | `DoDispose As Boolean` | — | Settings sichern |
| `ScraperOrderChanged` | — | — | Reihenfolge geändert |
| `GetMovieStudio` | `DBMovie As Database.DBElement`, `sStudio As List(Of String)` | `ModuleResult` | Studios nachladen |
| `GetTMDbIdByIMDbId` | `imdbId As String`, `tmdbId As Integer` | `ModuleResult` | IMDb- → TMDb-ID-Mapping (im IMDb-Modul leerer Stub, `IMDB_Data.vb:427`) |
| `Scraper_Movie` | `oDBElement`, `ScrapeModifiers`, `ScrapeType`, `ScrapeOptions` | `ModuleResult_Data_Movie` | Haupt-Scrape-Einstieg (Z. 93) |

Events: `ModuleSettingsChanged`, `ScraperEvent(Enums.ScraperEventType, Object)`, `ScraperSetupChanged(name, State, difforder)`, `SetupNeedsRestart`.
Properties: `ModuleName`, `ModuleVersion`, `ScraperEnabled`.

## `Interfaces.ScraperModule_Data_TV`
Datei: `EmberAPI\clsAPIInterfaces.vb` (Z. 140 ff.)

Von `IMDB_Data` implementiert (`IMDB_Data.vb:27`).

| Methode | Parameter | Rückgabewert | Zweck |
|---------|-----------|--------------|-------|
| `Init` | `sAssemblyName As String` | — | Modul initialisieren |
| `InjectSetupScraper` | — | `Containers.SettingsPanel` | Settings-Panel liefern |
| `SaveSetupScraper` | `DoDispose As Boolean` | — | Settings sichern |
| `ScraperOrderChanged` | — | — | Reihenfolge geändert |
| `Scraper_TVShow` | `oDBTV`, `ScrapeModifiers`, `ScrapeType`, `ScrapeOptions` | `ModuleResult_Data_TVShow` | Serien-Scrape (Z. 173) |
| `Scraper_TVEpisode` | `oDBElement`, `ScrapeOptions` | `ModuleResult_Data_TVEpisode` | Episoden-Scrape (Z. 181) |
| `Scraper_TVSeason` | `oDBElement`, `ScrapeOptions` | `ModuleResult_Data_TVSeason` | Staffel-Scrape (Z. 189) |

Events/Properties identisch zum Movie-Contract.
