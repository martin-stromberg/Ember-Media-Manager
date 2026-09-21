# Bestandsaufnahme: Logik

## Modul `scraper.Data.IMDB` (`Addons\scraper.IMDB.Data`) — Hauptumfang

### `Scraper` (clsScrapeIMDB.vb)
Datei: `Addons\scraper.IMDB.Data\Scraper\clsScrapeIMDB.vb` (Klasse ab Z. 57)

Alle Netzwerkzugriffe erfolgen über `HtmlAgilityPack.HtmlWeb.Load` auf `imdb.com`-Endpunkte. Insgesamt **19** `HtmlWeb.Load`-Aufrufe auf `imdb.com` in der Datei: `/title/{id}/reference` (Z. 209, 476, 687, 892), `/episodes` (Z. 617, 642, 860), `/releaseinfo` (Z. 1160, 1354), `/parentalguide` (Z. 1206), `/plotsummary` (Z. 1269) sowie die Suchaufrufe (Z. 1425, 1426, 1430, 1433, 1436, 1439, 1442, 1559).

| Methode | Sichtbarkeit | Kurzbeschreibung |
|---------|-------------|------------------|
| `New(SpecialSettings)` (Z. 102) | Public | Konstruktor; speichert `IMDB_Data.SpecialSettings` in `_SpecialSettings` |
| `CancelAsync` (Z. 106–116) | Public | Bricht `bwIMDB` ab und wartet synchron |
| `bwIMDB_DoWork` (Z. 118–138) | Private | Dispatcher auf `SearchMovie`/`SearchTVShow`/`GetMovieInfo`/`GetTVShowInfo` je `SearchType`; **kein Try/Catch** — Exceptions landen in `e.Error`/`e.Result` |
| `bwIMDB_RunWorkerCompleted` (Z. 140–158) | Private | `DirectCast(e.Result, Results)` **ohne `e.Error`-/`e.Cancelled`-Prüfung** — wirft bei Worker-Exception erneut, Ergebnis-Event feuert dann nie |
| `FindYear` (Z. 160–179) | Private | Extrahiert Jahreszahl aus Dateinamen und sucht Index des passenden Treffers in einer `List(Of MediaContainers.Movie)` |
| `GetMovieInfo` (Z. 190 ff.) | Public | Detailabruf Film per IMDb-ID; lädt `/title/{id}/reference` (Z. 209); Try/Catch mit `logger.Error` |
| `GetTVEpisodeInfo` (Z. 463, Überladung Z. 612) | Public | Episoden-Detailabruf (`/episodes?season=`, Z. 617/642) |
| `GetTVSeasonInfo` (Z. 638) | Public | Staffel-Iterierung über `GetTVEpisodeInfo` |
| `GetTVShowInfo` (Z. 668–888) | Public | Serien-Detailabruf (`/reference` Z. 687, `/episodes` Z. 860); Catch → `logger.Error` (Z. 884–887) |
| `GetMovieStudios` (Z. 890–900) | Public | Studio-Liste aus `/title/{id}/reference` (Z. 892); kein Try/Catch |
| `GetSearchMovieInfo` (Z. 902–963) | Public | Heuristik auf `SearchResults_Movie`: Ask → Dialog `dlgIMDBSearchResults_Movie`; Skip → nur `ExactMatches.Count = 1`; Auto/SingleScrape → `Lev <= 5`-Schwelle, `FindYear`, `useAnyway`-Fallback; Catch → `logger.Error` (Z. 959–962) |
| `GetSearchMovieInfoAsync` (Z. 965–976) | Public | Startet `bwIMDB` mit `SearchType.SearchDetails_Movie` (ID → Detailabruf für Dialog-Vorschau) |
| `GetSearchTVShowInfo` (Z. 978–1007) | Public | Serien-Heuristik auf `SearchResults_TVShow.Matches`: Ask → `dlgIMDBSearchResults_TV`; Skip → `Count = 1`; Auto → erster Treffer |
| `GetSearchTVShowInfoAsync` (Z. 1009–1020) | Public | Startet `bwIMDB` mit `SearchType.SearchDetails_TVShow` |
| `ParseActors` … `ParseTagline` (Z. 1022–1411) | Private | 16 Parse-Methoden auf dem alten IMDb-`/reference`-Markup (`ParseForcedTitle`/`ParsePlotFromSummaryPage`/`ParseMPAA`/`ParsePremiered` laden weitere Unterseiten) |
| `SearchMovie` (Z. 1413–1541) | Private | **Defekt:** lädt `/find?q=…&s=tt&ttype=ft` (Z. 1425), `…&exact=true` (Z. 1426) sowie settingsabhängig `/search/title?title_type=tv_movie|video|short` (Z. 1430/1433/1436) und `/find?ref_=fn_ft`/`fn_tt_pop` (Z. 1439/1442); parst `//table[@class="findList"]/tr[@class]/td[2]` (Z. 1452, 1467, 1527) und `//span[@title]` (Z. 1482, 1497, 1512); befüllt alle sechs `SearchResults_Movie`-Kategorien mit `Lev` via `StringUtils.ComputeLevenshtein`, `IMDbId` via `StringUtils.GetIMDBIDFromString`, `Year` via Regex `\((\d{4})`; Redirect auf Filmseite (REGEX `tt\d{7}`) → leeres Ergebnis (Z. 1446–1448); **kein Try/Catch** |
| `SearchMovieAsync` (Z. 1543–1553) | Public | Startet `bwIMDB` mit `SearchType.Movies`; aufgerufen von `dlgIMDBSearchResults_Movie.ShowDialog`/`btnSearch_Click` |
| `SearchTVShow` (Z. 1555–1581) | Private | **Defekt:** lädt `/search/title?title=…&title_type=tv_series&view=simple` (Z. 1559–1561), parst `//div[@class="lister-item mode-simple"]` (Z. 1563), IMDb-ID aus `img[data-tconst]` (Z. 1568), Titel aus `img[alt]`; befüllt `Matches`; kein Try/Catch |
| `SearchTVShowAsync` (Z. 1583–1591) | Public | Startet `bwIMDB` mit `SearchType.TVShows`; aufgerufen von `dlgIMDBSearchResults_TV`; **kein Try/Catch** (anders als `SearchMovieAsync`) |

