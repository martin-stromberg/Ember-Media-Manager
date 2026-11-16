# Code-Review

Basisbranch: `origin/staging` (Merge-Base `48b5739a`). Änderungen liegen im Working Tree (uncommitted). Speicherregel geprüft: Das neu gefeuerte `Exception`-Event (`clsScrapeIMDB.vb:149`, `clsScrapeTMDB.vb:236`) besitzt in allen fünf betroffenen Suchdialogen einen `SearchFailed`-Handler via `AddHandler` (`dlgIMDBSearchResults_Movie.vb:243`, `dlgIMDBSearchResults_TV.vb:242`, `dlgTMDBSearchResults_Movie.vb:224`, `dlgTMDBSearchResults_MovieSet.vb:208`, `dlgTMDBSearchResults_TV.vb:227`). Sämtliche `bw*`-Worker-Einstiegspunkte (`SearchMovieAsync`, `SearchTVShowAsync`, `GetSearch*InfoAsync`, `SearchAsync_*`) werden ausschließlich aus diesen Dialogen aufgerufen — kein auslösender Pfad ohne Handler.

## Ergebnis

**Status:** Befunde vorhanden

## Befunde

### `Addons\scraper.IMDB.Data\Scraper\clsScrapeIMDB.vb` (`Scraper`)

- **Fehlerbehandlung / Fehlermeldungsqualität** — `bwIMDB_RunWorkerCompleted` (Z. 142–151) gibt `e.Error` unverändert an `RaiseEvent Exception` weiter. Der `Exception`-Event feuert auch für die `SearchDetails_*`-Worker-Pfade (`bwIMDB_DoWork` Z. 132–138), nicht nur für die Suche. Der `SearchFailed`-Handler in den Dialogen löscht bei jeder Exception den kompletten `tvResults`-Baum — ein fehlgeschlagener *Detailabruf* nach erfolgreicher Suche zerstört damit die bereits angezeigte Trefferliste, obwohl der Kommentar behauptet „The search itself failed".

  Empfehlung: Im `SearchFailed`-Handler den Baum nur leeren, wenn noch keine Ergebnisse geladen wurden (z. B. `If tvResults.Nodes.Count = 0 OrElse <erste Suche läuft noch>`), oder Fehlerknoten ergänzen ohne `Nodes.Clear()`. Alternativ den Worker-Typ im Event transportieren, damit der Dialog Such- und Detailfehler unterscheiden kann.

- **Toter Code** — `Private Const REGEX_IMDBID` (Z. 67) wird nach Entfernung der IMDb-HTML-Suche nirgends mehr referenziert (einzige Verwendung war `Regex.IsMatch(strResponseUri, REGEX_IMDBID)` im alten `SearchMovie`).

  Empfehlung: Konstante entfernen.

- **Toter Code / nicht mehr erreichbare Zweige** — `GetSearchMovieInfo` (Z. 914–975) wertet weiterhin `r.PopularTitles` aus (Z. 926, 948–950, 954, 959–960, 963–964), obwohl `SearchMovie` diese Kategorie seit der Umstellung nie mehr befüllt; ebenso ist `ElseIf r.ExactMatches.Count = 1` (Z. 928) unerreichbar, weil Z. 924 denselben Fall bereits abdeckt. Gleiches gilt für die Kategorie-Knoten `TvTitles`/`VideoTitles`/`ShortTitles`/`PopularTitles` in `dlgIMDBSearchResults_Movie.SearchResultsDownloaded` (Z. 370 ff.), die nur noch leere Listen iterieren.

  Empfehlung: Die toten `PopularTitles`-Zweige in der Heuristik entfernen oder zumindest mit einem Kommentar als bewusst belassenen Vertrag markieren (die Properties selbst bleiben gemäß Anforderung als Ergebnisvertrag bestehen).

