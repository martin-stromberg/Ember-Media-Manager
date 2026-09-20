# Bestandsaufnahme: Titelbasierte IMDb-Suche für Filme und Serien wiederherstellen (Issue #8)

Analysiert wurde das Daten-Scraper-Modul `scraper.Data.IMDB` (`Addons\scraper.IMDB.Data`) samt Aufrufer `IMDB_Data`, den Suchdialogen und den API-basierten Referenzmodulen `scraper.TMDB.Data` und `scraper.Data.OMDb` — bezogen auf die Anforderung, die defekte Titelsuche auf eine stabile Schnittstelle umzustellen.

## Zusammenfassung

- **Defekte Komponente vorhanden wie beschrieben:** `Scraper.SearchMovie` (`clsScrapeIMDB.vb:1413–1541`) und `Scraper.SearchTVShow` (Z. 1555–1581) laden per `HtmlAgilityPack.HtmlWeb` die IMDb-HTML-Seiten `/find` und `/search/title` und parsen Markup (`findList`-Tabelle, `span[@title]`, `lister-item mode-simple`), das IMDb nicht mehr ausliefert → alle `SearchResults_Movie`-/`SearchResults_TVShow`-Listen bleiben leer → Dialog zeigt "No Matches Found".
- **Gleiche Datenquelle auch im Detailabruf:** `GetMovieInfo`, `GetTVShowInfo`, `GetTVEpisodeInfo`, `GetMovieStudios` u. a. lesen `/title/{id}/reference`, `/episodes`, `/releaseinfo`, `/parentalguide`, `/plotsummary` — 15 `HtmlWeb.Load`-Stellen auf `imdb.com` in `clsScrapeIMDB.vb` insgesamt.
- **Ergebnisvertrag ist stabil und API-unabhängig:** `SearchResults_Movie` (6 Kategorien) / `SearchResults_TVShow` (`Matches`), die `ScrapeType`-Heuristik in `GetSearchMovieInfo`/`GetSearchTVShowInfo` (Levenshtein ≤ 5, `FindYear`) und die Dialoge `dlgIMDBSearchResults_Movie`/`_TV` sind von der Datenquelle entkoppelt — die Suche ist die einzige IMDb-abhängige Stelle im Suchpfad.
- **Keine Fehlerunterscheidung:** Abruffehler der Such-HTML-Seiten werden nicht erkannt oder geloggt; jeder Ausfall endet still in "No Matches Found" (`SearchMovie`/`SearchTVShow` ohne Try/Catch).
- **API-Referenz existiert im Repo:** `scraper.TMDB.Data` nutzt `TMDbLib` (`SearchMovieAsync`, `SearchTvShowAsync`, `FindAsync(FindExternalSource.Imdb)` für IMDb↔TMDb-Mapping) mit Fallback-API-Key (`TMDB_Data.vb:57`) und konfigurierbarem `APIKey`-Setting; `scraper.Data.OMDb` nutzt `OpenMovieDatabase` mit pflichtigem `APIKey`, bietet aber nur ID-basierte Abrufe (`SearchMovieByImdbIdAsync`), keine Titelsuche.
- **Settings im IMDb-Modul:** `SearchPartialTitles`/`SearchPopularTitles` (Default `True`), `SearchTvTitles`/`SearchVideoTitles`/`SearchShortTitles` (Default `False`) steuern bisher nur zusätzliche IMDb-HTML-Abfragen; bei API-Suche funktionslos.
- **Test-Ausgangszustand:** Es konnte **kein einziger Test ausgeführt** werden — das einzige Testprojekt `EmberAPI_Test` ist nicht Teil der Solution und kompiliert nicht (referenziertes Hilfsprojekt `UnitTests` fehlt im Repo, 203× `BC30002`; keine AnyCPU-Konfiguration; MSTest v1). Nachweis und Details: [Tests](inventory/tests.md). Der Zustand aller Tests ist damit unbekannt; es existieren ohnehin keine Tests für das IMDb-Modul.

## Details

- [Datenmodell](inventory/models.md) — `SearchResults_Movie`/`SearchResults_TVShow` (IMDb- und TMDB-Variante), `SpecialSettings`, verwendete `MediaContainers`-Member, `UniqueidContainer`
- [Logik](inventory/logic.md) — `Scraper` (IMDb), `IMDB_Data`, Suchdialoge, TMDB-/OMDb-`Scraper` als Referenz
- [Enums](inventory/enums.md) — `Enums.ScrapeType`, private `SearchType`-Enums der Scraper
- [Interfaces](inventory/interfaces.md) — `ScraperModule_Data_Movie`, `ScraperModule_Data_TV`
- [Tests](inventory/tests.md) — Test-Ausgangszustand, Build-Nachweise, Testklassen-Inventar
