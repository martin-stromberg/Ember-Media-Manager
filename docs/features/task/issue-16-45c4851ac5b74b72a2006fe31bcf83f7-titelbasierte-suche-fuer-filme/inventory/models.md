# Bestandsaufnahme: Datenmodell

## Modul `scraper.Data.IMDB` (`Addons\scraper.IMDB.Data`)

### `SearchResults_Movie`
Datei: `Addons\scraper.IMDB.Data\Scraper\clsScrapeIMDB.vb` (Z. 27–45)

Ergebniscontainer der Filmsuche; wird von `Scraper.SearchMovie` befüllt und per Event `SearchResultsDownloaded_Movie` an `dlgIMDBSearchResults_Movie` geliefert. Alle Eigenschaften sind Auto-Properties mit initialisierten Listen.

| Eigenschaft | Typ | Beschreibung / Zweck |
|-------------|-----|----------------------|
| `ExactMatches` | `List(Of MediaContainers.Movie)` | Exakte Titel-Treffer (aus `/find?...&exact=true`); Heuristik-Priorität in `GetSearchMovieInfo` |
| `PartialMatches` | `List(Of MediaContainers.Movie)` | Partielle Treffer (`/find?...&ref_=fn_ft`); settingsabhängig (`SearchPartialTitles`) |
| `PopularTitles` | `List(Of MediaContainers.Movie)` | Populäre Treffer (`/find?...&ref_=fn_tt_pop`); settingsabhängig (`SearchPopularTitles`); wird von der Heuristik mit `Lev <= 5` ausgewertet |
| `TvTitles` | `List(Of MediaContainers.Movie)` | TV-Movie-Treffer (`/search/title?title_type=tv_movie`); settingsabhängig (`SearchTvTitles`) |
| `VideoTitles` | `List(Of MediaContainers.Movie)` | Video-Treffer (`/search/title?title_type=video`); settingsabhängig (`SearchVideoTitles`) |
| `ShortTitles` | `List(Of MediaContainers.Movie)` | Kurzfilm-Treffer (`/search/title?title_type=short`); settingsabhängig (`SearchShortTitles`) |

### `SearchResults_TVShow`
Datei: `Addons\scraper.IMDB.Data\Scraper\clsScrapeIMDB.vb` (Z. 47–55)

| Eigenschaft | Typ | Beschreibung / Zweck |
|-------------|-----|----------------------|
| `Matches` | `List(Of MediaContainers.TVShow)` | Serientreffer (aus `/search/title?title_type=tv_series`); Event `SearchResultsDownloaded_TV` → `dlgIMDBSearchResults_TV` |

### `IMDB_Data.SpecialSettings` (Structure)
Datei: `Addons\scraper.IMDB.Data\IMDB_Data.vb` (Z. 591–608)

| Feld | Typ | Beschreibung / Zweck |
|------|-----|----------------------|
| `FallBackWorldwide` | `Boolean` | Setting `FallBackWorldwide` (Default `False`) |
| `ForceTitleLanguage` | `String` | Setting `ForceTitleLanguage` (Default `String.Empty`) |
| `MPAADescription` | `Boolean` | Setting `MPAADescription` (Default `False`) |
| `PrefLanguage` | `String` | Laufzeitwert, gesetzt aus `oDBElement.Language` (`Scraper_Movie` Z. 443, `Scraper_TV` Z. 502); kein persistiertes Setting |
| `SearchPartialTitles` | `Boolean` | Setting `SearchPartialTitles` (Default `True`); steuert `/find?ref_=fn_ft`-Laden in `SearchMovie` |
| `SearchPopularTitles` | `Boolean` | Setting `SearchPopularTitles` (Default `True`); steuert `ref_=fn_tt_pop`-Laden |
| `SearchTvTitles` | `Boolean` | Setting `SearchTvTitles` (Default `False`); steuert `title_type=tv_movie`-Laden |
| `SearchVideoTitles` | `Boolean` | Setting `SearchVideoTitles` (Default `False`); steuert `title_type=video`-Laden |
| `SearchShortTitles` | `Boolean` | Setting `SearchShortTitles` (Default `False`); steuert `title_type=short`-Laden |
| `StudiowithDistributors` | `Boolean` | Setting `StudiowithDistributors` (Default `False`) |

