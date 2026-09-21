# Interfaces

Für diese Anforderung ist nur ein Contract relevant: `ModuleVersion` — die Property, über die jedes Addon-Modul seine eigene Assembly-Version an `ModulesManager.VersionList` liefert.

## `Interfaces.*` (`EmberAPI/clsAPIInterfaces.vb`)

Zehn Modul-Interfaces deklarieren jeweils dieselbe Property:

| Interface | Zeile (Property) |
|-----------|-------------------|
| `GenericModule` | 43 |
| `ScraperModule_Data_Movie` | 72 |
| `ScraperModule_Data_MovieSet` | 113 |
| `ScraperModule_Data_TV` | 154 |
| `ScraperModule_Image_Movie` | 211 |
| `ScraperModule_Image_MovieSet` | 245 |
| `ScraperModule_Image_TV` | 279 |
| `ScraperModule_Theme_Movie` | 311 |
| `ScraperModule_Theme_TV` | 342 |
| `ScraperModule_Trailer_Movie` | 373 |

| Member | Parameter | Rückgabewert | Zweck |
|--------|-----------|--------------|-------|
| `ModuleVersion` (ReadOnly Property) | — | `String` | Versionsstring des Moduls; Implementierungen lesen typischerweise `FileVersionInfo.GetVersionInfo(Assembly.GetExecutingAssembly.Location).FileVersion` (z. B. `Addons/generic.EmberCore.BulkRename/Module.BulkRenamer.vb` Z. 108–112) |

Verwendung: `ModulesManager.BuildVersionList()` (`EmberAPI/clsAPIModules.vb` Z. 89–145) übernimmt `ProcessorModule.ModuleVersion` in `VersionList` → Anzeige in `dlgVersions` und `dlgErrorViewer`. Es gibt keine Interfaces für die Hauptanwendungs-Versionsnummer selbst.
