# Abnahmeprotokoll – Issue #16: Titelbasierte Suche für Filme (TMDb statt IMDb-HTML)

Branch: `task/issue-16-45c4851ac5b74b72a2006fe31bcf83f7-titelbasierte-suche-fuer-filme`

Die automatisierte Testinfrastruktur des Projekts ist nicht nutzbar
(`EmberAPI_Test` ist nicht Teil der Solution und referenziert ein fehlendes
`UnitTests\UnitTests.vbproj`). Die Abnahme erfolgt daher manuell nach diesem
Protokoll.

## Vorbedingungen

- Build `Debug|x86` erfolgreich (siehe `test-results.md`).
- IMDb-Daten-Scraper ist in den Moduleinstellungen aktiviert (Film bzw. TV).
- Für Szenario 6 wird temporär ein ungültiger TMDB-API-Key in den
  IMDb-Scraper-Einstellungen eingetragen oder die Netzwerkverbindung getrennt.

## Szenarien

### 1. Filmsuche „28 Days Later“

- Aktion: Film mit Titel „28 Days Later“ (Jahr 2002) über den IMDb-Scraper suchen
  (ScrapeType „Ask“, damit der Suchergebnis-Dialog erscheint).
- Erwartet: Ergebnisliste enthält „28 Days Later (2002)“ mit IMDb-ID `tt0289043`.
  Auswahl bestätigen → `DialogResult.OK`, anschließend Detailabruf mit `tt0289043`.
- Ergebnis: ☐ bestanden ☐ fehlgeschlagen

### 2. Filmsuche „28 Weeks Later“

- Aktion: Suche „28 Weeks Later“ (Jahr 2007).
- Erwartet: Treffer mit IMDb-ID `tt0463854`.
- Ergebnis: ☐ bestanden ☐ fehlgeschlagen

### 3. Filmsuche „28 Years Later“

- Aktion: Suche „28 Years Later“ (Jahr 2025).
- Erwartet: Treffer mit IMDb-ID `tt10548174`.
- Ergebnis: ☐ bestanden ☐ fehlgeschlagen

### 4. TV-Suche

- Aktion: Bekannte Serie suchen, z. B. „Breaking Bad“.
- Erwartet: Ergebnisliste mit Einträgen, die auflösbare IMDb-IDs (`tt…`)
  besitzen (für „Breaking Bad“ `tt0903747`). Titel und Premiered-Jahr werden
  in der Liste angezeigt.
- Ergebnis: ☐ bestanden ☐ fehlgeschlagen

### 5. Manuelle IMDb-ID-Eingabe

- Aktion: In beiden IMDb-Suchdialogen (Film und TV) „Manual IMDB Entry“
  aktivieren, eine gültige `tt…`-ID eingeben und verifizieren.
- Erwartet: Verifizierung lädt Details (oder, falls der IMDb-Detailabruf
  fehlschlägt, bleibt die eingetragene/ausgewählte ID als Ergebnis erhalten
  und OK ist möglich). Ungültige IDs werden mit der vorhandenen
  Fehlermeldung abgewiesen.
- Ergebnis: ☐ bestanden ☐ fehlgeschlagen

### 6. Quellen-/API-Fehler statt „No Matches Found“

- Aktion: Ungültigen TMDB-API-Key in den IMDb-Scraper-Einstellungen
  hinterlegen („Use my own API key“) oder Netzwerk trennen; Suche starten.
- Erwartet: Der Dialog zeigt den Fehlerknoten „The search could not be
  completed: …“ (eLang 1493) statt „No Matches Found“. Ladeanzeige wird
  ausgeblendet, manuelle Eingabe bleibt nutzbar. Gleiches gilt für die
  TMDb-Suchdialoge (Film, TV, Movieset).
- Ergebnis: ☐ bestanden ☐ fehlgeschlagen

### 7. Scraper-Kette IMDb → TMDb

- Aktion: In den Moduleinstellungen IMDb vor TMDb anordnen und einen Film
  mit Titel-suche pflichtig scrapen (z. B. umbenannte Datei ohne IMDb-ID im
  NFO).
- Erwartet: Nach Auswahl eines Ergebnisses im IMDb-Dialog läuft die Kette
  weiter; der TMDb-Scraper übernimmt/ergänzt Daten, kein Abbruch und kein
  Crash im `RunWorkerCompleted`-Pfad.
- Ergebnis: ☐ bestanden ☐ fehlgeschlagen

## Hinweise für die Prüfung

- Treffer ohne auflösbare IMDb-ID werden bewusst ausgeblendet (Dialog und
  Auto-Heuristik benötigen `IMDbId`).
- Die alten IMDb-Suchkategorien (Popular/TV/Video/Short Titles) entfallen;
  `ExactMatches`/`PartialMatches` (Film) bzw. `Matches` (TV) bleiben als
  Ergebnisvertrag bestehen.
- Protokoll der Build-Verifikation: `test-results.md`.
