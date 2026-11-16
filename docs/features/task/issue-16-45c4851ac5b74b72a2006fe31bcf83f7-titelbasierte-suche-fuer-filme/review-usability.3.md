# Usability-Review

## Ergebnis

**Status:** Befunde vorhanden

## Befunde

### frmSettingsHolder_Movie.vb / frmSettingsHolder_TV.vb (IMDB-Modul-Einstellungen)

- **Abweichendes Muster** — Die Anforderung verlangt das `txtApiKey`-Feld „nach Muster der TMDb-Panels". Die Referenz-Panels (`scraper.TMDB.Data/frmSettingsHolder_*.vb`) enthalten neben dem Schlüsselfeld ein Info-Symbol (`pbTMDBApiKeyInfo`), das per `Functions.Launch(My.Resources.urlAPIKey)` die TMDb-Seite öffnet, auf der man einen eigenen API-Key beantragen kann. In den neuen IMDB-Panels fehlt dieser Hinweis vollständig. Ein Laie, dem die Fehlermeldung „The API key is invalid or missing. Check the TMDB API key in the module settings." in die Einstellungen schickt, findet dort den Button „Use my own API key" und ein leeres Textfeld — aber keinerlei Hinweis, was ein „TMDB API Key" ist oder wo man ihn herbekommt. Das ist eine Sackgasse: Die geforderte Interaktion „eigenen API-Key hinterlegen" ist ohne externes Vorwissen nicht durchführbar.

  Empfehlung: Wie in den TMDb-Panels ein klickbares Info-Element (PictureBox/LinkLabel) neben `txtApiKey` ergänzen, das die TMDb-Seite zur Key-Beantragung öffnet (Ressource `urlAPIKey` analog `scraper.TMDB.Data/My Project/Resources.resx`, Aufruf über `Functions.Launch` — in `EmberAPI/clsAPICommon.vb:1556` vorhanden).

### dlgIMDBSearchResults_Movie.vb / dlgIMDBSearchResults_TV.vb (Suchdialoge)

- **Erreichbarkeit** — Kleinere Fehlbeschriftung im Fehlerfall: Wenn die Anwenderin das Häkchen „Manual IMDB Entry" setzt, während noch ein Detailabruf für einen ausgewählten Treffer läuft, kann über `ClearInfo` → `_IMDB.CancelAsync()` (Warteschleife mit `DoEvents`) das `Exception`-Ereignis des abgebrochenen/fehlgeschlagenen Workers in `SearchFailed` eintreffen. Zu diesem Zeitpunkt ist `_searchPending = False` und `chkManual.Checked = True`, also erscheint die MessageBox „Unable to retrieve movie details for the entered IMDB ID. Please check your entry and try again." — obwohl die Anwenderin noch gar keine ID eingegeben hat. Da der IMDb-Detailabruf laut Anforderung derzeit generell fehlschlägt, ist dieser Pfad kein theoretischer Randfall, sondern beim Umschalten während eines laufenden Detail-Downloads der Normalfall. Die Meldung ist für einen Laien irritierend (sie suggeriert eine Fehleingabe, die es nicht gab), blockiert den Workflow aber nicht.

  Empfehlung: In `SearchFailed` zwischen „manuelle ID-Verifizierung fehlgeschlagen" (nur wenn `btnVerify` ausgelöst hatte / `txtIMDBID` befüllt ist) und „Detailabruf zum ausgewählten Treffer fehlgeschlagen" unterscheiden und im zweiten Fall die bereits vorhandene neutrale Meldung 1497 („The details for the selected entry could not be loaded, but the entry can still be used.") verwenden — analog zum bereits implementierten Detail-Fehlerpfad für den nicht-manuellen Modus.

## Geprüfte Interaktionen

Liste der aus der Anforderung geprüften Benutzerinteraktionen:

- Titelbasierte Filmsuche: Dialog öffnet sich beim Scrapen bzw. über die Schaltfläche „Search", Treffer erscheinen als benannte Knoten „Exact Matches (n)"/„Partial Matches (n)" mit Titel und Jahr — Auswahl ohne interne Kennung möglich → unauffällig
- Titelbasierte Seriensuche: analog, Trefferliste mit Klartext-Titeln → unauffällig
- Auswahl eines Treffers und Bestätigung mit „OK": OK-Button wird nach Detail-Ladung bzw. im Detail-Fehlerpfad (Fallback mit ID des gewählten Knotens) aktiviert → unauffällig
- Manuelle IMDb-ID-Eingabe (`chkManual`/`txtIMDBID`/`btnVerify`): weiterhin vorhanden und bedienbar; Format-Prüfung und „ohne Verifizierung fortfahren"-Dialog funktionieren auch bei defektem Detailabruf → unauffällig
- Unterscheidbare Fehlermeldung bei Quell-Ausfall: eigener Knoten „The search could not be completed: {0}" statt „No Matches Found", mit laienverständlichen Texten für ungültigen Key, Rate-Limit und Verbindungsfehler; Suche/Wiederholung und manuelle Eingabe bleiben möglich → unauffällig (Ausnahme: Fehlbeschriftung bei Umschalten auf manuelle Eingabe während laufendem Detailabruf — siehe Befund)
- Eigener TMDb-API-Key in den Moduleinstellungen hinterlegen: Button „Use my own API key" entsperrt `txtApiKey`, eingebetteter Fallback-Key funktioniert ohne Eingabe, gespeicherter Key wird beim erneuten Öffnen korrekt angezeigt (Button-Zustand „Use embedded API Key") → Befund vorhanden (fehlender Hinweis, woher ein eigener Key bezogen werden kann)
- Entfernen der fünf Suchkategorien-Checkboxen (Popular/Partial/TV Movie/Video/Short Titles): aus den Settings entfernt, die entsprechenden Ergebnisgruppen im Dialog entfallen — die verbleibenden Gruppen sind verständlich beschriftet → unauffällig

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
- `EmberAPI/Translations/en-US.xml`
