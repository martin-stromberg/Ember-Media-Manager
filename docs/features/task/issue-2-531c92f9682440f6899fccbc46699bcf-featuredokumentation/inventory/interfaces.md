# Interfaces

Alle Modul-Verträge liegen in `Interfaces` (`EmberAPI/clsAPIInterfaces.vb`).

## `GenericModule`

Basisvertrag jedes ladbaren Moduls.

| Member | Art | Zweck |
|--------|-----|-------|
| `Init(sAssemblyName, sExecutable)` | Methode | Initialisierung mit Assembly-Kontext |
| `RunGeneric(mType, _params, _singleobjekt, _dbelement)` | Methode | Einstiegspunkt für `ModuleEventType`-Ereignisse; liefert `ModuleResult` |
| `InjectSetup()` | Methode | Liefert `Containers.SettingsPanel` für den Einstellungsdialog |
| `ModuleName`, `ModuleVersion`, `ModuleType`, `Enabled`, `IsBusy` | Eigenschaften | Identität, abonnierte `ModuleEventType`s, Aktivstatus |
| `GenericEvent`, `ModuleEnabledChanged`, `ModuleSettingsChanged`, `SetupNeedsRestart` | Events | Rückmeldung an Host (`frmMain`/`ModulesManager`) |
| `AddToolStripItem*`/`SetToolsStripItem*`/`RemoveToolStripItem*` | Methoden | Toolstrip-Integration in der Haupt-UI |

## Scraper-Interfaces

Je ein Interface pro Kombination aus Scraper-Gruppe und Inhaltstyp; ergänzen `GenericModule` um `Scraper`-Methoden, `ScraperEventType`-Capabilities und Suchdialog-Anbindung.

| Interface | Inhaltstyp | Scraper-Gruppe |
|-----------|------------|----------------|
| `ScraperModule_Data_Movie` | Movie | Daten |
| `ScraperModule_Data_MovieSet` | MovieSet | Daten |
| `ScraperModule_Data_TV` | TV | Daten |
| `ScraperModule_Image_Movie` | Movie | Bilder |
| `ScraperModule_Image_MovieSet` | MovieSet | Bilder |
| `ScraperModule_Image_TV` | TV | Bilder |
| `ScraperModule_Theme_Movie` | Movie | Themes |
| `ScraperModule_Theme_TV` | TV | Themes |
| `ScraperModule_Trailer_Movie` | Movie | Trailer |

## Externe API-Contracts (C#-Bibliotheken)

| Interface | Projekt | Zweck |
|-----------|---------|-------|
| `IPlatformServices` | `KodiAPI` | Plattformdienste für den Kodi-RPC-Client |
| `ISocket`, `ISocketFactory` | `KodiAPI` | WebSocket-/TCP-Abstraktion für Benachrichtigungen |
| `ConnectionSettings` | `KodiAPI` | Verbindungsparameter (Host, Port, Credentials) |
| Interfaces unter `TheTVDBApi/src/TVDB/Interfaces/` | `TVDB` | Contracts des TheTVDB-Clients |

## `ModuleResult` / `Containers.SettingsPanel` / `Structures.*`

Rückgabe- und Konfigurationstypen der Modulverträge (`clsAPICommon.vb`): `ModuleResult` (Erfolg/Abbruch/Auswahl), `SettingsPanel` (eingebettetes Einstellungspanel), `ScanOrClean` (Scan-Auftrag), `SeasonAndEpisodeItems` (Scanner-Rückgabe).
