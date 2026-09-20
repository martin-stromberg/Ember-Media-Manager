# Übersetzte Anforderung: Titelbasierte IMDb-Suche für Filme und Serien wiederherstellen (Issue #8)

## Fachliche Zusammenfassung

Die titelbasierte Suche des Daten-Scrapers `IMDB_Data` (Assembly `scraper.Data.IMDB`, Projekt `Addons\scraper.IMDB.Data`) liefert für Filme und TV-Serien keine Treffer mehr — der Dialog "Search Results" zeigt stets "No Matches Found", sodass die IMDb-ID manuell eingegeben werden muss. Die Ursache liegt in der vom Scraper genutzten Datenquelle, nicht im Anwendungsablauf: `Scraper.SearchMovie` und `Scraper.SearchTVShow` parsen per `HtmlAgilityPack.HtmlWeb` die öffentlichen IMDb-HTML-Seiten `/find` und `/search/title`. IMDb liefert auf diese Endpunkte inzwischen eine AWS-WAF-Bot-Challenge (HTTP 202, Header `x-amzn-waf-action: challenge`, leerer Body — live verifiziert) bzw. ein komplett umgebautes React-Frontend; die vom Scraper erwarteten Markup-Strukturen (`findList`-Tabelle, `lister-item`-Divs, `span[@title]`) existieren nicht mehr, alle `SelectNodes`-Aufrufe liefern daher `Nothing` und die Ergebnislisten bleiben leer. Die Entwicklungsanforderung an das zuständige Projekt lautet: Die Titelsuche des IMDb-Daten-Scrapers für Filme und Serien ist auf eine technisch stabile Schnittstelle umzustellen, sodass der Suchdialog wieder Treffer mit IMDb-IDs anzeigt (Referenzfälle: "28 Days Later" → tt0289043, "28 Weeks Later" → tt0463854, "28 Years Later" → tt10548174).

## Betroffene Klassen und Komponenten

### Fehlerhafte Komponente (primär zu beheben)

- `Addons\scraper.IMDB.Data\Scraper\clsScrapeIMDB.vb` — Klasse `Scraper`:
  - `SearchMovie(ByVal title, ByVal year)` (Z. 1413–1541): lädt `http://www.imdb.com/find?q=…&s=tt&ttype=ft` (Z. 1425–1426, 1439, 1442) sowie `http://www.imdb.com/search/title?title=…&title_type=tv_movie|video|short&view=simple` (Z. 1430–1436). Die XPath-Selektoren `//table[@class="findList"]/tr[@class]/td[2]` (Z. 1452, 1467, 1527) und `//span[@title]` (Z. 1482, 1497, 1512) finden im aktuellen IMDb-Markup keine Knoten mehr.
  - `SearchTVShow(ByVal title)` (Z. 1555–1581): lädt `/search/title?title=…&title_type=tv_series&view=simple`, XPath `//div[@class="lister-item mode-simple"]` — identisch betroffen.
  - `SearchResults_Movie` (Z. 27–45) und `SearchResults_TVShow` (Z. 47–55): Ergebniscontainer mit Kategorien `ExactMatches`, `PopularTitles`, `PartialMatches`, `TvTitles`, `VideoTitles`, `ShortTitles` — bleiben vollständig leer, worauf der Dialog den Knoten "No Matches Found" einfügt (`dlgIMDBSearchResults_Movie.vb:454`, `dlgIMDBSearchResults_TV.vb:335`).
- `Addons\scraper.IMDB.Data\IMDB_Data.vb` — `Scraper_Movie` (Z. 437–488) öffnet bei `ScrapeType.SingleScrape`/`SingleAuto` ohne vorhandene IMDb-/TMDb-ID den Dialog `dlgIMDBSearchResults_Movie` (Z. 473–482); `Scraper_TV` (Z. 496–550) analog mit `dlgIMDBSearchResults_TV`. Der Aufrufpfad selbst ist korrekt und nicht die Fehlerursache.
- Aufrufkette der Anwendung (nur Kontext, keine Änderung): `EmberMediaManager\frmMain.vb` → Kontextmenü `(Re)Scrape Movie` (`cmnuMovieScrape`, String-ID 163) → `ScrapeType.SingleScrape` → `ModulesManager` → `IMDB_Data.Scraper_Movie` → `Scraper.SearchMovieAsync` → `bwIMDB_DoWork` → `SearchMovie`.

### Sekundär betroffen — gleiche Datenquelle, vermutlich ebenfalls defekt