**Nicht vorhanden:** ein `APIKey`-Feld (anders als `TMDB_Data.SpecialSettings`).

### `Scraper.Arguments` / `Scraper.Results` (Private Structures)
Datei: `Addons\scraper.IMDB.Data\Scraper\clsScrapeIMDB.vb` (Z. 1597–1623)

- `Arguments` (Z. 1597–1612): `FullCast`, `FullCrew`, `Options_Movie`, `Options_TV` (`Structures.ScrapeOptions`), `Parameter` (String), `ScrapeModifiers` (`Structures.ScrapeModifiers`), `Search` (`SearchType`), `Year` (String) — BackgroundWorker-Payload.
- `Results` (Z. 1614–1623): `Result` (Object), `ResultType` (`SearchType`) — BackgroundWorker-Ergebnis.

## Modul `scraper.Data.TMDB` (`Addons\scraper.TMDB.Data`)

### `SearchResults_Movie` / `SearchResults_MovieSet` / `SearchResults_TVShow`
Datei: `Addons\scraper.TMDB.Data\Scraper\clsScrapeTMDB.vb` (Z. 25–92)

Drei getrennte Klassen mit je einer Eigenschaft `Matches` (`List(Of MediaContainers.Movie)` Z. 35 / `List(Of MediaContainers.Movieset)` Z. 58 / `List(Of MediaContainers.TVShow)` Z. 81). Namensgleich mit den IMDb-Containern, aber flacher (keine Kategorien).

### `TMDB_Data.SpecialSettings` (Structure)
Datei: `Addons\scraper.TMDB.Data\TMDB_Data.vb` (Z. 906–917)

| Feld | Typ | Beschreibung / Zweck |
|------|-----|----------------------|
| `APIKey` | `String` | Aus `AdvancedSettings.GetSetting("APIKey", ..., ContentType.*)`; leer → Fallback-Konstante `_strAPIKey` (Z. 57) |
| `FallBackEng` | `Boolean` | Setting `FallBackEn`; aktiviert englischen Fallback-Client `_clientE` |
| `GetAdultItems` | `Boolean` | Setting `GetAdultItems`; Parameter `includeAdult` von `SearchMovieAsync` |
| `SearchDeviant` | `Boolean` | Setting `SearchDeviant`; Jahr ±1-Wiederholung in `SearchMovie` |

## Modul `scraper.Data.OMDb` (`Addons\scraper.Data.OMDb`)

### `OMDb_Data.SpecialSettings` (Class)
Datei: `Addons\scraper.Data.OMDb\OMDb_Data.vb` (Z. 408–428)

| Eigenschaft | Typ | Beschreibung / Zweck |
|-------------|-----|----------------------|
| `APIKey` | `String` | Pflicht-Key ohne Fallback (Setting `APIKey` je ContentType; `CreateAPI` bricht ohne Key ab, `clsScrapeOMDb.vb:66–69`) |
| `IMDb` / `Metascore` / `Tomatometer` | `Boolean` | Rating-Quellen-Schalter |
| `AnyRatingEnabled` | `Boolean` (ReadOnly) | Oder-Verknüpfung der drei Rating-Schalter |

## Framework (`EmberAPI`)

### `MediaContainers.Movie`
Datei: `EmberAPI\clsAPIMediaContainers.vb` (Klasse ab Z. 1150)

| Eigenschaft | Typ | Beschreibung / Zweck |
|-------------|-----|----------------------|
| `Title` | `String` (Z. 1244) | Filmtitel; `TitleSpecified` (Z. 1247) |
| `OriginalTitle` | `String` | Originaltitel (befüllt in `clsScrapeTMDB.SearchMovie` Z. 1427) |
| `Year` | `String` (Z. 1304) | Jahr; `YearSpecified` (Z. 1320) |
| `Premiered` | `String` (Z. 1348) | Premierendatum |
| `Lev` | `Integer` (Z. 1771, `XmlIgnore`) | Levenshtein-Score des Suchtreffers; gesetzt in `clsScrapeIMDB.SearchMovie` (Z. 1456 u. a.); Schwellwert `<= 5` in `GetSearchMovieInfo` |
| `UniqueIDs` | `UniqueidContainer` (Z. 1224) | siehe unten; `UniqueIDsSpecified` (Z. 1227) |
| `ThumbPoster` | `MediaContainers.Image` | Poster-URLs (`URLOriginal`/`URLThumb`); befüllt in `clsScrapeTMDB.SearchMovie` Z. 1419–1422 |
| `Plot` | `String` | Handlung; befüllt aus TMDb-`Overview` (Z. 1418/1429) |

