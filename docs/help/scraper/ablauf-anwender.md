← [Back to overview](index.md)

# Scrapers — User Walkthrough: the Search Results dialog

## Prerequisites

The respective data scraper is enabled in *Edit → Settings...* under *Scrapers - Data* and the scrape run uses an *Ask* mode (or the search is triggered from the dialog of a previous step).

## Step-by-step guide

### 1. Start the search

1. Select a movie or TV show and choose *(Re)Scrape* from the context menu (or a scrape run reaches the *Ask* step).
2. The *Search Results* dialog opens and searches for the item's title automatically. The header shows *Movie Search Results* resp. *TV Search Results*.

### 2. Pick the correct result

1. Hits are grouped under *Exact Matches* and *Partial Matches* (each with the number of hits). *Exact Matches* contains hits whose title and year match exactly; *Partial Matches* contains the remaining hits.
2. Select an entry — the details are loaded and shown in the info area.
3. Confirm with *OK*; the entry's ID is applied and the scrape continues.

> **Note:** If the details of an entry cannot be loaded, the info area shows *The details for the selected entry could not be loaded, but the entry can still be used.* — the entry can still be confirmed.

### 3. Refine or correct the search (optional)

- Change the text in the search field at the top and click the search button next to it to search again.
- If the search source fails, the result list shows *The search could not be completed: …* with the reason (invalid API key, request limit reached, source unreachable). See [Troubleshooting](troubleshooting.md).

### 4. Enter an ID manually (optional)

1. Enable *Manual IMDB Entry* (IMDb dialog) resp. *Manual TMDB Entry* / *Manual TMDb or IMDb ID Entry* (TMDb dialog) — the result list is locked and the ID field becomes editable.
2. Enter the ID and click *Verify* to check it. If verification fails, the entry can still be confirmed via *Continue without verification?*.
3. Confirm with *OK*.

## Result

The dialog closes with the chosen ID; the data scraper fetches the metadata for that entry and the scrape run continues with the next scraper in the *Scrape Order*. *Cancel* aborts the whole scrape run — later scrapers in the order are no longer called for the current item.