Der Detailabruf des IMDb-Moduls nutzt dieselben abgeschalteten bzw. WAF-geschützten IMDb-HTML-Endpunkte (Annahme, durch Live-Test der Endpoint-Antworten gestützt, nicht per UI verifiziert):

- `GetMovieInfo` (Z. 209: `/title/{id}/reference`), `GetTVShowInfo` (Z. 687), `GetTVEpisodeInfo` (Z. 476, 617, 642, 860: `/title/{id}/episodes`), `GetMovieStudios` (Z. 892: `/reference`), Releaseinfo-Parsing (Z. 1160, 1354: `/releaseinfo`), Zertifizierungen (Z. 1206: `/parentalguide`), Plot-Fallback (Z. 1269: `/plotsummary`). Alle `Parse*`-Methoden (Z. 65 `REGEX_Certifications`, `ipl-zebra-list__*`-Selektoren u. a.) setzen auf Markup der alten IMDb-Referenzansicht, die IMDb abgeschaltet hat. Konsequenz (Annahme): Auch nach manueller IMDb-ID-Eingabe werden keine oder nur fragmentarische Metadaten geladen — Umfang ist in den offenen Fragen zu klären.

### Nicht betroffen / als Referenz nutzbar (API-basiert)

- `Addons\scraper.TMDB.Data` — `clsScrapeTMDB.vb`: `SearchMovie` über die offizielle TMDb-API via `TMDbLib` (`_client.SearchMovieAsync`, Z. 1362–1449); Auflösung IMDb-ID ↔ TMDb-ID über `FindAsync(FindExternalSource.Imdb)` (Z. 1092 ff.). Fallback-API-Key ist eingebettet (`TMDB_Data.vb:57`), eigener Key konfigurierbar (`APIKey`-Einstellung, Z. 352–353).
- `Addons\scraper.Data.OMDb` — OMDb-API liefert Suchergebnisse inkl. `imdbID` direkt (separates Modul, als Schnittstellen-Referenz verwendbar).
- UI-Dialoge `dlgIMDBSearchResults_Movie` / `dlgIMDBSearchResults_TV` — können unverändert weiterverwendet werden, sofern `SearchResults_Movie`/`SearchResults_TVShow` wieder befüllt werden; manuelle IMDb-ID-Eingabe (`chkManual`/`txtIMDBID`/`btnVerify`) bleibt bestehen.
- Weitere HTML-Scraping-Module mit potenziell gleichem Risiko (nicht Teil dieser Anforderung): `scraper.OFDB.Data`, `scraper.MoviepilotDE.Data`, `scraper.EmberCore.XML`.

## Implementierungsansatz

Die Kundenanforderung sieht eine Analyse vor; die abgeleitete Anforderungsbeschreibung für das zuständige Entwicklungsprojekt lautet:

1. **Suche umstellen**: `Scraper.SearchMovie` und `Scraper.SearchTVShow` im Modul `scraper.Data.IMDB` dürfen die IMDb-HTML-Seiten `/find` und `/search/title` nicht mehr verwenden. Stattdessen ist eine stabile Schnittstelle zu nutzen. Optionen (Präferenz = Annahme, zu entscheiden):
   - **TMDb-API**: Titelsuche via `TMDbClient.SearchMovieAsync` bzw. `SearchTVShowAsync`, anschließendes Mapping auf IMDb-IDs über `FindAsync(FindExternalSource.Imdb)`/`external_ids`. Infrastruktur existiert bereits im Schwestermodul `scraper.TMDB.Data` — Wiederverwendung oder Auslagerung gemeinsamen Codes prüfen.
   - **OMDb-API**: `?s=`/`?t=`-Endpunkte liefern `imdbID`; benötigt einen API-Key (Konfiguration analog `TMDB API Key` nötig).
   - **IMDb-interne Endpunkte** (z. B. Suggestion-JSON `v*.sg.media-imdb.com`, GraphQL): undokumentiert, nur als Fallback.