Publizierte Events: `Exception` (Z. 90, wird nirgends in der Klasse gefeuert), `SearchInfoDownloaded_Movie`/`_TV` (Z. 92–93), `SearchResultsDownloaded_Movie`/`_TV` (Z. 95–96).
Abonnierte Events: `bwIMDB.DoWork`, `bwIMDB.RunWorkerCompleted` (`Handles`-Klauseln).
Hilfsfelder: `Private Enum SearchType` (Z. 78–84), `REGEX_IMDBID` = `"tt\d\d\d\d\d\d\d"` (Z. 66), `Private Structure Arguments`/`Results` (Z. 1597–1623).

**Nicht vorhanden:** `TMDbClient`-Instanz, `CreateAPI`-Methode, jegliche API-Key-Behandlung.

### `IMDB_Data` (IMDB_Data.vb)
Datei: `Addons\scraper.IMDB.Data\IMDB_Data.vb` (Klasse ab Z. 25)

Implementiert `Interfaces.ScraperModule_Data_Movie` und `Interfaces.ScraperModule_Data_TV`.

| Methode | Sichtbarkeit | Kurzbeschreibung |
|---------|-------------|------------------|
| `Init_Movie` / `Init_TV` (Z. 128–136) | Public (Impl.) | Setzt `_AssemblyName`, lädt Settings |
| `InjectSetupScraper_Movie` (Z. 138–186) | Public (Impl.) | Erzeugt `frmSettingsHolder_Movie`, belegt u. a. die fünf `chk*Titles`-Checkboxen aus `SpecialSettings` (Z. 165–169); `SPanel.Order = 110`, Prefix `IMDBMovieInfo_` |
| `InjectSetupScraper_TV` (Z. 188–231) | Public (Impl.) | Erzeugt `frmSettingsHolder_TV`; Prefix `IMDBTVInfo_` |
| `LoadSettings_Movie` (Z. 233–261) | Public | Liest `AdvancedSettings` (ContentType.Movie); lädt die fünf `Search*Titles`-Settings (Z. 255–259, Defaults: Partial/Popular `True`, Tv/Video/Short `False`) |
| `LoadSettings_TV` (Z. 263–286) | Public | Liest `AdvancedSettings` (ContentType.TVEpisode/TVShow); **kein** `APIKey`-Setting |
| `SaveSettings_Movie` (Z. 288–317) | Public | Schreibt alle Settings inkl. der fünf `Search*Titles` (Z. 309–313) |
| `SaveSettings_TV` (Z. 319–343) | Public | Schreibt TV-Settings |
| `SaveSetupScraper_Movie` / `_TV` (Z. 345–381 / 382–412) | Public (Impl.) | Überträgt Panel-Zustände in `ConfigScrapeOptions*`/`_SpecialSettings_*` und speichert |
| `GetMovieStudio` (Z. 414–425) | Public (Impl.) | Studio-Liste via `Scraper.GetMovieStudios` (IMDb-ID erforderlich) |
| `GetTMDbIdByIMDbId` (Z. 427–429) | Public (Impl.) | **Leerer Stub** — gibt nur `New ModuleResult With {.breakChain = False}` zurück, `tmdbId` bleibt unberührt |
| `Scraper_Movie` (Z. 437–488) | Public (Impl.) | Bei `MainNFO AndAlso Not DoSearch`: IMDb-ID vorhanden → `GetMovieInfo`; sonst (nicht SingleScrape) → `GetSearchMovieInfo`. Bei `SingleScrape`/`SingleAuto` ohne IMDb-/TMDb-ID → `dlgIMDBSearchResults_Movie` (Z. 473–482); OK → `GetMovieInfo` + `ScrapeModifiers.DoSearch = False` (Z. 477); Abbruch → `ModuleResult_Data_Movie.Cancelled = True` (Z. 480) → bricht `ModulesManager`-Kette ab |
| `Scraper_TV` (Z. 496–550) | Public (Impl.) | Analog für Serien mit `dlgIMDBSearchResults_TV` (Z. 535–543); `Cancelled` bei Z. 542 |
| `Scraper_TVEpisode` (Z. 552–573) | Public (Impl.) | Episoden via `GetTVEpisodeInfo` (IMDb-ID erforderlich) |
| `Scraper_TVSeason` (Z. 575–577) | Public (Impl.) | Gibt immer `Result = Nothing` zurück (Stub) |
| `ScraperOrderChanged_Movie` / `_tv` (Z. 579–585) | Public (Impl.) | Delegiert an `_setup_*.orderChanged()` |

