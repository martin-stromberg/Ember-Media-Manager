# Enums — Bestandsaufnahme

## `Enums.ScrapeType`
Datei: `EmberAPI\clsAPICommon.vb` (Z. 743–766)

Steuert in `GetSearchMovieInfo`/`GetSearchTVShowInfo` sowie `IMDB_Data.Scraper_Movie`/`Scraper_TV`, ob automatisch gematcht, gefragt oder übersprungen wird.

| Wert | Bedeutung |
|------|-----------|
| `AllAuto` = 0 | Alle Filme, automatisch |
| `AllAsk` = 1 | Alle Filme, bei Bedarf nachfragen |
| `AllSkip` = 2 | Alle Filme, bei Unsicherheit überspringen |
| `MissingAuto`/`MissingAsk`/`MissingSkip` = 3–5 | Nur fehlende Einträge |
| `NewAuto`/`NewAsk`/`NewSkip` = 6–8 | Nur neue Einträge |
| `MarkedAuto`/`MarkedAsk`/`MarkedSkip` = 9–11 | Nur markierte Einträge |
| `FilterAuto`/`FilterAsk`/`FilterSkip` = 12–14 | Gefilterte Einträge |
| `SingleScrape` = 15 | Einzelner Scrape (öffnet im IMDb-Modul bei fehlender ID den Suchdialog, `IMDB_Data.vb:471–484`) |
| `SingleField` = 16 | Einzelnes Feld |
| `SingleAuto` = 17 | Einzelner Scrape, automatisch (öffnet ebenfalls den Dialog) |
| `SelectedAuto`/`SelectedAsk`/`SelectedSkip` = 18–20 | Ausgewählte Einträge |
| `None` = 99 | Kein Scrape |

## `Scraper.SearchType` (IMDb-Modul, privat)
Datei: `Addons\scraper.IMDB.Data\Scraper\clsScrapeIMDB.vb` (Z. 78–84)

Interne Arbeitsauftragsart für `bwIMDB` (BackgroundWorker) — Unterscheidung in `bwIMDB_DoWork`/`bwIMDB_RunWorkerCompleted`.

| Wert | Bedeutung |
|------|-----------|
| `Details` = 0 | (deklariert, nicht verwendet) |
| `Movies` = 1 | `SearchMovie` ausführen |
| `SearchDetails_Movie` = 2 | `GetMovieInfo` ausführen |
| `SearchDetails_TVShow` = 3 | `GetTVShowInfo` ausführen |
| `TVShows` = 4 | `SearchTVShow` ausführen |

## `Scraper.SearchType` (TMDB-Modul, privat, Referenz)
Datei: `Addons\scraper.TMDB.Data\Scraper\clsScrapeTMDB.vb` (Z. 136–144)

| Wert | Bedeutung |
|------|-----------|
| `Movies` = 0, `Details` = 1, `SearchDetails_Movie` = 2, `MovieSets` = 3, `SearchDetails_MovieSet` = 4, `TVShows` = 5, `SearchDetails_TVShow` = 6 | Analoge Worker-Unterscheidung inkl. MovieSets |
