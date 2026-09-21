# Offene Aufgaben

Erstellt am: 2026-09-21
Abbruchgrund: Maximale Iterationsanzahl erreicht

Die folgenden Aufgaben konnten im automatisierten Zyklus nicht abgeschlossen werden
und müssen manuell oder in einem erneuten Lauf bearbeitet werden.

## Offene Planelemente

- [ ] Task 27 — Manuelles Abnahmeprotokoll (`abnahmeprotokoll.md`) durchführen: alle 7 Pflicht-Szenarien abarbeiten (Suche „28 Days Later" → `tt0289043`, „28 Weeks Later" → `tt0463854`, „28 Years Later" → `tt10548174`, Seriensuche, manuelle IMDb-ID-Eingabe, Quell-Ausfall-Fehlermeldung, Scraper-Kette IMDb→TMDb). Nicht automatisierbar — erfordert laufende WinForms-Instanz mit TMDb-API-Zugang.

## Code-Review-Befunde

- [ ] `clsScrapeTMDB.vb` — `Try … Catch ex As Exception → Throw`-Hüllen um die Methodenrümpfe von `SearchMovie` (Z. 1474–1557), `SearchMovieSet` (Z. 1574–1617) und `SearchTVShow` (Z. 1634–1686) entfernen; erklärenden Kommentar als Methodenkommentar belassen.
- [ ] `clsScrapeTMDB.vb` — `strTitle`/`strYear` sind in `SearchMovieSet` (Z. 1587) bzw. `SearchTVShow` (Z. 1647–1648) vor der Schleife deklariert → Einträge ohne `Name`/`FirstAirDate` erben Vorgängerwerte (latente Falschzuordnung, pre-existing). Deklaration in den `For Each`-Block verschieben (Muster aus `SearchMovie`, Z. 1515–1519).
- [ ] `clsScrapeIMDB.vb` — `GetClient()` (Z. 1472–1480): `_client` wird vor `GetConfigAsync().GetAwaiter().GetResult()` zugewiesen → bei Fehler halb initialisierter Client im Feld. Erst nach erfolgreichem Config-Abruf dem Feld zuweisen (lokale Variable).
- [ ] `scraper.Data.IMDB.vbproj` — ungenutzten `<Import Include="System.Threading.Tasks" />` (Z. ~187) entfernen.
- [ ] Suchdialoge — doppelter Detail-Fehler-Fallback-Block (`*InfoDownloaded`-ElseIf vs. `SearchFailed`-ElseIf, ~8–10 Zeilen) in eine private Hilfsmethode pro Dialog auslagern (kein Blocker).

## Usability-Befunde

- [ ] `frmSettingsHolder_Movie.vb` / `frmSettingsHolder_TV.vb` (IMDB-Modul) — Info-Symbol neben `txtApiKey` fehlt (TMDb-Referenz: `pbTMDBApiKeyInfo` → `Functions.Launch(My.Resources.urlAPIKey)`); Anwender finden keinen Hinweis, woher ein eigener TMDB-API-Key bezogen werden kann. Klickbares Info-Element analog den TMDb-Panels ergänzen.
- [ ] `dlgIMDBSearchResults_Movie.vb` / `dlgIMDBSearchResults_TV.vb` — `SearchFailed` zeigt bei `chkManual.Checked = True` die Verify-Meldung „Unable to retrieve movie details for the entered IMDB ID", auch wenn keine ID eingegeben wurde (z. B. Detail-Fehler beim Umschalten während laufendem Download). Zwischen Verify-Fehler und Detail-Fehler unterscheiden; im Detail-Fall Meldung 1497 verwenden.

## Fehlgeschlagene Tests

- [ ] Abnahmeprotokoll-Szenarien 1–7 — nicht ausgeführt (manuelle Abnahme ausstehend; kein UI-Test-Framework, Live-TMDb-API-Abhängigkeit). Siehe `abnahmeprotokoll.md` und `test-results.md`.