Felder: `ConfigScrapeOptions_Movie`/`_TV`, `ConfigScrapeModifier_Movie`/`_TV` (`Shared`), `_SpecialSettings_Movie`/`_TV`, `_ScraperEnabled_Movie`/`_TV`. **Kein** `_strAPIKey`-Fallback, kein `strPrivateAPIKey`.

## Modul `scraper.Data.TMDB` (`Addons\scraper.TMDB.Data`) — Referenzimplementierung

### `Scraper` (clsScrapeTMDB.vb)
Datei: `Addons\scraper.TMDB.Data\Scraper\clsScrapeTMDB.vb` (Klasse ab Z. 94)

Felder: `Private _client As TMDbLib.Client.TMDbClient` (Z. 100), `Private _clientE` (englischer Fallback, Z. 101), `_addonSettings` (Z. 102), `bwTMDB` (Z. 111).

| Methode | Sichtbarkeit | Kurzbeschreibung |
|---------|-------------|------------------|
| `CreateAPI` (Z. 162–184) | Public Async | Erzeugt `New TMDbLib.Client.TMDbClient(_addonSettings.APIKey)`, `Await GetConfigAsync()`, `MaxRetryCount = 2`; bei `FallBackEng` zweiter Client `_clientE` mit `DefaultLanguage = "en-US"`; Catch → `_Logger.Error` |
| `bwTMDB_DoWork` (Z. 186–225) | Private | Dispatcher auf `SearchMovie`/`SearchMovieSet`/`SearchTVShow`/`GetInfo_*`; **kein Try/Catch** |
| `bwTMDB_RunWorkerCompleted` (Z. 227–252) | Private | `DirectCast(e.Result, Results)` **ohne `e.Error`-Prüfung** — Exception → Ergebnis-Event feuert nie |
| `CancelAsync` (Z. 254–261) | Public | Abbrechen + synchrones Warten |
| `GetMovieID` (Z. 263 ff.) | Public | `GetMovieAsync` mit IMDb-/TMDb-ID; befüllt `DBMovie.Movie.UniqueIDs.TMDbId` |
| `GetInfo_Movie` (Z. 316 ff.) | Public | `GetMovieAsync(id, Credits Or Releases Or Videos)`; übernimmt `Result.ImdbId` → `UniqueIDs.IMDbId` (Z. 344); Englisch-Fallback via `RunFallback_Movie` |
| `GetInfo_TVShow` (Z. ~889 ff.) | Public | `GetTvShowAsync(id, ContentRatings Or Credits Or ExternalIds)` (Z. 889); `ExternalIds.TvdbId`/`ImdbId` → `UniqueIDs` (Z. 901–902) |
| `GetInfo_TVEpisode`/`_TVSeason`/`_Movieset` | Public | Analog; `TvEpisodeMethods`/`TvSeasonMethods.ExternalIds` |
| `GetTMDBbyIMDB` (Z. 1089–1104) | Public | `FindAsync(FindExternalSource.Imdb, imdbId)` → `TvResults(0).Id`; **mit** `APIResult.Exception`-Prüfung (Z. 1094); Catch → `_Logger.Error` |
| `GetTMDBbyTVDB` (Z. 1106 ff.) | Public | Analog für TVDb-ID |
| `GetSearchMovieInfo` (Z. 1150–1179) | Public | Heuristik auf `SearchResults_Movie.Matches` (Ask→Dialog, Skip→Count=1, Auto→erster Treffer); kein `Lev`-Vergleich |
| `GetSearchMovieSetInfo` (Z. 1181–1210) | Public | Analog für MovieSets |
| `GetSearchTVShowInfo` (Z. 1212–1241) | Public | Analog für Serien |
| `GetSearchMovieInfoAsync`/`_MovieSet`/`_TVShow` (Z. 1243–1271) | Public | Detailabruf für Dialog-Vorschau via `bwTMDB` |
| `SearchAsync_Movie` (Z. 1328–1340) | Public | Startet `bwTMDB` mit `SearchType.Movies` (Parameter Titel + Jahr als Integer) |
| `SearchAsync_MovieSet` (Z. 1342–1350), `SearchAsync_TVShow` (Z. 1352–1360) | Public | Analoge Worker-Einstiege |
| `SearchMovie` (Z. 1362–1449) | Private | `_client.SearchMovieAsync(strMovie, Page, GetAdultItems, iYear)` (Z. 1372); **liest `APIResult.Result` ohne Exception-Prüfung** (Z. 1374 u. a.) → `AggregateException`/`NullReferenceException` bei API-Fehler; Fallback-Englisch und Jahr ±1 (`SearchDeviant`); iteriert bis `Page <= 3`; mappt `SearchMovie`-Treffer auf `MediaContainers.Movie` mit `UniqueIDs.TMDbId` (Z. 1431) — **kein** `IMDbId`, kein `Lev` |
| `SearchMovieSet` (Z. 1451–1502) | Private | `SearchCollectionAsync`; gleiche `APIResult.Result`-Lücke |
| `SearchTVShow` (Z. 1504–1560) | Private | `_client.SearchTvShowAsync(showName, Page)` (Z. 1514); `APIResult.Result` ungeprüft (Z. 1516); mappt auf `MediaContainers.TVShow` mit `UniqueIDs.TMDbId` (Z. 1544) |

