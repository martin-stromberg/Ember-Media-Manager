← [Zurück zur Übersicht](index.md)

# Modulsystem — API

## Übersicht

Alle Verträge liegen in `Interfaces` (`EmberAPI/clsAPIInterfaces.vb`). Module werden als .NET-Assemblys (VB.NET) implementiert und von `ModulesManager` per `Assembly.LoadFrom` geladen.

## `GenericModule` (Basisvertrag)

| Member | Art | Signatur | Zweck |
|--------|-----|----------|-------|
| `Init` | Methode | `Init(sAssemblyName, sExecutable)` | Initialisierung beim Laden |
| `RunGeneric` | Methode | `RunGeneric(mType, _params, _singleobjekt, _dbelement) As ModuleResult` | Ereignis-Entry-Point |
| `InjectSetup` | Methode | `InjectSetup() As Containers.SettingsPanel` | Einstellungspanel liefern |
| `ModuleName` | Property | `String` | Anzeigename |
| `ModuleVersion` | Property | `String` | Versionsstring |
| `ModuleType` | Property | `List(Of Enums.ModuleEventType)` | abonnierte Ereignisse |
| `Enabled` | Property | `Boolean` | Aktivstatus |
| `IsBusy` | Property | `Boolean` | Laufstatus |
| `GenericEvent` | Event | `(mType, _params)` | Rückmeldung an Host |
| `ModuleEnabledChanged` | Event | `(Name, State, diffOrder)` | Aktivierung geändert |
| `ModuleSettingsChanged` | Event | — | Einstellungen geändert |
| `SetupNeedsRestart` | Event | — | Neustart erforderlich |
| `AddToolStripItem*` / `SetToolsStripItem*` / `RemoveToolStripItem*` | Methoden | je Inhaltstyp-Variante | Toolstrip-Integration |

## Scraper-Interfaces

| Interface | Erweitert | Zweck |
|-----------|-----------|-------|
| `ScraperModule_Data_Movie` / `…_MovieSet` / `…_TV` | `GenericModule` | Metadaten-Scraping |
| `ScraperModule_Image_Movie` / `…_MovieSet` / `…_TV` | `GenericModule` | Bilder-Scraping |
| `ScraperModule_Theme_Movie` / `…_TV` | `GenericModule` | Theme-Scraping |
| `ScraperModule_Trailer_Movie` | `GenericModule` | Trailer-Scraping |

## `ModuleEventType` (Auswahl)

| Wert | Auslöser |
|------|----------|
| `AfterEdit_Movie/MovieSet/TVEpisode/TVSeason/TVShow` | Nach Bearbeiten |
| `BeforeEdit_Movie` (u. a.) | Vor Bearbeiten/NFO-Einlesen |
| `AfterUpdateDB_Movie` / `AfterUpdateDB_TV` | Nach Bibliotheks-Update |
| `ScraperSingle_*` / `ScraperMulti_*` | Einzel-/Batch-Scraping |
| `Remove_Movie` / `Remove_TVEpisode` / `Remove_TVShow` | Löschungen |
| `Task`, `Notification`, `Sync*` | Aufgaben, Hinweise, Sync |

## Rückgabe-/Hilfstypen

| Typ | Zweck |
|-----|-------|
| `Interfaces.ModuleResult` | Ergebnis von `RunGeneric`/`Scraper` (Erfolg, Abbruch, Auswahl) |
| `Containers.SettingsPanel` | Eingebettetes Panel (`Panel` + Ordnungs-/Titeldaten) |
| `Structures.ScanOrClean` | Scan-/Clean-Auftrag |
| `Database.DBElement` | Übergabeobjekt des betroffenen Mediums |
| `SearchResultsContainer` / `PreferredImagesContainer` | Scraper-Ergebnisbehälter |
