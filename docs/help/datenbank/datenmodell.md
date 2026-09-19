← [Zurück zur Übersicht](index.md)

# Datenbank — Datenmodell

## Entitäten

### `movie`

Film-Stammsatz (u. a. Titel, Originaltitel, Jahr, Handlung, `MoviePath`, IMDb-ID, Flags `New`/`Mark`/`Lock`, `idSource`).

### `sets` + `setlinkmovie`

Filmsammlungen (`sets`: Name, Übersicht) und n:m-Zuordnung Film↔Set.

### `tvshow`, `seasons`, `episode`

Serienhierarchie: `tvshow` (Serien-Stammsatz), `seasons` (Staffel je Serie), `episode` (Episode mit Staffel-/Episodennummer, `idShow`-Bezug).

### `movielinktvshow`

n:m-Verknüpfung Film↔Serie (z. B. Begleit-/Zusatzmaterial).

### `files`, `moviesource`, `tvshowsource`

Dateinamen-Registry (`files`: `idFile`, `strFilename` — referenziert über `episode.idFile`; Filme speichern ihren Pfad direkt in `movie.MoviePath`) und Quellverzeichnisse — `moviesource` für Filmquellen, `tvshowsource` für Serienquellen (jeweils mit Pfad, Sprache, Sortierungs- und Ausschlussoptionen, letztem Scan-Zeitpunkt).

### `OrigPaths`, `EmberFiles`

Offline-Medien (Stubs): `OrigPaths` bildet Originalpfade auf Ember-Pfade je Plattform ab; `EmberFiles` hält die zugehörigen Dateien inkl. Hash und `UseFile`-Flag.

### `ExcludeFiles`, `ExcludeDir`, `ExcludeFilesInFolders`

Scan-Ausschlussregeln: global ausgeschlossene Dateinamen (`ExcludeFiles`), ausgeschlossene Verzeichnisnamen (`ExcludeDir`) sowie ausgeschlossene Dateien innerhalb bestimmter Ordner (`ExcludeFilesInFolders`).

### `actors` + `actorlinkmovie`, `actorlinkepisode`, `actorlinktvshow`, `gueststarlinkepisode`

Personen und Rollenverknüpfungen inkl. Gaststars je Episode.

### `directorlinkmovie`, `directorlinkepisode`, `directorlinktvshow`, `writerlinkmovie`, `writerlinkepisode`, `creatorlinktvshow`

Crew-Verknüpfungen (Regie, Drehbuch, Creator).

### `genre`, `genrelinkmovie`, `genrelinktvshow`

Genres und Zuordnung.

### `country`, `countrylinkmovie`, `countrylinktvshow`

Produktionsländer und Zuordnung.

### `studio`, `studiolinkmovie`, `studiolinktvshow`

Studios/Netzwerke und Zuordnung.

### `rating`

Bewertungen je Medium und Quelle (Name, Wert, Stimmen, Default-Flag).

### `tag`, `taglinks`

Benutzerdefinierte Schlagworte und Zuordnung zu Medien.

### `art`

Artwork-Zuordnung: Bildtyp (poster, fanart, banner, landscape, clearart, clearlogo, discart, characterart, thumb) je Medium mit URL/Datei.

### `uniqueid`

Externe IDs je Medium (IMDb, TMDb, TVDb u. a.) mit Default-Markierung.

### `MoviesVStreams`, `MoviesAStreams`, `MoviesSubs`, `TVVStreams`, `TVAStreams`, `TVSubs`

Stream-Details aus der Dateianalyse: Video- (Codec, Auflösung, Seitenverhältnis, Dauer), Audio- (Codec, Kanäle, Sprache) und Untertitel-Spuren (Sprache, Format) für Filme bzw. Episoden.

## Beziehungen

```mermaid
erDiagram
    moviesource ||--o{ movie : "enthält"
    tvshowsource ||--o{ episode : "enthält"
    files ||--o{ episode : "liefert Dateinamen"
    movie ||--o{ uniqueid : "hat IDs"
    movie ||--o{ art : "hat Artwork"
    movie ||--o{ rating : "hat Bewertungen"
    movie }o--o{ sets : "setlinkmovie"
    movie }o--o{ tvshow : "movielinktvshow"
    movie }o--o{ actors : "actorlinkmovie"
    movie }o--o{ genre : "genrelinkmovie"
    movie }o--o{ country : "countrylinkmovie"
    movie }o--o{ studio : "studiolinkmovie"
    movie ||--o{ MoviesVStreams : "hat"
    movie ||--o{ MoviesAStreams : "hat"
    movie ||--o{ MoviesSubs : "hat"
    tvshow ||--o{ seasons : "hat"
    seasons ||--o{ episode : "enthält"
    tvshow ||--o{ art : "hat Artwork"
    tvshow }o--o{ actors : "actorlinktvshow"
    tvshow }o--o{ studio : "studiolinktvshow"
    tvshow }o--o{ genre : "genrelinktvshow"
    episode }o--o{ actors : "actorlinkepisode/gueststarlinkepisode"
    episode ||--o{ TVVStreams : "hat"
    episode ||--o{ TVAStreams : "hat"
    episode ||--o{ TVSubs : "hat"
    tag }o--o{ movie : "taglinks"
    tag }o--o{ tvshow : "taglinks"
    tag }o--o{ episode : "taglinks"
```
