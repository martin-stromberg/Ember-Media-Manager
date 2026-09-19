# Projektlandschaft

Solution: `Ember Media Manager.sln` — 32 Projekt- und ein Solution-Ordner-Einträge. Alle Projekte zielen auf .NET Framework 4.8 (vereinheitlicht im Zuge von „Solution kompilierbar machen", siehe `changes.log`). Ausgabeverzeichnisse: `EmberMM - {Configuration} - {Platform}` (x86, x64, AnyCPU).

## Kernprojekte

| Projekt | Pfad | Sprache | Zweck |
|---------|------|---------|-------|
| `EmberMediaManager` | `EmberMediaManager/EmberMediaManager.vbproj` | VB.NET | Hauptanwendung (WinForms-Exe): `frmMain` (Hauptfenster ~19.000 Zeilen), 33 Dialoge (`dlg*.vb`), `MasterSettingsPanels`, `Themes`, `ApplicationEvents.vb` |
| `EmberAPI` | `EmberAPI/EmberAPI.vbproj` | VB.NET | Kernbibliothek: Datenbank, Scanner, Modulsystem, NFO, Bilder, Medieninfo, Settings, Lokalisierung (`clsAPI*.vb`), DB-Schemadateien unter `EmberAPI/DB/` |
| `EmberAPI_Test` | `EmberAPI_Test/EmberAPI_Test.vbproj` | VB.NET | MSTest-Testprojekt — **nicht in der Solution, nicht kompilierbar** (fehlende Referenz `..\UnitTests\UnitTests.vbproj`); siehe [tests.md](tests.md) |

## Schnittstellen-/API-Bibliotheken

| Projekt | Pfad | Sprache | Zweck |
|---------|------|---------|-------|
| `KodiAPI` | `KodiAPI/KodiAPI.csproj` | C# | Kodi-JSON-RPC-Client (`XBMCRPC`-Namespace, generierte Methoden unter `XBMCRPC/Methods`), WebSocket-Benachrichtigungen, Thumbnail-Abruf |
| `Trakttv` | `Trakttv/Trakttv.csproj` | C# | Trakt.tv-API-v2-Client: `TraktAPI.cs`, `TraktMethods.cs`, `TraktURIs.cs` (Sync-Endpunkte: History, Ratings, Watchlist, Collection, Listen, Kommentare), `Model/` |
| `TVDB` | `TheTVDBApi/src/TVDB/TVDB.csproj` | C# | TheTVDB-API-Client (vendored, GPL-3.0, ursprünglich `DanCooper/TheTVDBApi`): `Interfaces/`, `Model/`, `Web/` |

## Generische Module (`generic.EmberCore.*`)

| Projekt | Verzeichnis | Funktion |
|---------|-------------|----------|
| `generic.EmberCore.BulkRename` | `Addons/generic.EmberCore.BulkRename` | Stapel-Umbenennung von Film-/Seriendateien und -ordnern (`clsAPIRenamer.vb`, `dlgBulkRename_Movie/TV`, `dlgRenameManual_*`) |
| `generic.EmberCore.ContextMenu` | `Addons/generic.EmberCore.ContextMenu` | Kontextmenü-Erweiterungen (`genericContextMenu.vb`) |
| `generic.EmberCore.MediaListEditor` | `Addons/generic.EmberCore.FilterEditor` | Medienlisten-/Filter-Editor (`genericMediaListEditor.vb`) |
| `generic.EmberCore.Mapping` | `Addons/generic.EmberCore.Mapping` | Genre-/Regex-/Simple-Mapping-Dialoge (`dlgGenreMapping`, `dlgRegexMapping`, `dlgSimpleMapping`) |
| `generic.EmberCore.MediaFileManager` | `Addons/generic.EmberCore.MediaFileManager` | Dateioperationen auf Mediendateien inkl. TeraCopy-Integration (`clsTeraCopy.vb`, `dlgCopyFiles.vb`) |
| `generic.EmberCore.MetadataEditor` | `Addons/generic.Embercore.MetadataEditor` | Editor für Codec-/Metadaten-Bezeichner (`genericVCodecEditor.vb`) |
| `generic.EmberCore.MovieExporter` | `Addons/generic.EmberCore.MovieExport` | Export der Filmbibliothek über Templates (`clsAPIMediaExporter.vb`, `dlgExportMovies.vb`, `Templates/`) |
| `generic.EmberCore.TagManager` | `Addons/generic.EmberCore.TagManager` | Verwaltung von Tags/Schlagworten (`dlgTagManager.vb`) |
| `generic.EmberCore.VideoSourceMapping` | `Addons/generic.EmberCore.VideoSourceMapping` | Zuordnung von Videoquellen-Bezeichnern (`genericVideoSourceMapping.vb`) |

## Interface-Module (`generic.Interface.*`)

| Projekt | Verzeichnis | Funktion |
|---------|-------------|----------|
| `generic.Interface.Kodi` | `Addons/generic.Interface.Kodi` | Kodi-Integration: Synchronisation, Host-Verwaltung (`Interface.Kodi.vb`, `clsAPIKodi.vb`, `dlgHost.vb`) |
| `generic.Interface.Trakttv` | `Addons/generic.Interface.Trakttv` | Trakt.tv-Synchronisation: Autorisierung, Manager-Dialog (`Interface.Trakt.vb`, `clsAPITrakt.vb`, `dlgTrakttvManager.vb`, `frmAuthorize.vb`) |

## Scraper-Module (`scraper.*`)

### Daten-Scraper
| Projekt | Verzeichnis | Quelle |
|---------|-------------|--------|
| `scraper.Data.IMDB` | `Addons/scraper.IMDB.Data` | IMDb (Film + Serie) |
| `scraper.Data.TMDB` | `Addons/scraper.TMDB.Data` | TheMovieDB (Film, Filmsammlung, Serie) |
| `scraper.Data.TVDB` | `Addons/scraper.Data.TVDB` | TheTVDB (Serie, nutzt vendored `TVDB`) |
| `scraper.Data.OMDb` | `Addons/scraper.Data.OMDb` | OMDb API (Film + Serie) |
| `scraper.Data.OFDB` | `Addons/scraper.OFDB.Data` | OFDb (deutsch) |
| `scraper.Data.MoviepilotDE` | `Addons/scraper.MoviepilotDE.Data` | Moviepilot.de (deutsch) |
| `scraper.Data.Trakttv` | `Addons/scraper.Trakttv.Data` | Trakt.tv (Film + Serie, nutzt `Trakttv`-Bibliothek) |

### Bilder-Scraper
| Projekt | Verzeichnis | Quelle |
|---------|-------------|--------|
| `scraper.Image.TMDB` | `Addons/scraper.TMDB.Poster` | TheMovieDB-Bilder (Film, Set, Serie) |
| `scraper.Image.FanartTV` | `Addons/scraper.FanartTV.Poster` | Fanart.tv (Film, Set, Serie) |
| `scraper.Image.TVDB` | `Addons/scraper.Image.TVDB` | TheTVDB-Bilder (Serie) |

### Trailer-Scraper
| Projekt | Verzeichnis | Quelle |
|---------|-------------|--------|
| `scraper.Trailer.YouTube` | `Addons/scraper.Trailer.YouTube` | YouTube-Trailer |
| `scraper.Trailer.TMDB` | `Addons/scraper.TMDB.Trailer` | TMDB-Trailer |
| `scraper.Trailer.Apple` | `Addons/scraper.Apple.Trailer` | Apple-Trailer |
| `scraper.Trailer.Davestrailerpage` | `Addons/scraper.Davestrailerpage.Trailer` | hd-trailers.net |
| `scraper.Trailer.VideobusterDE` | `Addons/scraper.Trailer.VideobusterDE` | Videobuster.de (deutsch) |

### Theme-Scraper
| Projekt | Verzeichnis | Quelle |
|---------|-------------|--------|
| `scraper.Theme.YouTube` | `Addons/scraper.Theme.YouTube` | YouTube-Themes (Film + Serie) |
| `scraper.Theme.TelevisionTunes` | `Addons/scraper.TelevisionTunes.Theme` | TelevisionTunes-Themes (Film + Serie) |

## Nicht in der Solution enthalten

| Verzeichnis | Inhalt | Bemerkung |
|-------------|--------|-----------|
| `Addons/scraper.EmberCore.XML` | `scraper.EmberCore.XML.vbproj`, `XMLScraper/`, `Langs/`, `clsScrapeImages.vb`, `clsScrapeTrailers.vb` | Legacy-XML-Scraper-Framework (scraper.xml-basiert); nicht im Build |
| `Addons/scraper.TVDB.Poster` | `scraper.TVDB.Data.vbproj`, `TVDB_Data.vb`, `TVScraper/` | Älterer kombinierter TVDB-Scraper; ersetzt durch `scraper.Data.TVDB` + `scraper.Image.TVDB`; nicht im Build |
| `EmberAPI_Test` | `EmberAPI_Test.vbproj` | Siehe oben |

## Build-/Deployment-Artefakte

- `Directory.Build.props` — setzt `FrameworkPathOverride` auf die NuGet-Referenzassemblys `Microsoft.NETFramework.ReferenceAssemblies.net48` (kein Developer Pack nötig)
- `.nuget/NuGet.exe` — NuGet 6.14.0 für `packages.config`-Restore
- `BuildSetup/` — NSIS-Installer (`1.4_InstallerScript.nsi`), Build-Batch-Dateien (`0_BuildSetup_x64.bat`, `0_BuildSetup_x86.bat`), `BRC32.exe`, `tx.exe`, `txDownload.bat`, `LangAllConfig.cfg`
- `ImageSources/`, `SourceImages/` — Grafikquellen; `3D-Modes-mkv.xlsx`, `Filenames.xlsx` — Referenztabellen
- `ember-media-manager-14x_help_(state_2018-04-16).zip` — eingefrorener Stand der alten Online-Hilfe
- Keine CI: kein `.github/workflows`-Verzeichnis vorhanden

## Wesentliche NuGet-/Drittabhängigkeiten

- `System.Data.SQLite.Core` 1.0.115.5 — Datenbankzugriff
- `Newtonsoft.Json` 13.0.1 — JSON (u. a. Scraper, APIs)
- `NLog` 4.7.14 — Logging (`NLog.config`)
- `NiL.JS` 2.5.1552 — JavaScript-Engine
- `VideoLibrary` 3.1.9 — YouTube-Download-Link-Auflösung
- `MediaInfo.dll` (nativ, `EmberAPI/x86`/`x64`) — Stream-Analyse
- FFmpeg/ffprobe (nativ, `EmberAPI/x86`/`x64`) — Mediendaten & Trailer-Verarbeitung
