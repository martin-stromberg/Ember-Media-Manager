# Bestandsaufnahme: Featuredokumentation (gesamtes Repository)

Vollständige Bestandsaufnahme des Forks `martin-stromberg/Ember-Media-Manager` (Ember Media Manager, WinForms/.NET Framework 4.8, VB.NET + C#) als Grundlage für die retroaktive Projektdokumentation gemäß `requirement.md`.

## Zusammenfassung

- **Anwendung:** Ember Media Manager — Windows-Desktop-Medienmanager für Filme, Serien und Filmsammlungen mit Scraper-, Bild-/Trailer-Verwaltung, Kodi- und Trakt.tv-Integration. GPL-3.0, Fork von `DanCooper/Ember-MM-Newscraper`.
- **Lösung:** `Ember Media Manager.sln` mit 32 Projekten (Hauptanwendung `EmberMediaManager`, Kernbibliothek `EmberAPI`, Schnittstellenbibliotheken `KodiAPI`/`Trakttv`/`TVDB`, 28 Addon-Projekte). Zwei weitere Projektverzeichnisse (`scraper.EmberCore.XML`, `scraper.TVDB.Poster`) sind **nicht** Teil der Solution.
- **Architektur:** Ladbares Modulsystem — `ModulesManager` lädt Addon-Assemblys aus dem `Modules`-Verzeichnis; Module implementieren `Interfaces.GenericModule` bzw. eines von neun Scraper-Interfaces (Daten/Bilder/Themes/Trailer je Inhaltstyp Film/Filmsammlung/Serie).
- **Persistenz:** SQLite-Datenbank `MyVideos*.emm` (Kodi-Namenskonvention), Schema-Versionierung über 47 nummerierte Patch-Dateien; zentrale Zugriffsklasse `Database` (`clsAPIDatabase.vb`).
- **Dokumentationsstand vorher:** Nur `docs/help/build/` (Build & Installation), `changes.log` mit einem Eintrag, `docs/RELEASE_NOTES.md` zur letzten Änderung, README mit Build-Anleitung. Alle fachlichen Funktionsbereiche sind **undokumentiert**.
- **Test-Ausgangszustand:** Es gibt **keine ausführbaren automatisierten Tests**. Das einzige Testprojekt `EmberAPI_Test` ist nicht Teil der Solution und nicht kompilierbar — die referenzierte Projektdatei `..\UnitTests\UnitTests.vbproj` fehlt im Repository (~200 Kompilierfehler `Der Typ "UnitTest" ist nicht definiert`). Nachweis: [tests.md](inventory/tests.md) und [Build-Log](inventory/test-results/msbuild-emberapi_test-release-x64.txt).

## Details

- [Projektlandschaft](inventory/projekte.md) — alle Solution-Projekte, nicht-solution-Projekte, Drittbibliotheken
- [Architektur und Modulsystem](inventory/architektur.md) — Anwendungsaufbau, Modul-Lademechanismus, Event-System, Einstiegspunkte
- [Datenmodell](inventory/models.md) — Media-Container-Klassen, SQLite-Schema, Einstellungs-/Profilmodell
- [Zentrale Logikklassen](inventory/logic.md) — EmberAPI-Kern (`clsAPI*.vb`), Hauptfenster `frmMain`, Dialoge
- [Addons / Module](inventory/addons.md) — alle 31 Addon-Verzeichnisse mit Funktion
- [Enums](inventory/enums.md) — zentrale Aufzählungstypen
- [Interfaces](inventory/interfaces.md) — Modul-Schnittstellenverträge
- [Tests](inventory/tests.md) — Testbestand, Test-Ausgangszustand, Ausführungsnachweis

## Für die Dokumentation relevante Funktionsbereiche (aus Anwendersicht)

Abgeleitet aus Projektstruktur, Modulen und UI (`frmMain`, Dialoge):

| Funktionsbereich | Inhalt | Quellen |
|------------------|--------|---------|
| `medienbibliothek` | Quellen, Ordner-Scan, Filter, Offline-Medien, Datei-/Stream-Erkennung | `Scanner`, `Database`, `dlgSourceMovie/TVShow`, Filter-Panels |
| `filme` | Filmverwaltung, Bearbeiten, NFO, Bilder, Trailer, Wiederholte-/Neue-Markierung | `frmMain`, `dlgEdit_Movie`, `Containers.Movie` |
| `serien` | Serien-/Staffeln-/Episodenverwaltung | `dlgEdit_TVShow/Season/Episode`, `Containers.TVShow` |
| `filmsammlungen` | MovieSets verwalten und zuordnen | `dlgEdit_Movieset`, `dlgNewSet`, `Containers.Movieset` |
| `scraper` | Daten-/Bilder-/Theme-/Trailer-Scraping, Scraper-Konfiguration | 20 Scraper-Addons, `dlgCustomScraper`, `dlgImgSelect` |
| `kodi` | Kodi-Synchronisation (Watched-State, Bibliothek, Benachrichtigungen) | `generic.Interface.Kodi`, `KodiAPI` |
| `trakt` | Trakt.tv-Sync und Trakt-Datenscraper | `generic.Interface.Trakttv`, `scraper.Data.Trakttv`, `Trakttv` |
| `werkzeuge` | Generische Module: Umbenennen, Export, Dateimanager, Tag-Manager, Medienlisten-Editor, Mapping, Metadaten-Editor, Kontextmenü, Videoquellen-Mapping | `generic.EmberCore.*`-Addons |
| `einstellungen` | Einstellungsdialog, Profile, AdvancedSettings, Sprachen | `dlgSettings`, `clsAPISettings`, `clsAPIProfiles`, `Localization` |
| `module-system` | Addon-Architektur, Interfaces, Events (Entwickler-Doku) | `ModulesManager`, `Interfaces` |
| `datenbank` | SQLite-Schema, Migrationen, Mediendateien/NFO-Ablage | `Database`, `EmberAPI/DB` |
| `build` | Build, Abhängigkeiten, Installer | bereits dokumentiert |
