# Zentrale Logikklassen

## EmberAPI (`clsAPI*.vb`)

| Klasse | Datei | Aufgabe |
|--------|-------|---------|
| `Database` | `clsAPIDatabase.vb` (~6.500 Zeilen) | Sämtlicher SQLite-Zugriff: `Connect_MyVideos`, `Save_*`, `Load_*`, `Delete_*`, `Clean`, `Cleanup_*`, `FillDataTable_*`, `GetAll_*`; Schema-Erstellung und Patch-Anwendung |
| `Scanner` | `clsAPIScanner.vb` (~1.900 Zeilen) | Verzeichnis-Scan: `Start`, `ScanSourceDirectory_Movie/TV`, `ScanForFiles_*`, `GetFolderContents_*`, `Load_Movie/MovieSet/TVShow/TVEpisode`, `RegexGetTVEpisode`, `IsValidDir` |
| `ModulesManager` | `clsAPIModules.vb` (~2.245 Zeilen) | Modul-Lifecycle: Laden aus `Modules/`, Interface-Zuordnung, Event-Weiterleitung, Enable/Disable, Setup-Panels |
| `NFO` | `clsAPINFO.vb` (~2.490 Zeilen) | Lesen/Schreiben der Kodi-NFO-Dateien für alle Inhaltstypen |
| `Settings` | `clsAPISettings.vb` (~1.990 Zeilen) | `Settings.xml` laden/speichern (Existenzprüfung vor Reader — Startabsturz-Fix), Modul-Settings |
| `Master` | `clsAPIMaster.vb` | Globale Anwendungszustände, zentrale Verweise (`Master.DB`, `Master.eSettings`, Scanner-Instanzen) |
| `Images` | `clsAPIImages.vb` | Bild laden/speichern/aus Web, MemoryStream-basiert, Extrathumbs/Extrafanart |
| `ImageUtils` | `clsAPIImageUtils.vb` | Bildvergleiche (`ImageComparison`), Größen, Flag-Rendering |
| `MediaInfo` | `clsAPIMediaInfo.vb` | MediaInfo.dll-Wrapper: Stream-Erkennung (Video/Audio/Subs) |
| `FFmpeg` / `FFmpegTask` / `FFProbe*` | `clsAPIFFmpeg.vb` | ffprobe-Auswertung, Trailer-/Video-Verarbeitung |
| `APIXML` | `clsAPIXML.vb` | XML-Hilfsfunktionen (u. a. Cache-Dateien der Scraper) |
| `HTTP` | `clsAPIHTTP.vb` | HTTP(S)-Downloads (Poster, Trailer, Daten) |
| `YouTube` | `clsAPIYouTube.vb` | YouTube-Link-Auflösung/Download (via `VideoLibrary`) |
| `Localization` | `clsAPILocalization.vb` | Übersetzungs-Lookup aus `Translations/*.xml` |
| `Profiles` | `clsAPIProfiles.vb` | Profilverwaltung |
| `FileUtils` | `clsAPIFileUtils.vb` | Datei-/Pfad-Operationen, Umbenennen, `GetFilenameList`, `Delete`, `CleanUp` |
| `MediaFiles` / `MediaStub` | `clsAPIMediaFiles.vb`, `clsAPIMediaStub.vb` | Mediendatei-Erkennung, Offline-Stub-Erzeugung |
| `DVD` / `DVDProfiler` / `Iso` | `clsAPIDVD.vb`, `clsAPIDVDProfiler.vb` | DVD-Laufwerke, DVD-Profiler-Import, ISO-Handling |
| `CommandLine` | `clsAPICommandLine.vb` | CLI-Argumente (u. a. Profilwahl, Auto-Scan) |
| `TaskManager` | `clsAPITaskManager.vb` | Parallele Aufgaben mit Fortschritt |
| `Notifications` | `clsAPINotifications.vb` | Benachrichtigungen |
| `Common` / `Functions` / `Enums` / `Containers` / `Structures` | `clsAPICommon.vb` | Enums (u. a. `ModuleEventType`, `ScraperEventType`, `ScrapeType`), Hilfsfunktionen, gemeinsame Container/Strukturen |
| `StringUtils` / `NumUtils` | `clsAPIStringUtils.vb`, `clsAPINumUtils.vb` | String-/Zahlen-Helfer (größte Testabdeckung im Testprojekt) |
| `Sorter` / `ListViewColumnSorter` / `ListSorting` / `MainTabSorting` | `clsAPISorter.vb` | Sortierung der Listenansichten |
| `Forms` / `DragAndDrop` / `ClipboardHandler` | `clsAPIFormsUtils.vb` | UI-Hilfen |
| `AdvancedSettings` | `XML Serialization/clsXMLAdvancedSettings.vb` | Erweiterte Einstellungen |
| `XmlTranslations` / `clsXMLGenreMapping` / `clsXMLRegexMapping` / `clsXMLSimpleMapping` / `clsXMLRatings` / `clsXMLScraperLanguages` | `XML Serialization/*.vb` | XML-serialisierte Mapping-/Sprach-/Ratings-Dateien |
| `frmSplash`, `dlgVersions` | `frmSplash.vb`, `dlgVersions.vb` | Startdialog, Versionsübersicht |