2. **Ergebnisvertrag beibehalten**: `SearchResults_Movie`/`SearchResults_TVShow` und die Auswertelogik in `GetSearchMovieInfo`/`GetSearchTVShowInfo` (Levenshtein-Schwelle `Lev <= 5`, `FindYear`-Jahresabgleich, `ScrapeType`-Gestaltung Auto/Ask/Skip) sollen weiterlaufen — API-Ergebnisse sind auf die bisherigen Kategorien zu mappen (z. B. `ExactMatches`/`PartialMatches`), damit `dlgIMDBSearchResults_Movie`/`_TV` und die Auto-Match-Heuristik unverändert funktionieren.
3. **Fehlerbehandlung (Annahme)**: Quell-Ausfälle (HTTP-Fehler, WAF-Challenge, Rate-Limits) sollen erkannt und geloggt werden, damit "Quelle nicht erreichbar" von "keine Treffer" unterscheidbar bleibt — aktuell führt jeder Abruffehler stillschweigend zu "No Matches Found".
4. **Detailabruf separat bewerten**: Da `/reference` und die Unterseiten ebenfalls nicht mehr verfügbar sind, ist zu prüfen, ob das gesamte Modul (Suche + Details) oder zunächst nur die Suche erneuert wird. Ohne Detailabruf-Fix bleibt das Scraping auch nach erfolgreicher ID-Zuordnung inhaltlich wirkungslos.
5. **Akzeptanzkriterium**: Beim (Re)Scrape der drei Referenzfilme zeigt der "Search Results"-Dialog mindestens je einen Treffer mit korrekter IMDb-ID (tt0289043, tt0463854, tt10548174); die Seriensuche liefert analog Treffer für bekannte Serientitel.

## Konfiguration

- Die bestehenden Modul-Einstellungen `SearchPartialTitles`, `SearchPopularTitles`, `SearchTvTitles`, `SearchVideoTitles`, `SearchShortTitles` (`IMDB_Data.LoadSettings_Movie`, Z. 255–259; UI `frmSettingsHolder_Movie`) steuern bisher, welche IMDb-Ergebnisbereiche zusätzlich abgefragt werden. Bei API-basierter Suche existieren diese Bereiche nicht mehr — Entscheidung erforderlich, ob die Optionen entfallen oder auf Ergebnisfilterung gemappt werden (siehe offene Fragen).
- Keine Änderungen an `Enums.ScrapeType`, Scrape Order, `ScrapeModifiers` oder den Such-Dialogen erforderlich — Annahme, solange der Ergebnisvertrag (Punkt 2) eingehalten wird.
- Falls OMDb gewählt wird: neuer API-Key-Eintrag im IMDb-Modul-Settings-Panel (`AdvancedSettings`, Muster wie `APIKey` in `TMDB_Data`).

## Offene Fragen

1. **Aktiver Scraper beim Kunden**: Der beschriebene Dialog ("Search Results", manuelle IMDb-ID) passt primär auf `dlgIMDBSearchResults_Movie` des `IMDB_Data`-Moduls; `dlgTMDBSearchResults_Movie` zeigt jedoch denselben Titel und akzeptiert tt-IDs im Feld "Manual TMDB Entry". Welcher Daten-Scraper ist aktiviert bzw. führt die Scrape Order an? Zu verifizieren anhand der `AdvancedSettings`/Modulkonfiguration der Kundeninstallation.
2. **Umfang des Fixes**: Nur die Suche oder das komplette IMDb-Modul inkl. Detailabrufen (`/reference`, `/releaseinfo`, `/plotsummary`, `/parentalguide`, `/episodes`) erneuern? Die Analyse legt nahe, dass auch die Detailpfade defekt sind — andernfalls wäre nach manueller ID-Eingabe vollständiges Metadaten-Scraping möglich, was der Kunde nicht bestätigt.
3. **Ziel-Schnittstelle**: offizielle APIs (TMDb, OMDb — Nutzungsbedingungen/API-Key-Pflicht) vs. undokumentierte IMDb-Endpunkte (kein Key, aber rechtlich/technisch fragil)? Präferenz des zuständigen Projekts klären.
4. **Mapping der Ergebniskategorien**: Entfallen `PartialMatches`/`PopularTitles`/`TvTitles`/`VideoTitles`/`ShortTitles` zugunsten einer einheitlichen Trefferliste, oder werden API-Ergebnisse künstlich auf die Kategorien verteilt? Betrifft Settings-UI und `GetSearchMovieInfo`-Heuristik.
5. **Fehlerkommunikation**: Soll bei nicht erreichbarer Datenquelle eine explizite Fehlermeldung statt "No Matches Found" erscheinen?
6. **Seriensuche**: `SearchTVShow`/`dlgIMDBSearchResults_TV` ist identisch betroffen — wird der Fix für Filme und Serien gemeinsam oder getrennt abgenommen?
