← [Back to overview](index.md)

# Scrapers — Troubleshooting

## IMDb title search always shows "No Matches Found"

**Symptom:** The *Search Results* dialog of the IMDb data scraper shows *No Matches Found* for every movie or TV show title, regardless of the search term. Known affected versions: current code base (defect verified for `SearchMovie`/`SearchTVShow` in `scraper.Data.IMDB`).

**Cause:** The IMDb data scraper performs its title search by parsing the public IMDb HTML pages `imdb.com/find` and `imdb.com/search/title`. IMDb no longer serves these pages in the expected form: the endpoints answer with an AWS WAF bot challenge (HTTP 202, header `x-amzn-waf-action: challenge`, empty body — verified by live request) resp. a completely rebuilt React frontend. None of the expected markup exists anymore, so all result lists stay empty and the dialog falls back to *No Matches Found*. The fetch failure itself is not reported or logged — an unreachable source is indistinguishable from "no hits".

**Workaround:**

1. Look up the IMDb ID of the movie or show on the IMDb website (format `tt…`).
2. In the *Search Results* dialog enable *Manual IMDB Entry*, enter the IMDb ID in the field next to it and click *Verify*.
3. The manual entry path is still functional.

> **Note:** The IMDb detail fetches (reference pages, release info, plotsummary, parental guide, episodes) use the same affected IMDb pages and are presumably broken as well — the scope of the remaining metadata retrieval after a manual ID entry is not yet verified. A full analysis with the recommended remediation (migration of the title search to the TMDb API) is documented in `docs/analysis/issue-8-titelsuche-imdb.md`.

## TMDb data scraper returns no search results either

**Symptom:** On an installation with both the IMDb and the TMDb data scraper enabled, the title search still delivers no results — not even with all enabled scrapers.

**Cause:** Under investigation. Two hypotheses are documented in the analysis referenced above: (a) the TMDb title search itself may be broken (outdated `TMDbLib` 1.9.1, possible API/TLS changes, possibly invalid embedded fallback API key), or (b) a scrape-order effect — the first data scraper in the order opens its search dialog, and cancelling it aborts the whole scrape chain before the second scraper is ever reached.

**Workaround:**

1. Check the *Scrape Order* in *Edit → Settings…*: if the IMDb scraper runs first, its empty *Search Results* dialog can only be dismissed by *Cancel* or a manual ID entry — cancelling aborts the whole run before the TMDb scraper is ever called. Either enter the IMDb ID manually (see above) or move the TMDb scraper above the IMDb scraper in the order.
2. If the TMDb scraper is reached but still returns nothing, configure a personal TMDb API key in the module settings; the embedded fallback key may be invalid or rate-limited.
