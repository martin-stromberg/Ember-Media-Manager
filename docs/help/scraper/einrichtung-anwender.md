← [Zurück zur Übersicht](index.md)

# Scraper — Einrichtung

## Zweck

Vor dem ersten Scrape-Lauf werden die Scraper-Module aktiviert, in der gewünschten Reihenfolge sortiert und — falls nötig — mit API-Keys oder Konten versehen.

## Einstellungen

| Einstellung | Bedeutung |
|-------------|-----------|
| Aktivierung (Checkbox je Modul) | Modul wird beim Scrapen berücksichtigt |
| *Scrape Order* | Reihenfolge der Daten-Scraper; der erste aktive Scraper liefert zuerst |
| Sprache | Bevorzugte Sprache für Inhalte und Suchergebnisse (z. B. „default language … when scraping TV Show items") |
| Felder/Bildtypen je Scraper | Welche Metadaten bzw. Artwork-Typen der Scraper liefern darf |
| Konto/API-Key | Bei Quellen mit Anmeldung (z. B. Trakt.tv: Autorisierung; OMDb: API-Key) |
| „also use Trailer Scrapers" | Trailer-Scraper zusätzlich zum Daten-Scraping ausführen |

## Vorgehen

1. *Edit → Settings...* öffnen.
2. Im Bereich *Scrapers* (je Inhaltstyp: Movies / MovieSets / TV Shows) die gewünschten Daten-, Bilder-, Trailer- und Theme-Scraper aktivieren.
3. Über *Scrape Order* die Reihenfolge festlegen.
4. Konten/API-Keys in den jeweiligen Modul-Einstellungen hinterlegen (z. B. Trakt-Autorisierung über den Autorisierungsdialog).
5. Optional je Scraper die erlaubten Felder und Bildtypen einschränken.

## Hinweise

- Nur aktivierte Scraper werden benutzt — ein deaktiviertes Modul bleibt auch bei „All"-Läufen inaktiv.
- Die Sprachwahl wirkt auf Suchergebnisse und Inhalte; für deutsche Inhalte empfiehlt sich ein deutscher Daten-Scraper weit vorne in der Reihenfolge.
- Änderungen an den Scraper-Einstellungen können einen Neustart der Anwendung erfordern (das Modul meldet *Setup Needs Restart*).
