← [Back to overview](index.md)

# Trakt.tv — Technical Flow

## Overview

Two modules use Trakt.tv: `generic.Interface.Trakttv` (sync/UI) and `scraper.Data.Trakttv` (metadata scraper). Both wrap `clsAPITrakt`, which works against the Trakt API v2 — partly via the `Trakttv` library in the repository (`TraktAPI`, `TraktMethods`, `TraktURIs`, `TraktAPI.Model`) and partly via TraktApiSharp types (`TraktNet.Objects`, `TraktApiSharp.Enums`, `TraktAuthorization`).

## Flow

### 1. Authorization and token

- `frmAuthorize` performs the PIN/OAuth approval; `TraktAuthorization.CreateWith` creates the token.
- `Handle_NewToken` stores the token in the module settings; `Handle_ModuleSettingsChanged`/`Handle_ModuleEnabledChanged` react to configuration changes.

### 2. Sync manager (`dlgTrakttvManager`)

The manager dialog ("Sync lists and playcount with your trakt.tv account") works with `BackgroundWorker` runs:

- `bwSaveWatchedStateToEmber_Movies`/`bwSaveWatchedStateToEmber_TVEpisodes` — writes playcounts back to Ember
- `_myWatchedMovies` (`TraktMovieWatched`), `_myWatchedTVEpisodes` (`TraktEpisodeWatched`), `_myWatchedProgressTVShows` (`TraktShowWatchedProgress`), `_myWatchedRatedMovies` — loaded Trakt states
- `myWatchlistEpisodes` — watchlist mapping; the tag collection is loaded from the Ember DB, updated at runtime and written back

`dlgWorker` shows progress of the sync jobs.

### 3. Context-menu queries

`PopulateMenus`/`CreateContextMenu`/`CreateToolsMenu` attach entries to the menus per `Enums.ContentType`; handlers call `clsAPITrakt`:

- `cmnuGetWatchedState_Movie/TVEpisode/TVSeason/TVShow_Click` — fetch watched state of individual items
- `mnuGetPlaycount_Movies/TVEpisodes_Click` — load playcounts

### 4. API calls (`clsAPITrakt` → `TrakttvAPI`)

Calls used by the module (selection): `AddMoviesToWatchedHistory`, `AddShowsToWatchedHistoryEx`, `AddMoviesToRatings`, `AddItemsToList`, `AddUserList`, `AddCommentForMovie`, `GetComments`, `GetRatedEpisodes`, `GetProgressShow`, `GetNetworkFriends`, `GetNetworkFollowing`. Matching happens via IDs (`TraktItem.Ids`, `TraktSearchIdType.ImDB/TmDB/TvDB`).

## Diagram

```mermaid
flowchart TD
    A[frmMain menus/context menus] --> B[Interface.Trakt RunGeneric/click handlers]
    B --> C[clsAPITrakt]
    C --> D[Trakttv library / TraktApiSharp]
    D --> E[api-v2launch.trakt.tv / Trakt API]
    B --> F[dlgTrakttvManager + BackgroundWorker]
    F --> G[playcount → Database.Save_* / NFO]
```

## Error handling

- Missing IDs (no IMDb/TMDb/TVDb) → item cannot be matched and is skipped.
- Token/network errors → error message in the error log (`dlgErrorViewer`); Ember data stays unchanged.
- `Exceptions/` of the `Trakttv` library define dedicated error types for API errors.
