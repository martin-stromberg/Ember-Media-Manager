← [Back to overview](index.md)

# Scrapers — Business Rules

## Scrape scope and mode

**Description:** Every scrape run combines a scope (which items) with a mode (how decisions are made) — mapped in `ScrapeType`.

**Conditions:**
- Scope: `All`, `New`, `Marked`, `Filter`, `Missing`
- Mode: `Auto`, `Ask`, `Skip`

**Behavior:**
- `…Auto` → first search result is taken without asking
- `…Ask` → search/selection dialog per item (`dlgSearchResults`, `dlgImgSelect`)
- `…Skip` → item is skipped
- `Missing*` → only items with missing content are processed
- `Marked*`/`Filter*` → only marked or filtered items

**Implementation:** `Enums.ScrapeType` (`clsAPICommon.vb`), evaluated in `frmMain`

## Field takeover by data scrapers

**Description:** Data scrapers run sequentially in *Scrape Order*; a field is only taken over when it is selected for the run, still empty and not locked.

**Conditions:**
- Field enabled in the custom-scraper/module selection
- Field empty in the target `DBElement` or not protected by *Lock*

**Behavior:**
- The earlier scraper in the order wins: filled fields are not overwritten by later scrapers
- `Lock` flag → no field changes
- `NFOItem` selected → NFO is written after the run

**Implementation:** field merge in `frmMain` after `ScraperModule_Data_*.Scraper` call

## Image selection

**Description:** All active image scrapers deliver candidate lists per `ScraperEventType` image type; the selection happens centrally, not inside the scraper.

**Behavior:**
- `Auto` mode: first/top-ranked result per image type
- `Ask` mode: `dlgImgSelect` shows all results merged; the user selects per image type
- Image scraper order only matters for automatic runs (first scraper first)

**Implementation:** `dlgImgSelect`, `Images`/`ImageUtils` (download/size check), `PreferredImagesContainer`

## Trailer and theme handling

**Description:** Trailers and themes are treated like images: scrapers provide sources, central components download and save once.

**Behavior:**
- "also use Trailer Scrapers" enabled → trailer scrapers run in addition to data scrapers
- Download via `HTTP`/`YouTube`; stored as `{file}-trailer.*` or `theme.*`

**Implementation:** `ScraperModule_Trailer_Movie`, `ScraperModule_Theme_*`, `clsAPIYouTube`, `clsAPIFFmpeg`
