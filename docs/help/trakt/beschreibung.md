← [Back to overview](index.md)

# Trakt.tv — Description

## Purpose

The *Trakt.tv* module synchronizes the local media library with the user's Trakt.tv account — "Sync lists and playcount with your trakt.tv account." It allows syncing watched state between devices and Ember, maintaining Trakt lists and using Trakt as a metadata source.

## How it works

- **Authorization:** One-time account linking via the authorization dialog; the token is stored and renewed automatically.
- **Watched state:** *Get watched movies* / *Get watched episodes* loads the Trakt watched state; *Save playcount to database/Nfo* writes it into the Ember database and NFOs. Conversely, the local state can be reported to Trakt.
- **Context menus:** Per movie/episode/season/show the watched state can be fetched from or reported to Trakt selectively.
- **Lists:** Trakt lists (watchlist, custom lists, collection) can be synchronized with tags or the Ember library.
- **Ratings & comments:** report ratings to Trakt, read/write comments.
- **Data scraper:** A separate Trakt data scraper provides metadata for movies and TV shows (see [Scrapers](../scraper/index.md)).

## Examples

- Mark movies watched on the media center as watched in Ember: *Get watched movies* → *Save playcount to database/Nfo*.
- Show progress: *Get watched episodes* → take over episode playcounts in Ember; missing episodes become visible.
- Custom Trakt list as tag: synchronize a list into Ember as a keyword.

## Limitations

- Requires a Trakt.tv account and a one-time authorization of the application.
- Matching works via external IDs (IMDb/TMDb/TVDb) — media without such an ID cannot be matched.
- The sync functions depend on the Trakt API service; changes to the service directly affect availability.
