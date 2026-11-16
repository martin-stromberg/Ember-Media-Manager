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

## Nachgetragener Fix: Cancelled-Abbruch (Upstream-Defekt)

Erstellt am: 2026-09-21 (nach erstem manuellen Testlauf des Anwenders)

Beim manuellen Test zeigte sich: Titelsuche liefert Exact-/Partial-Matches, aber
nach Bestätigen des Dialogs „passiert nichts". Ursache ist **nicht** die neue
Titelsuche, sondern eine nie abgeschlossene Upstream-Migration aus Commit
`d08f4dae` (2022-11-27, DanCooper, Commit-Text: „preparing for switching module
result from 'False' to 'True'"):

- Alle `ScrapeData_*`/`ScrapeImage_*`/`ScrapeTheme_*`/`ScrapeTrailer_*`-Funktionen
  in `EmberAPI/clsAPIModules.vb` geben weiterhin `ret.Cancelled` zurück
  (**True = Abbruch/Fehler**, alte Semantik — unverändert seit 2016).
- `d08f4dae` hat aber nur die Aufrufer in `EmberMediaManager/frmMain.vb` auf die
  neue Semantik (**True = Erfolg**) umgestellt — 45 Bedingungen.
- Alle Aufrufer außerhalb von `frmMain` (`dlgEdit_*`, `dlgOfflineHolder`,
  `clsAPIScanner`, `clsAPITaskManager`, `dlgMediaFileSelect`, TVDB-Addon) sowie
  zwei übersehene Stellen in `frmMain` selbst (11761, 15543/15558) erwarten noch
  die alte Semantik.

Folge: Ein erfolgreicher Scrape (`Return False`) wurde in `frmMain` als Abbruch
gewertet → `bwMovieScraper.CancelAsync()` → Ergebnis verworfen, Film von Platte
neu geladen. Die komplette Scrape-Pipeline (Daten, Bilder, Themes, Trailer) war
seit Nov 2022 funktionslos.

- [x] Fix: Alle 45 vom Commit geänderten Bedingungen in `frmMain.vb` auf die alte,
      konsistente Semantik zurückgedreht (38× `If X` → `If Not X` für
      „bei Erfolg fortfahren", 8× `If Not X` → `If X` für Abbruch-Checks).
      Die nicht migrierten Aufrufer in den übrigen Dateien werden dadurch
      automatisch wieder korrekt. Kein Funktions- oder API-Eingriff in
      `clsAPIModules.vb` nötig.
- [x] Build `Debug|x86` und `Debug|AnyCPU` erfolgreich (Exit 0).

## Nachgetragener Fix: Detail-Vorschau im Suchdialog (TMDb)

Erstellt am: 2026-09-21 (Anwender-Rückmeldung nach erfolgreichem Scrape)

Im Suchdialog wurden bei markiertem Treffer nur die IMDb-ID angezeigt —
Premiered/Year, Directors, Genres, Plot Outline und Poster blieben leer. Grund:
Die Vorschau (`SearchType.SearchDetails_*` in `bwIMDB_DoWork`) rief weiterhin
`GetMovieInfo`/`GetTVShowInfo` auf, die auf den defekten IMDb-HTML-Detailseiten
basieren (Parsing schlägt fehl, aber ohne Exception → leere Felder).

- [x] Fix: `clsScrapeIMDB.vb` — neue `GetMoviePreviewInfo`/`GetTVShowPreviewInfo`,
      die die Vorschau über die TMDb-API befüllen (`GetMovieAsync` akzeptiert die
      IMDb-ID direkt; für Serien Auflösung über `FindAsync(Imdb)` →
      `GetTvShowAsync`). Gemappt: Title/OriginalTitle, Tagline, Year/Premiered,
      Directors (Crew: Department „Directing"/Job „Director"), Genres,
      Outline/Plot (Overview) bzw. Creators/Plot bei Serien, Poster-URL
      (`w185`) über `strPosterURL`. `bwIMDB_DoWork` ruft für
      `SearchDetails_*` nun diese Funktionen; `GetMovieInfo`/`GetTVShowInfo`
      (IMDb-Detail-Scrape für den eigentlichen Scrape) bleiben unverändert.
      Fehlerfall läuft über den bestehenden `ShowDetailLookupFallback`-Pfad.
- [x] Build `scraper.Data.IMDB` `Debug|x86` und `Debug|AnyCPU` erfolgreich (Exit 0).

## Fehlgeschlagene Tests

- [ ] Abnahmeprotokoll-Szenarien 1–7 — nicht ausgeführt (manuelle Abnahme ausstehend; kein UI-Test-Framework, Live-TMDb-API-Abhängigkeit). Siehe `abnahmeprotokoll.md` und `test-results.md`. Erster Teillauf des Anwenders (2026-09-21): Suche zeigte Exact- und Partial-Matches korrekt; Bestätigen scheiterte am oben behobenen Cancelled-Abbruch — **Wiederholung der Abnahme mit dem neuen Build erforderlich**.
