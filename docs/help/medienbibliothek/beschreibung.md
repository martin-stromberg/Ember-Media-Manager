← [Zurück zur Übersicht](index.md)

# Medienbibliothek — Beschreibung

## Zweck

Ember Media Manager verwaltet keine Dateien „on the fly", sondern baut eine eigene Medienbibliothek auf: Der Anwender legt **Quellen** (Source) für Filme und Serien fest, die Anwendung durchsucht diese Verzeichnisse und speichert die gefundenen Medien samt Metadaten, Bildern und Dateiinformationen in einer lokalen Datenbank. Alle Listenansichten, Scraper und Werkzeuge arbeiten auf dieser Datenbank.

## Funktionsweise

- **Quellen:** Jede Quelle besteht aus einem Namen, einem Pfad und Optionen (z. B. rekursive Suche, Sprache, Sortierung). Film- und Serienquellen werden getrennt verwaltet.
- **Scan:** Über das Menü *Tools → Update Library* bzw. die Reload-Funktionen (*Reload All Movies*, *Reload All TV Shows*, *Reload All MovieSets*) werden die Quellen nach neuen oder entfernten Dateien durchsucht. Neue Medien erscheinen markiert als „New" in den Listen.
- **Erkennung:** Aus Datei- und Ordnernamen werden Titel, Jahr, bei Serien Staffel- und Episodennummern sowie Videoquellen-Bezeichner (z. B. Bluray, DVD, HDTV) ermittelt. Vorhandene NFO-Dateien werden eingelesen.
- **Filter:** Über den Listen lassen sich Einträge nach Quelle (*Video Sources*), Genre, Markierung, Lock-Status, Jahr und weiteren Kriterien filtern; *Clear Filters* setzt alle Filter zurück.
- **Markieren und Sperren:** Einträge können markiert (*Mark*, *Mark All*) oder gegen Änderungen gesperrt (*Lock*) werden.
- **Offline-Medien:** Über den *Offline Media Manager* werden Medien verwaltet, die nicht als Datei vorliegen (z. B. DVD/Blu-ray im Regal), inklusive Stub-Dateien für Medien-Center.

## Beispiele

- Ein neuer Film wird ins Filmverzeichnis kopiert → *Update Library* → der Film erscheint mit „New"-Kennung in der Filmliste und kann anschließend gescrapt werden.
- Nur Filme einer bestimmten Quelle anzeigen: in der Filterleiste unter *Video Sources* die Quelle auswählen.
- Eine Blu-ray-Sammlung ohne Dateien pflegen: über den *Offline Media Manager* Einträge mit Standort-Hinweis anlegen.

## Einschränkungen

- Die Bibliothek spiegelt den Stand des letzten Scans; Dateiänderungen außerhalb von Ember werden erst beim nächsten Scan erkannt.
- Entfernte Dateien werden erst durch die Bereinigungsfunktion (*Clean Database* / Clean Files) aus der Datenbank gelöscht.
- Die Anwendung ist englisch lokalisiert; alle sichtbaren Bezeichnungen sind englisch.
