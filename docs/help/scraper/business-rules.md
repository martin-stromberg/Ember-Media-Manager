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

## Title-search match classification (IMDb data scraper)

**Description:** The IMDb data scraper resolves title searches via the TMDb API and classifies each hit so the `ScrapeType` heuristics can decide without user interaction.

**Conditions:**
- Hit title equals the search title after `FilterYear` normalization (case-insensitive) **and** (no search year given or hit release year equals the search year) → `ExactMatches`
- All other hits with a resolvable IMDb ID → `PartialMatches`
- Hits whose IMDb ID cannot be resolved (`GetMovieExternalIdsAsync`/`GetTvShowExternalIdsAsync` fails or returns no `ImdbId`) are logged and skipped entirely

**Behavior:**
- `…Ask`: a single `ExactMatches` hit is used without a dialog; otherwise the search dialog opens (tree groups *Exact Matches* / *Partial Matches* only — the former `PopularTitles`/`TvTitles`/`VideoTitles`/`ShortTitles` categories are never filled)
- `…Auto`/`…Skip`: the first hit whose `Lev` distance (`StringUtils.ComputeLevenshtein`) is ≤ 5 wins; if all hits exceed it, the first `ExactMatches`/`PartialMatches` hit is used anyway (`useAnyway`)
- A `FindYear` hit (filename year matching a result's year) is preferred among multiple exact matches

**Implementation:** `Scraper.SearchMovie`/`SearchTVShow` (classification) and `Scraper.GetSearchMovieInfo`/`GetSearchTVShowInfo` (heuristics) in `clsScrapeIMDB.vb`

## Search failure vs. "no matches"

**Description:** A failed search source (API error, rate limit, network) is a different outcome than an empty result list and must surface differently.

**Conditions:**
- Search worker finishes with `e.Error` → `Exception` event → error node in the dialog
- Search worker finishes with an empty result → *No Matches Found* node

**Behavior:**
- Failed search → the dialog shows *The search could not be completed: {reason}* with a mapped reason (invalid/missing API key, request limit reached, source unreachable); *Manual IMDB Entry*/*Manual TMDB Entry* stays enabled
- In synchronous `ScrapeType` paths a failed search is caught, logged and returns `Nothing` (in *Ask* modes the search dialog is opened so the failure is visible)
- Failed detail lookup for a selected result → the entry stays confirmable; the dialog shows *The details for the selected entry could not be loaded, but the entry can still be used.*

**Implementation:** `bwIMDB_RunWorkerCompleted`/`bwTMDB_RunWorkerCompleted` (`e.Error` → `Exception` event), `SearchFailed`/`GetSearchErrorMessage` in `dlgIMDBSearchResults_*`/`dlgTMDBSearchResults_*`, `Try/Catch` in `GetSearch*Info`

## Trailer and theme handling

**Description:** Trailers and themes are treated like images: scrapers provide sources, central components download and save once.

**Behavior:**
- "also use Trailer Scrapers" enabled → trailer scrapers run in addition to data scrapers
- Download via `HTTP`/`YouTube`; stored as `{file}-trailer.*` or `theme.*`

**Implementation:** `ScraperModule_Trailer_Movie`, `ScraperModule_Theme_*`, `clsAPIYouTube`, `clsAPIFFmpeg`
