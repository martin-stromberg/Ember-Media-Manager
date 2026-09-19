← [Zurück zur Übersicht](index.md)

# Filme — Beschreibung

## Zweck

Die Filmliste (*Movies*) zeigt alle gescannten Filme der Medienbibliothek. Ember Media Manager verwaltet pro Film neben den Mediendateien die kompletten Metadaten (Titel, Originaltitel, Jahr, Genre, Handlung, Besetzung, Bewertungen, externe IDs), alle Bildtypen (Poster, Fanart, Banner, ClearArt, ClearLogo, DiscArt, Landscape, Extrathumbs, Extrafanart), Trailer, Themes und Untertitel — kompatibel zum Kodi-Datei- und NFO-Schema.

## Funktionsweise

- **Bearbeiten:** *Edit Movie* öffnet den Bearbeitungsdialog mit allen Metadatenfeldern, Bildauswahl, Besetzung, Streams und Dateiinformationen.
- **Scraping:** Über Kontextmenü *(Re)Scrape Movie* oder *Custom Scraper...* werden Metadaten/Bilder/Trailer aus den aktivierten Scrapern geladen (siehe [Scraper](../scraper/index.md)).
- **Bilder:** Bilder können aus Scraper-Ergebnissen, aus lokalen Dateien oder per URL gesetzt werden (*Set As Fanart*, *dlgImageManual*).
- **Sammlungen:** Filme lassen sich Movie Sets zuordnen (*Set*-Feld, *Sets Manager*).
- **Status:** *Mark*, *Lock*, *New*-Kennung steuern Batch-Aktionen und Schreibschutz.
- **DVD-Profiler-Import:** Vorhandene DVD-Profiler-Sammlungen können über den Import-Dialog eingelesen und Film-Einträgen zugeordnet werden.

## Beispiele

- Film mit falschem Titel: *Edit Movie* → Titel/Jahr korrigieren → speichern schreibt NFO und Datenbank.
- Poster ersetzen: Im Detailbereich Poster-Kontextmenü → *Change* → lokale Datei oder Scraper-Ergebnis wählen.
- Mehrere Filme neu scrapen: Filme *Mark*ieren → *(Re)Scrape Selected Movies* → *Marked Movies - Auto*.

## Einschränkungen

- Gesperrte (*Lock*) Filme werden von Scrape- und Update-Läufen nicht verändert.
- Die IMDb-ID ist der führende eindeutige Bezeichner für Filme (Designvorgabe des Projekts); fehlt sie, wird sie über die Scraper ermittelt.
- Änderungen an Dateien außerhalb von Ember erscheinen erst nach dem nächsten Bibliotheks-Scan.
