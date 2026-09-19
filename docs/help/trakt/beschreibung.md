← [Zurück zur Übersicht](index.md)

# Trakt.tv — Beschreibung

## Zweck

Das Modul *Trakt.tv* synchronisiert die lokale Medienbibliothek mit dem Trakt.tv-Konto des Anwenders — „Sync lists and playcount with your trakt.tv account." Damit lassen sich der Gesehen-Status zwischen Geräten und Ember abgleichen, Trakt-Listen pflegen und Trakt als Metadatenquelle nutzen.

## Funktionsweise

- **Autorisierung:** Einmalige Konto-Verknüpfung über den Autorisierungsdialog; das Token wird gespeichert und automatisch erneuert.
- **Watched-Status:** *Get watched movies* / *Get watched episodes* lädt den Trakt-Watched-Status; *Save playcount to database/Nfo* schreibt ihn in die Ember-Datenbank und NFOs. Umgekehrt kann der lokale Status an Trakt gemeldet werden.
- **Kontextmenüs:** Pro Film/Episode/Staffel/Serie kann der Watched-Status gezielt von Trakt geholt oder gemeldet werden.
- **Listen:** Trakt-Listen (Watchlist, eigene Listen, Collection) können mit Tags bzw. der Ember-Bibliothek synchronisiert werden.
- **Ratings & Kommentare:** Bewertungen an Trakt melden, Kommentare lesen/schreiben.
- **Daten-Scraper:** Ein separater Trakt-Datenscraper liefert Metadaten für Filme und Serien (siehe [Scraper](../scraper/index.md)).

## Beispiele

- Auf dem Media-Center gesehene Filme in Ember als gesehen markieren: *Get watched movies* → *Save playcount to database/Nfo*.
- Serienfortschritt: *Get watched episodes* → Episoden-Playcounts in Ember übernehmen; fehlende Folgen sind so sichtbar.
- Eigene Trakt-Liste als Tag: Liste in Ember als Schlagwort synchronisieren.

## Einschränkungen

- Erfordert ein Trakt.tv-Konto und eine einmalige Autorisierung der Anwendung.
- Der Abgleich erfolgt über externe IDs (IMDb/TMDb/TVDb) — Medien ohne solche ID können nicht zugeordnet werden.
- Die Sync-Funktionen hängen vom Trakt-API-Dienst ab; Änderungen des Diensts wirken direkt auf die Verfügbarkeit.
