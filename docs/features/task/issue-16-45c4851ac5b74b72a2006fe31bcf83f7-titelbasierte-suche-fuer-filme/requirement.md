# Übersetzte Anforderung: Titelbasierte Suche für Filme und Serien auf stabile Schnittstelle umstellen (Issue #16)

Grundlage: Kundenanforderung zu Issue #16 sowie die verifizierte Analyse `docs/analysis/issue-8-titelsuche-imdb.md` (Ergebnis von Issue #8). Alle genannten Fundstellen wurden im Repository bestätigt.

## Fachliche Zusammenfassung

Die titelbasierte Suche des Daten-Scraper-Moduls `scraper.Data.IMDB` (`Addons\scraper.IMDB.Data`) wird von den defekten IMDb-HTML-Endpunkten (`/find`, `/search/title` — AWS-WAF-Challenge bzw. umgebautes React-Frontend) auf die TMDb-API als festgelegte primäre Schnittstelle umgestellt (`TMDbLib`, Referenzimplementierung im Schwestermodul `scraper.TMDB.Data`). Vorbedingung ist die Eingrenzung und Behebung des TMDb-Befunds: Beim Kunden liefern trotz aktiviertem IMDb- **und** TMDb-Scraper beide keine Treffer — Ursache ist entweder eine defekte TMDb-Integration (`TMDbLib` 1.9.1, eingebetteter Fallback-Key, unbehandelte Exceptions) oder ein Scrape-Order-Effekt (`Cancelled`-Abbruch der Kette in `ModulesManager.ScrapeData_Movie`). Der Ergebnisvertrag (`SearchResults_Movie`/`SearchResults_TVShow`, Suchdialoge, `GetSearchMovieInfo`/`GetSearchTVShowInfo`-Heuristik) bleibt unverändert; Quell-Ausfälle werden künftig als von „keine Treffer" unterscheidbare Fehlermeldung angezeigt statt stillschweigend „No Matches Found".

## Betroffene Klassen und Komponenten

### Modul `scraper.IMDB.Data` (`Addons\scraper.IMDB.Data`) — Hauptumfang

- `Scraper\clsScrapeIMDB.vb`:
  - `Scraper.SearchMovie` (Z. 1413–1541) — Datenbeschaffung vollständig ersetzen: statt bis zu sieben `HtmlWeb.Load`-Aufrufen auf `imdb.com/find` und `imdb.com/search/title` nun `TMDbClient.SearchMovieAsync` sowie IMDb-ID-Auflösung je Treffer. Treffer-Mapping auf `MediaContainers.Movie` (`Title`, `Year`, `UniqueIDs.IMDbId`, `Lev` via `StringUtils.ComputeLevenshtein` analog Z. 1456) und Einsortierung in `SearchResults_Movie.ExactMatches` (exakter Titel+Jahr-Treffer) bzw. `PartialMatches` (übrige Treffer). Die Kategorien `PopularTitles`, `TvTitles`, `VideoTitles`, `ShortTitles` bleiben künftig leer.
  - `Scraper.SearchTVShow` (Z. 1555–1581) — analog über `TMDbClient.SearchTvShowAsync`, Ergebnis in `SearchResults_TVShow.Matches` (`MediaContainers.TVShow` mit `Title`, `UniqueIDs.IMDbId`).
  - `SearchResults_Movie` (Z. 27–45) / `SearchResults_TVShow` (Z. 47–55) — Klassen bleiben als Vertrag bestehen; die vier Spezialkategorien werden nicht mehr befüllt.
  - `bwIMDB_DoWork` (Z. 118–138) / `bwIMDB_RunWorkerCompleted` (Z. 140–158) — Fehlerbehandlung neu: Lade-/API-Exceptions propagieren aktuell unbehandelt (`e.Result`-Zugriff wirft erneut, Ergebnis-Event feuert nie). Fehlerzustand ist abzufangen, via `logger.Error` zu protokollieren (Muster: `GetSearchMovieInfo` Z. 959–962) und an den Dialog zu melden, damit eine unterscheidbare Fehlermeldung statt „No Matches Found" erscheint.
  - Neu: `TMDbClient`-Instanz samt Initialisierung nach dem Muster `CreateAPI` in `clsScrapeTMDB.vb` (Z. 162–184: `GetConfigAsync`, `MaxRetryCount`, ggf. Englisch-Fallback-Client). Entscheidung Neuinstanz vs. gekapselter API-Gateway obliegt dem Entwicklungsprojekt (keine Shared-Komponente vorhanden; `_client` in `clsScrapeTMDB.vb:100` ist `Private`).
  - `GetSearchMovieInfo` (Z. 902–963) / `GetSearchTVShowInfo` (Z. 978–1007) — Heuristik (`Lev <= 5`, `FindYear`, `ScrapeType`-Fallunterscheidung Ask/Skip/Auto) bleibt unverändert und muss mit den neu befüllten Kategorien weiter funktionieren.
