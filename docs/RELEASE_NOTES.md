# Release Notes

## Important Notes Before Update

- IMDb title search: the special result categories *Popular Titles*, *TV Movie Titles*, *Video Titles* and *Short Titles* have been removed — search hits are now only grouped into *Exact Matches* and *Partial Matches*.
- The five `Search*Titles` settings in the IMDb module are deprecated and no longer evaluated; existing entries in `AdvancedSettings.xml` remain inert (no migration required).

## What's New

- Title-based search for movies and TV shows in the IMDb data scraper works again: the title search now queries the TMDb API (TMDbLib 2.3.0) and resolves the IMDb ID of each hit.
- New `APIKey` setting in the IMDb module settings (movies and TV shows): a personal TMDb API key (v3) can be entered via *Use my own API key*; an empty field falls back to the embedded Ember API key.
- Source failures are now distinguishable from "no hits": an invalid or missing API key, a reached request limit or an unreachable source show a dedicated error entry in the *Search Results* dialog instead of *No Matches Found* — for both the IMDb and the TMDb data scraper; manual ID entry remains available as fallback.
- Failed detail lookups are tolerated: if the details of a selected search result cannot be loaded, the entry can still be confirmed and its ID is applied.
- Scraper help documentation updated and extended (`docs/help/scraper/`): reworked troubleshooting guide covering the new error messages and workarounds (manual ID entry, personal TMDb API key), plus description, user setup, technical flow, business rules and a new installation page.
- Analysis/requirements document for Issue #8 added (`docs/analysis/issue-8-titelsuche-imdb.md`): documents the broken title-based IMDb search for movies and TV shows and specifies the migration of the title search to the TMDb API.

## Wichtige Hinweise vor dem Update

- IMDb-Titelsuche: Die speziellen Ergebniskategorien *Popular Titles*, *TV Movie Titles*, *Video Titles* und *Short Titles* wurden entfernt — Treffer werden nur noch in *Exact Matches* und *Partial Matches* gruppiert.
- Die fünf `Search*Titles`-Settings im IMDb-Modul sind deprecated und werden nicht mehr ausgewertet; bestehende Einträge in `AdvancedSettings.xml` verbleiben wirkungslos (keine Migration erforderlich).

## Neuerungen

- Die titelbasierte Suche für Filme und Serien im IMDb-Daten-Scraper funktioniert wieder: Die Titelsuche fragt nun die TMDb-API ab (TMDbLib 2.3.0) und löst die IMDb-ID jedes Treffers auf.
- Neues `APIKey`-Setting in den IMDb-Moduleinstellungen (Filme und Serien): Über *Use my own API key* kann ein eigener TMDb-API-Key (v3) hinterlegt werden; ein leeres Feld fällt auf den eingebetteten Ember-API-Key zurück.
- Quell-Ausfälle sind jetzt von „keine Treffer" unterscheidbar: Ein ungültiger oder fehlender API-Key, ein erreichtes Request-Limit oder eine nicht erreichbare Quelle zeigen einen eigenen Fehlereintrag im *Search Results*-Dialog statt *No Matches Found* — im IMDb- wie im TMDb-Daten-Scraper; die manuelle ID-Eingabe bleibt als Fallback verfügbar.
- Fehlgeschlagene Detailabrufe werden toleriert: Können die Details eines gewählten Suchtreffers nicht geladen werden, lässt sich der Eintrag trotzdem bestätigen und seine ID wird übernommen.
- Scraper-Hilfedokumentation aktualisiert und erweitert (`docs/help/scraper/`): überarbeitete Troubleshooting-Anleitung zu den neuen Fehlermeldungen und Workarounds (manuelle ID-Eingabe, eigener TMDb-API-Key), dazu Beschreibung, Anwender-Einrichtung, technischer Ablauf, Business Rules und eine neue Installationsseite.
- Analyse-/Anforderungsdokument für Issue #8 ergänzt (`docs/analysis/issue-8-titelsuche-imdb.md`): dokumentiert die defekte titelbasierte IMDb-Suche für Filme und Serien und legt die Umstellung der Titelsuche auf die TMDb-API fest.
