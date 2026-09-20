# Datenmodell — Bestandsaufnahme

## `SearchResults_Movie` (IMDb-Modul)
Datei: `Addons\scraper.IMDB.Data\Scraper\clsScrapeIMDB.vb` (Z. 27–45)

Ergebniscontainer der IMDb-Titelsuche für Filme. Wird von `Scraper.SearchMovie` befüllt, von `Scraper.GetSearchMovieInfo` ausgewertet und an `dlgIMDBSearchResults_Movie` übergeben (Tree-Kategorien).

| Eigenschaft | Typ | Beschreibung / Zweck |
|-------------|-----|----------------------|
| `ExactMatches` | `List(Of MediaContainers.Movie)` | Treffer aus `/find?...&exact=true` (Z. 1526–1537) |
| `PartialMatches` | `List(Of MediaContainers.Movie)` | Treffer aus `/find?...&ref_=fn_ft` (Z. 1466–1478) |
| `PopularTitles` | `List(Of MediaContainers.Movie)` | Treffer aus `/find?...&ref_=fn_tt_pop` (Z. 1451–1463) |
| `TvTitles` | `List(Of MediaContainers.Movie)` | TV-Movies aus `/search/title?title_type=tv_movie` (Z. 1481–1493) |
| `VideoTitles` | `List(Of MediaContainers.Movie)` | Videos aus `/search/title?title_type=video` (Z. 1496–1508) |
| `ShortTitles` | `List(Of MediaContainers.Movie)` | Shorts aus `/search/title?title_type=short` (Z. 1511–1523) |

Alle Listen werden leer initialisiert; bei komplett leeren Listen zeigt der Dialog "No Matches Found" (`dlgIMDBSearchResults_Movie.vb:454`).

## `SearchResults_TVShow` (IMDb-Modul)
Datei: `Addons\scraper.IMDB.Data\Scraper\clsScrapeIMDB.vb` (Z. 47–55)

| Eigenschaft | Typ | Beschreibung / Zweck |
|-------------|-----|----------------------|
| `Matches` | `List(Of MediaContainers.TVShow)` | Einzige Kategorie; befüllt aus `/search/title?title_type=tv_series&view=simple` (Z. 1563–1577); `Tag` im Dialog trägt die IMDb-ID |

## `IMDB_Data.SpecialSettings`
Datei: `Addons\scraper.IMDB.Data\IMDB_Data.vb` (Z. 591–608)

Structure, wird an den `Scraper`-Konstruktor übergeben und steuert u. a. die Suchabfragen.

| Feld | Typ | Beschreibung / Zweck |
|------|-----|----------------------|
| `FallBackWorldwide` | `Boolean` | Fallback "worldwide" für Premiered/MPAA (AdvancedSettings `FallBackWorldwide`, Z. 252) |
| `ForceTitleLanguage` | `String` | Sprache für erzwungenen Titel (`ForceTitleLanguage`, Z. 253) |
| `MPAADescription` | `Boolean` | MPAA-Beschreibungstext (`MPAADescription`, Z. 254) |
| `PrefLanguage` | `String` | Scraper-Sprache, wird in `Scraper_Movie`/`Scraper_TV` aus `oDBElement.Language` gesetzt (Z. 443, 502) |
| `SearchPartialTitles` | `Boolean` | Zusatzsuche Partial Titles (`SearchPartialTitles`, Z. 255, Default `True`) |
| `SearchPopularTitles` | `Boolean` | Zusatzsuche Popular Titles (`SearchPopularTitles`, Z. 256, Default `True`) |
| `SearchTvTitles` | `Boolean` | Zusatzsuche TV-Movie-Titles (`SearchTvTitles`, Z. 257, Default `False`) |
| `SearchVideoTitles` | `Boolean` | Zusatzsuche Video-Titles (`SearchVideoTitles`, Z. 258, Default `False`) |
| `SearchShortTitles` | `Boolean` | Zusatzsuche Short-Titles (`SearchShortTitles`, Z. 259, Default `False`) |
| `StudiowithDistributors` | `Boolean` | Studios inkl. Distributoren (`StudiowithDistributors`, Z. 260) |

## `MediaContainers.Movie` (verwendete Member)
Datei: `EmberAPI\clsAPIMediaContainers.vb` (Klasse ab Z. 1150)

Vom Suchergebnis genutzte Eigenschaften: `Title`, `OriginalTitle`, `Year`, `Plot`, `Lev` (Z. 1771, Levenshtein-Distanz für die Auto-Match-Heuristik, Schwelle `<= 5` in `GetSearchMovieInfo`), `UniqueIDs` (`UniqueidContainer`), `Scrapersource` (Z. 1575, wird in `GetMovieInfo` auf `"IMDB"` gesetzt, Z. 201), `ThumbPoster` (nur TMDB-Modul).

## `MediaContainers.TVShow` (verwendete Member)
Datei: `EmberAPI\clsAPIMediaContainers.vb` (Klasse ab Z. 2772)

Vom Suchergebnis genutzte Eigenschaften: `Title`, `Premiered` (TMDB-Modul nutzt es als Jahr), `UniqueIDs`, `Scrapersource` (Z. 3162).

## `MediaContainers.UniqueidContainer`
Datei: `EmberAPI\clsAPIMediaContainers.vb` (Z. 4649 ff.)

| Eigenschaft | Typ | Beschreibung / Zweck |
|-------------|-----|----------------------|
| `IMDbId` | `String` (Z. 4677) | IMDb-ID (`tt\d{7}`); `IMDbIdSpecified` = nicht leer (Z. 4693) |
| `TMDbId` | `Integer` (Z. 4700) | TMDb-ID; `TMDbIdSpecified` = `<> -1` (Z. 4718) |

## `SearchResults_Movie` / `SearchResults_TVShow` (TMDB-Modul, Referenz)
Datei: `Addons\scraper.TMDB.Data\Scraper\clsScrapeTMDB.vb` (Z. 25–46, 71–92)

Abweichender Vertrag: nur eine einheitliche Liste `Matches` (`List(Of MediaContainers.Movie)` bzw. `List(Of MediaContainers.TVShow)`), Treffer tragen `UniqueIDs.TMDbId` (keine IMDb-ID, keine `Lev`-Werte). Keine Kategorien wie im IMDb-Modul.