Publizierte Events: `SearchInfoDownloaded_Movie`/`_MovieSet`/`_TVShow`, `SearchResultsDownloaded_Movie`/`_MovieSet`/`_TVShow` (Z. 150–156).

### `TMDB_Data` (TMDB_Data.vb)
Datei: `Addons\scraper.TMDB.Data\TMDB_Data.vb` (Klasse ab ~Z. 28)

Implementiert `ScraperModule_Data_Movie`, `ScraperModule_Data_MovieSet`, `ScraperModule_Data_TV`.

- `Private Const _strAPIKey As String = "44810eef…"` (Z. 57) — eingebetteter Fallback-Key.
- `APIKey`-Setting-Muster: `LoadSettings_Movie` Z. 352–353, `LoadSettings_MovieSet` Z. 363–366, `LoadSettings_TV` Z. 397–400 (`GetSetting("APIKey", String.Empty, , ContentType.*)` + Fallback `If(IsNullOrEmpty, _strAPIKey, key)`); `SaveSettings_*` Z. 429/438/472 (`SetSetting("APIKey", _setup_*.txtApiKey.Text.Trim, …)`); `SaveSetupScraper_*` erkennt Key-Änderung und ruft `CreateAPI` neu (Z. 497–506, 519–527, 563–571).
- `ScraperEnabled_*`-Setter starten `Task.Run(CreateAPI)` (Z. 103–105, 115–117, 127–129); `GetMovieStudio`/`GetTMDbIdByIMDbId`/`GetCollectionID` prüfen `IsClientCreated` und erstellen den Client bei Bedarf (Z. 586–588, 605–607, 621–623).
- `GetTMDbIdByIMDbId` (Z. 602–616) — **implementiert** (im Gegensatz zum IMDb-Stub).
- `Scraper_Movie` (Z. 642–697): `dlgTMDBSearchResults_Movie` bei SingleScrape/SingleAuto (Z. 682–691), `DoSearch = False` (Z. 686), `Cancelled = True` (Z. 689).
- `Scraper_MovieSet` (Z. 699 ff.), `Scraper_TV` (Z. ~759–822, Dialog `dlgTMDBSearchResults_TV` Z. 807–816, `Cancelled` Z. 814), `Scraper_TVEpisode` (Z. 824–856), `Scraper_TVSeason` (Z. 858–888).