- `IMDB_Data.vb`:
  - `SpecialSettings` (Z. 591–608) — neues Feld `APIKey` (String); die fünf Felder `SearchPartialTitles`, `SearchPopularTitles`, `SearchTvTitles`, `SearchVideoTitles`, `SearchShortTitles` werden deprecated.
  - `LoadSettings_Movie` (Z. 233–261) / `SaveSettings_Movie` / `LoadSettings_TV` (Z. 263–286) / `SaveSettings_TV` — `APIKey`-Setting laden/speichern exakt nach dem Muster `TMDB_Data.vb` (Z. 352–353, 397–400: `AdvancedSettings.GetSetting("APIKey", String.Empty, , Enums.ContentType.*)` mit Fallback auf eingebetteten Key); eingebetteter Fallback-Key als Konstante nach Muster `TMDB_Data.vb:57` (`_strAPIKey`).
  - `Scraper_Movie` (Z. 437–488) / `Scraper_TV` (Z. 496–550) — bleiben vertragsgemäß unverändert (`dlgIMDBSearchResults_Movie`/`_TV`-Aufruf, `ScrapeModifiers.DoSearch = False`, `Cancelled`-Rückgabe).
  - `GetTMDbIdByIMDbId` (Z. 427–429) — leerer Stub; Implementierung ist ausdrücklich kein Bestandteil dieser Anforderung (Nebenbefund, optional).
