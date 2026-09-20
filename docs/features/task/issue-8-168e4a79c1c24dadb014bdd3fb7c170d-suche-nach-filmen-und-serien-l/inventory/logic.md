# Logik — Bestandsaufnahme

## `Scraper` (IMDb-Modul)
Datei: `Addons\scraper.IMDB.Data\Scraper\clsScrapeIMDB.vb` (Z. 57–1627)

Kernklasse des Moduls `scraper.Data.IMDB`. Sämtliche Datenzugriffe laufen über `HtmlAgilityPack.HtmlWeb.Load` auf öffentliche IMDb-HTML-Seiten (NuGet `HtmlAgilityPack` 1.11.42, `packages.config`). Konstruktor nimmt `IMDB_Data.SpecialSettings` (Z. 102–104).

| Methode | Sichtbarkeit | Kurzbeschreibung |
|---------|-------------|------------------|
| `New(SpecialSettings)` | Public | Speichert `_SpecialSettings` |
| `CancelAsync()` | Public | Bricht `bwIMDB` ab und wartet synchron |
| `bwIMDB_DoWork` | Private | Dispatcher: ruft `SearchMovie`/`SearchTVShow`/`GetMovieInfo`/`GetTVShowInfo` je nach `SearchType` (Z. 118–138) |
| `bwIMDB_RunWorkerCompleted` | Private | Wirft die `SearchResultsDownloaded_*`/`SearchInfoDownloaded_*`-Events (Z. 140–158) |
| `FindYear(tmpname, movies)` | Private | Sucht Jahreszahl aus Dateiname in Trefferliste (Z. 160–179); genutzt von `GetSearchMovieInfo` |
| `GetMovieInfo(id, getposter, filteredoptions)` | Public | Detailabruf Film: lädt `/title/{id}/reference` (Z. 209), parst alle Felder via `Parse*`; liefert `MediaContainers.Movie` mit `Scrapersource="IMDB"` |
| `GetTVEpisodeInfo(id, filteredoptions)` | Public | Episoden-Details über `/reference` (Z. 463 ff., 476) |
| `GetTVEpisodeInfo(showid, season, episode, filteredoptions)` | Public | Episode über `/episodes?season=` (Z. 612–637) |
| `GetTVSeasonInfo(...)` | Public | Staffelinfo über `/episodes` (Z. 638 ff., 860) |
| `GetTVShowInfo(id, scrapemodifier, filteredoptions, getposter)` | Public | Serien-Details über `/reference` (Z. 668 ff., 687) |
| `GetMovieStudios(id)` | Public | Studios über `/reference` + `ParseStudios` (Z. 890–900) |
| `GetSearchMovieInfo(title, year, oDBElement, scrapetype, filteredoptions)` | Public | Sucht via `SearchMovie`, wendet `ScrapeType`-Heuristik an (Lev ≤ 5, `FindYear`, Ask→Dialog `dlgIMDBSearchResults_Movie`), lädt danach `GetMovieInfo` (Z. 902–963); aufgerufen von `IMDB_Data.Scraper_Movie` |
| `GetSearchMovieInfoAsync(imdbID, FilteredOptions)` | Public | Startet `GetMovieInfo` im `bwIMDB` (Z. 965–976); genutzt vom Dialog (`btnVerify`, `tmrLoad`) |
| `GetSearchTVShowInfo(title, oDBElement, scrapetype, scrapemodifier, FilteredOptions)` | Public | Wie `GetSearchMovieInfo`, für Serien (Z. 978–1007); Dialog `dlgIMDBSearchResults_TV` |
| `GetSearchTVShowInfoAsync(id, options)` | Public | Startet `GetTVShowInfo` im `bwIMDB` (Z. 1009–1020) |
| `ParseActors` … `ParseTagline` | Private | 18 HTML-Parser für `/reference`-Markup (u. a. `ipl-zebra-list__*`-Selektoren, `REGEX_Certifications` Z. 65); `ParseForcedTitle`/`ParsePremiered(id,…)`/`ParsePlotFromSummaryPage`/`ParseMPAA` laden zusätzlich `/releaseinfo` (Z. 1160, 1354), `/parentalguide` (Z. 1206), `/plotsummary` (Z. 1269) |
| `SearchMovie(title, year)` | Private | **Defekte Titelsuche** (Z. 1413–1541): lädt `imdb.com/find?q=…&s=tt&ttype=ft` (2×) sowie je nach `SpecialSettings` `/find` (partial/popular) und `/search/title` (tv_movie/video/short). XPath `//table[@class="findList"]/tr[@class]/td[2]` bzw. `//span[@title]` liefern im aktuellen IMDb-Markup `Nothing` → alle Kategorien bleiben leer. Sonderfall: Redirect direkt auf eine Titel-URL (`REGEX_IMDBID`, Z. 66, 1446–1448) → leeres `R` zurück |
| `SearchMovieAsync(title, year, filteredoptions)` | Public | Startet `SearchMovie` via `bwIMDB` (Z. 1543–1553); aufgerufen von `dlgIMDBSearchResults_Movie` |
| `SearchTVShow(title)` | Private | **Defekte Seriensuche** (Z. 1555–1581): lädt `/search/title?title=…&title_type=tv_series&view=simple`, XPath `//div[@class="lister-item mode-simple"]`, IMDb-ID aus `img[data-tconst]` — Selektor findet keine Knoten → `Matches` leer |
| `SearchTVShowAsync(title, scrapemodifiers, filteredoptions)` | Public | Startet `SearchTVShow` via `bwIMDB` (Z. 1583–1591); aufgerufen von `dlgIMDBSearchResults_TV` |

