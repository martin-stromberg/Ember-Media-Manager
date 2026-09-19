# Architektur und Modulsystem

## Anwendungsaufbau

- **Einstiegspunkt:** `EmberMediaManager` (WinForms-Exe, VB.NET). `ApplicationEvents.vb` behandelt Startparameter; `clsAPICommandLine` (`EmberAPI`) wertet Kommandozeilenargumente aus. `frmSplash` (EmberAPI) zeigt den Startbildschirm.
- **Hauptfenster:** `frmMain.vb` (~19.000 Zeilen) — zentrale Arbeitsfläche mit Datenrastern `dgvMovies` und `dgvTVShows`, Detail-Panel, Filter-Panels (u. a. `pnlFilterVideoSources_Movies`), Menüband (`mnuMain*`, Tools-Menü mit `mnuMainToolsReloadMovies`, `mnuMainToolsReloadMovieSets`, `mnuMainToolsReloadTVShows`, `mnuMainToolsExportMovies`) und TaskManager-Anzeige.
- **Dialoge:** 33 `dlg*` -Dialoge im Hauptprojekt, darunter Edit-Dialoge (`dlgEdit_Movie`, `dlgEdit_Movieset`, `dlgEdit_TVShow`, `dlgEdit_TVSeason`, `dlgEdit_TVEpisode`), Quellenverwaltung (`dlgSourceMovie`, `dlgSourceTVShow`), Einstellungen (`dlgSettings`), Scraper-Auswahl (`dlgCustomScraper`, `dlgImgSelect`, `dlgTrailer`), Profilverwaltung (`dlgProfileSelect`), Versions-/Fehleranzeige (`dlgNewVersion`, `dlgErrorViewer`, `dlgAbout`).
- **Sprachen:** VB.NET (Hauptanwendung, EmberAPI, alle Addons) und C# (KodiAPI, Trakttv, TVDB). Logging über NLog (`NLog.config`).
- **Multi-Profil:** `Profiles` (`clsAPIProfiles.vb`) + `dlgProfileSelect` — getrennte Einstellungen/DBs pro Profil; `-profile` Kommandozeilenparameter.

## Modulsystem

- **`ModulesManager`** (`EmberAPI/clsAPIModules.vb`, ~2.245 Zeilen, Singleton): lädt Addon-Assemblys zur Laufzeit aus `Path.Combine(Functions.AppPath, "Modules")` via `Assembly.LoadFrom` im `bwLoadModules`-BackgroundWorker. Jedes geladene Modul wird nach Interface-Typ in getrennte Listen einsortiert (`externalGenericModules`, `externalScrapersModules_Data_Movie`, `externalScrapersModules_Data_TV`, `externalScrapersModules_Image_*`, `externalScrapersModules_Theme_*`, `externalScrapersModules_Trailer_Movie`).
- **Modulvertrag:** Alle Module implementieren `Interfaces.GenericModule` (`Init`, `RunGeneric`, `InjectSetup`, `ModuleName`, `ModuleVersion`, `Enabled`, `IsBusy`, Events `GenericEvent`, `ModuleEnabledChanged`, `ModuleSettingsChanged`, `SetupNeedsRestart`) bzw. zusätzlich ein Scraper-Interface mit `Scraper`-Methode; siehe [interfaces.md](interfaces.md).
- **Einstellungsintegration:** `InjectSetup()` liefert `Containers.SettingsPanel`, das in `dlgSettings` eingebettet wird — jedes Modul bringt sein eigenes Einstellungspanel (`frmSettingsHolder*.vb`) mit.
- **Ereignisgesteuerte Laufzeit:** Module melden via `ModuleEventType` (in `Enums`, `clsAPICommon.vb`), für welche Ereignisse sie sich interessieren (`AfterEdit_*`, `AfterUpdateDB_*`, `BeforeEdit_*`, `ScraperMulti`, `Sync`* u. v. m.); `frmMain`/`ModulesManager` rufen `RunGeneric(mType, params, singleobjekt, dbelement)` auf.

