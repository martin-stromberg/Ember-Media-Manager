← [Back to overview](index.md)

# Module System — API

## Overview

All contracts live in `Interfaces` (`EmberAPI/clsAPIInterfaces.vb`). Modules are implemented as .NET assemblies (VB.NET) and loaded by `ModulesManager` via `Assembly.LoadFrom`.

## `GenericModule` (base contract)

| Member | Kind | Signature | Purpose |
|--------|------|-----------|---------|
| `Init` | Method | `Init(sAssemblyName, sExecutable)` | initialization on load |
| `RunGeneric` | Method | `RunGeneric(mType, _params, _singleobjekt, _dbelement) As ModuleResult` | event entry point |
| `InjectSetup` | Method | `InjectSetup() As Containers.SettingsPanel` | provide settings panel |
| `ModuleName` | Property | `String` | display name |
| `ModuleVersion` | Property | `String` | version string |
| `ModuleType` | Property | `List(Of Enums.ModuleEventType)` | subscribed events |
| `Enabled` | Property | `Boolean` | active state |
| `IsBusy` | Property | `Boolean` | running state |
| `GenericEvent` | Event | `(mType, _params)` | feedback to host |
| `ModuleEnabledChanged` | Event | `(Name, State, diffOrder)` | activation changed |
| `ModuleSettingsChanged` | Event | — | settings changed |
| `SetupNeedsRestart` | Event | — | restart required |
| `AddToolStripItem*` / `SetToolsStripItem*` / `RemoveToolStripItem*` | Methods | per content-type variant | toolstrip integration |

## Scraper interfaces

| Interface | Extends | Purpose |
|-----------|---------|---------|
| `ScraperModule_Data_Movie` / `…_MovieSet` / `…_TV` | `GenericModule` | metadata scraping |
| `ScraperModule_Image_Movie` / `…_MovieSet` / `…_TV` | `GenericModule` | image scraping |
| `ScraperModule_Theme_Movie` / `…_TV` | `GenericModule` | theme scraping |
| `ScraperModule_Trailer_Movie` | `GenericModule` | trailer scraping |

## `ModuleEventType` (selection)

| Value | Trigger |
|-------|---------|
| `AfterEdit_Movie/MovieSet/TVEpisode/TVSeason/TVShow` | after editing |
| `BeforeEdit_Movie` (among others) | before editing/NFO reading |
| `AfterUpdateDB_Movie` / `AfterUpdateDB_TV` | after library update |
| `ScraperSingle_*` / `ScraperMulti_*` | single/batch scraping |
| `Remove_Movie` / `Remove_TVEpisode` / `Remove_TVShow` | deletions |
| `Task`, `Notification`, `Sync*` | tasks, notices, sync |

## Return/helper types

| Type | Purpose |
|------|---------|
| `Interfaces.ModuleResult` | result of `RunGeneric`/`Scraper` (success, abort, selection) |
| `Containers.SettingsPanel` | embedded panel (`Panel` + ordering/title data) |
| `Structures.ScanOrClean` | scan/clean job |
| `Database.DBElement` | transfer object of the affected media item |
| `SearchResultsContainer` / `PreferredImagesContainer` | scraper result containers |
