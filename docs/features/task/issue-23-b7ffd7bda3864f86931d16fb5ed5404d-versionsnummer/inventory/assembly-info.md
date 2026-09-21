# Assembly-Versionsattribute

Bestandsaufnahme aller Assembly-Attributdateien und versionsrelevanten Projektdatei-Felder. Da alle Projekte Legacy-`.vbproj`/`.csproj` (nicht SDK-Style, .NET Framework 4.8, `packages.config`) sind, existieren die Versionsattribute ausschließlich in den `AssemblyInfo`-Dateien — `Directory.Build.props` definiert nur `FrameworkPathOverride` für die NuGet-Referenzassemblys, keine Versions-Properties.

## `EmberMediaManager` (Haupt-Exe, `Ember Media Manager.exe`)

Datei: `EmberMediaManager/My Project/AssemblyInfo.vb`

| Attribut | Zeile | Wert |
|----------|-------|------|
| `AssemblyTitle` | 11 | `Ember Media Manager` |
| `AssemblyDescription` | 12 | `http://forum.xbmc.org/forumdisplay.php?fid=195` |
| `AssemblyCompany` | 13 | `Ember Media Manager` |
| `AssemblyProduct` | 14 | `Ember Media Manager` |
| `AssemblyCopyright` | 15 | `Copyright ©  2021` |
| `ComVisible` | 18 | `False` |
| `Guid` | 21 | `84CA0E93-7ABB-412D-940D-227E3E87C5C3` |
| `AssemblyVersion` | 34 | **`1.11.1.0`** (hartkodiert) |
| `AssemblyFileVersion` | 35 | **`1.11.1.0`** (hartkodiert) |

`AssemblyInformationalVersion` ist nicht vorhanden. Diese beiden Attribute bestimmen `My.Application.Info.Version` der Exe — die Quelle aller angezeigten Versionsnummern (`Master.Version`, Update-Vergleich in `bwCheckVersion_DoWork`, `ModulesManager.VersionList`-Eintrag „Ember Application").

## `EmberAPI` (`EmberAPI.dll`)

Datei: `EmberAPI/My Project/AssemblyInfo.vb`

| Attribut | Zeile | Wert |
|----------|-------|------|
| `AssemblyTitle` | 11 | `EmberAPI` |
| `AssemblyVersion` | 34 | **`1.11.1.0`** (hartkodiert) |
| `AssemblyFileVersion` | 35 | **`1.11.1.0`** (hartkodiert) |

Wird von `Functions.EmberAPIVersion()` (`EmberAPI/clsAPICommon.vb` Z. 1109–1111) per `FileVersionInfo` ausgelesen und in der Versionsliste als „Ember API" angezeigt.

## Addon-Assemblys (`Addons/`)

30 `AssemblyInfo.vb`-Dateien mit individuellen, uneinheitlichen Versionen (`AssemblyVersion` == `AssemblyFileVersion` in allen Fällen). Ihre `ModuleVersion` wird zur Laufzeit per `FileVersionInfo` aus der eigenen DLL gelesen (z. B. `Addons/generic.EmberCore.BulkRename/Module.BulkRenamer.vb` Z. 108–112).

| Projekt | Version | Projekt | Version |
|---------|---------|---------|---------|
| generic.EmberCore.BulkRename | 1.11.0.0 | scraper.EmberCore.XML | 1.3.0.5 |
| generic.EmberCore.ContextMenu | 1.10.0.0 | scraper.FanartTV.Poster | 1.11.0.0 |
| generic.EmberCore.FilterEditor | 1.10.0.0 | scraper.Image.TVDB | 1.11.0.0 |
| generic.EmberCore.Mapping | 1.11.0.0 | scraper.IMDB.Data | 1.11.1.0 |
| generic.EmberCore.MediaFileManager | 1.10.0.0 | scraper.MoviepilotDE.Data | 1.10.0.0 |
| generic.Embercore.MetadataEditor | 1.10.0.0 | scraper.OFDB.Data | 1.10.0.0 |
| generic.EmberCore.MovieExport | 1.11.0.0 | scraper.TelevisionTunes.Theme | 1.10.0.0 |
| generic.EmberCore.TagManager | 1.11.0.0 | scraper.Theme.YouTube | 1.10.0.0 |
| generic.EmberCore.VideoSourceMapping | 1.10.0.0 | scraper.TMDB.Data | 1.11.1.0 |
| generic.Interface.Kodi | 1.11.0.0 | scraper.TMDB.Poster | 1.11.0.0 |
| generic.Interface.Trakttv | 1.11.0.0 | scraper.TMDB.Trailer | 1.10.0.0 |
| scraper.Apple.Trailer | 1.10.0.0 | scraper.Trailer.VideobusterDE | 1.10.0.0 |
| scraper.Data.OMDb | 1.10.1.0 | scraper.Trailer.YouTube | 1.10.0.0 |
| scraper.Data.TVDB | 1.10.1.0 | scraper.Trakttv.Data | 1.10.1.0 |
| scraper.Davestrailerpage.Trailer | 1.10.0.0 | scraper.TVDB.Poster | 1.4.7.0 |

## C#-Projekte

| Projekt | Datei | `AssemblyVersion` | `AssemblyFileVersion` | In Solution? |
|---------|-------|--------------------|------------------------|--------------|
| `KodiAPI` | `KodiAPI/Properties/AssemblyInfo.cs` | `1.10.0` | `1.10.0` | ja (`KodiAPI.csproj`) |
| `TVDB` (vendored, `TheTVDBApi/src/TVDB`) | `TheTVDBApi/src/TVDB/Properties/AssemblyInfo.cs` | `1.4.4.0` | `1.4.4.0` | ja (`TVDB.csproj`) |
| `Trakttv` | `Trakttv/Properties/AssemblyInfo.cs` | `1.4.4.0` | `1.4.4.0` | **nein** — `Trakttv/Trakttv.csproj` ist nicht in `Ember Media Manager.sln` enthalten |

## `EmberAPI_Test` (Testprojekt, nicht in Solution)

Datei: `EmberAPI_Test/My Project/AssemblyInfo.vb` — `AssemblyVersion`/`AssemblyFileVersion` = `1.4.0.0` (Z. 34–35). Nicht Teil von `Ember Media Manager.sln`, kompiliert nicht (siehe [tests.md](tests.md)).

## Versionsrelevante Felder in `EmberMediaManager.vbproj`

| Feld | Zeile | Wert | Bemerkung |
|------|-------|------|-----------|
| `ApplicationVersion` | 34 | `1.0.0.%2a` | ClickOnce-Versionsfeld; `PublishUrl`/`BootstrapperEnabled` vorhanden, aber keine ClickOnce-Veröffentlichung in der Pipeline — ohne Einfluss auf die angezeigte Version |
| `ApplicationRevision` | 33 | `0` | ebenfalls ClickOnce |
| `AssemblyName` | 13 | `Ember Media Manager` | Exe-Dateiname |

Weitere Projekte enthalten keine versionsrelevanten MSBuild-Properties; `Directory.Build.props` setzt keinerlei Versions-Defaults.