- `frmSettingsHolder_Movie.vb` (+ `.Designer.vb`) — die fünf Checkboxen `chkPartialTitles`, `chkPopularTitles`, `chkTvTitles`, `chkVideoTitles`, `chkShortTitles` (durch Deprecated-Settings belegt, `IMDB_Data.vb:165–169`) entfernen/ausblenden; `txtApiKey` nach Muster der TMDb-Panels ergänzen.
- `frmSettingsHolder_TV.vb` (+ `.Designer.vb`) — `txtApiKey` ergänzen.
- `dlgIMDBSearchResults_Movie.vb` / `dlgIMDBSearchResults_TV.vb` — kein Umbau; lediglich die unterscheidbare Fehleranzeige bei Quell-Ausfall ergänzen (derzeit fester Knoten „No Matches Found", Z. 454 bzw. Z. 335). Manuelle IMDb-ID-Eingabe (`chkManual`/`txtIMDBID`/`btnVerify`) bleibt funktionsfähig.
- `scraper.Data.IMDB.vbproj` + `packages.config` — NuGet-Verweis auf `TMDbLib` neu hinzufügen (bisher nur `HtmlAgilityPack` 1.11.42 + `NLog` 4.7.14); transitiv `Newtonsoft.Json`, `System.Net.Http` u. a. wie in `scraper.TMDB.Data\packages.config`.

### Modul `scraper.TMDB.Data` (`Addons\scraper.TMDB.Data`) — Befund-Eingrenzung und ggf. Fix

- `Scraper\clsScrapeTMDB.vb` — `CreateAPI` (Z. 162–184), `SearchMovie` (Z. 1362–1449, `_client.SearchMovieAsync` Z. 1372), `SearchTVShow` (Z. 1504–1560, `SearchTvShowAsync` Z. 1514), `GetTMDBbyIMDB` (Z. 1089–1104, `FindAsync(FindExternalSource.Imdb)` Z. 1092). Bekannte Fehlerlücke: `APIResult.Result` ohne Exception-Prüfung (Z. 1374, 1516) → `AggregateException`/`NullReferenceException`; `bwTMDB_RunWorkerCompleted` (Z. 227 ff.) wirft beim `e.Result`-Zugriff erneut — Ergebnis-Event feuert nie.
- `TMDB_Data.vb` — `_strAPIKey` (Z. 57), `APIKey`-Setting-Muster (Z. 352–353, 363–366, 397–400), Dialog-Aufruf `dlgTMDBSearchResults_Movie` (Z. 680–692).
- `packages.config` — `TMDbLib` 1.9.1 (Z. 12); Versionsanhebung abhängig vom Befund (Upstream: 1.9.2 behebt Deserialisierungsfehler, 2.x/3.x aktueller).

### Framework (nur diagnostisch relevant, nicht zu ändern)

- `EmberAPI\clsAPIModules.vb` — `ScrapeData_Movie` (Z. 915–1007) / `ScrapeData_TVShow` (ab Z. 1215): sequenzielle Modul-Abarbeitung in `ModuleOrder` (Z. 918), `ret.Cancelled` bricht die gesamte Kette ab (Z. 949), `ret.breakChain` ebenso (Z. 969); Logzeile `[ModulesManager] [ScrapeData_Movie] [Using] {Modulname}` (Z. 944) für die Eingrenzung. Keine Änderung an `Enums.ScrapeType`, Scrape Order, `ScrapeModifiers` (Abgrenzung).
- `EmberAPI` — `MediaContainers.Movie`/`MediaContainers.TVShow`, `MediaContainers.UniqueidContainer.IMDbId`/`TMDbId`, `StringUtils.ComputeLevenshtein`/`FilterYear`/`GetIMDBIDFromString`, `Structures.ScrapeOptions`/`ScrapeModifiers` — Wiederverwendung.

### Alternative Schnittstelle (nur falls TMDb nicht tragfähig)

- `scraper.Data.OMDb` — Bibliothek `MovieCollection.OpenMovieDatabase` 3.0.1 (`packages.config:3`) bietet `SearchMoviesAsync`/`SearchMovieAsync` mit direkter `imdbID`-Lieferung; im Modul ist aber nur `SearchMovieByImdbIdAsync` implementiert (`clsScrapeOMDb.vb:84`) → Neuimplementierung nötig; Pflicht-API-Key ohne Fallback (`CreateAPI` Z. 53–70).

### Tests

Kein bestehendes Testprojekt für die Addon-Module vorhanden; Abnahme erfolgt manuell über die Akzeptanzkriterien (Filmsuche „28 Days/Weeks/Years Later" → `tt0289043`/`tt0463854`/`tt10548174`; analoge Seriensuche; manuelle ID-Eingabe; unterscheidbare Fehlermeldung bei Quell-Ausfall).

## Implementierungsansatz

1. **TMDb-Befund eingrenzen (Vorbedingung, Ergebnis dokumentieren):** Anhand der Kundenkonfiguration (`AdvancedSettings`, `EmberModules`-Reihenfolge) und der Logzeilen `clsAPIModules.vb:944` klären, ob `clsScrapeTMDB.SearchMovie`/`SearchTVShow` überhaupt erreicht werden (Hypothese b: `Cancelled`-Abbruch durch den trefferlosen IMDb-Dialog, `IMDB_Data.vb:480`, verhindert den TMDb-Aufruf) oder die TMDb-Integration selbst defekt ist (Hypothese a: `TMDbLib` 1.9.1 vs. aktuelle API v3, ungültiger Fallback-Key `TMDB_Data.vb:57`, unbehandelte Exception an `APIResult.Result`). Bei defekter Integration: Ursache beheben (ggf. TMDbLib-Versionsanhebung, Exception-Handling in `bwTMDB_DoWork`/`bwTMDB_RunWorkerCompleted`), bevor TMDb als Suchbasis übernommen wird.
2. **Suche im IMDb-Modul umstellen:** `SearchMovie` fragt `TMDbClient.SearchMovieAsync(title, page, includeAdult, year)` ab und löst je Treffer die IMDb-ID auf (siehe offene Frage 2 zur konkreten TMDbLib-Methode); Mapping auf `MediaContainers.Movie` mit `Lev`-Berechnung wie bisher; Klassifikation exakter Titel+Jahr-Treffer → `ExactMatches`, übrige → `PartialMatches`. `SearchTVShow` analog über `SearchTvShowAsync` → `Matches`. Die `HtmlWeb.Load`-Aufrufe auf `imdb.com` für die Titelsuche entfallen vollständig.
3. **Fehlerbehandlung:** API-Aufrufe kapseln (Try/Catch bzw. `APIResult.Exception`-Prüfung), HTTP-Fehler/Rate-Limits/ungültige oder fehlende API-Keys erkennen, via `logger.Error` protokollieren und den Fehlerzustand bis zum Dialog transportieren (z. B. über das `Results`-Objekt/`e.Error` in `bwIMDB_RunWorkerCompleted`), damit eine von „keine Treffer" unterscheidbare Meldung angezeigt wird — konkrete UI-Form frei.
4. **Settings:** Fünf `Search*Titles`-Settings deprecaten (nicht mehr laden/auswerten, Checkboxen aus `frmSettingsHolder_Movie` entfernen/ausblenden); neues `APIKey`-Setting für Movie und TV mit `txtApiKey` im Settings-Panel und eingebettetem Fallback-Key — exakt nach `TMDB_Data`-Muster inkl. Validierung (leer → Fallback; ungültig → klare Fehlermeldung über den neuen Fehlerpfad).
5. **Abhängigkeiten:** `TMDbLib`-Verweis (Version abhängig vom Befund) plus transitive Pakete in `scraper.IMDB.Data` ergänzen; `vbproj`/`packages.config`/`app.config`-Binding-Redirects entsprechend pflegen.
6. **Gemeinsame Umsetzung und Abnahme:** Film- und Serienpfad teilen denselben Mechanismus und werden gemeinsam abgenommen (festgelegt).

## Konfiguration

- **`APIKey`** (String) je Content-Type (`Enums.ContentType.Movie`/`Enums.ContentType.TV`) über `AdvancedSettings` — Muster `TMDB_Data.vb:352–353, 397–400`; UI-Eingabe über `txtApiKey` in `frmSettingsHolder_Movie`/`frmSettingsHolder_TV`; Standardwert = eingebetteter Fallback-Key (Konstante nach Muster `TMDB_Data.vb:57`). Leerer Eintrag → Fallback-Key; ungültiger Key → Fehlermeldung über den neuen Fehlerpfad.
- **Deprecated:** `SearchPartialTitles`, `SearchPopularTitles`, `SearchTvTitles`, `SearchVideoTitles`, `SearchShortTitles` (`IMDB_Data.vb:255–259`) — werden nicht mehr ausgewertet; zugehörige Checkboxen in `frmSettingsHolder_Movie` entfernen/ausblenden. Bestehende `AdvancedSettings`-Einträge beim Kunden verbleiben wirkungslos in der Konfigurationsdatei (kein Migrationszwang erkennbar).

## Offene Fragen

1. **Ergebnis der TMDb-Eingrenzung:** Trifft Hypothese (a) (TMDb-Integration defekt — `TMDbLib`-Version, Fallback-Key, unbehandelte Exceptions) oder (b) (Scrape-Order/`Cancelled`-Abbruch, TMDb-Pfad wird nie erreicht) zu — oder beides? Davon hängt ab, ob neben dem IMDb-Modul auch `scraper.TMDB.Data` gefixt werden muss und welche `TMDbLib`-Version einzusetzen ist.
2. **IMDb-ID-Auflösung je TMDb-Treffer:** Die Analyse referenziert `FindAsync(FindExternalSource.Imdb)` — diese Methode löst jedoch die Richtung IMDb-ID → TMDb-Objekt auf (`GetTMDBbyIMDB`, `clsScrapeTMDB.vb:1089–1104`). Für die benötigte Richtung TMDb-Treffer → IMDb-ID ist vermutlich `GetMovieExternalIdsAsync`/`GetTvShowExternalIdsAsync` (bzw. `MovieMethods.ExternalIds` beim Detailabruf) erforderlich — gegen die gewählte `TMDbLib`-Version zu verifizieren (Annahme).
3. **`TMDbLib`-Version für `scraper.IMDB.Data`:** Referenzstand ist 1.9.1; je nach Befund kann 1.9.2+ oder ein 2.x/3.x-Sprung erforderlich sein (ggf. API-Brüche in den Signaturen `SearchMovieAsync`/`SearchTvShowAsync`/External-Ids prüfen).
4. **Abnahme-Risiko Detailabruf:** Die Akzeptanzkriterien verlangen nur Treffer mit korrekter IMDb-ID im Dialog; der `OK_Button` wird jedoch erst nach geladenem Detail-Info aktiviert (`dlgIMDBSearchResults_Movie.vb:288`), das über den ebenfalls defekten IMDb-Detailabruf (`GetMovieInfo` → `/reference`) läuft. Zu klären: Reicht für die Abnahme die Trefferanzeige, oder muss der Dialog-Abschluss (inkl. `btnVerify`-Pfad) trotz defektem Detailabruf funktionieren — ggf. Minimalziel „Dialog liefert `DialogResult.OK` mit IMDb-ID" sicherstellen.
5. **Form der unterscheidbaren Fehlermeldung:** Festgelegt ist nur „unterscheidbar von 'No Matches Found'" — eigener Knoten im `tvResults`-Baum, MessageBox oder Statuszeile bleibt dem Entwicklungsprojekt überlassen; ggf. mit Kunden abstimmen.
6. **Client-Architektur:** Neuinstanz von `TMDbClient` im IMDb-Modul, bewusste Code-Duplikation aus `clsScrapeTMDB.vb` oder gekapselter gemeinsamer API-Gateway — als Anforderung zu entscheiden (keine Shared-Komponente vorhanden).
