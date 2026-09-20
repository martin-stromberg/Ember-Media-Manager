← [Back to overview](index.md)

# Media Library — Business Rules

## Source assignment and validity

**Description:** Only files beneath configured sources enter the library; movie and TV show sources are strictly separated.

**Conditions:**
- Source has type Movie (`DBSource` for movies) or TV show (`DBSource` for TV)
- Source options (recursive, exclusion patterns, language)

**Behavior:**
- Directory satisfies `IsValidDir` (no exclusion pattern, not a hidden/system folder): it is scanned
- Directory listed in `GetAll_ExcludedDirectories`: it is skipped
- For movies: `SubDirsHaveMovies` decides whether subfolders are separate movies or belong to the parent movie (e.g. `VIDEO_TS`, `BDMV`, extras)

**Implementation:** `Scanner.IsValidDir`, `Scanner.ScanSubDirectory_Movie`, `Scanner.SubDirsHaveMovies` (`clsAPIScanner.vb`)

## Episode detection

**Description:** Episode files are assigned to a show via filename patterns (e.g. `S01E02`, `1x02`); the patterns are configurable.

**Conditions:**
- TV show source scanned, show folder detected
- Regex profiles in the settings (`dlgTVRegExProfiles`)

**Behavior:**
- Filename matches an episode pattern → `RegexGetTVEpisode` returns season/episode number(s) including multi-episodes (`S01E01E02`)
- No match → file is not imported as an episode
- `Season Result` evaluation decides for season packs

**Implementation:** `Scanner.RegexGetTVEpisode` (`clsAPIScanner.vb`)

## "New" flag and cleanup logic

**Description:** Newly found media are marked `IsNew`; only the cleanup actually removes deleted files from the database.

**Conditions:**
- Scan with update/clean task (`Structures.ScanOrClean`)

**Behavior:**
- New file → entry created with `IsNew` (shown as "New")
- File no longer found during scan → entry remains on a plain update; with *Clean Database*/Clean Files it is removed (`Database.Clean`, `Delete_Invalid_TVEpisodes`, `Delete_Empty_TVSeasons`)
- `Database.Clear_New` clears all New flags

**Implementation:** `Database.Clean`, `Database.Clear_New` (`clsAPIDatabase.vb`)

## Lock/Mark

**Description:** `IsLock` protects an item from being overwritten by scrapers/updates; `IsMarked` is the working selection for batch operations (ScrapeType `Marked*`, export, rename).

**Behavior:**
- `IsLock` set → scrapers and field updates do not modify the item
- `IsMarked` set → item belongs to the marked set for bulk actions

**Implementation:** flags on `Database.DBElement`, evaluated in `frmMain` and the modules
