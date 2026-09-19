# Addons / Module

Alle Module liegen unter `Addons/` und implementieren `Interfaces.GenericModule` (bzw. zusätzlich ein Scraper-Interface). Status „in Solution" bezieht sich auf `Ember Media Manager.sln`.

## Generische Module (`GenericModule`)

| Modul | Verzeichnis | In Solution | Funktion aus Anwendersicht |
|-------|-------------|------------|-----------------------------|
| Bulk Renamer | `generic.EmberCore.BulkRename` | Ja | Dateien/Ordner von Filmen und Serien anhand von Mustern stapelweise oder manuell umbenennen (`dlgBulkRename_Movie/TV`, `dlgRenameManual_*`) |
| Kontextmenü | `generic.EmberCore.ContextMenu` | Ja | Zusätzliche Kontextmenü-Einträge in den Medienlisten (`genericContextMenu.vb`) |
| Medienlisten-Editor | `generic.EmberCore.FilterEditor` (Projekt `MediaListEditor`) | Ja | Benutzerdefinierte Filter/Medienlisten bearbeiten (`genericMediaListEditor.vb`) |
| Mapping-Editor | `generic.EmberCore.Mapping` | Ja | Genre-, Regex- und Simple-Mappings pflegen (`dlgGenreMapping`, `dlgRegexMapping`, `dlgSimpleMapping`) |
| Media File Manager | `generic.EmberCore.MediaFileManager` | Ja | Mediendateien kopieren/verschieben (u. a. TeraCopy-Integration, `dlgCopyFiles`) |
| Metadaten-Editor | `generic.Embercore.MetadataEditor` | Ja | Codec-/Metadaten-Bezeichner bearbeiten (`genericVCodecEditor`) |
| Movie Exporter | `generic.EmberCore.MovieExport` (Projekt `MovieExporter`) | Ja | Filmbibliothek über Templates exportieren (`dlgExportMovies`, `Templates/`) |
| Tag Manager | `generic.EmberCore.TagManager` | Ja | Tags/Schlagworte verwalten (`dlgTagManager`) |
| Video Source Mapping | `generic.EmberCore.VideoSourceMapping` | Ja | Videoquellen-Bezeichner zuordnen (`genericVideoSourceMapping`) |
| Kodi-Interface | `generic.Interface.Kodi` | Ja | Kodi-Hosts verwalten, Bibliothek/Watched-State synchronisieren (`dlgHost`, `clsAPIKodi`) |
| Trakt.tv-Interface | `generic.Interface.Trakttv` | Ja | Trakt-Konto autorisieren (`frmAuthorize`), Sync-Manager (`dlgTrakttvManager`, `dlgWorker`) |

## Scraper-Module

### Daten (`ScraperModule_Data_*`)

| Modul | Inhaltstyp | Quelle |
|-------|------------|--------|
| `scraper.Data.IMDB` | Movie, TV | IMDb |
| `scraper.Data.TMDB` | Movie, MovieSet, TV | TheMovieDB |
| `scraper.Data.TVDB` | TV | TheTVDB (vendored `TVDB`-Bibliothek) |
| `scraper.Data.OMDb` | Movie, TV | OMDb API |
| `scraper.Data.OFDB` | Movie | OFDb (deutsch) |
| `scraper.Data.MoviepilotDE` | Movie | Moviepilot.de (deutsch) |
| `scraper.Data.Trakttv` | Movie, TV | Trakt.tv (`Trakttv`-Bibliothek, `frmAuthorize`) |

### Bilder (`ScraperModule_Image_*`)

| Modul | Inhaltstyp | Quelle |
|-------|------------|--------|
| `scraper.Image.TMDB` | Movie, MovieSet, TV | TheMovieDB |
| `scraper.Image.FanartTV` | Movie, MovieSet, TV | Fanart.tv |
| `scraper.Image.TVDB` | TV | TheTVDB |

### Trailer (`ScraperModule_Trailer_*`)

| Modul | Inhaltstyp | Quelle |
|-------|------------|--------|
| `scraper.Trailer.YouTube` | Movie | YouTube |
| `scraper.Trailer.TMDB` | Movie | TheMovieDB |
| `scraper.Trailer.Apple` | Movie | Apple Trailers |
| `scraper.Trailer.Davestrailerpage` | Movie | hd-trailers.net |
| `scraper.Trailer.VideobusterDE` | Movie | Videobuster.de (deutsch) |

### Themes (`ScraperModule_Theme_*`)

| Modul | Inhaltstyp | Quelle |
|-------|------------|--------|
| `scraper.Theme.YouTube` | Movie, TV | YouTube |
| `scraper.Theme.TelevisionTunes` | Movie, TV | TelevisionTunes |

## Nicht in der Solution

| Verzeichnis | Projekt | Bemerkung |
|-------------|---------|-----------|
| `scraper.EmberCore.XML` | `scraper.EmberCore.XML.vbproj` | Legacy-XML-Scraper-Framework (`XMLScraper/`, `Langs/`, eigene Dialoge `dlgSearchResults`, `dlgImgSelect`, `dlgTrailer`); wird nicht gebaut |
| `scraper.TVDB.Poster` | `scraper.TVDB.Data.vbproj` | Älterer kombinierter TVDB-Scraper; ersetzt durch `scraper.Data.TVDB`/`scraper.Image.TVDB`; wird nicht gebaut |

## Gemeinsamer Aufbau aller Module

- `Init(sAssemblyName, sExecutable)` — Initialisierung mit Assembly-Kontext
- `InjectSetup()` — liefert `Containers.SettingsPanel` (`frmSettingsHolder*.vb`) für `dlgSettings`
- `RunGeneric(mType, params, singleobjekt, dbelement)` / `Scraper(...)` — Einstiegspunkt für Events bzw. Scrape-Aufrufe
- Toolstrip-Integration: `AddToolStripItem*`/`SetToolsStripItem*`/`RemoveToolStripItem*` für Menüeinträge in `frmMain`
- Eigene `app.config` mit Scraper-/Account-Einstellungen
