← [Back to overview](index.md)

# TV Shows — Business Rules

## Episode file assignment

**Description:** Episodes are assigned exclusively via filename patterns; the configurable regex profile decides which files count as episodes.

**Conditions:**
- File is located beneath a detected show folder
- Filename matches an active regex profile (`dlgTVRegExProfiles`)

**Behavior:**
- `S01E02` pattern → season 1, episode 2
- `1x02` pattern → season 1, episode 2
- `S01E01E02`/range patterns → multi-episode (one file covers several episodes)
- No pattern match → file is ignored (no episode entry)

**Implementation:** `Scanner.RegexGetTVEpisode` (`clsAPIScanner.vb`)

## Season logic

**Description:** Seasons are derived from season folders and/or the episode metadata; empty and invalid seasons are cleaned up.

**Conditions:**
- Season number from folder name or file detection
- Specials → season 0

**Behavior:**
- `Delete_Invalid_TVSeasons`/`Delete_Invalid_TVEpisodes` remove seasons/episodes whose files no longer exist
- `Delete_Empty_TVSeasons` removes seasons without episodes
- `Season Result` evaluation decides for ambiguous season packs

**Implementation:** `Database.Delete_Invalid_TVSeasons`, `Database.Delete_Invalid_TVEpisodes`, `Database.Delete_Empty_TVSeasons` (`clsAPIDatabase.vb`)

## Episode ordering

**Description:** Per show it can be chosen whether episodes are sorted and stored in aired or DVD order (`EpisodeOrdering`).

**Behavior:**
- Aired: original air-date order from the scraper
- DVD: DVD order, if provided by the scraper

**Implementation:** `Enums.EpisodeOrdering`, `EpisodeDetails`/`SeasonDetails` (`clsAPIMediaContainers.vb`)

## Episode flags

**Description:** Episodes carry the same status flags as movies (`IsNew`, `IsMarked`, `IsLock`); locking a season or show affects the levels beneath it.

**Implementation:** `Database.DBElement` flags; evaluated in `frmMain` and the modules
