← [Back to overview](index.md)

# Scrapers — Installation and Configuration

## Prerequisites

- Scraper modules ship as add-on assemblies under `Modules\` and are loaded by `ModulesManager` on startup — no separate installation.
- The data scrapers `scraper.Data.IMDB` and `scraper.Data.TMDB` require outbound HTTPS access to the TMDb API (`api.themoviedb.org`).

## Configuration

### `APIKey` (IMDb data scraper)

The title search of `scraper.Data.IMDB` uses the TMDb API. The module reads a personal TMDb API key (v3) from `AdvancedSettings`, one entry per content type:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `APIKey` (section `scraper.Data.IMDB`, `Enums.ContentType.Movie`) | `String` | `String.Empty` → embedded fallback `_strAPIKey` | Personal TMDb API key for the movie title search |
| `APIKey` (section `scraper.Data.IMDB`, `Enums.ContentType.TV`) | `String` | `String.Empty` → embedded fallback `_strAPIKey` | Personal TMDb API key for the TV show title search |

- Loaded in `IMDB_Data.LoadSettings_Movie`/`LoadSettings_TV` via `AdvancedSettings.GetSetting("APIKey", …)`; an empty value falls back to the embedded key `IMDB_Data._strAPIKey` (same key as `TMDB_Data._strAPIKey`).
- Persisted via `SetSetting("APIKey", txtApiKey.Text.Trim, …)` in `SaveSettings_Movie`/`SaveSettings_TV`; UI entry via `txtApiKey`/`btnUnlockAPI`/`lblEMMAPI` in `frmSettingsHolder_Movie`/`frmSettingsHolder_TV` (see [Setup](einrichtung-anwender.md)).
- The `TMDbClient` is created per `Scraper` instance (`GetClient()` in `clsScrapeIMDB.vb`), so a changed key takes effect on the next search — no client refresh needed.
- The `scraper.Data.TMDB` module keeps its own `APIKey` setting in its own section (`clsAPIAdvancedSettings` separates sections by calling assembly) — no collision with the IMDb entries.

### Deprecated settings

| Parameter | Status |
|-----------|--------|
| `SearchPartialTitles`, `SearchPopularTitles`, `SearchTvTitles`, `SearchVideoTitles`, `SearchShortTitles` (section `scraper.Data.IMDB`) | Deprecated — no longer loaded, saved or evaluated; the fields remain in `IMDB_Data.SpecialSettings` for compatibility only. Existing entries in a user's `AdvancedSettings.xml` stay inert; no migration is performed. |

## Dependencies

| Package | Version | Module | Notes |
|---------|---------|--------|-------|
| `TMDbLib` | 2.3.0 | `scraper.Data.IMDB` (new), `scraper.Data.TMDB` (upgraded from 1.9.1) | Highest stable release still targeting .NET Framework (`lib\net45`, assembly version `2.0.0.0`); `TMDbLib` 3.x targets .NET 8+ and is not usable. |
| `Newtonsoft.Json` | 13.0.3 | `scraper.Data.IMDB` (new transitive) | Already used elsewhere; existing binding redirect suffices. |
| `System.Net.Http`, `System.IO`, `System.Runtime`, `System.Security.Cryptography.*` | 4.3.x | `scraper.Data.IMDB` (new transitive) | Same set as `scraper.Data.TMDB`. |

- `EmberMediaManager\App.config` carries a `TMDbLib` binding redirect `0.0.0.0-2.0.0.0 → 2.0.0.0` (the assembly is not strong-named, `publicKeyToken="null"` — consistency is additionally enforced by identical HintPaths in both modules).
- Deployment note: `TMDbLib.dll` is copied next to each module's output (`Modules\scraper.data.imdb\`, `Modules\scraper.data.tmdb\`); both modules must ship the same file version.

## Verification

- After `nuget restore`, `packages\TMDbLib.2.3.0\lib\net45\TMDbLib.dll` exists and both module projects compile (`Debug|x86` / `Release|x64`).
- At runtime, a title search in the *Search Results* dialog returns hits grouped under *Exact Matches*/*Partial Matches* (IMDb scraper) resp. the matches list (TMDb scraper); a deliberately invalid `APIKey` surfaces as *The search could not be completed: The API key is invalid or missing. …* instead of *No Matches Found*.