## Framework (`EmberAPI`) — nur diagnostisch relevant

### `ModulesManager` (clsAPIModules.vb)
Datei: `EmberAPI\clsAPIModules.vb`

| Methode | Sichtbarkeit | Kurzbeschreibung |
|---------|-------------|------------------|
| `ScrapeData_Movie` (Z. 915–1007) | Public | Iteriert aktivierte Daten-Scraper sequenziell in `ModuleOrder` (Z. 918); Logzeile `[Using] {ModuleName}` (Z. 944); `ret.Cancelled` → sofortiger `Return` (Z. 949, nachfolgende Scraper werden nie erreicht); `ret.breakChain` → `Exit For` (Z. 969); übernimmt `UniqueIDs` des Treffers in `oDBMovie` für Folge-Scraper (Z. 955–957) |
| `ScrapeData_TVShow` (Z. 1215 ff.) | Public | Analog; `Cancelled`-Abbruch Z. 1260; `AddRange` der UniqueIDs Z. 1267 |
| `GetMovieTMDbIdByIMDbId` (Z. 183–197) | Public | Ruft `GetTMDbIdByIMDbId` aller aktivierten Movie-Daten-Scraper auf; erster Treffer mit `tmdbId > -1` gewinnt |

### `StringUtils` (clsAPIStringUtils.vb)
Datei: `EmberAPI\clsAPIStringUtils.vb`

| Methode | Sichtbarkeit | Kurzbeschreibung |
|---------|-------------|------------------|
| `ComputeLevenshtein` (Z. 303) | Public Shared | Levenshtein-Distanz; Basis der `Lev`-Heuristik (`<= 5` in `GetSearchMovieInfo`) |
| `FilterYear` (Z. 517) | Public Shared | Entfernt Jahresangabe aus Titelstring (für Lev-Vergleich) |
| `GetIMDBIDFromString` (Z. 610) | Public Shared | Extrahiert `tt\d+`-IMDb-ID aus beliebigem Text/HTML |

### `Functions` (clsAPICommon.vb)
- `ScrapeOptionsAndAlso` (Z. 1298–1338), `ScrapeModifiersAndAlso` (Z. 1340–1380), `SetScrapeModifiers` (Z. 1425 ff., `ModifierType.DoSearch` Z. 1474–1475).

### `AdvancedSettings` (clsAPIAdvancedSettings.vb)
- `GetBooleanSetting` (Z. 86), `GetSetting` (Z. 110), `SetSetting` (Z. 335) — je mit optionalem `cContent As Enums.ContentType`; Muster für das neue `APIKey`-Setting.

### TLS
`EmberMediaManager\ApplicationEvents.vb:45` — `ServicePointManager.SecurityProtocol Or Tls11 Or Tls12` beim Start.

## Modul `scraper.Data.OMDb` (`Addons\scraper.Data.OMDb`) — Alternative Schnittstelle

### `Scraper` (clsScrapeOMDb.vb)
Datei: `Addons\scraper.Data.OMDb\Scraper\clsScrapeOMDb.vb`

| Methode | Sichtbarkeit | Kurzbeschreibung |
|---------|-------------|------------------|
| `CreateAPI` (Z. 53–70) | Public | `OpenMovieDatabaseService(HttpClient, OpenMovieDatabaseOptions(APIKey))`; **bricht ohne Key ab** (`_Logger.Error`, Z. 67) |
| `GetRatingsByImbId` (Z. 76–143) | Public | Einzige Datenmethode; ruft `_Client.SearchMovieByImdbIdAsync(ImdbId)` (Z. 84) — nur IMDb-ID→Ratings, **keine Titelsuche**; `APIResult.Exception`-Prüfung vorhanden (Z. 90) |

