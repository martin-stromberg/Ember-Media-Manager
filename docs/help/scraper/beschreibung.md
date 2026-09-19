← [Zurück zur Übersicht](index.md)

# Scraper — Beschreibung

## Zweck

Scraper-Module beziehen Informationen aus dem Internet: Metadaten (Titel, Handlung, Besetzung, Bewertungen, IDs), Bilder aller Artwork-Typen, Trailer-Videos und Themes (Titelmusik). Sie werden je Inhaltstyp — Film, Filmsammlung, Serie — getrennt aktiviert und in einer Scrape-Reihenfolge (*Scrape Order*) ausgeführt.

## Funktionsweise

- **Daten-Scraper** laufen nacheinander und füllen nur die ausgewählten und noch leeren Felder (sofern nicht gesperrt).
- **Bilder-Scraper** laufen parallel und liefern Ergebnislisten, die in einem gemeinsamen Auswahldialog zusammengeführt werden.
- **Trailer-Scraper** liefern Trailer-Quellen; gewählte Trailer werden heruntergeladen und neben dem Medium abgelegt.
- **Theme-Scraper** liefern Titelmusik (`theme`-Datei).
- **Scrape-Modi:** Für jeden Lauf wird Umfang und Interaktion gewählt: *All*, *New*, *Marked*, *Filter* oder *Missing Items* — jeweils als *Auto* (automatisch erstes Ergebnis), *Ask* (Auswahldialog) oder *Skip*.
- **Custom Scraper:** *Custom Scraper...* erlaubt die Auswahl einzelner Felder, Bildtypen und Optionen je Lauf.

## Verfügbare Scraper-Module

| Gruppe | Modul | Inhaltstyp |
|--------|-------|------------|
| Daten | IMDb | Film, Serie |
| Daten | TMDb | Film, Filmsammlung, Serie |
| Daten | TheTVDB | Serie |
| Daten | OMDb | Film, Serie |
| Daten | OFDb | Film (deutsch) |
| Daten | Moviepilot | Film (deutsch) |
| Daten | Trakt.tv | Film, Serie |
| Bilder | TMDb | Film, Filmsammlung, Serie |
| Bilder | Fanart.tv | Film, Filmsammlung, Serie |
| Bilder | TheTVDB | Serie |
| Trailer | YouTube | Film |
| Trailer | TMDb | Film |
| Trailer | Apple Trailers | Film |
| Trailer | hd-trailers.net | Film |
| Trailer | Videobuster | Film (deutsch) |
| Themes | YouTube | Film, Serie |
| Themes | TelevisionTunes | Film, Serie |

## Beispiele

- Neuen Film vollständig befüllen: *(Re)Scrape Movie* → *New Movies - Auto* → Daten aus erstem Treffer, Bildauswahl im Dialog.
- Nur fehlende Poster nachladen: *Custom Scraper...* → nur Poster aktivieren → *Missing Items - Auto*.
- Deutsche Inhalte: OFDb/Moviepilot in der Daten-Scraper-Reihenfolge vorziehen.

## Einschränkungen

- Die Verfügbarkeit und Datenqualität der Online-Quellen liegt außerhalb des Projekts; einzelne Dienste können ihren Dienst geändert oder eingestellt haben — das Modul meldet dann schlicht keine Ergebnisse.
- Einige Quellen erfordern API-Keys oder Konto-Anmeldung (siehe [Einrichtung](einrichtung-anwender.md)).
- Gesperrte Einträge (*Lock*) werden nicht verändert; leere Felder werden nur gefüllt, wenn der Scraper sie liefert.
