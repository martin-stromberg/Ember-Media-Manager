# Release Notes

## Important Notes Before Update

- There are no special notices.

## What's New

- New troubleshooting guide for the known scraper defect (`docs/help/scraper/troubleshooting.md`): explains why the IMDb title search always shows "No Matches Found" (IMDb now answers with an AWS WAF bot challenge) and documents workarounds (manual IMDb ID entry, scraper order, own TMDb API key).
- Analysis/requirements document for Issue #8 added (`docs/analysis/issue-8-titelsuche-imdb.md`): documents the broken title-based IMDb search for movies and TV shows and specifies the planned migration of the title search to the TMDb API.
- Startup crash fixed: `SQLite.Interop.dll` is now deployed to the output directory for AnyCPU builds — the previous `DllNotFoundException` followed by a `NullReferenceException` in `Connect_MyVideos` no longer occurs.
- Fail-fast error handling in `Connect_MyVideos`: a failed database connection is now cleaned up and the real exception is rethrown instead of continuing with an invalid connection.

## Wichtige Hinweise vor dem Update

- Es gibt keine besonderen Hinweise.

## Neuerungen

- Neue Troubleshooting-Anleitung für den bekannten Scraper-Defekt (`docs/help/scraper/troubleshooting.md`): erklärt, warum die IMDb-Titelsuche immer "No Matches Found" anzeigt (IMDb antwortet inzwischen mit einer AWS-WAF-Bot-Challenge), und dokumentiert Workarounds (manuelle IMDb-ID-Eingabe, Scraper-Reihenfolge, eigener TMDb-API-Key).
- Analyse-/Anforderungsdokument für Issue #8 ergänzt (`docs/analysis/issue-8-titelsuche-imdb.md`): dokumentiert die defekte titelbasierte IMDb-Suche für Filme und Serien und legt die geplante Umstellung der Titelsuche auf die TMDb-API fest.
- Startabsturz behoben: `SQLite.Interop.dll` wird nun bei AnyCPU-Builds ins Ausgabeverzeichnis deployed — die bisherige `DllNotFoundException` mit anschließender `NullReferenceException` in `Connect_MyVideos` tritt nicht mehr auf.
- Fail-fast-Fehlerbehandlung in `Connect_MyVideos`: Bei einer fehlgeschlagenen Datenbankverbindung wird jetzt aufgeräumt und die echte Exception weitergereicht, statt mit einer ungültigen Verbindung weiterzulaufen.
