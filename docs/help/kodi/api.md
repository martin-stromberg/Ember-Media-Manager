← [Back to overview](index.md)

# Kodi Interface — API

## Overview

The interface consists of two layers: the generated C# client library `XBMCRPC` (`KodiAPI/KodiAPI.csproj`, namespace `XBMCRPC`) and the VB module `generic.Interface.Kodi`, which uses the client for Ember synchronization. Communication runs over Kodi JSON-RPC (HTTP) plus WebSocket for notifications.

## Authentication

HTTP Basic Auth with the credentials configured in Kodi (`ConnectionSettings`: host, port, UserName, Password).

## Used RPC method groups (`XBMCRPC/Methods/*`)

### `VideoLibrary` (library)

| Method | Purpose |
|--------|---------|
| `GetMovies` / `GetMovieDetails` / `SetMovieDetails` / `RemoveMovie` | read/write/remove movies |
| `GetMovieSets` / `GetMovieSetDetails` / `SetMovieSetDetails` | movie sets |
| `GetTVShows` / `GetTVShowDetails` / `SetTVShowDetails` / `RemoveTVShow` | TV shows |
| `GetSeasons` / `GetSeasonDetails` / `SetSeasonDetails` | seasons |
| `GetEpisodes` / `GetEpisodeDetails` / `SetEpisodeDetails` / `RemoveEpisode` | episodes |
| `Scan` / `Clean` | trigger library scan/cleanup |

### `Files` (file system/sources)

| Method | Purpose |
|--------|---------|
| `GetSources` | fetch Kodi sources (path mapping) |
| `GetDirectory` | read directory contents |
| `PrepareDownload` | create download URL for artwork |
| `AllFields` | field selection |

### `Textures` (artwork cache)

| Method | Purpose |
|--------|---------|
| `GetTextures` / `RemoveTexture` | read/clean artwork cache |
| `url` | texture URL |

### `Player` (playback)

| Method | Purpose |
|--------|---------|
| `GetActivePlayers` | determine active playback |

### Additional available groups (generated, not necessarily used)

`Addons`, `Application`, `AudioLibrary`, `Favourites`, `GUI`, `Input`, `JSONRPC`, `PVR`, `Playlist`, `Profiles`, `Settings`, `System`, `XBMC`

## Custom client extensions (`KodiAPI/Client.cs`)

| Method | Purpose |
|--------|---------|
| `GetImageStream(thumbnailUri)` | load thumbnail as stream |
| `GetImageUri(thumbnailUri)` | resolve download URI (`image:` references) |

## Notifications (WebSocket)

| Event | Handling |
|-------|----------|
| `VideoLibrary.OnScanFinished` | `VideoLibrary_OnScanFinished` — follow-up after Kodi scan |
| `VideoLibrary.OnCleanFinished` | `VideoLibrary_OnCleanFinished` — follow-up after Kodi clean |

## Errors

| Code / Exception | Cause |
|------------------|-------|
| RPC error/timeout | host unreachable, wrong credentials |
| Item without Kodi ID | entry does not exist in the Kodi library → library scan required ("Please Scrape In Ember First!") |