### `MediaContainers.TVShow`
Datei: `EmberAPI\clsAPIMediaContainers.vb` (Klasse ab Z. 2772)

| Eigenschaft | Typ | Beschreibung / Zweck |
|-------------|-----|----------------------|
| `Title` | `String` (Z. 2845) | Serientitel |
| `Premiered` | `String` (Z. 3081) | Jahr der Erstausstrahlung (befüllt aus `FirstAirDate` in `clsScrapeTMDB.SearchTVShow` Z. 1542) |
| `UniqueIDs` | `UniqueidContainer` (Z. 2825) | siehe unten |

### `MediaContainers.UniqueidContainer`
Datei: `EmberAPI\clsAPIMediaContainers.vb` (Z. 4649–4772)

Liste `Items` von `Uniqueid` (Type/Value/IsDefault); typsichere Zugriffs-Properties:

| Eigenschaft | Typ | Beschreibung / Zweck |
|-------------|-----|----------------------|
| `IMDbId` | `String` (Z. 4677) | Item `"imdb"`; `IMDbIdSpecified` (Z. 4693) |
| `TMDbId` | `Integer` (Z. 4700) | Item `"tmdb"`, `-1` = nicht gesetzt; `TMDbIdSpecified` (Z. 4718) |
| `TMDbCollectionId` | `Integer` (Z. 4725) | Item `"tmdbcol"` |
| `TVDbId` | `Integer` (Z. 4750) | Item `"tvdb"` |
| `Add`/`AddRange`/`GetDefaultId` | Methoden (Z. 4778 ff.) | Pflege der ID-Liste; `AddRange` wird von `ScrapeData_Movie`/`ScrapeData_TVShow` zur Übergabe an Folge-Scraper genutzt (`clsAPIModules.vb:956`, `1267`) |

### `Interfaces.ModuleResult*`
Datei: `EmberAPI\clsAPIInterfaces.vb` (Z. 398–534)

| Struktur | Felder | Zweck |
|----------|--------|-------|
| `ModuleResult` (Z. 398–414) | `breakChain`, `Cancelled` (Boolean) | Basis-Rückgabe |
| `ModuleResult_Data_Movie` (Z. 420–438) | + `Result As MediaContainers.Movie` | Rückgabe von `Scraper_Movie`; `Cancelled` bricht die Kette ab (`clsAPIModules.vb:949`), `breakChain` beendet sie (Z. 969) |
| `ModuleResult_Data_TVShow` (Z. 516–534) | + `Result As MediaContainers.TVShow` | Rückgabe von `Scraper_TVShow`; `Cancelled`-Abbruch `clsAPIModules.vb:1260` |
| `ModuleResult_Data_MovieSet` / `_TVEpisode` / `_TVSeason` | analog | weitere Content-Typen |

### `Structures.ScrapeModifiers`
Datei: `EmberAPI\clsAPICommon.vb` (Z. 1695–1784)

37 `Boolean`-Felder; für diese Anforderung relevant: `DoSearch` (Z. 1703 — erzwingt Suche bei SingleScrape/SingleAuto), `MainNFO` (Z. 1723 — Gate für den Suchpfad in `Scraper_Movie`/`Scraper_TV`), `withEpisodes`/`withSeasons`, `EpisodeNFO`/`SeasonNFO` (Gates in `Scraper_TV` Z. 506–509). Property `AnyEnabled` (Z. 1741).

### `Structures.ScrapeOptions`
Datei: `EmberAPI\clsAPICommon.vb` (Z. 1790–1832, `<Serializable>`)

41 `Boolean`-Felder `bMain*`/`bEpisode*`/`bSeason*` (z. B. `bMainTitle`, `bMainRating`, `bMainPremiered`). Werden per `Functions.ScrapeOptionsAndAlso` (Z. 1298–1338) mit den Modul-Config-Optionen verUNDet.