Abonnierte Events: `bwIMDB.DoWork`, `bwIMDB.RunWorkerCompleted` (intern, `WithEvents`).
Publizierte Events: `Exception`, `SearchInfoDownloaded_Movie`, `SearchInfoDownloaded_TV`, `SearchResultsDownloaded_Movie`, `SearchResultsDownloaded_TV` (Z. 90–96).

Genutzte Helfer aus EmberAPI: `StringUtils.ComputeLevenshtein` (`clsAPIStringUtils.vb:303`), `StringUtils.FilterYear` (Z. 517), `StringUtils.GetIMDBIDFromString` (Z. 610), `Functions.ScrapeOptionsAndAlso`, `AdvancedSettings`.

Fehlerbehandlung: `SearchMovie`/`SearchTVShow` haben **keine** eigene Fehlerbehandlung — ein Ladefehler/HTTP-Fehler in `HtmlWeb.Load` führt nicht zu einer unterscheidbaren Meldung; `GetSearchMovieInfo`/`GetMovieInfo` fangen Exceptions per `Catch` → `logger.Error` → `Return Nothing` ab (Z. 457–460, 959–962).

## `IMDB_Data`
Datei: `Addons\scraper.IMDB.Data\IMDB_Data.vb` (Z. 25–612)

Modulfassade, implementiert `Interfaces.ScraperModule_Data_Movie` und `Interfaces.ScraperModule_Data_TV`. Wird über `ModulesManager` aus `EmberMediaManager\frmMain.vb` aufgerufen.

| Methode | Sichtbarkeit | Kurzbeschreibung |
|---------|-------------|------------------|
| `Scraper_Movie(oDBElement, ScrapeModifiers, ScrapeType, ScrapeOptions)` | Public (Impl.) | Orchestration Filmsuche/-scrape (Z. 437–488): bei vorhandener IMDb-ID → `GetMovieInfo`; sonst bei Nicht-`SingleScrape` → `GetSearchMovieInfo`; bei `SingleScrape`/`SingleAuto` ohne IMDb-/TMDb-ID → `dlgIMDBSearchResults_Movie.ShowDialog(title, year, filename, FilteredOptions)` (Z. 473–482) |
| `Scraper_TV(...)` (Impl. `Scraper_TVShow`) | Public (Impl.) | Analog für Serien mit `dlgIMDBSearchResults_TV` (Z. 496–550) |
| `Scraper_TVEpisode` / `Scraper_TVSeason` | Public (Impl.) | Episodenabruf über IMDb-ID bzw. Show-ID+S/E (Z. 552–577); `Scraper_TVSeason` liefert stets `Nothing` |
| `GetMovieStudio` / `GetTMDbIdByIMDbId` | Public (Impl.) | Studio-Nachabruf via `GetMovieStudios` (Z. 414–425); `GetTMDbIdByIMDbId` ist leerer Stub (Z. 427–429) |
| `Init_Movie`/`Init_TV`, `LoadSettings_*`, `SaveSettings_*`, `InjectSetupScraper_*`, `SaveSetupScraper_*`, `ScraperOrderChanged_*` | Public (Impl.) | Modul-Lebenszyklus, Settings (`SearchPartialTitles` etc., Z. 255–259), Settings-Panel `frmSettingsHolder_Movie`/`_TV` |

Publizierte Events (Interface): `ModuleSettingsChanged_*`, `ScraperEvent_*`, `ScraperSetupChanged_*`, `SetupNeedsRestart_*` (Z. 53–62).

## `dlgIMDBSearchResults_Movie`
Datei: `Addons\scraper.IMDB.Data\Scraper\dlgIMDBSearchResults_Movie.vb` (608 Zeilen)

