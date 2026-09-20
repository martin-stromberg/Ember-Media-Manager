← [Back to overview](index.md)

# Settings — Installation and Configuration

## Prerequisites

An installed Ember Media Manager instance (see [Build](../build/index.md) or the NSIS installer from `BuildSetup/`).

## Configuration storage

| File / directory | Content |
|------------------|---------|
| `Settings.xml` (in the profile directory) | Entire application and module settings |
| `AdvancedSettings.xml` | Advanced key-value options (regex, exclusions, format conversion) |
| `MyVideos*.emm` | SQLite database of the profile |
| `Modules/` | Add-on assemblies, loaded at startup |
| `Defaults/` (program directory) | Factory defaults: `DefaultAdvancedSettings - AudioFormatConverts.xml`, `DefaultAdvancedSettings - VideoFormatConverts.xml`, `DefaultAdvancedSettings - VideoSourceMapping.xml`, `DefaultRatings.xml`, `Core.Languages.Scrapers.xml`, `Core.Mapping.Editions.xml` |
| `Translations/` | Language resources (`en-US.xml`, `db-DB.xml`) |
| `NLog.config` | Logging configuration |

## Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Settings.xml` | File | created on first start | If the file is missing, default settings are used (no crash) |
| `AdvancedSettings.xml` | File | taken from `Defaults/` | Advanced options outside the dialogs |
| Command line `-profile` | String | — | Starts Ember with a named profile |

## Verification

- After the first start `Settings.xml` must exist in the profile directory.
- In the settings dialog the settings tree with the module panels must appear on the left; missing panels indicate modules not loaded from `Modules/`.
- The error log (*Error Viewer*) shows problems loading settings or modules.
