← [Back to overview](index.md)

# Movie Sets — Description

## Purpose

Movie sets bundle movie series. Ember Media Manager manages sets as dedicated entries with title, plot and their own artwork (poster, fanart, banner, ClearArt, ClearLogo, DiscArt, landscape) and links movies through the set assignment. When scraping, sets can be created automatically from scraper data (e.g. TMDb collections).

## How it works

- **Sets Manager:** Central management of the sets (view *Sets & Manager*).
- **Assignment:** In the movie edit dialog a set is chosen or created in the *Set* field; a movie can be assigned to sets.
- **Editing:** *Edit MovieSet* maintains set metadata and images; *New Set* creates custom collections.
- **Scraping:** Movie-set scrapers (e.g. TMDb) fetch set metadata and images; movie-set information is stored in NFOs and the database.
- **Ordering:** Sets can be sorted by their own rules (ordering methods of the set).

## Examples

- Bundle a trilogy: create a *New Set* → assign movies via *Edit Movie* → add poster/fanart to the set.
- Review automatically detected sets: after scraping, check the set assignments in the *Sets Manager* and adjust if needed.

## Limitations

- Automatic set detection depends on the data scraper; without collection data no sets are created.
- Deleting a movie also removes its set link; empty sets remain until cleanup.