| Methode | Sichtbarkeit | Kurzbeschreibung |
|---------|-------------|------------------|
| `New(SpecialSettings, IMDB As Scraper)` | Public | Übernimmt Scraper-Instanz (Z. 61) |
| `ShowDialog(title, year, filename, filterOptions)` | Public Overloads | Startdialog: setzt `txtSearch`, ruft `_IMDB.SearchMovieAsync` (Z. 71–90) |
| `ShowDialog(Res As SearchResults_Movie, title, filename)` | Public Overloads | Direkte Übergabe eines Ergebnisses (Z. 93–104), aus `GetSearchMovieInfo` |
| `SearchResultsDownloaded(tSearchResults)` | Private | Befüllt `tvResults` mit Kategorien Partial/TV Movie/Video/Short/Popular/Exact; bei allen leer → Knoten "No Matches Found" (Z. 337–462, 454) |
| `btnSearch_Click`, `btnVerify_Click`, `tmrLoad_Tick`, `tvResults_AfterSelect` | Private | Neue Suche (`SearchMovieAsync`), manuelle IMDb-ID-Verifikation via `GetSearchMovieInfoAsync` mit Regex `tt\d{7}` (Z. 124–134, 502) |
| `chkManual_CheckedChanged`, `OK_Button_Click`, `SetPreviewOptions`, `GetMovieClone` | Private | Manueller ID-Modus (`chkManual`/`txtIMDBID`/`btnVerify`), OK-Übernahme in `_tmpMovie`/`Result` |

Abonniert: `_IMDB.SearchResultsDownloaded_Movie`, `_IMDB.SearchInfoDownloaded_Movie` (Z. 242 ff.).

## `dlgIMDBSearchResults_TV`
Datei: `Addons\scraper.IMDB.Data\Scraper\dlgIMDBSearchResults_TV.vb` (435+ Zeilen)

Analog zum Movie-Dialog: `ShowDialog`-Overloads (Z. 72–106), `SearchResultsDownloaded` mit "No Matches Found" (Z. 322–340, 335), manuelle ID via `txtIMDBID`/`btnVerify` → `GetSearchTVShowInfoAsync` (Z. 126–136, 374). Abonniert `SearchResultsDownloaded_TV`, `SearchInfoDownloaded_TV` (Z. 241 ff.).

## `Scraper` (TMDB-Modul, Referenz — API-basiert)
Datei: `Addons\scraper.TMDB.Data\Scraper\clsScrapeTMDB.vb` (Z. 94–1594)

| Methode | Sichtbarkeit | Kurzbeschreibung |
|---------|-------------|------------------|
| `SearchMovie(strMovie, iYear)` | Private | `TMDbClient.SearchMovieAsync` (TMDbLib), Paging bis 3 Seiten, Fallback auf englischen Client `_clientE`, `SearchDeviant` ±1 Jahr (Z. 1362–1449); Ergebnis `SearchResults_Movie.Matches` mit `TMDbId` |
| `SearchTVShow(showName)` | Private | `_client.SearchTvShowAsync`, analoges Paging/Fallback (Z. 1504–1560) |
| `GetTMDBbyIMDB(imdbId)` | Public | Mapping IMDb-ID → TMDb-ID via `_client.FindAsync(FindExternalSource.Imdb)` (Z. 1089–1104) |
| `GetTMDBbyTVDB(tvdbId)` | Public | Mapping TVDb-ID → TMDb-ID (Z. 1106–1121) |
| `GetMovieStudios`, `GetSearchMovieInfo`, `GetInfo_Movie`, `GetInfo_TVShow` u. a. | Public | Detailabrufe komplett über die TMDb-API |

Client-Erzeugung: `New TMDbLib.Client.TMDbClient(_addonSettings.APIKey)` (Z. 166, 172). API-Key: Fallback-Konstante in `TMDB_Data.vb:57` (`_strAPIKey`), eigener Key via `AdvancedSettings` `"APIKey"` (`TMDB_Data.vb:352–353, 397–400`) und `txtApiKey` im Settings-Panel.

## `Scraper` (OMDb-Modul, Referenz)
Datei: `Addons\scraper.Data.OMDb\Scraper\clsScrapeOMDb.vb`

Nutzt die Bibliothek `OpenMovieDatabase` (`OpenMovieDatabaseService`, `_Client`). Vorhanden ist nur `GetRatingsByImbId` → `_Client.SearchMovieByImdbIdAsync` (Z. 76–143) — **keine** titelbasierte Suche implementiert. API-Key-Pflicht: `OMDb_Data.SpecialSettings.APIKey` (`OMDb_Data.vb:418`), Settings `APIKey` je Content-Typ (Z. 200, 209), `CreateAPI` bricht ohne Key ab (Z. 53–70).