## Hauptanwendung (`EmberMediaManager`)

| Klasse | Aufgabe |
|--------|---------|
| `frmMain` | Zentrale UI: Listen (`dgvMovies`, `dgvTVShows`), Filter, Menüs, Scrape-Steuerung, TaskManager-Anzeige, Modul-Toolstrip-Integration |
| `clsTheming` | Theme-/Skin-Unterstützung (`Themes/`) |
| `dlgEdit_Movie` / `dlgEdit_Movieset` / `dlgEdit_TVShow` / `dlgEdit_TVSeason` / `dlgEdit_TVEpisode` | Bearbeitungsdialoge je Inhaltstyp |
| `dlgSettings` | Einstellungen inkl. eingebetteter Modul-Panels (`InjectSetup`) |
| `dlgSourceMovie` / `dlgSourceTVShow` | Quellverzeichnis-Verwaltung |
| `dlgCustomScraper` | Auswahl der Felder/Bilder/Trailer je Scrape-Lauf |
| `dlgImgSelect` | Bildauswahl über alle Bild-Scraper-Ergebnisse |
| `dlgFileInfo` / `dlgFIStreamEditor` | Stream-/Dateiinfo-Anzeige und -Bearbeitung |
| `dlgMediaFileSelect`, `dlgImageManual`, `dlgImageViewer`, `dlgSortFiles` | Datei-/Bild-/Sortierdialoge |
| `dlgTVChangeEp`, `dlgTVRegExProfiles`, `frmTV_Data_SeasonTitleBlacklist` | Serien-Spezifika |
| `dlgErrorViewer`, `dlgAbout`, `dlgNewVersion`, `dlgRestart`, `dlgDeleteConfirm`, `dlgClearOrReplace`, `dlgAddEditActor`, `dlgDVDProfilerSelect`, `dlgOfflineHolder`, `dlgProfileSelect`, `dlgTagManager`, `dlgNewSet` | Weitere Fachdialoge |

## KodiAPI (C#)

| Klasse | Aufgabe |
|--------|---------|
| `XBMCRPC.Client` | JSON-RPC-Client (generierte `Methods/*` für Kodi-API: `VideoLibrary`, `Files`, `Player`, `JSONRPC` u. a.), `GetImageStream`/`GetImageUri` für Artwork, WebSocket-`NotificationListenerSocketState` |
| `IPlatformServices` / `ISocket` / `ISocketFactory` / `ConnectionSettings` | Plattform-Abstraktion und Verbindungskonfiguration |

## Trakttv (C#)

| Klasse | Aufgabe |
|--------|---------|
| `TraktAPI` / `TraktMethods` | Trakt.tv-API-v2-Zugriffe (OAuth, Sync, Ratings, Listen) |
| `TraktURIs` | Endpunkt-Konstanten (`api-v2launch.trakt.tv`): Login, History, Ratings, Watchlist, Collection, Listen, Kommentare, Watched-Status |
| `TraktSettings` / `Exceptions/` / `Model/` | Konfiguration, Fehlertypen, JSON-Modelle |

## TVDB (vendored, C#)

| Bereich | Aufgabe |
|---------|---------|
| `Interfaces/` | Client-Contracts |
| `Model/` | Serien-/Episoden-/Bilder-Modelle |
| `Web/` | HTTP-Zugriff auf TheTVDB-API |
