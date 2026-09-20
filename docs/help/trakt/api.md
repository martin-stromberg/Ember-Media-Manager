← [Back to overview](index.md)

# Trakt.tv — API

## Overview

Access to the Trakt API v2 via the `Trakttv` library in the repository (`Trakttv/Trakttv.csproj`: `TraktAPI`, `TraktMethods`, `TraktURIs`, `TraktSettings`, `Model/`, `Exceptions/`) plus TraktApiSharp types in the interface module. Base endpoint in code: `https://api-v2launch.trakt.tv`.

## Authentication

OAuth/PIN authorization via `TraktURIs.Login` (`/auth/login`); the resulting token is held in the module settings (`TraktSettings`, `TraktAuthorization.CreateWith`).

## Endpoint groups (`TraktURIs`)

### Sync write

| Constant | Endpoint | Purpose |
|----------|----------|---------|
| `SENDWatchedHistoryAdd` / `…Remove` | `/sync/history` | report/remove watched history |
| `SENDRatingsAdd` / `…Remove` | `/sync/ratings` | report/remove ratings |
| `SENDWatchlistAdd` / `…Remove` | `/sync/watchlist` | maintain watchlist |
| `SENDCollectionAdd` / `…Remove` | `/sync/collection` | maintain collection |
| `SENDListDelete/Add/Edit/ItemsAdd/ItemsRemove` | `/users/{0}/lists…` | manage custom lists |
| `SENDCommentAdd/Like/Delete/Update/Reply` | `/comments…` | comments |

### Sync read

| Constant | Endpoint | Purpose |
|----------|----------|---------|
| `GETCollectionMovies` / `GETCollectionEpisodes` | `/sync/collection/movies`, `/sync/collection/shows` | collection |
| `GETWatchedMovies` / `GETWatchedEpisodes` | `/sync/watched/movies`, `/sync/watched/shows` | watched state |
| `GETWatchedHistoryMovies` | `/users/{0}/history/movies?extended=full&limit=5000` | history |
| `GETRatedMovies` / `GETRatedEpisodes` / `GETRatedShows` / `GETRatedSeasons` | `/sync/ratings/…` | ratings |
| `GETMovieRating` | `/movies/{0}/ratings` | single rating |
| `GETProgressShow` | `/shows/{0}/progress/watched` | show progress |

## Types (selection)

| Type | Purpose |
|------|---------|
| `TraktAPI.Model.TraktMovieWatched` / `TraktEpisodeWatched` / `TraktShowWatchedProgress` / `TraktMovieWatchedRated` | read watched states |
| `TraktItem.Ids` / `TraktMovie.Ids` | external IDs (IMDb/TMDb/TVDb) |
| `TraktSearchIdType.ImDB/TmDB/TvDB` / `TraktSearchResultType.*` / `TraktSyncItemType.*` / `TraktRatingsItemType.*` | ID/type enums |
| `Exceptions/` | API error types |

## Errors

| Code / Exception | Cause |
|------------------|-------|
| Trakt exception (`Exceptions/`) | API error, rate limit, invalid token |
| No match | item without IMDb/TMDb/TVDb ID cannot be matched |