## Scraper-Architektur

- Drei Scraper-Gruppen sind bewusst getrennt (Designvorgabe laut README): **Daten**, **Bilder** (Poster/Fanart/Banner etc.), **Trailer** — plus **Themes**.
- Pro Inhaltstyp getrennte Interfaces: Movie, MovieSet, TV → insgesamt 10 Scraper-Interfaces.
- `ScraperEventType` definiert die abrufbaren Elementarten: `BannerItem`, `CharacterArtItem`, `ClearArtItem`, `ClearLogoItem`, `DiscArtItem`, `ExtrafanartsItem`, `ExtrathumbsItem`, `FanartItem`, `LandscapeItem`, `NFOItem`, `PosterItem`, `ThemeItem`, `TrailerItem`.
- `ScrapeType` steuert den Modus: `AllAuto/AllAsk/AllSkip`, `MissingAuto/MissingAsk/MissingSkip`, `NewAuto/NewAsk/NewSkip`, `MarkedAuto/MarkedAsk/MarkedSkip`, `FilterAuto/FilterAsk/FilterSkip` u. a.
- Daten-Scraper laufen sequentiell und füllen nur ausgewählte/leere Felder; Bilder-Scraper parallel, Auswahl zentral über `dlgImgSelect`.
- Jeder Daten-Scraper bringt eigenen Suchdialog mit (`dlgSearchResults` in den Scraper-Modulen).

## Persistenz & Ablage

- SQLite-Datenbank (`System.Data.SQLite`) `MyVideos{Profil}.emm` — Kodi-kompatible Tabellenbenennung; zentrale Klasse `Database` (`clsAPIDatabase.vb`, ~6.500 Zeilen). Schema-Init über `EmberAPI/DB/MyVideosDBSQL.txt`, Versionierung via 47 Patch-Dateien `MyVideosDBSQL_v{n}_Patch.xml`.
- NFO-Dateien neben den Mediendateien (Kodi-NFO-Format) — `NFO` (`clsAPINFO.vb`, ~2.490 Zeilen) liest/schreibt Movie/MovieSet/TVShow/Episode-NFOs.
- Bilder/Trailer als Dateien neben dem Medium (Kodi-Benennung: `poster`, `fanart`, `banner`, `landscape`, `clearart`, `clearlogo`, `discart`, `extrathumbs`, `extrafanart`, `theme`) — `Images` (`clsAPIImages.vb`), Dateiverwaltung `FileUtils`/`MediaFiles`.
- Einstellungen: `Settings.xml` (`Settings`, `clsAPISettings.vb`), `AdvancedSettings.xml` (`AdvancedSettings`, `clsXMLAdvancedSettings.vb`), Modul-Settings als XML je Modul.

## Ablauf beim Scan/Update

1. `frmMain` stößt `Scanner.Start(ScanOrClean, SourceIDs, Folder)` an (`clsAPIScanner.vb`).
2. `Scanner` durchsucht Quellverzeichnisse (`ScanSourceDirectory_Movie/TV`, `ScanForFiles_Movie/TV`, `IsValidDir`), erkennt Episoden per Regex (`RegexGetTVEpisode`), liest Ordnerinhalte (`GetFolderContents_*`).
3. `Load_Movie/MovieSet/TVShow/TVEpisode` liest NFOs + MediaInfo (`MediaInfo`-Klasse) und legt `DBElement` an.
4. `Database.Save_*` persistiert; `AfterUpdateDB_*`-Events gehen an Module.
5. Scraping anschließend über `ModulesManager` → Scraper-Module.

## Threading

- `BackgroundWorker` für Scan-, Scrape-, Modul-Lade- und Bild-Ladevorgänge (`bwLoadModules`, Scanner-Worker, Scraper-Worker in `frmMain`); `TaskManager` (`clsAPITaskManager.vb`) verwaltet parallele Aufgaben mit Statusanzeige.
