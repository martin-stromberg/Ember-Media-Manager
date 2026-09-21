# Offene Aufgaben

Erstellt am: 2026-09-21
Abbruchgrund: Maximale Iterationsanzahl erreicht
Letzte Aktualisierung: 2026-09-21 (Nacharbeits-Lauf — alle automatisierbaren Punkte erledigt)

Die folgenden Aufgaben konnten im automatisierten Zyklus nicht abgeschlossen werden
und müssen manuell oder in einem erneuten Lauf bearbeitet werden.

## Offene Planelemente

- [ ] Task 27 — Manuelles Abnahmeprotokoll (`abnahmeprotokoll.md`) durchführen: alle 7 Pflicht-Szenarien abarbeiten (Suche „28 Days Later" → `tt0289043`, „28 Weeks Later" → `tt0463854`, „28 Years Later" → `tt10548174`, Seriensuche, manuelle IMDb-ID-Eingabe, Quell-Ausfall-Fehlermeldung, Scraper-Kette IMDb→TMDb). Nicht automatisierbar — erfordert laufende WinForms-Instanz mit TMDb-API-Zugang.

## Code-Review-Befunde

- [x] `clsScrapeTMDB.vb` — `Try … Catch ex As Exception → Throw`-Hüllen um die Methodenrümpfe von `SearchMovie`, `SearchMovieSet` und `SearchTVShow` entfernt; erklärende Kommentare als Methodenkommentare über den Signaturen belassen.
- [x] `clsScrapeTMDB.vb` — `strTitle`/`strYear` in `SearchMovieSet` bzw. `SearchTVShow` in den `For Each`-Block verschoben (Muster aus `SearchMovie`); latente Falschzuordnung behoben.
- [x] `clsScrapeIMDB.vb` — `GetClient()`: `_client` wird erst nach erfolgreichem `GetConfigAsync().GetAwaiter().GetResult()` über lokale Variable zugewiesen; kein halb initialisierter Client mehr.
- [x] `scraper.Data.IMDB.vbproj` — ungenutzten `<Import Include="System.Threading.Tasks" />` entfernt.
- [x] Suchdialoge — doppelter Detail-Fehler-Fallback-Block in allen fünf Dialogen in die private Hilfsmethode `ShowDetailLookupFallback()` ausgelagert.

## Usability-Befunde

- [x] `frmSettingsHolder_Movie.vb` / `frmSettingsHolder_TV.vb` (IMDB-Modul) — Info-Symbol `pbTMDBApiKeyInfo` neben `txtApiKey` ergänzt (Designer + Formular-`.resx` + `urlAPIKey`-Ressource in `My Project/Resources.resx`/`Resources.Designer.vb`); `pbTMDBApiKeyInfo_Click` → `Functions.Launch(My.Resources.urlAPIKey)`.
- [x] `dlgIMDBSearchResults_Movie.vb` / `dlgIMDBSearchResults_TV.vb` — `SearchFailed`/`Search*InfoDownloaded` unterscheiden jetzt Verify-Fehler (`chkManual.Checked AndAlso Not String.IsNullOrEmpty(txtIMDBID.Text)` → Meldung 825) und Detail-Fehler (→ `ShowDetailLookupFallback()` mit Meldung 1497); analog in den drei TMDB-Dialogen (`txtTMDBID`, Meldung 935).

## Fehlgeschlagene Tests

- [ ] Abnahmeprotokoll-Szenarien 1–7 — nicht ausgeführt (manuelle Abnahme ausstehend; kein UI-Test-Framework, Live-TMDb-API-Abhängigkeit). Siehe `abnahmeprotokoll.md` und `test-results.md`.
