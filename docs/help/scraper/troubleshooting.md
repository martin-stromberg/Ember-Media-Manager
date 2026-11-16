← [Back to overview](index.md)

# Scrapers — Troubleshooting

## Search Results dialog shows "The search could not be completed: The API key is invalid or missing. …"

**Symptom:** The *Search Results* dialog of the IMDb or TMDb data scraper shows an error entry reading *The search could not be completed: The API key is invalid or missing. Check the TMDB API key in the module settings.* instead of result groups.

**Cause:** The title search of both data scrapers uses the TMDb API. The TMDb API rejected the key in use — either the embedded Ember API key (shown as *Ember Media Manager Embedded API Key* in the module settings) is no longer accepted, or a self-entered key in the *TMDB Api Key* field (in the IMDb panel: *TMDB API Key (used for title search)*) is wrong (e.g. typo, truncated paste, or a v4 read access token instead of a v3 API key — only the v3 key is accepted).

**Solution:**

1. Open *Edit → Settings…* → *Movies* → *Scrapers - Data* (or *TV Shows* → *Scrapers - Data*) → the *IMDB* resp. *TMDB* panel.
2. Click *Use my own API key*, enter a valid personal TMDb API key (v3) in the API key field and save the settings.
3. Re-run the search.

> **Note:** An empty API key field falls back to the embedded Ember key — clearing the field and switching back via *Use embedded API Key* restores the default.

## Search Results dialog shows "The search could not be completed: The request limit of the source has been reached. …"

**Symptom:** The *Search Results* dialog shows *The search could not be completed: The request limit of the source has been reached. Please try again later.*

**Cause:** The TMDb API rate limit was hit. The embedded API key is shared by all Ember installations, so bursts — or resolving the IMDb ID of every search hit — can exhaust it.

**Solution:**

1. Wait a moment and retry the search.
2. If the message recurs, configure a personal TMDb API key in the module settings (see above) — a personal key has its own quota.

## Search Results dialog shows "The search could not be completed: The source could not be reached. …"

**Symptom:** The *Search Results* dialog shows *The search could not be completed: The source could not be reached. Check the internet connection and try again later.*

**Cause:** The TMDb API could not be reached — no internet connection, a blocking firewall/proxy, or a temporary outage of the service.

**Solution:**

1. Check the internet connection and any firewall/proxy rules for outgoing HTTPS.
2. Retry the search later.
3. If the source stays unavailable, the IMDb ID of a movie or TV show can still be entered manually: enable *Manual IMDB Entry* (IMDb dialog) or *Manual TMDB Entry* / *Manual TMDb or IMDb ID Entry* (TMDb dialog), enter the ID and click *Verify* — or confirm it directly and continue without verification.

## Selected result shows "The details for the selected entry could not be loaded, but the entry can still be used."

**Symptom:** After selecting a search result, no details appear; instead the info area shows *The details for the selected entry could not be loaded, but the entry can still be used.*

**Cause:** The detail lookup for the selected entry failed. For the IMDb scraper the detail pages are still retrieved from IMDb directly, and parts of that source are unavailable; for the TMDb scraper the same indicates a failed detail request.

**Solution:**

1. The selected entry can still be confirmed — its ID is applied and the scrape continues.
2. Alternatively pick a different search result or enter the ID manually (*Manual IMDB Entry* / *Manual TMDB Entry*).
3. Details that could not be loaded remain empty or are filled by the next scraper in the *Scrape Order*.

## Older versions: IMDb title search always showed "No Matches Found"

**Symptom:** On versions before this change, the *Search Results* dialog of the IMDb data scraper showed *No Matches Found* for every movie or TV show title, regardless of the search term.

**Cause:** The former IMDb title search parsed the public IMDb HTML pages `imdb.com/find` and `imdb.com/search/title`. IMDb stopped serving these pages in the expected form (AWS WAF bot challenge resp. a rebuilt React frontend), so all result lists stayed empty — an unreachable source was indistinguishable from "no hits". A side effect: when the empty search dialog was dismissed with *Cancel*, the whole scrape chain aborted before a later scraper (e.g. TMDb) in the *Scrape Order* was ever reached.

**Solution:** Update to a version containing this fix. The title search of the `scraper.Data.IMDB` module (`SearchMovie`/`SearchTVShow` in `clsScrapeIMDB.vb`) now uses the TMDb API via `TMDbLib` and resolves the IMDb ID of each hit; source failures surface as the distinct error entries described above. The manual IMDb ID entry remains available as fallback.
