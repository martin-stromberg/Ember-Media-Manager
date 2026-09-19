← [Zurück zur Übersicht](index.md)

# Werkzeuge — Beschreibung

## Zweck

Die generischen Module (`generic.EmberCore.*`) stellen Werkzeuge rund um die Medienbibliothek bereit. Sie werden über die Modul-Einstellungen aktiviert und integrieren sich über Menü- und Kontextmenü-Einträge sowie eigene Dialoge.

## Bulk Renamer

*Bulk Renamer* benennt Film- und Seriendateien/-ordner nach frei definierbaren Mustern um — stapelweise (*Bulk Rename*, *TV Bulk Renamer*) oder einzeln (*Manual Rename*). Die Muster-Syntax umfasst Platzhalter für Titel, Jahr, Auflösung, Codecs, Staffel-/Episodennummern u. v. m. Optionen wie *Display Only Movies That Will Be Renamed*, *Automatically Rename Files During Multi-/Single-Scraper* steuern Vorschau und Automatik. Fehlgeschlagene Umbenennungen (gesperrte Dateien/Ordner) werden mit Fehlermeldung quittiert.

## Movie List Exporter

*Export Movies* / *Movie List Exporter* exportiert die Filmbibliothek über Template-Dateien (z. B. HTML-Listen). *Export Movie List* wählt Template und Ziel; die Vorlagen liegen im `Templates`-Ordner des Moduls.

## Media File Manager

Dateioperationen für Mediendateien: Kopieren/Verschieben in Zielverzeichnisse (*Copy Files*-Dialog), optional über TeraCopy.

## Tag Manager

Verwaltung von Tags/Schlagworten: Tags anlegen, bearbeiten, löschen und den Medien zuordnen. Ergänzend existiert der einfache *Tag Manager*-Dialog der Hauptanwendung für direkte Zuordnung.

## Medienlisten-Editor (Filter Editor)

Benutzerdefinierte Filter und Medienlisten bearbeiten — Kriterien für die Listenansichten pflegen, die dann in der Filterleiste zur Verfügung stehen.

## Mapping-Editor

Bearbeitet die Zuordnungslisten der Anwendung: Genre-Mapping, Regex-Mapping und Simple-Mapping (z. B. Übersetzung von Genre-Bezeichnern oder Quell-Bezeichnern in eigene Werte).

## Metadaten-Editor

Pflegt die Bezeichner-Tabellen für Codecs und Metadaten (z. B. welche Codec-Strings welchem Flag/Anzeigewert entsprechen).

## Kontextmenü

Stellt zusätzliche Kontextmenü-Einträge in den Medienlisten bereit.

## Video Source Mapping

Ordnet Videoquellen-Bezeichner zu (z. B. welche Dateinamen-Bestandteile als Blu-ray, DVD, HDTV erkannt werden).

## Einschränkungen

- Alle Werkzeuge arbeiten auf der Ember-Datenbank — Dateien, die noch nicht gescannt sind, stehen nicht zur Verfügung.
- Der Bulk Renamer verändert Dateien und Ordner auf dem Datenträger; gesperrte oder geöffnete Dateien führen zu Fehlermeldungen (*Unable to Rename*).
- Einige Module melden nach Einstellungsänderungen *Setup Needs Restart*.
