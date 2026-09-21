# Test-Ergebnisse

Branch: `task/issue-16-45c4851ac5b74b72a2006fe31bcf83f7-titelbasierte-suche-fuer-filme`

## Ergebnis

**Status:** Fehler vorhanden

Hinweis zur Einordnung: Es gibt **keine fehlgeschlagenen automatisierten Tests und
keine Build-Fehler** — alle drei betroffenen Projekte kompilieren fehlerfrei
(Exit-Code 0, siehe Build-Verifikation unten). Der Status ergibt sich ausschließlich
daraus, dass die sechs geplanten Pflicht-E2E-Szenarien (manuelles
Abnahmeprotokoll, siehe `abnahmeprotokoll.md`) in diesem Lauf **nicht ausgeführt**
wurden — sie sind manuelle Abnahmeschritte und in dieser automatisierten
Ausführung nicht durchführbar (keine UI-Test-Infrastruktur im Projekt;
Anwender-Entscheidung: dokumentiertes manuelles Protokoll als E2E-Ersatz).

## Fehlgeschlagene Tests

Keine — es wurden keine automatisierten Tests ausgeführt (keine lauffähige
Testsuite vorhanden, siehe „Automatisierte Tests" unten). Der Status
„Fehler vorhanden" begründet sich aus den ausstehenden Pflicht-E2E-Szenarien
(Abschnitt „E2E-Abdeckung"), nicht aus Testfehlschlägen.

## Build-Verifikation (Lauf 5 — Iteration-3-Fixes, Nachlauf)

Nachweis per Build, da keine kompilierbare Testsuite existiert (siehe Abschnitt
„Automatisierte Tests" unten). Der Code wurde seit dem letzten Lauf geändert
(Iteration-3-Nacharbeiten: Guard in `bwIMDB_RunWorkerCompleted`, Label-Texte in
den Settings-Panels, Logging-Bereinigung, Designer-Anpassungen in
`frmSettingsHolder_Movie.Designer.vb`/`frmSettingsHolder_TV.Designer.vb`);
dieser Lauf (2026-09-21) ist der erneute automatisierbare Nachweis für den
aktuellen Code-Stand.

Werkzeug: `C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe`
(MSBuild 18.10.1, .NET Framework), Konfiguration `Debug|x86`.
Vorab: `.nuget\NuGet.exe restore "Ember Media Manager.sln"` → Exit-Code 0
(„Alle in packages.config aufgeführten Pakete sind bereits installiert",
`packages\TMDbLib.2.3.0` vorhanden).

| Projekt | Befehl | Exit-Code | Ergebnis |
|---------|--------|-----------|----------|
| `Addons\scraper.IMDB.Data\scraper.Data.IMDB.vbproj` | `MSBuild.exe <proj> -p:Configuration=Debug -p:Platform=x86 -v:minimal -nologo` | 0 | `EmberMM - Debug - x86\Modules\scraper.data.imdb\scraper.Data.IMDB.dll` |
| `Addons\scraper.TMDB.Data\scraper.Data.TMDB.vbproj` | `MSBuild.exe <proj> -p:Configuration=Debug -p:Platform=x86 -v:minimal -nologo` | 0 | `EmberMM - Debug - x86\Modules\scraper.data.tmdb\scraper.Data.TMDB.dll` |
| `EmberMediaManager\EmberMediaManager.vbproj` | `MSBuild.exe <proj> -p:Configuration=Debug -p:Platform=x86 -v:minimal -nologo` | 0 | `EmberMM - Debug - x86\Ember Media Manager.exe` |

Einzige Warnung: `MSB3884` (fehlende Regelsatzdatei
`MinimumRecommendedRules.ruleset` in `EmberAPI.vbproj`) — vorbestehend, nicht
durch diese Änderung verursacht.

## Lauf-Historie (konsolidiert)

| Lauf | Anlass | Builds | Ergebnis |
|------|--------|--------|----------|
| 1 | Erstverifikation nach Implementierung (Plan-Schritt 7) | 3/3 erfolgreich | Keine Build-Fehler |
| 2 | Review-Fehlerkorrektur (Befunde aus `review.md` Task 22, `review-code.md`, `review-usability.md` 3× Erreichbarkeit) | 3/3 erfolgreich | Keine Build-Fehler |
| 3 | Iteration-2-Fixes (nachgelieferte Korrekturen in `clsScrapeIMDB.vb`, `clsScrapeTMDB.vb`, 5 Dialogen, `en-US.xml`) | 3/3 erfolgreich | Keine Build-Fehler |
| 4 | Iteration-3-Fixes (`e.Result`-Guard, `strPlot` entfernt, doppeltes Logging aufgelöst, Label 1498, `SetColumnSpan` TV-Panel, Repo-Artefakte gelöscht) | 3/3 erfolgreich | Keine Build-Fehler |
| 5 | Iteration-3-Nacharbeiten (Guard, Label-Texte, Logging, `frmSettingsHolder_*.Designer.vb`) — erneuter `/run-tests`-Lauf (2026-09-21) | 3/3 erfolgreich | Keine Build-Fehler |

Anmerkung zu Lauf 2 (unverändert gültig): In `SearchMovie`/`SearchMovieSet`/
`SearchTVShow` (`clsScrapeTMDB.vb`) werden gefaultete Tasks per
`GetAwaiter().GetResult()` entpackt (echte Exception statt `AggregateException`)
und weitergeworfen, damit der Dialog-Pfad den geforderten, von „No Matches
Found" unterscheidbaren Fehlerknoten (Abnahme-Szenario 6) erhält. Seit Lauf 4
erfolgt die Protokollierung nicht mehr in den Suchmethoden selbst, sondern
ausschließlich auf Caller-Seite (`bwTMDB_RunWorkerCompleted` im Async-Pfad,
innerer `Try/Catch` in `GetSearch*Info` im Sync-Pfad) — dadurch wird jeder
Fehler genau einmal geloggt. Der synchrone Pfad (`GetSearchMovieInfo`/
`GetSearchMovieSetInfo`/`GetSearchTVShowInfo`) ist vollständig mit `Try/Catch`
abgesichert; im Auto-/Skip-Flow wird der Fehler geloggt und `Nothing`
zurückgegeben.

## Automatisierte Tests

Nicht ausführbar: Das einzige Testprojekt `EmberAPI_Test` ist **nicht Teil der
Solution** (`Ember Media Manager.sln` enthält kein Testprojekt) und referenziert
das fehlende `..\UnitTests\UnitTests.vbproj` (Verzeichnis `EmberAPI_Test\UnitTests`
existiert nicht) — daher nicht kompilierbar. Es existieren keine Testdateien für
die Addon-Module (`scraper.Data.IMDB`, `scraper.Data.TMDB`); die vorhandenen
`Test_clsAPI*`-Dateien betreffen ausschließlich EmberAPI-Hilfsklassen. Ausgeführte
Tests: **0**. Der automatisierbare Nachweis ist der Build (oben).

## E2E-Abdeckung

Geplante Pflicht-Szenarien aus `plan.md` (Abschnitt „E2E-Tests") /
`plan-check.md` (Abschnitt „E2E-Abdeckung"). Das Protokoll existiert als
`abnahmeprotokoll.md` im Feature-Verzeichnis — alle sechs Pflicht-Szenarien sind
dort als Szenarien 1–7 dokumentiert (Szenarien 2/3 der Referenzfilme in einem
Tabelleneintrag des Plans zusammengefasst), alle Checkboxen unausgefüllt
(„☐ bestanden ☐ fehlgeschlagen").

| Szenario | Test / Testklasse | Ergebnis |
|----------|-------------------|----------|
| Filmsuche „28 Days Later" → `dlgIMDBSearchResults_Movie` zeigt Treffer mit `tt0289043` | Manuell — `abnahmeprotokoll.md` Szenario 1 | Nicht ausgeführt (ausstehend — manuelle Abnahme) |
| Filmsuche „28 Weeks Later" → `tt0463854`; „28 Years Later" → `tt10548174` | Manuell — `abnahmeprotokoll.md` Szenarien 2 + 3 | Nicht ausgeführt (ausstehend — manuelle Abnahme) |
| Seriensuche mit bekanntem Titel → `dlgIMDBSearchResults_TV` zeigt Treffer mit korrekter IMDb-ID („Breaking Bad" → `tt0903747`) | Manuell — `abnahmeprotokoll.md` Szenario 4 | Nicht ausgeführt (ausstehend — manuelle Abnahme) |
| Manuelle IMDb-ID-Eingabe (`chkManual`/`txtIMDBID`/`btnVerify`) in beiden Dialogen | Manuell — `abnahmeprotokoll.md` Szenario 5 | Nicht ausgeführt (ausstehend — manuelle Abnahme) |
| Quell-Ausfall (ungültiger `APIKey`/Netzwerk getrennt) → unterscheidbare Fehlermeldung statt „No Matches Found" (IMDb- und TMDb-Dialoge) | Manuell — `abnahmeprotokoll.md` Szenario 6 | Nicht ausgeführt (ausstehend — manuelle Abnahme) |
| Scrape-Order-Fluss: beide Daten-Scraper aktiv (IMDb vor TMDb) → Kette läuft nach Trefferauswahl weiter (`[Using]`-Logzeilen) | Manuell — `abnahmeprotokoll.md` Szenario 7 | Nicht ausgeführt (ausstehend — manuelle Abnahme) |

Bewertung: Alle geplanten Protokoll-Szenarien **existieren** im
Abnahmeprotokoll und sind vollständig beschrieben (Aktion + Erwartungswert).
Keines wurde ausgeführt — die manuelle Abnahme (Plan-Schritt 8) steht noch aus
und erfordert eine laufende WinForms-Instanz mit Netzwerkzugang zur TMDb-API.
Da diese Pflicht-Szenarien nicht automatisiert ausführbar sind, bleibt der
Gesamtstatus „Fehler vorhanden" (nicht „Keine Fehler"), bis die manuelle
Abnahme durchgeführt und protokolliert ist.

## Zusammenfassung

- Gesamt: 0 (automatisierte Tests)
- Bestanden: 0
- Fehlgeschlagen: 0
- Übersprungen: 0
- Builds (aktueller Lauf 5): 3 von 3 erfolgreich (Exit-Code 0)
- Manuelle E2E-Pflichtszenarien: 6 geplant / 0 ausgeführt (ausstehend)

## Testabdeckung

**Abdeckung:** Nicht messbar

Kein Coverage-Tool und keine lauffähige Testsuite im Projekt vorhanden.

## Fehlende Tests

Quelle: `Dateinamen-Konvention` — für sämtliche von dieser Änderung betroffenen
Quelldateien existiert keine korrespondierende Testdatei (im Projekt existiert
generell keine Testinfrastruktur für die Addon-Module):

- `Addons\scraper.IMDB.Data\Scraper\clsScrapeIMDB.vb` — Keine Testdatei gefunden
- `Addons\scraper.IMDB.Data\Scraper\dlgIMDBSearchResults_Movie.vb` — Keine Testdatei gefunden
- `Addons\scraper.IMDB.Data\Scraper\dlgIMDBSearchResults_TV.vb` — Keine Testdatei gefunden
- `Addons\scraper.IMDB.Data\IMDB_Data.vb` — Keine Testdatei gefunden
- `Addons\scraper.IMDB.Data\frmSettingsHolder_Movie.vb` — Keine Testdatei gefunden
- `Addons\scraper.IMDB.Data\frmSettingsHolder_TV.vb` — Keine Testdatei gefunden
- `Addons\scraper.TMDB.Data\Scraper\clsScrapeTMDB.vb` — Keine Testdatei gefunden
- `Addons\scraper.TMDB.Data\Scraper\dlgTMDBSearchResults_Movie.vb` — Keine Testdatei gefunden
- `Addons\scraper.TMDB.Data\Scraper\dlgTMDBSearchResults_TV.vb` — Keine Testdatei gefunden
- `Addons\scraper.TMDB.Data\Scraper\dlgTMDBSearchResults_MovieSet.vb` — Keine Testdatei gefunden

## Hinweis Binding-Redirect

`TMDbLib` 2.3.0 ist nicht starknamensigniert (`PublicKeyToken=null`,
Assembly-Version 2.0.0.0). Für nicht signierte Assemblys wertet der CLR
Binding-Redirects nicht aus; die eingetragenen Redirects in
`Addons\scraper.IMDB.Data\app.config` und `EmberMediaManager\app.config` sind
daher funktional neutral und bleiben aus Dokumentationsgründen bestehen.
Laufzeitverhalten ist im Rahmen der manuellen Abnahme (Szenarien 1–3)
abschließend zu bestätigen.
