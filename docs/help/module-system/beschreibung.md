← [Zurück zur Übersicht](index.md)

# Modulsystem — Beschreibung

## Zweck

Ember Media Manager ist um ein ladbares Modulsystem herum gebaut: Sämtliche Scraper, Werkzeuge und Schnittstellen sind eigenständige Assemblys im `Modules`-Verzeichnis, die beim Start geladen und über klar definierte Interfaces angesprochen werden. Dadurch lassen sich neue Quellen und Werkzeuge ergänzen, ohne die Hauptanwendung zu ändern.

## Funktionsweise

- **Laden:** Der `ModulesManager` (Singleton) lädt alle Assemblys aus `Modules/` und sortiert sie nach implementiertem Interface in getrennte Listen (generische Module, Daten-/Bilder-/Theme-/Trailer-Scraper je Inhaltstyp).
- **Vertrag:** Jedes Modul implementiert `GenericModule` — mit `Init`, `RunGeneric`, `InjectSetup`, Eigenschaften (`ModuleName`, `ModuleVersion`, `Enabled`, `IsBusy`) und Events (`GenericEvent`, `ModuleEnabledChanged`, `ModuleSettingsChanged`, `SetupNeedsRestart`).
- **Ereignisse:** Module abonnieren `ModuleEventType`-Ereignisse über `ModuleType`; `frmMain`/`ModulesManager` rufen `RunGeneric` auf, wenn das Ereignis eintritt (z. B. `AfterEdit_Movie`, `AfterUpdateDB_Movie`, `ScraperSingle_*`).
- **UI-Integration:** Module liefern ihr Einstellungspanel via `InjectSetup()` in den Einstellungsdialog und registrieren Toolstrip-Einträge in der Haupt-UI.
- **Aktivierung:** Jedes Modul kann aktiviert/deaktiviert werden; Status liegt in den Einstellungen.

## Beispiele (Modularten)

- Generisches Modul: Bulk Renamer, Media File Manager, Tag Manager
- Interface-Modul: Kodi-Schnittstelle, Trakt.tv-Schnittstelle
- Scraper-Modul: `scraper.Data.IMDB`, `scraper.Image.FanartTV`, `scraper.Trailer.YouTube`, `scraper.Theme.TelevisionTunes`

## Einschränkungen

- Module werden per Reflection aus dem `Modules`-Ordner geladen — nicht auf der Festplatte vorhandene oder nicht dem Vertrag entsprechende Assemblys erscheinen nicht.
- Zwei Projektverzeichnisse (`scraper.EmberCore.XML`, `scraper.TVDB.Poster`) existieren im Repository, sind aber nicht Teil der Solution und werden nicht gebaut.
