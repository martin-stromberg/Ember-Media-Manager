# Datenmodell

## Media-Container (`MediaContainers`, `EmberAPI/clsAPIMediaContainers.vb`, ~4.900 Zeilen)

| Klasse | Zweck |
|--------|-------|
| `Movie` | Filmdatensatz (Details, IDs, Bilder, Streams, Dateiinfos) |
| `MovieInSet` | Film-in-Sammlung-Zuordnung |
| `Movieset` / `MoviesetContainer` / `MoviesetDetails` / `MoviesetDetails_YAMJ` | Filmsammlungen inkl. YAMJ-Kompatibilität |
| `TVShow` | Seriendatensatz |
| `EpisodeDetails` / `EpisodeGuide` / `KnownEpisode` | Episoden (Details, Episode-Guide-Verknüpfung, bekannte Episoden) |
| `SeasonDetails` / `Seasons` | Staffeln |
| `Person` | Schauspieler/Regisseure/Autoren (Name, Rolle, Thumb, URLs) |
| `RatingContainer` / `RatingDetails` | Bewertungen je Quelle |
| `Uniqueid` / `UniqueidContainer` / `DefaultId` | Externe IDs (IMDb, TMDb, TVDb …) mit Default-Markierung |
| `Image` / `ImagesContainer` / `PreferredImagesContainer` / `EpisodeOrSeasonImagesContainer` / `SearchResultsContainer` | Bildverwaltung je Bildtyp und Quelle |
| `MediaFile` / `Fileinfo` / `StreamCollection` / `StreamVariant` / `VideoStream` / `AudioStream` / `Subtitle` / `StreamData` | Datei- und Streaminformationen (aus MediaInfo/FFmpeg) |
| `Audio` / `Video` / `Format` | Codec-/Formatdetails |
| `Fanart` / `Thumb` | Bild-URLs mit Vorschau |
| `DiscStub` / `MediaStub` | Offline-Medien (Stub-Dateien) |
| `MetadataPerType` | Metadaten-Auswahl je Inhaltstyp |

## Datenbank-Container (`Database`, `clsAPIDatabase.vb`)

| Klasse | Zweck |
|--------|-------|
| `DBElement` | Einheitlicher DB-Datensatz: kapselt Movie/MovieSet/TVShow/Episode/Season-Container + Dateipfade + Flags (`IsNew`, `IsMarked`, `IsLock`, `Online`-Status) |
| `DBSource` | Quellverzeichnis-Definition (Pfad, Typ Film/Serie, Scan-Optionen, rekursiv, Exclude-Muster) |

## SQLite-Schema (`EmberAPI/DB/MyVideosDBSQL.txt`, Versionierung via `MyVideosDBSQL_v1..v47_Patch.xml`)

Haupttabellen (Kodi-Namenskonvention):

| Tabelle | Inhalt |
|---------|--------|
| `movie` | Filme (u. a. Titel, IDs, Pfade, Flags, `idSource`, `idFile`) |
| `movielinktvshow` | Film↔Serie-Verknüpfung |
| `sets`, `setlinkmovie` | Filmsammlungen + Zuordnung |
| `tvshow`, `seasons`, `episode` | Serien, Staffeln, Episoden |
| `files`, `moviesource` | Dateien und Quellverzeichnisse |
| `actors`, `actorlinkmovie`, `actorlinkepisode`, `actorlinktvshow`, `gueststarlinkepisode` | Personen + Verknüpfungen |
| `art` | Artwork-Zuordnung |
| `genre`, `genrelinkmovie`, `genrelinktvshow` | Genres |
| `country`, `countrylinkmovie`, `countrylinktvshow` | Länder |
| `studio`, `studiolinkmovie`, `studiolinktvshow` | Studios |
| `directorlink*`, `writerlink*`, `creatorlinktvshow` | Crew-Verknüpfungen |
| `rating` | Bewertungen |
| `tag`, `taglinks` | Tags/Schlagworte |
| `uniqueid` | Externe IDs je Medium |
| `MoviesVStreams`, `MoviesAStreams`, `MoviesSubs`, `TVVStreams`, `TVAStreams`, `TVSubs` | Stream-Details (Video/Audio/Untertitel) |

## Einstellungs-/Profilmodell

| Artefakt | Klasse/Datei | Inhalt |
|----------|--------------|--------|
| `Settings.xml` | `Settings` (`clsAPISettings.vb`) | Alle Anwendungs- und Moduleinstellungen (serialisiert); Profil-abhängig |
| `AdvancedSettings.xml` | `AdvancedSettings` (`clsXMLAdvancedSettings.vb`) | Schlüssel-Wert-Erweiterte-Einstellungen (Regex, Datei-/Ordnerfilter, Formatkonvertierung) |
| `Defaults/` | `DefaultAdvancedSettings - *.xml`, `DefaultRatings.xml`, `Core.Languages.Scrapers.xml`, `Core.Mapping.Editions.xml` | Werksvorgaben |
| Profile | `Profiles` (`clsAPIProfiles.vb`) | Benannte Profile mit eigener DB + Settings |
| `db-DB.xml`, `en-US.xml` | `Localization` (`clsAPILocalization.vb`), `XmlTranslations` | Übersetzungsressourcen (`EmberAPI/Translations/`) |