- **Hardcodierter Wert** — `SearchMovie` ruft `client.SearchMovieAsync(strTitleFiltered, Page, False, iYear)` (Z. 1459, 1500) mit festem `includeAdult := False` auf; das Referenzmodul nutzt dafür die Einstellung `_addonSettings.GetAdultItems`. Im IMDb-Modul existiert keine entsprechende Option — bewusste Entscheidung, aber implizit.

  Empfehlung: `False` als benannte Konstante oder mit kurzem Kommentar versehen, damit die Abweichung vom TMDB-Muster erkennbar ist.

- **Toter Code (trivial)** — `Imports TMDbLib.Client` (Z. 26) ist ungenutzt; alle Verwendungen (`TMDbLib.Client.TMDbClient`, `TMDbLib.Objects.*`) sind vollqualifiziert.

  Empfehlung: Import entfernen oder Typen unqualifiziert schreiben.

### `Addons\scraper.TMDB.Data\Scraper\clsScrapeTMDB.vb` (`Scraper`)

- **Fehlerbehandlung** — Die ergänzten `Is Nothing`-Guards in `SearchMovie`/`SearchMovieSet`/`SearchTVShow` (z. B. Z. 1392, 1399, 1422, 1425, 1481, 1487, 1492, 1534, 1540, 1545) decken nur `Nothing`-Ergebnisse ab; `Movies = APIResult.Result` (Z. 1390, 1394, 1401, 1405, 1412, 1416, 1456, 1459 sowie analog Z. 1479, 1483, 1509, 1512, 1532, 1536, 1567, 1570) wirft bei gefaulteten Tasks weiterhin `AggregateException`. Im Dialog-Pfad wird das über `e.Error` abgefangen, im synchronen Pfad (`GetSearchMovieInfo` Z. 1167, `GetSearchMovieSetInfo` Z. 1198, `GetSearchTVShowInfo` Z. 1229) propagiert die Exception unbehandelt bis in die Scrape-Kette — dort fehlt im Gegensatz zum IMDb-Modul (`GetSearchMovieInfo`/`GetSearchTVShowInfo` mit neuem `Try/Catch`) jede Absicherung. Bereits als offene Aufgabe 22 in `review.md` festgehalten.

  Empfehlung: `APIResult.Exception`-Prüfung oder `Try/Catch` um die `.Result`-Zugriffe; im Fehlerfall `InnerException` entpacken, `_Logger.Error` und leeres Ergebnis zurückgeben (Muster wie im IMDb-Modul).

- **Fehlermeldungen ohne Kontext** — Da die TMDb-Suchaufrufe über `Task.Run(...).Result` blockieren, landet bei API-Fehlern eine `AggregateException` in `e.Error`; `SearchFailed` zeigt dann nur `ex.Message` = „One or more errors occurred." — für den Nutzer nicht aussagekräftig und schlechter als die angestrebte unterscheidbare Fehlermeldung.

  Empfehlung: In `bwTMDB_RunWorkerCompleted` vor `RaiseEvent Exception` eine `AggregateException` auf `InnerException` entpacken (oder in `SearchFailed` behandeln).

### Suchdialoge (`dlgIMDBSearchResults_Movie`/`_TV`, `dlgTMDBSearchResults_Movie`/`_MovieSet`/`_TV`)

- **Doppelter Code** — `SearchFailed` ist in allen fünf Dialogen wortidentisch (~15 Zeilen inkl. Kommentarblock). Innerhalb desselben Moduls (`dlgIMDBSearchResults_Movie` vs. `_TV`; die drei TMDB-Dialoge untereinander) wäre eine gemeinsame private Hilfsroutine bzw. eine Vererbungs-/Shared-Basis möglich. Über die Modulgrenzen hinweg ist die Duplikation wegen getrennter Assemblys vertretbar und folgt dem vorhandenen Codebasismuster (auch `SearchResultsDownloaded` u. a. sind je Dialog dupliziert).

  Empfehlung: Akzeptabel als konsistentes Muster; optional eine modulinterne gemeinsame Routine erwägen — kein Blocker.

