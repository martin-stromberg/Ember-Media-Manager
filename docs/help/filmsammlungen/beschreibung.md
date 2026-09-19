← [Zurück zur Übersicht](index.md)

# Filmsammlungen — Beschreibung

## Zweck

Filmsammlungen (Movie Sets) fassen Filmreihen zusammen. Ember Media Manager verwaltet Sammlungen als eigene Einträge mit Titel, Handlung und eigenem Artwork (Poster, Fanart, Banner, ClearArt, ClearLogo, DiscArt, Landscape) und verknüpft Filme über die Set-Zuordnung. Beim Scrapen können Sets automatisch aus den Scraper-Daten (z. B. TMDb-Collections) entstehen.

## Funktionsweise

- **Sets Manager:** Zentrale Verwaltung der Sammlungen (Anzeige *Sets & Manager*).
- **Zuordnung:** Im Film-Bearbeitungsdialog wird im *Set*-Feld eine Sammlung gewählt oder neu angelegt; ein Film kann Sets zugeordnet sein.
- **Bearbeiten:** *Edit MovieSet* pflegt Set-Metadaten und -Bilder; *New Set* legt eigene Sammlungen an.
- **Scraping:** MovieSet-Scraper (z. B. TMDb) laden Set-Metadaten und -Bilder; MovieSet-Informationen werden in NFOs und Datenbank gespeichert.
- **Sortierung:** Sets können nach eigenen Regeln sortiert werden (Sortier-Methoden der Sammlung).

## Beispiele

- Trilogie bündeln: *New Set* anlegen → Filme per *Edit Movie* dem Set zuweisen → Set mit Poster/Fanart versehen.
- Automatisch erkannte Sets prüfen: Nach dem Scrapen im *Sets Manager* die Set-Zuordnungen kontrollieren und bei Bedarf ändern.

## Einschränkungen

- Eine automatische Set-Erkennung hängt vom Daten-Scraper ab; ohne Collection-Daten werden keine Sets angelegt.
- Das Löschen eines Films entfernt auch dessen Set-Verknüpfung; leere Sets bleiben bis zur Bereinigung bestehen.
