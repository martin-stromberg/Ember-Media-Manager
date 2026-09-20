← [Back to overview](index.md)

# TV Shows — Description

## Purpose

The TV show view (*TV Shows*) manages shows on three levels: show, season and episode. Ember Media Manager maintains separate metadata and artwork per level — e.g. show poster/fanart/banner, season posters and episode thumbs — as well as episode cast (including guest stars), episode orderings and multi-episodes.

## How it works

- **Hierarchy:** show folder → season folder (`Season 01`, `Season 1`, `Staffel 1` and others) → episode files; specials are kept as season 0.
- **Episode assignment:** filename patterns like `S01E02` or `1x02` assign files to episodes; multi-episodes (`S01E01E02`) are supported.
- **Episode ordering:** shows can be kept in aired or DVD order (Episode Ordering).
- **Editing:** *Edit TV Show*, *Edit Season* and *Edit Episode* open dedicated edit dialogs per level; *TV Change Episode* allows moving episodes.
- **Scraping:** *(Re)Scrape Show*, *(Re)Scrape Season* and *(Re)Scrape Episode* per level; missing episodes can be shown as "Missing Episodes".
- **Images/trailers/themes:** separate artwork types per level, including CharacterArt/ClearLogo on show level.

## Examples

- New season: copy the season folder into the TV show source → *Reload All TV Shows* → season and episodes appear in the hierarchy.
- Misassigned episode: open *Edit Episode* and correct season/episode number, or use *TV Change Episode*.
- Set a season poster: select the season → set the poster in the image area from a scraper result or file.

## Limitations

- Episode files without a recognizable season/episode pattern are not assigned — filename patterns must match the configured regex profiles.
- Season/episode content depends on the chosen show scraper (TheTVDB/TMDb/IMDb) and its data availability.
- Locked shows/seasons/episodes (*Lock*) are not modified.
