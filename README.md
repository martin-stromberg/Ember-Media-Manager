<a href="http://flattr.com/thing/1321788/" target="_blank"><img src="http://api.flattr.com/button/flattr-badge-large.png" alt="Flattr this" title="Flattr this" border="0" /></a>

# Ember Media Manager

[![.NET](https://img.shields.io/badge/.NET-4.8-512BD4?logo=dotnet)](https://dotnet.microsoft.com)
[![License](https://img.shields.io/github/license/martin-stromberg/Ember-Media-Manager)](EmberMediaManager/License.txt)
[![Release](https://img.shields.io/github/actions/workflow/status/martin-stromberg/Ember-Media-Manager/release.yml?label=Release)](https://github.com/martin-stromberg/Ember-Media-Manager/actions/workflows/release.yml)
[![Pre-Release](https://img.shields.io/github/actions/workflow/status/martin-stromberg/Ember-Media-Manager/staging-ci.yml?branch=staging&label=Pre-Release)](https://github.com/martin-stromberg/Ember-Media-Manager/actions/workflows/staging-ci.yml)

We decided that was time to give Ember a new home. We've taken it upon ourselves not only to pick up the code where it was left off but to attempt to continue its development.

Ember Media Manager is a Windows media manager for movies, TV shows and movie sets. It scans media folders into a local library, scrapes metadata, artwork, trailers and themes from online sources and produces Kodi-compatible NFO and artwork files. Add-ons provide Kodi and Trakt.tv synchronization as well as bulk renaming, exporting and other tools.

## Features

- Media library for movies, TV shows/seasons/episodes and movie sets (local SQLite database, Kodi `MyVideos` naming)
- Pluggable scrapers — data (IMDb, TMDb, TheTVDB, OMDb, OFDb, Moviepilot, Trakt.tv), images (TMDb, Fanart.tv, TheTVDB), trailers (YouTube, TMDb, Apple, hd-trailers.net, Videobuster) and themes (YouTube, TelevisionTunes)
- Kodi-compatible file layout: NFO files, poster/fanart/banner and other artwork next to the media
- Kodi interface module: syncs edits and library operations to Kodi hosts via JSON-RPC
- Trakt.tv module: watched-state/playcount sync, lists and ratings
- Tools: Bulk Renamer, Movie List Exporter, Media File Manager, Tag Manager, media list/filter editor, mapping editors, video source mapping
- Multi-profile support, advanced settings, offline media (stub) management
- Extensible module system: add-on assemblies loaded from the `Modules` directory

## Documentation

Feature documentation lives under [`docs/help/`](docs/help/index.md). The change history is tracked in [`changes.log`](changes.log); release notes are in [`docs/RELEASE_NOTES.md`](docs/RELEASE_NOTES.md).

If you found our work useful feel free to [donate](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=VWVJCUV3KAUX2&lc=CH&item_name=Ember%2dTeam%3a%20DanCooper%2c%20m%2esavazzi%20%26%20Cocotus&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted) us a beer!

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=VWVJCUV3KAUX2&lc=CH&item_name=Ember%2dTeam%3a%20DanCooper%2c%20m%2esavazzi%20%26%20Cocotus&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted)

## Goals
To continue development of EmberMM, because its a great product, that in my opinion is the most stable and useful media manager available, I've tried all others, but yet still come back to Ember.

## Links
- Main discussion : http://forum.xbmc.org/forumdisplay.php?fid=195
- GitHub : https://github.com/DanCooper/Ember-MM-Newscraper (DanCooper is mainaining the most aligned version)

## Building

Requirements: Windows, Visual Studio (MSBuild), .NET Framework 4.8 runtime.
A .NET Framework 4.8 Developer Pack is **not** required — the reference
assemblies are restored via NuGet (`Microsoft.NETFramework.ReferenceAssemblies.net48`)
and wired in through `Directory.Build.props`.

1. Restore NuGet packages (packages.config based):

   ```
   .nuget\NuGet.exe restore "Ember Media Manager.sln"
   ```

2. Build the solution (supported platforms: x86 and x64; `Any CPU` also compiles,
   but does not ship the native per-platform dependencies):

   ```
   msbuild "Ember Media Manager.sln" -p:Configuration=Release -p:Platform=x64
   ```

   Output lands in `EmberMM - Release - x64` (resp. `... - x86` / `... - AnyCPU`).

All projects target .NET Framework 4.8. The `TVDB` library sources are vendored
under `TheTVDBApi/` (GPL-3.0, originally from `DanCooper/TheTVDBApi`).

## Project structure

- `EmberMediaManager/` — main WinForms application
- `EmberAPI/` — core library (database, scanner, module system, NFO, images, media info, settings)
- `Addons/` — add-on modules (generic tools, Kodi/Trakt interfaces, all scrapers)
- `KodiAPI/`, `Trakttv/`, `TheTVDBApi/` — API client libraries
- `BuildSetup/` — NSIS installer and build scripts
- `docs/help/` — feature documentation

## Tests

The repository contains a legacy MSTest project (`EmberAPI_Test/`). It is currently **not part of the solution** and does not build — it references a `UnitTests` project that is not in the repository. There are no executable automated tests at the moment.

## Continuous Integration / Git Hooks

The repository ships two layers of quality gates:

- **Local Git hooks** (`.githooks/`): a `pre-commit` hook that checks `.resx` localization consistency, and a `pre-push` hook that mirrors the CI security gate (`nuget restore` + NU190x vulnerability check, blocking). Activate them once per clone:

  ```
  .githooks\install-hooks.cmd    :: Windows
  ./.githooks/install-hooks.sh   # Linux/macOS (Git Bash)
  ```

- **GitHub Actions** (`.github/workflows/`): PRs against `staging` run `PR CI for Staging` (NuGet vulnerability gate + `Debug|x86` and `Release|x64` builds). Pushes to `staging` additionally create `vX.Y.Z-rc.N` pre-releases (`Pre-Release`); a successful run opens a draft promotion PR `staging` → `master` (PRs against `master` are only accepted from `staging`). Pushes to `master` trigger a back-merge PR `master` → `staging` and the `Release` workflow (semantic-release; manual `v*.*.*` tags are also supported). A weekly `Security Scan` runs every Monday 04:00 UTC.

The `pre-commit` hook needs Python 3 on `PATH`; the `pre-push` scan runs out of the box on Windows (on Linux/macOS it requires Mono, otherwise it is skipped with a warning — the server-side CI gate still applies). Full documentation: [CI/CD & Git Hooks](docs/help/ci-cd/index.md).

## License

GPL-3.0 — see `EmberMediaManager/License.txt`.

## Helping the development
Any help is more than welcome. We do suggest everyone to participate in the forum to be aligned and updated.

As the codebase is managed by several people we tried to make it easier to maintain and review. We ask everyone to try to adhere to some simple guidelines as much as you can:
- keep it simple, if complexity is needed add a comment to explain why
- avoid duplication of code, if mandatory or needed please comment
- read all the code before changing it, avoid duplication of almost identical functionalities/classes/data. In case of doubt, please ask

_(We know everyone knows and agrees on them but the more we work on the code the more we discover how those simple principles has not been applied even from us... )_

We made a major effort in reviewing the core of Ember Media Manager, the scraping process and part, to bring it to the next level. Here are major points to consider:
- IMDB id is the unique identifier for movies.
- It is INTENTIONAL to separate the scrapers in three groups (Data, Poster, Trailer). We decided that the small overhead of code in the modules manager and some duplication of code was a far minor issue than the complexity (or mess) that had evolved in the multipurpose scrapers, making it complex to fix and almost impossible to add new ones quickly enough.
- Data scrapers will be executed one after the other and will fill ONLY selected & empty fields if not locked from global properites
- Each Data scraper will have the search dialog (is a known and accepted code duplication) because there are TOO many differences between IMDB, TMDB and other so having only one dialog in main would lead to a mess.
- Image scrapers will work in parallel and will return a list of images. The image selection dialog will merge all lists and show them. The dialog will be moved at main program level as is useless to have it replicated in the scrapers
- Order in Image scrapers will only be used for automated scraping where only the first one will be invoked (to be quicker)
- All the file save-handling logic with the names etc... will be put at main program level and will happen only once.
- All image Handling (load-save-fromWEb, etc) MUST be in only in the Images class and must use the memorystream as source (already almost there in 1.3.0.12)
- Trailers should behave as images


## Contact
Please use the forum as main contact point.
