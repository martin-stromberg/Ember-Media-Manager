# Release Notes

## Important Notes Before Update

- The solution now targets .NET Framework 4.8 — the .NET Framework 4.8 runtime is required to run the application.
- The TVDB library is vendored inside the repository (`TheTVDBApi/`); a separate checkout next to the repository is no longer needed.
- NuGet restore is required before building (`.nuget\NuGet.exe restore "Ember Media Manager.sln"`); no .NET 4.8 Developer Pack is needed.

## What's New

- Complete feature documentation added under `docs/help/` (media library, movies, TV shows, movie sets, scrapers, Kodi, Trakt.tv, tools, settings, module system, database, build).
- `changes.log` backfilled with retroactive entries for all major development steps (2013–2020).
- `README.md` updated: feature overview, project structure, test status, license and documentation references.
- Solution builds self-contained again after a fresh clone (previously failed on the missing external `TheTVDBApi` project).
- All projects retargeted to .NET Framework 4.8 (previously mixed 3.5 / 4.5 / 4.8 targets).
- NuGet tooling updated to 6.14.0; package restore works again.
- Compile errors fixed (missing tag database methods, renamed XML cache call, invalid `Prefer32Bit` flags, conditional post-build copy).
- Fixed a startup crash on first run: missing `Settings.xml` no longer throws `FileNotFoundException`; default settings are used instead.
- Build instructions added to `README.md` and `docs/help/build/`.

## Wichtige Hinweise vor dem Update

- Die Solution zielt nun auf .NET Framework 4.8 — zum Ausführen der Anwendung ist die .NET Framework 4.8 Runtime erforderlich.
- Die TVDB-Bibliothek ist im Repository vendored (`TheTVDBApi/`); ein separater Checkout neben dem Repository ist nicht mehr nötig.
- Vor dem Bauen ist ein NuGet-Restore erforderlich (`.nuget\NuGet.exe restore "Ember Media Manager.sln"`); ein .NET 4.8 Developer Pack wird nicht benötigt.

## Neuerungen

- Vollständige Featuredokumentation unter `docs/help/` ergänzt (Medienbibliothek, Filme, Serien, Filmsammlungen, Scraper, Kodi, Trakt.tv, Werkzeuge, Einstellungen, Modulsystem, Datenbank, Build).
- `changes.log` um retroaktive Einträge für alle wesentlichen Entwicklungsschritte (2013–2020) ergänzt.
- `README.md` aktualisiert: Feature-Übersicht, Projektstruktur, Teststatus, Lizenz und Dokumentationsverweise.
- Die Solution ist nach einem frischen Clone wieder eigenständig baubar (zuvor scheiterte der Build am fehlenden externen `TheTVDBApi`-Projekt).
- Alle Projekte wurden auf .NET Framework 4.8 angehoben (zuvor gemischte Targets 3.5 / 4.5 / 4.8).
- NuGet-Werkzeuge auf 6.14.0 aktualisiert; der Paket-Restore funktioniert wieder.
- Kompilierfehler behoben (fehlende Tag-Datenbankmethoden, umbenannter XML-Cache-Aufruf, ungültige `Prefer32Bit`-Einstellungen, abgesichertes Post-Build-Kopieren).
- Startabsturz beim ersten Lauf behoben: Eine fehlende `Settings.xml` löst keine `FileNotFoundException` mehr aus; stattdessen werden Standardeinstellungen verwendet.
- Build-Anleitung in `README.md` und `docs/help/build/` ergänzt.
