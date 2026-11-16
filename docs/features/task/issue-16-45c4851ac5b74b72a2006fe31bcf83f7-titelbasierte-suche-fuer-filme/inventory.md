# Bestandsaufnahme: Titelbasierte Suche für Filme und Serien auf stabile Schnittstelle umstellen (Issue #16)

Bestandsaufnahme des bestehenden Codes bezogen auf die Anforderung `requirement.md` (Umstellung der titelbasierten Suche des Moduls `scraper.Data.IMDB` von IMDb-HTML-Endpunkten auf die TMDb-API). Analysiert wurden die Module `Addons\scraper.IMDB.Data`, `Addons\scraper.TMDB.Data` (Referenzimplementierung), `Addons\scraper.Data.OMDb` (Alternative), das Framework `EmberAPI` (Module-Vertrag, Media-Container, Scrape-Kette) sowie das einzige Testprojekt `EmberAPI_Test`.

## Zusammenfassung

- Die titelbasierte Suche im IMDb-Modul läuft vollständig über `HtmlAgilityPack.HtmlWeb.Load` auf `imdb.com/find` bzw. `imdb.com/search/title` (`Scraper.SearchMovie`, `clsScrapeIMDB.vb:1413–1541`, bis zu 7 Ladeaufrufe; `Scraper.SearchTVShow`, `clsScrapeIMDB.vb:1555–1581`, 1 Ladeaufruf). Der Ergebnisvertrag `SearchResults_Movie` (6 Kategorien) / `SearchResults_TVShow` (`Matches`) und die Heuristik in `GetSearchMovieInfo`/`GetSearchTVShowInfo` sind vorhanden und unverändert nutzbar.
- Es gibt **keine** TMDb- oder API-basierte Infrastruktur im IMDb-Modul: `packages.config` enthält nur `HtmlAgilityPack` 1.11.42 und `NLog` 4.7.14; `IMDB_Data.SpecialSettings` kennt kein `APIKey`-Feld; kein `txtApiKey`-Steuerelement in den Settings-Panels.
- Die TMDb-Referenzimplementierung ist vollständig vorhanden: `TMDbLib` 1.9.1, `TMDbClient`-Erzeugung in `Scraper.CreateAPI` (`clsScrapeTMDB.vb:162–184`), Titelsuche `SearchMovie`/`SearchTVShow` via `SearchMovieAsync`/`SearchTvShowAsync`, IMDb-ID-Auflösung über `GetMovieAsync`→`Movie.ImdbId` (Z. 344) bzw. `GetTvShowAsync` mit `TvShowMethods.ExternalIds`→`ExternalIds.ImdbId` (Z. 902), `FindAsync(FindExternalSource.Imdb)` für die Gegenrichtung (`GetTMDBbyIMDB`, Z. 1089–1104). `_client` ist `Private` (Z. 100) — keine projektübergreifende Shared-Komponente.
- Bekannte Fehlerlücken sind im Code bestätigt: `bwIMDB_DoWork`/`bwIMDB_RunWorkerCompleted` ohne Try/Catch und ohne `e.Error`-Prüfung (`clsScrapeIMDB.vb:118–158`); `APIResult.Result` ohne `Exception`-Prüfung in `clsScrapeTMDB.vb` (Z. 1374, 1378, 1385, 1389, 1396, 1400, 1440, 1443, 1463, 1467, 1516, 1520, 1551, 1554); gleiches Muster in `bwTMDB_RunWorkerCompleted` (Z. 227–252). Kein Pfad transportiert einen Fehlerzustand bis zum Dialog — die Dialoge zeigen bei leeren Listen nur „No Matches Found" (`dlgIMDBSearchResults_Movie.vb:454`, `dlgIMDBSearchResults_TV.vb:335`).
- `IMDB_Data.GetTMDbIdByIMDbId` ist ein leerer Stub (`IMDB_Data.vb:427–429`); `IMDB_Data.Scraper_Movie` (Z. 437–488) und `Scraper_TV` (Z. 496–550) entsprechen dem beschriebenen Vertrag inkl. `Cancelled`-Rückgabe.
- Die Scrape-Kette in `ModulesManager` (`clsAPIModules.vb`, `ScrapeData_Movie` Z. 915–1007, `ScrapeData_TVShow` ab Z. 1215) bricht bei `ret.Cancelled` (Z. 949/1260) die gesamte `ModuleOrder`-Sequenz ab — die vom Kunden gemeldete Gesamt-Trefferlosigkeit ist damit mechanisch plausibel (Hypothese b der Analyse).
- Alternative OMDb: `MovieCollection.OpenMovieDatabase` 3.0.1 ist als NuGet-Paket im Repo vorhanden (`packages\MovieCollection.OpenMovieDatabase.3.0.1`, mit `SearchMoviesAsync`/`SearchMovieAsync`), aber `scraper.Data.OMDb` implementiert nur den IMDb-ID-Abruf (`clsScrapeOMDb.vb:84`) — keine Titelsuche.
- **Test-Ausgangszustand:** Das einzige Testprojekt `EmberAPI_Test` (MSTest v1, 204 `[TestMethod]` in 12 `[TestClass]`-Klassen) ist nicht Teil der Solution und **kompiliert nicht** — das referenzierte Hilfsprojekt `..\UnitTests\UnitTests.vbproj` fehlt im Repository (203× `BC30002` „Der Typ 'UnitTest' ist nicht definiert"). Es wurden **0 Tests ausgeführt**; es existieren keine nachgewiesenen Testfehler. Die betroffenen Produktivprojekte `scraper.Data.IMDB` und `scraper.Data.TMDB` kompilieren fehlerfrei (Debug|x86). Details: [Tests](inventory/tests.md).

## Details

- [Datenmodell](inventory/models.md) — Ergebnis-Container, `SpecialSettings`-Strukturen, `MediaContainers`, `ModuleResult`-/`ScrapeOptions`-/`ScrapeModifiers`-Strukturen
- [Logik](inventory/logic.md) — `Scraper`/`IMDB_Data` (IMDb-Modul), `Scraper`/`TMDB_Data` (TMDb-Modul), `ModulesManager`-Scrape-Kette, `OMDb_Data`/`Scraper` (OMDb), Suchdialoge und Settings-Panels
- [Enums](inventory/enums.md) — `Enums.ScrapeType`, `Enums.ContentType`, `Enums.ModifierType`, modulinterne `SearchType`-Enums
- [Interfaces](inventory/interfaces.md) — `ScraperModule_Data_Movie`, `ScraperModule_Data_TV`, `ScraperModule_Data_MovieSet`
- [Abhängigkeiten und Projektdateien](inventory/dependencies.md) — `vbproj`/`packages.config`/`app.config` der betroffenen Module
- [Tests](inventory/tests.md) — Test-Ausgangszustand, Testläufe, Nachweise, bestehende Testklassen

## Abgrenzung

Diese Bestandsaufnahme dokumentiert nur den gefundenen Ist-Zustand; Produktivcode, Tests und Testkonfiguration wurden nicht verändert. Quellen: Anforderung `requirement.md` (Issue #16), Voranalyse `docs\analysis\issue-8-titelsuche-imdb.md` (Issue #8).

## Offene Punkte (im Code nicht beantwortbar)

- Ob die gemeldete Trefferlosigkeit allein durch die defekten IMDb-HTML-Endpunkte, durch den `Cancelled`-Abbruch der Scraper-Kette oder durch beides verursacht wird — beide Mechanismen existieren nachweislich im Code.
- Ob TMDbLib 1.9.1 im IMDb-Modul die benötigte TMDb→IMDb-ID-Auflösung (`Movie.ImdbId`, `TvShowMethods.ExternalIds`) unter den realen API-Bedingungen zuverlässig liefert — die Member sind in der Paketversion vorhanden, ein Laufzeitnachweis steht aus.
- Ob das IMDb-Modul die TMDb-Client-Erzeugung (`CreateAPI`-Muster aus `clsScrapeTMDB.vb:162–184`) dupliziert oder eine gemeinsame Komponente eingeführt wird — aktuell ist `_client` `Private` im TMDb-Modul, es existiert keine Shared-Infrastruktur.
- Ob neben der Titelsuche auch die weiterhin auf IMDb-HTML (`/title/{id}/reference`, `/episodes`, `/releaseinfo`, `/parentalguide`, `/plotsummary`) beruhenden Detailabrufe betroffen sind — der Dialog-OK-Pfad (`GetSearchMovieInfoAsync` → `GetMovieInfo`) hängt davon ab.
- Die konkrete UI-Form der geforderten unterscheidbaren Fehleranzeige (API-/Quellenfehler vs. „No Matches Found") ist weder in Anforderung noch im vorhandenen Dialog-Code festgelegt.
