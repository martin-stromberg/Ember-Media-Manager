← [Zurück zur Übersicht](index.md)

# Einstellungen — Installation und Konfiguration

## Voraussetzungen

Installierte Ember Media Manager Instanz (siehe [Build](../build/index.md) bzw. NSIS-Installer aus `BuildSetup/`).

## Ablage der Konfiguration

| Datei / Verzeichnis | Inhalt |
|---------------------|--------|
| `Settings.xml` (im Profilverzeichnis) | Gesamte Anwendungs- und Modul-Einstellungen |
| `AdvancedSettings.xml` | Erweiterte Schlüssel-Wert-Optionen (Regex, Ausschlüsse, Formatkonvertierung) |
| `MyVideos*.emm` | SQLite-Datenbank des Profils |
| `Modules/` | Addon-Assemblys, werden beim Start geladen |
| `Defaults/` (Programmverzeichnis) | Werksvorgaben: `DefaultAdvancedSettings - AudioFormatConverts.xml`, `DefaultAdvancedSettings - VideoFormatConverts.xml`, `DefaultAdvancedSettings - VideoSourceMapping.xml`, `DefaultRatings.xml`, `Core.Languages.Scrapers.xml`, `Core.Mapping.Editions.xml` |
| `Translations/` | Sprachressourcen (`en-US.xml`, `db-DB.xml`) |
| `NLog.config` | Logging-Konfiguration |

## Konfiguration

| Parameter | Typ | Standardwert | Beschreibung |
|-----------|-----|--------------|--------------|
| `Settings.xml` | Datei | wird beim ersten Start erzeugt | Fehlt die Datei, werden Standardeinstellungen verwendet (kein Absturz) |
| `AdvancedSettings.xml` | Datei | wird aus `Defaults/` übernommen | Erweiterte Optionen außerhalb der Dialoge |
| Kommandozeile `-profile` | String | — | Startet Ember mit benanntem Profil |

## Überprüfung

- Nach dem ersten Start muss `Settings.xml` im Profilverzeichnis existieren.
- Im Einstellungsdialog muss links der Einstellungsbaum mit den Modul-Panels erscheinen; fehlende Panels deuten auf nicht geladene Module in `Modules/` hin.
- Das Fehlerprotokoll (*Error Viewer*) zeigt Probleme beim Laden von Einstellungen oder Modulen.
