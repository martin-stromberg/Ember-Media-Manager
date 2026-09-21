← [Back to overview](index.md)

# Scrapers — Setup

## Purpose

Before the first scrape run the scraper modules are enabled, sorted in the desired order and — if needed — provided with API keys or accounts.

## Settings

| Setting | Meaning |
|---------|---------|
| Activation (checkbox per module) | Module is considered during scraping |
| *Scrape Order* | Order of the data scrapers; the first active scraper delivers first |
| Language | Preferred language for content and search results (e.g. "default language … when scraping TV Show items") |
| Fields/image types per scraper | Which metadata or artwork types the scraper may provide |
| Account/API key | For sources with sign-in (e.g. Trakt.tv: authorization; OMDb: API key; TMDb and — for its title search — IMDb: TMDb API key) |
| "also use Trailer Scrapers" | Run trailer scrapers in addition to data scraping |

## Steps

1. Open *Edit → Settings...*.
2. In the *Scrapers* area (per content type: Movies / MovieSets / TV Shows) enable the desired data, image, trailer and theme scrapers.
3. Set the order via *Scrape Order*.
4. Store accounts/API keys in the respective module settings (e.g. Trakt authorization via the authorization dialog).
5. Optionally restrict the allowed fields and image types per scraper.

### TMDb API key (IMDb and TMDb data scrapers)

Both the *TMDB* data scraper and the title search of the *IMDB* data scraper query the TMDb service. Without further setup they use the embedded Ember API key — the *Ember Media Manager Embedded API Key* hint in the module panel indicates this. To use a personal TMDb API key instead:

1. Open *Edit → Settings...* → *Movies* → *Scrapers - Data* (or *TV Shows* → *Scrapers - Data*) → the *IMDB* resp. *TMDB* panel.
2. Click *Use my own API key* — the key field becomes editable.
3. Enter the personal TMDb API key and apply the settings.
4. To revert, click *Use embedded API Key* — the field is cleared and locked again.

## Notes

- Only enabled scrapers are used — a disabled module stays inactive even on "All" runs.
- An empty API key field falls back to the embedded Ember API key; an invalid key surfaces as a distinguishable error in the *Search Results* dialog (see [Troubleshooting](troubleshooting.md)).
- The language choice affects search results and content; for German content a German data scraper should be near the top of the order.
- Changes to the scraper settings may require an application restart (the module reports *Setup Needs Restart*).
