# Bestandsaufnahme: Enums

## Framework (`EmberAPI\clsAPICommon.vb`)

### `Enums.ScrapeType` (Z. 743–766)
Steuert den Heuristik-Zweig in `GetSearchMovieInfo`/`GetSearchTVShowInfo` und die Dialog-Öffnung in `Scraper_Movie`/`Scraper_TV`.

| Member | Bedeutung im Kontext der Suche |
|--------|--------------------------------|
| `SingleScrape` | Erzwingt Suchdialog bzw. Heuristik-Interaktion |
| `SingleAuto` | Erzwingt Suchdialog bei fehlender ID (mit `DoSearch`) |
| `SingleField` | Kein Dialog; Heuristik-Pfad je nach `ScrapeModifiers` |
| `Update_Movie` / `Update_TVShow` / … | Update-Modi; ohne `DoSearch` keine Suche |
| `CleanVDB` | Nur DB-Bereinigung, kein Scrape |
| `Ask` | Dialog zur Auswahl des Treffers (`Ask`/`NewAsk`) |
| `Auto` | Automatische Trefferauswahl (erster Treffer / `Lev <= 5`) |
| `Skip` | Nur bei exakt einem ExactMatch |

### `Enums.ContentType` (Z. 444–454)
`Movie`, `MovieSet`, `None`, `TV`, `TVEpisode`, `TVSeason`, `TVShow` — Schlüssel für `AdvancedSettings`-Settings (z. B. `GetSetting("APIKey", String.Empty, , Enums.ContentType.Movie)` in `TMDB_Data.LoadSettings_Movie`).

### `Enums.ModifierType` (Z. 506–545)
39 Member; für diese Anforderung relevant:
- `DoSearch` (Z. 512) — Flag in `ScrapeModifiers`, erzwingt den Suchpfad in `Scraper_Movie`/`Scraper_TV`.
- `MainNFO`, `SeasonNFO`, `EpisodeNFO` — Gates für den Such-/Scrape-Pfad.
- `withEpisodes`, `withSeasons` — steuern `ScrapeModifiers` bei Serien.

### `Enums.ModuleType` (Z. 567–575)
`Data_Movie`, `Data_MovieSet`, `Data_TVEpisode`, `Data_TVSeason`, `Data_TVShow`, `Generic`, `Image_Movie`, `Image_TV` — Kategorisierung der Module in `ModulesManager`.

## Modul-interne Enums

### `Scraper.SearchType` (Private, `Addons\scraper.IMDB.Data\Scraper\clsScrapeIMDB.vb` Z. 78–84)
`Movies`, `SearchDetails_Movie`, `SearchDetails_TVShow`, `TVEpisodes`, `TVShows` — BackgroundWorker-Dispatch-Schlüssel in `bwIMDB_DoWork`.

### `Scraper.SearchType` (Private, `Addons\scraper.TMDB.Data\Scraper\clsScrapeTMDB.vb` Z. 141–148)
`Movies`, `MovieSets`, `SearchDetails_Movie`, `SearchDetails_MovieSet`, `SearchDetails_TVShow`, `TVShows` — BackgroundWorker-Dispatch in `bwTMDB_DoWork`.

## Externe Enum (TMDbLib)
`TMDbLib.Objects.Find.FindExternalSource.Imdb` — Parameter von `TMDbClient.FindAsync` in `Scraper.GetTMDBbyIMDB`/`GetTMDBbyTVDB` (`clsScrapeTMDB.vb:1093`). Enum-Member in der Paket-XML-Doku (`packages\TMDbLib.1.9.1\lib\netstandard1.0\TMDbLib.xml`): `Imdb`, `Tvdb`, `FreeBaseId`, `FreeBaseMid`, `TvRage`, `Tmdb`, `Facebook`, `Twitter`, `Instagram` — keine Mitgliedschaft im Repo-Code.
