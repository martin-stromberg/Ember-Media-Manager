← [Back to overview](index.md)

# Scrapers — Description

## Purpose

Scraper modules fetch information from the internet: metadata (title, plot, cast, ratings, IDs), images of all artwork types, trailer videos and themes (title music). They are enabled per content type — movie, movie set, TV show — and run in a configurable *Scrape Order*.

## How it works

- **Data scrapers** run sequentially and only fill the selected, still-empty fields (unless locked).
- **Image scrapers** run in parallel and return result lists that are merged into a shared selection dialog.
- **Trailer scrapers** provide trailer sources; selected trailers are downloaded next to the media file.
- **Theme scrapers** provide title music (`theme` file).
- **Scrape modes:** For each run the scope and interaction level is chosen: *All*, *New*, *Marked*, *Filter* or *Missing Items* — each as *Auto* (automatically use first result), *Ask* (selection dialog) or *Skip*.
- **Custom Scraper:** *Custom Scraper...* allows selecting individual fields, image types and options per run.

## Available scraper modules

| Group | Module | Content type |
|-------|--------|--------------|
| Data | IMDb | Movie, TV show |
| Data | TMDb | Movie, Movie set, TV show |
| Data | TheTVDB | TV show |
| Data | OMDb | Movie, TV show |
| Data | OFDb | Movie (German) |
| Data | Moviepilot | Movie (German) |
| Data | Trakt.tv | Movie, TV show |
| Images | TMDb | Movie, Movie set, TV show |
| Images | Fanart.tv | Movie, Movie set, TV show |
| Images | TheTVDB | TV show |
| Trailers | YouTube | Movie |
| Trailers | TMDb | Movie |
| Trailers | Apple Trailers | Movie |
| Trailers | hd-trailers.net | Movie |
| Trailers | Videobuster | Movie (German) |
| Themes | YouTube | Movie, TV show |
| Themes | TelevisionTunes | Movie, TV show |

## Examples

- Fully populate a new movie: *(Re)Scrape Movie* → *New Movies - Auto* → data from first match, image selection via dialog.
- Fetch only missing posters: *Custom Scraper...* → enable only posters → *Missing Items - Auto*.
- German content: move OFDb/Moviepilot up in the data scraper order.

## Limitations

- Availability and data quality of the online sources are outside the project's control; individual services may have changed or shut down — the module then simply reports no results.
- Some sources require API keys or account sign-in (see [Setup](einrichtung-anwender.md)).
- Locked entries (*Lock*) are not modified; empty fields are only filled when the scraper provides them.