- **Doppelter Code** — `btnUnlockAPI_Click` ist in `frmSettingsHolder_Movie.vb` (Z. 54–66) und `frmSettingsHolder_TV.vb` (Z. 104–116) identisch; der textbasierte Toggle (`btnUnlockAPI.Text = GetString(1188, …)` als Zustandsabfrage) ist zwar aus dem TMDB-Referenzmodul übernommen, koppelt die Logik aber an den lokalisierten Buttontext.

  Empfehlung: Zustand stattdessen über `txtApiKey.Enabled` oder ein Feld prüfen; zumindest als bekanntes Muster des Referenzmoduls akzeptieren.

## Geprüfte Dateien

- `Addons\scraper.IMDB.Data\IMDB_Data.vb`
- `Addons\scraper.IMDB.Data\Scraper\clsScrapeIMDB.vb`
- `Addons\scraper.IMDB.Data\Scraper\dlgIMDBSearchResults_Movie.vb`
- `Addons\scraper.IMDB.Data\Scraper\dlgIMDBSearchResults_TV.vb`
- `Addons\scraper.IMDB.Data\frmSettingsHolder_Movie.vb`
- `Addons\scraper.IMDB.Data\frmSettingsHolder_Movie.Designer.vb`
- `Addons\scraper.IMDB.Data\frmSettingsHolder_TV.vb`
- `Addons\scraper.IMDB.Data\frmSettingsHolder_TV.Designer.vb`
- `Addons\scraper.IMDB.Data\app.config`
- `Addons\scraper.IMDB.Data\packages.config`
- `Addons\scraper.IMDB.Data\scraper.Data.IMDB.vbproj`
- `Addons\scraper.TMDB.Data\Scraper\clsScrapeTMDB.vb`
- `Addons\scraper.TMDB.Data\Scraper\dlgTMDBSearchResults_Movie.vb`
- `Addons\scraper.TMDB.Data\Scraper\dlgTMDBSearchResults_MovieSet.vb`
- `Addons\scraper.TMDB.Data\Scraper\dlgTMDBSearchResults_TV.vb`
- `Addons\scraper.TMDB.Data\packages.config`
- `Addons\scraper.TMDB.Data\scraper.Data.TMDB.vbproj`
- `EmberAPI\Translations\en-US.xml`
- `EmberMediaManager\App.config`

## Positiv festgestellt (keine Befunde)

- `bwIMDB_RunWorkerCompleted`/`bwTMDB_RunWorkerCompleted`: `e.Cancelled`-/`e.Error`-/`e.Result`-Prüfung vor dem `DirectCast` — behebt den bisherigen Re-Throw beim `e.Result`-Zugriff.
- `GetClient()` (clsScrapeIMDB.vb:1430–1438): Lazy-Initialisierung mit `GetConfigAsync` und `MaxRetryCount`, Fehler propagiert korrekt in den `e.Error`-Pfad; kein Deadlock-Risiko durch `.GetAwaiter().GetResult()`, da TMDbLib intern `ConfigureAwait(false)` verwendet.
- `SpecialSettings.APIKey` + `strPrivateAPIKey`/`_strAPIKey`-Muster inkl. Fallback ist exakt nach `TMDB_Data`-Vorbild umgesetzt; `InjectSetupScraper_*` lädt die Settings vor der Panel-Befüllung neu, sodass das geteilte `strPrivateAPIKey`-Feld je Content-Type korrekt befüllt.
- Treffer ohne auflösbare IMDb-ID werden in `SearchMovie`/`SearchTVShow` einzeln toleriert (`Try/Catch` + `Continue For`) statt die gesamte Suche fehlschlagen zu lassen.
- TMDbLib-Upgrade 1.9.1 → 2.3.0 in beiden Modulen konsistent (identische HintPaths, `Newtonsoft.Json` 13.0.3, transitive Pakete); Binding-Redirects sind dokumentiert funktional neutral (Assembly nicht strong-named).
- Entfernte `Search*Titles`-Checkboxen/Handler/Designer-Deklarationen sind rückstandsfrei entfernt (keine verwaisten Referenzen mehr).
