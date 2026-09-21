# Usability-Review

## Ergebnis

**Status:** Befunde vorhanden

## Befunde

### clsScrapeIMDB.vb (Suchpfad hinter den Dialogen dlgIMDBSearchResults_Movie / _TV)

- **Erreichbarkeit** — Die geforderte, von „keine Treffer" unterscheidbare Fehlermeldung erreicht die Anwenderin nur im SingleScrape-Dialog (`SearchMovieAsync` → `bwIMDB_RunWorkerCompleted` → `Exception`-Event → `SearchFailed`). Im normalen (Re-)Scrape- bzw. Ask-Flow läuft die Suche synchron über `GetSearchMovieInfo` (clsScrapeIMDB.vb:920) bzw. `GetSearchTVShowInfo` (clsScrapeIMDB.vb:992). Schlägt dort die TMDb-Abfrage fehl (Ausfall, ungültiger Key, kein Netz), wird die Exception vom umgebenden `Catch` (Z. 971–974 bzw. 1020–1023) nur ins Log geschrieben und `Nothing` zurückgegeben — `Scraper_Movie`/`Scraper_TV` (IMDB_Data.vb:463/525) beenden den Scrape still mit „kein Ergebnis". Für die Nutzerin ist ein Quell-Ausfall damit weiterhin nicht von „keine Treffer" unterscheidbar; es erscheint weder der Suchdialog noch eine Fehlermeldung.

  Empfehlung: Den Fehlerzustand in `GetSearchMovieInfo`/`GetSearchTVShowInfo` nicht verschlucken, sondern an die aufrufende UI transportieren — z. B. bei Ask-Scrape-Typen den Suchdialog mit dem Fehlerknoten öffnen (derselbe `SearchFailed`-Pfad wie im Async-Fall) oder eine verständliche MessageBox zeigen, damit die Nutzerin erkennt, dass die Quelle ausgefallen ist und nicht der Titel unbekannt war.

### dlgIMDBSearchResults_Movie.vb / dlgIMDBSearchResults_TV.vb / dlgTMDBSearchResults_*.vb (Suchdialoge)

- **Erreichbarkeit** — Die neue Fehleranzeige (`SearchFailed`, z. B. dlgIMDBSearchResults_Movie.vb:342–359) setzt die rohe `ex.Message` ungefiltert in den Baumknoten („The search could not be completed: {0}"). Die Nutzerin sieht je nach Fehler kryptische, englische .NET-/HTTP-Meldungen (z. B. „Response status code does not indicate success: 401" oder TMDbLib-Interna). Die Meldung ist zwar von „No Matches Found" unterscheidbar, gibt ihr aber keinen Hinweis, was sie tun kann (Key prüfen? Netz prüfen? später erneut versuchen?).

  Empfehlung: Häufige Fehlerfälle auf verständliche, lokalisierte Texte mappen (z. B. ungültiger/fehlender API-Key → Hinweis auf die Moduleinstellungen; Netz-/Serverfehler → „später erneut versuchen") und die technische `ex.Message` nur ergänzend bzw. im Log ausgeben.

- **Erreichbarkeit** — Schlägt der Detailabruf eines ausgewählten Treffers fehl (defekter IMDb-Detail-Endpunkt), bleibt die Detailansicht komplett leer: `lblIMDBID` wird zwar gesetzt, aber `ControlsVisible(True)` wird nicht aufgerufen, sodass alle Labels unsichtbar bleiben (dlgIMDBSearchResults_Movie.vb:331–335, dlgIMDBSearchResults_TV.vb:319–323). OK ist zwar aktiviert und der Dialog liefert die IMDb-ID, aber die Nutzerin erhält keine Rückmeldung, warum keine Vorschau erscheint — der Zustand sieht aus wie „Treffer ohne Daten".

  Empfehlung: Bei fehlgeschlagenem Detailabruf zumindest die ermittelte IMDb-ID sichtbar machen (`ControlsVisible(True)`) oder einen kurzen Hinweis anzeigen, dass Details nicht geladen werden konnten, der Treffer aber übernommen werden kann.

## Geprüfte Interaktionen

Liste der aus der Anforderung geprüften Benutzerinteraktionen:
- Film per Titel suchen, Treffer im Dialog auswählen und mit OK bestätigen → unauffällig (Trefferliste mit Titel/Jahr, Kategorien Exact/Partial Matches, OK wird nach Auswahl freigeschaltet; bei defektem Detailabruf bleibt die Auswahl bestätigbar)
- Serie per Titel suchen und auswählen (dlgIMDBSearchResults_TV) → unauffällig
- Quell-Ausfall von „keine Treffer" unterscheiden → Befund vorhanden (nur Dialog-Pfad implementiert; Ask/Auto-Pfad verschluckt den Fehler; Fehlertext ist rohe Exception-Meldung)
- Eigenen TMDb-API-Key in den IMDb-Moduleinstellungen hinterlegen → unauffällig (deaktiviertes Feld + „Use my own API key"-Button + „Embedded API Key"-Hinweis entsprechen exakt dem etablierten Muster der TMDb-Panels; gespeicherter Key wird beim Öffnen korrekt wiederhergestellt; leer = eingebetteter Fallback-Key)
- Manuelle IMDb-ID-Eingabe als Fallback (`chkManual`/`txtIMDBID`/`btnVerify`) → unauffällig (unverändert, optional, nach Fehler wieder freigeschaltet; kein Pflichtwissen, da die titelbasierte Suche der Normalweg ist)
- Entfernte Suchkategorie-Checkboxen (Popular/Partial/TV/Video/Short Titles) in den Moduleinstellungen → unauffällig (tote Optionen entfernt, keine Interaktion geht verloren)

## Geprüfte Dateien

Liste aller geprüften UI-Dateien:
- `Addons/scraper.IMDB.Data/Scraper/dlgIMDBSearchResults_Movie.vb`
- `Addons/scraper.IMDB.Data/Scraper/dlgIMDBSearchResults_TV.vb`
- `Addons/scraper.IMDB.Data/frmSettingsHolder_Movie.vb`
- `Addons/scraper.IMDB.Data/frmSettingsHolder_Movie.Designer.vb`
- `Addons/scraper.IMDB.Data/frmSettingsHolder_TV.vb`
- `Addons/scraper.IMDB.Data/frmSettingsHolder_TV.Designer.vb`
- `Addons/scraper.TMDB.Data/Scraper/dlgTMDBSearchResults_Movie.vb`
- `Addons/scraper.TMDB.Data/Scraper/dlgTMDBSearchResults_MovieSet.vb`
- `Addons/scraper.TMDB.Data/Scraper/dlgTMDBSearchResults_TV.vb`
- `EmberAPI/Translations/en-US.xml`

Zur Beurteilung der UI-Wirkungskette zusätzlich gelesen (nicht Teil der Diff-UI-Dateien): `Addons/scraper.IMDB.Data/IMDB_Data.vb`, `Addons/scraper.IMDB.Data/Scraper/clsScrapeIMDB.vb`, `Addons/scraper.TMDB.Data/Scraper/clsScrapeTMDB.vb`.