Die NuGet-Bibliothek `MovieCollection.OpenMovieDatabase` 3.0.1 enthält laut mitgelieferter XML-Doku zusätzlich `SearchMoviesAsync`/`SearchMovieAsync` (verifiziert in `packages\MovieCollection.OpenMovieDatabase.3.0.1\lib\net451\MovieCollection.OpenMovieDatabase.xml`) — im Modul nicht verdrahtet.

### `OMDb_Data` (OMDb_Data.vb)
`SpecialSettings`-Klasse (Z. 408–428) mit `APIKey`; `LoadSettings_Movie`/`_TV` (Z. 200, 209) ohne Fallback-Key; `txtApiKey` in beiden Settings-Panels (Z. 154, 180); `SaveSetupScraper_*` mit `bAPIKeyChanged`→`CreateAPI`-Neuaufruf (Z. 234–244, 254–263).

## Suchdialoge und Settings-Panels (`scraper.Data.IMDB`)

### `dlgIMDBSearchResults_Movie`
Datei: `Addons\scraper.IMDB.Data\Scraper\dlgIMDBSearchResults_Movie.vb`

- `ShowDialog(sMovieTitle, sMovieYear, sMovieFilename, filterOptions)` (Z. 71–91): startet `_IMDB.SearchMovieAsync` (Z. 88); Überladung `ShowDialog(Res, …)` (Z. 93–105) rendert vorhandene `SearchResults_Movie` direkt.
- `SearchResultsDownloaded` (Z. 337–462): rendert die sechs Kategorien als `tvResults`-Knoten (Reihenfolge Partial→Tv→Video→Short→Popular→Exact); bei allen Listen leer → Knoten „No Matches Found" (Z. 454); danach `pnlLoading.Visible = False`, `chkManual.Enabled = True`. **Kein Fehlerpfad** — ein Scraper-Fehler erreicht diesen Handler nie (siehe `bwIMDB_RunWorkerCompleted`).
- `OK_Button` ist erst nach geladenem Detail-Info aktiv (`SearchMovieInfoDownloaded` → `OK_Button.Enabled = True`, Z. 288); Detailabruf läuft über `_IMDB.GetSearchMovieInfoAsync` → `GetMovieInfo` (defekter `/reference`-Endpunkt).
- Manuelle ID-Eingabe: `chkManual` (Z. 186–200), `txtIMDBID`, `btnVerify` mit Regex `tt\d{7}` (Z. 127) → `GetSearchMovieInfoAsync`; unverifizierte Eingabe möglich nach Confirm-MessageBox (`OK_Button_Click` Z. 260–280).
- `Result`-Property (Z. 51–55) liefert `_tmpMovie` (mit `UniqueIDs.IMDbId`).

### `dlgIMDBSearchResults_TV`
Datei: `Addons\scraper.IMDB.Data\Scraper\dlgIMDBSearchResults_TV.vb`

- Analog: `ShowDialog` startet `SearchTVShowAsync` (Z. 90); `SearchResultsDownloaded` (Z. 322–339) rendert `Matches` flach, sonst „No Matches Found" (Z. 335); `btnVerify` (Z. 126–135) prüft `tt\d{7}` → `GetSearchTVShowInfoAsync`; `OK_Button` erst nach `SearchInfoDownloaded` aktiv (Z. 278).

### `frmSettingsHolder_Movie` / `frmSettingsHolder_TV` (IMDb-Modul)
Dateien: `Addons\scraper.IMDB.Data\frmSettingsHolder_Movie.vb` + `.Designer.vb`, `frmSettingsHolder_TV.vb` + `.Designer.vb`

- Movie-Panel enthält die fünf Checkboxen `chkPopularTitles`, `chkPartialTitles`, `chkTvTitles`, `chkVideoTitles`, `chkShortTitles` in `tblScraperOpts` (Designer Z. 525–532, Felder Z. 766–770); `CheckedChanged`-Handler feuern `ModuleSettingsChanged` (frmSettingsHolder_Movie.vb Z. 96–164); Texte in `Setup()` (Z. 210–221).
- **Kein** `txtApiKey`/`lblApiKey`/`pbTMDBApiKeyInfo` in beiden Panels (Verweis-Muster in `Addons\scraper.TMDB.Data\frmSettingsHolder_*.Designer.vb`, z. B. `txtApiKey` Z. 189–195, `pbTMDBApiKeyInfo` Z. 143–152, `lblApiKey` Z. 153–168).
- `orderChanged()` nutzt `ModulesManager.Instance.externalScrapersModules_Data_Movie` für die Scrape-Order-Buttons (Z. 186–195).
