← [Zurück zur Übersicht](index.md)

# Trakt.tv — API

## Übersicht

Zugriff auf die Trakt-API-v2 über die im Repository liegende `Trakttv`-Bibliothek (`Trakttv/Trakttv.csproj`: `TraktAPI`, `TraktMethods`, `TraktURIs`, `TraktSettings`, `Model/`, `Exceptions/`) sowie TraktApiSharp-Typen im Interface-Modul. Basis-Endpunkt im Code: `https://api-v2launch.trakt.tv`.

## Authentifizierung

OAuth/PIN-Autorisierung über `TraktURIs.Login` (`/auth/login`); resultierendes Token wird in den Moduleinstellungen gehalten (`TraktSettings`, `TraktAuthorization.CreateWith`).

## Endpunktgruppen (`TraktURIs`)

### Sync schreiben

| Konstante | Endpunkt | Zweck |
|-----------|----------|-------|
| `SENDWatchedHistoryAdd` / `…Remove` | `/sync/history` | Watched-History melden/entfernen |
| `SENDRatingsAdd` / `…Remove` | `/sync/ratings` | Bewertungen melden/entfernen |
| `SENDWatchlistAdd` / `…Remove` | `/sync/watchlist` | Watchlist pflegen |
| `SENDCollectionAdd` / `…Remove` | `/sync/collection` | Collection pflegen |
| `SENDListDelete/Add/Edit/ItemsAdd/ItemsRemove` | `/users/{0}/lists…` | Eigene Listen verwalten |
| `SENDCommentAdd/Like/Delete/Update/Reply` | `/comments…` | Kommentare |

### Sync lesen

| Konstante | Endpunkt | Zweck |
|-----------|----------|-------|
| `GETCollectionMovies` / `GETCollectionEpisodes` | `/sync/collection/movies`, `/sync/collection/shows` | Sammlung |
| `GETWatchedMovies` / `GETWatchedEpisodes` | `/sync/watched/movies`, `/sync/watched/shows` | Watched-Status |
| `GETWatchedHistoryMovies` | `/users/{0}/history/movies?extended=full&limit=5000` | Verlauf |
| `GETRatedMovies` / `GETRatedEpisodes` / `GETRatedShows` / `GETRatedSeasons` | `/sync/ratings/…` | Bewertungen |
| `GETMovieRating` | `/movies/{0}/ratings` | Einzelrating |
| `GETProgressShow` | `/shows/{0}/progress/watched` | Serienfortschritt |

## Typen (Auswahl)

| Typ | Zweck |
|-----|-------|
| `TraktAPI.Model.TraktMovieWatched` / `TraktEpisodeWatched` / `TraktShowWatchedProgress` / `TraktMovieWatchedRated` | Gelesene Watched-Zustände |
| `TraktItem.Ids` / `TraktMovie.Ids` | Externe IDs (IMDb/TMDb/TVDb) |
| `TraktSearchIdType.ImDB/TmDB/TvDB` / `TraktSearchResultType.*` / `TraktSyncItemType.*` / `TraktRatingsItemType.*` | ID-/Typ-Enums |
| `Exceptions/` | API-Fehlertypen |

## Fehler

| Code / Exception | Ursache |
|------------------|---------|
| Trakt-Exception (`Exceptions/`) | API-Fehler, Rate-Limit, ungültiges Token |
| Kein Treffer | Element ohne IMDb/TMDb/TVDb-ID nicht zuordenbar |
