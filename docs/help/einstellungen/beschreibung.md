← [Zurück zur Übersicht](index.md)

# Einstellungen — Beschreibung

## Zweck

Über *Edit → Settings...* wird die gesamte Anwendung konfiguriert: Film- und Serienquellen, Datei- und Ordnerbenennung (NFO-/Artwork-Schema), Scraper-Auswahl und -Reihenfolge, Modul-Aktivierung, Filter- und Anzeigeoptionen. Jedes Modul bringt dabei sein eigenes Einstellungspanel mit und bettet es in den Dialog ein.

## Funktionsweise

- **Einstellungsdialog:** Baumansicht links, Einstellungspanel rechts; Änderungen werden mit *Apply* übernommen.
- **Quellen:** Film-/Serienquellen mit *Add Source* verwalten (siehe [Medienbibliothek](../medienbibliothek/index.md)).
- **Dateibenennung:** Pro Inhaltstyp konfigurierbare Dateinamen-Schemata (z. B. `<movie>.nfo`, `<movie>-fanart.jpg`, `/extrathumbs/`) — Kodi-kompatible Vorgaben sind vorbelegt.
- **Scraper:** Aktivierung, Reihenfolge und Feld-/Bildauswahl je Scraper-Gruppe.
- **Module:** Aktivierung und Modul-spezifische Panels; manche Änderungen erfordern einen Neustart.
- **Profile:** Über *Select Profile...* / Kommandozeilenparameter werden getrennte Konfigurationen mit eigener Datenbank verwaltet — beim ersten Start wird das Profil abgefragt.
- **Erweiterte Einstellungen:** Zusätzliche Schlüssel-Wert-Optionen außerhalb der sichtbaren Dialoge (Advanced Settings), u. a. Regex-Filter, Ausschlussverzeichnisse, Formatkonvertierungen.

## Beispiele

- Dateinamen-Konvention ändern: Settings → Movies → File Naming → Schema wählen.
- Nur Poster ab einer Mindestgröße: Settings → Images → Größenfilter setzen.
- Zweite Konfiguration (z. B. Kind/Eltern): Neues Profil anlegen und beim Start wählen.

## Einschränkungen

- Die UI ist englisch; Übersetzungsressourcen sind auf das gelieferte Sprachpaket beschränkt.
- Ungültige `Settings.xml` führt zu Standardeinstellungen statt zum Absturz; die Datei wird dann neu geschrieben.
- Modul-Einstellungen gehören zum Modul — deaktivierte Module zeigen keine Panels.
