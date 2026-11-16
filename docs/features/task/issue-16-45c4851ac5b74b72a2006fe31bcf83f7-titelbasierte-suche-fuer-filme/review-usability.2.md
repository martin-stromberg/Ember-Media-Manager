# Usability-Review

## Ergebnis

**Status:** Befunde vorhanden

## Befunde

### frmSettingsHolder_Movie.vb / frmSettingsHolder_TV.vb (IMDb-Moduleinstellungen)

- **Erreichbarkeit** — Betroffene Interaktion: „Eigenen API-Key hinterlegen" (Konfiguration `APIKey`). In den Einstellungen des **IMDb**-Scrapers erscheint ein Feld mit der Beschriftung „TMDB API Key" (`lblApiKey`, `frmSettingsHolder_Movie.vb:222` bzw. `frmSettingsHolder_TV.vb` Setup) sowie der Button „Use my own API key". Eine nicht-technische Anwenderin kennt den Dienst „TMDb" nicht und kann nicht wissen, warum das IMDb-Modul einen fremden API-Key verlangt — im Fehlerfall („The API key is invalid or missing. Check the API key in the module settings.") sucht sie in den IMDb-Einstellungen nach einem „API Key" und findet nur eine Angabe zu einem ihr unbekannten Dienst. Das Feld selbst ist zwar erreichbar und das Toggle-Muster („Use my own API key" / „Ember Media Manager Embedded API Key") ist korrekt vom TMDb-Panel übernommen, aber die Beschriftung verlangt implizites Vorwissen über die interne Umstellung der Titelsuche auf TMDb.

  Empfehlung: Beschriftung bzw. Hinweistext erweitern, damit der Zusammenhang ohne Vorwissen verständlich ist, z. B. Label „TMDB API Key (wird für die Titelsuche verwendet)" oder ein erklärender Hinweis im Panel wie „Die Titelsuche dieses Moduls nutzt die TMDb-Schnittstelle." Alternativ den Fehlertext (String 1494) konkretisieren: „Check the TMDB API key in the module settings."

## Geprüfte Interaktionen

Liste der aus der Anforderung geprüften Benutzerinteraktionen:
- Titelbasierte Filmsuche: Dialog öffnet sich, Treffer erscheinen als Klartext (Titel + Jahr) im Ergebnisbaum in „Exact Matches"/„Partial Matches", Auswahl lädt Detailvorschau, OK bestätigt → unauffällig (`dlgIMDBSearchResults_Movie.vb`, Suche über `clsScrapeIMDB.SearchMovie` via TMDb)
- Erneute Suche im Dialog über Suchfeld + „Search"-Button (freie Titel-/Jahres-Eingabe, keine Kennung nötig) → unauffällig
- Titelbasierte Seriensuche: analoger Dialog mit Trefferliste und Auswahl → unauffällig (`dlgIMDBSearchResults_TV.vb`)
- Manuelle IMDb-ID-Eingabe (`chkManual` + `txtIMDBID` + `btnVerify`): optionaler, von der Anforderung ausdrücklich beibehaltener Escape-Pfad, verständlich beschriftet („Manual IMDB Entry"/„Verify") → unauffällig
- Unterscheidbare Fehlermeldung bei Quell-Ausfall: Fehlerknoten im Ergebnisbaum „The search could not be completed: …" mit verständlichen Varianten für ungültigen API-Key, Request-Limit und Verbindungsfehler (Strings 1493–1496) — klar von „No Matches Found" unterscheidbar; danach bleiben erneute Suche und manuelle Eingabe erreichbar (`chkManual.Enabled = True`) → unauffällig
- Detailabruf schlägt fehl: ausgewählter Treffer bleibt bestätigbar, Hinweistext „The details for the selected entry could not be loaded, but the entry can still be used." (String 1497), OK aktiviert → unauffällig
- Eigenen API-Key hinterlegen (Movie- und TV-Settings): Feld vorhanden und über Toggle-Button erreichbar, eingebetteter Fallback-Key als Standard → Befund vorhanden (siehe oben: unverständliche „TMDB"-Beschriftung im IMDb-Kontext)
- Entfernte Kategorie-Checkboxen („Partial/Popular/TV Movie/Video/Short Titles"): nicht mehr sichtbar, keine verwaisten Hinweistexte (`lblInfoParsing` bezieht sich weiterhin auf `chkMPAADescription` mit `*`-Marker) → unauffällig
- Gleiche Fehlerbehandlung in den TMDb-Suchdialogen (Movie, MovieSet, TV) → unauffällig

## Geprüfte Dateien

Liste aller geprüften UI-Dateien:
- `Addons/scraper.IMDB.Data/Scraper/dlgIMDBSearchResults_Movie.vb`
- `Addons/scraper.IMDB.Data/Scraper/dlgIMDBSearchResults_TV.vb`
- `Addons/scraper.IMDB.Data/frmSettingsHolder_Movie.vb`
- `Addons/scraper.IMDB.Data/frmSettingsHolder_Movie.Designer.vb`
- `Addons/scraper.IMDB.Data/frmSettingsHolder_TV.vb`
- `Addons/scraper.IMDB.Data/frmSettingsHolder_TV.Designer.vb`
- `Addons/scraper.TMDB.Data/Scraper/dlgTMDBSearchResults_Movie.vb`
- `Addons/scraper.TMDB.Data/Scraper/dlgTMDBSearchResults_MovieSet.vb`
- `Addons/scraper.TMDB.Data/Scraper/dlgTMDBSearchResults_TV.vb`
- `EmberAPI/Translations/en-US.xml` (neue Strings 1493–1497)
