← [Back to overview](index.md)

# Media Library — Description

## Purpose

Ember Media Manager does not manage files "on the fly" — it builds its own media library: the user defines **sources** for movies and TV shows, the application scans these directories and stores the discovered media together with metadata, images and file information in a local database. All list views, scrapers and tools operate on this database.

## How it works

- **Sources:** Each source consists of a name, a path and options (e.g. recursive search, language, ordering). Movie and TV show sources are managed separately.
- **Scan:** Via *Tools → Update Library* or the reload functions (*Reload All Movies*, *Reload All TV Shows*, *Reload All MovieSets*) the sources are scanned for new or removed files. New media appear flagged as "New" in the lists.
- **Detection:** Title, year and — for TV shows — season and episode numbers as well as video source identifiers (e.g. Bluray, DVD, HDTV) are derived from file and folder names. Existing NFO files are read in.
- **Filters:** Above the lists, entries can be filtered by source (*Video Sources*), genre, marker, lock status, year and other criteria; *Clear Filters* resets all filters.
- **Mark and lock:** Entries can be marked (*Mark*, *Mark All*) or protected against changes (*Lock*).
- **Offline media:** The *Offline Media Manager* manages media that do not exist as files (e.g. DVD/Blu-ray on a shelf), including stub files for media centers.

## Examples

- A new movie is copied into the movie directory → *Update Library* → the movie appears with a "New" flag in the movie list and can then be scraped.
- Show only movies from a specific source: select the source under *Video Sources* in the filter bar.
- Maintain a Blu-ray collection without files: create entries with a location hint via the *Offline Media Manager*.

## Limitations

- The library reflects the state of the last scan; file changes made outside Ember are only detected on the next scan.
- Removed files are only deleted from the database by the cleanup function (*Clean Database* / Clean Files).
- The application is localized in English; all visible labels are in English.
