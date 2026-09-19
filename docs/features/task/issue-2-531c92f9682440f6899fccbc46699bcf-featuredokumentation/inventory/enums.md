# Enums

Zentrale Aufzählungstypen, überwiegend in `Enums` (`EmberAPI/clsAPICommon.vb`) sowie einzelnen Fachklassen.

## `ModuleEventType` (`clsAPICommon.vb`)

Ereignisse, auf die generische Module reagieren können (Auswahl):

| Wert | Bedeutung |
|------|-----------|
| `AfterEdit_Movie` / `AfterEdit_MovieSet` / `AfterEdit_TVEpisode` / `AfterEdit_TVSeason` / `AfterEdit_TVShow` | Nach dem Bearbeiten eines Elements |
| `AfterUpdateDB_Movie` / `AfterUpdateDB_TV` | Nach Abschluss eines DB-Update-/Scanlaufs |
| `BeforeEdit_Movie` (u. a. `BeforeEdit_*`) | Beim manuellen Bearbeiten oder NFO-Einlesen |
| `ScraperMulti`, `Sync*` u. a. | Scrape- und Sync-Ereignisse |

## `ScraperEventType` (`clsAPICommon.vb`)

| Wert | Bedeutung |
|------|-----------|
| `BannerItem`, `CharacterArtItem`, `ClearArtItem`, `ClearLogoItem`, `DiscArtItem` | Bildarten |
| `ExtrafanartsItem`, `ExtrathumbsItem`, `FanartItem`, `LandscapeItem`, `PosterItem` | Bildarten |
| `NFOItem` | NFO/Metadaten |
| `ThemeItem` | Theme (Audio) |
| `TrailerItem` | Trailer (Video) |

## `ScrapeType` (`clsAPICommon.vb`)

Steuert Umfang und Interaktion eines Scrape-Laufs: `AllAuto`, `AllAsk`, `AllSkip`, `MissingAuto`, `MissingAsk`, `MissingSkip`, `NewAuto`, `NewAsk`, `NewSkip`, `MarkedAuto`, `MarkedAsk`, `MarkedSkip`, `FilterAuto`, `FilterAsk`, `FilterSkip` (Muster: {Scope}{Auto|Ask|Skip}).

## Weitere relevante Enums

| Enum | Datei | Bedeutung |
|------|-------|-----------|
| `ContentType` | `clsAPICommon.vb` | Inhaltstyp (Movie, MovieSet, TVShow, TVSeason, TVEpisode) |
| `ScannerEventType` | `clsAPICommon.vb` | Ergebnis-/Ereignistypen des Scanlaufs |
| `TaskManagerEventType`, `TaskManagerType` | `clsAPICommon.vb` | TaskManager-Aufgaben |
| `EpisodeOrdering`, `EpisodeSorting` | `clsAPICommon.vb` | Episodenreihenfolge (Aired/DVD u. a.) |
| `AudioCodec`, `VideoCodec`, `AudioBitrate`, `VideoResolution`, `VideoType` | `clsAPICommon.vb` | Codec-/Qualitätsklassifikation für Flag-Anzeige |
| `MovieBannerSize`, `MovieFanartSize`, `MoviePosterSize`, `TVBannerSize`, `TVBannerType`, `TVFanartSize`, `TVPosterSize`, `TVSeasonPosterSize`, `TVEpisodePosterSize` | `clsAPICommon.vb` | Bildgrößen je Bildtyp |
| `FlagType` | `clsAPICommon.vb` | Flag-Kategorien der Listenanzeige |
| `SortMethod_MovieSet` | `clsAPICommon.vb` | Sortierung von Filmsammlungen |
| `InfoKind`, `ModifierType`, `SelectionType`, `DefaultType` | `clsAPICommon.vb` | Scraper-/Metadaten-Klassifikation |
| `StreamKind`, `StreamType`, `FileSizeUnit`, `Algorithm` | `clsAPICommon.vb`, `clsAPIMediaContainers.vb` | Stream-/Datei-Klassifikation |
