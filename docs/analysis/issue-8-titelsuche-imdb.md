# Anforderungsanalyse: Titelbasierte IMDb-Suche für Filme und Serien wiederherstellen (Issue #8)

**Kontext:** Dieses Dokument ist die angeforderte Analyse zu Issue #8. Es richtet sich an das zuständige Entwicklungsprojekt und spezifiziert die Umstellung der defekten titelbasierten Suche des Daten-Scraper-Moduls `scraper.Data.IMDB` (`Addons\scraper.IMDB.Data`, Assembly `scraper.Data.IMDB`) auf eine technisch stabile Schnittstelle — bei unverändertem Ergebnisvertrag (`SearchResults_Movie`/`SearchResults_TVShow`, Suchdialoge, `ScrapeType`-Heuristik). Es enthält ausschließlich Anforderungen und Festlegungen; die Umsetzung obliegt dem Entwicklungsprojekt. Grundlage sind `requirement.md` und `inventory.md` in diesem Ordner; alle Fundstellen wurden im Repository verifiziert.

## Problemstellung / IST-Zustand

Die titelbasierte Suche des IMDb-Daten-Scrapers liefert für Filme und Serien keine Treffer mehr — der Dialog "Search Results" zeigt stets "No Matches Found".

- `Scraper.SearchMovie` (`Addons\scraper.IMDB.Data\Scraper\clsScrapeIMDB.vb:1413–1541`) lädt per `HtmlAgilityPack.HtmlWeb` die öffentlichen IMDb-HTML-Seiten `http://www.imdb.com/find?q=…&s=tt&ttype=ft` (Z. 1425–1426, plus settingsabhängig Z. 1439, 1442) sowie `http://www.imdb.com/search/title?title=…&title_type=tv_movie|video|short&view=simple` (Z. 1430–1436) und parst die XPath-Selektoren `//table[@class="findList"]/tr[@class]/td[2]` (Z. 1452 u. a.) und `//span[@title]` (Z. 1482, 1497, 1512).
- `Scraper.SearchTVShow` (Z. 1555–1581) lädt `/search/title?title=…&title_type=tv_series&view=simple` (Z. 1559–1561) und parst `//div[@class="lister-item mode-simple"]` (Z. 1563), IMDb-ID aus `img[data-tconst]` (Z. 1568).
- IMDb liefert auf diese Endpunkte inzwischen eine AWS-WAF-Bot-Challenge (HTTP 202, Header `x-amzn-waf-action: challenge`, leerer Body — live verifiziert, siehe `requirement.md`) bzw. ein komplett umgebautes React-Frontend. Die erwarteten Markup-Strukturen existieren nicht mehr; alle `SelectNodes`-Aufrufe liefern `Nothing`, alle Ergebnislisten bleiben leer.
- Folge: `SearchResults_Movie` (Kategorien `ExactMatches`, `PopularTitles`, `PartialMatches`, `TvTitles`, `VideoTitles`, `ShortTitles`; `clsScrapeIMDB.vb:27–45`) und `SearchResults_TVShow` (`Matches`, Z. 47–55) bleiben vollständig leer; die Dialoge fügen den Knoten "No Matches Found" ein (`dlgIMDBSearchResults_Movie.vb:454`, `dlgIMDBSearchResults_TV.vb:335`). Die manuelle IMDb-ID-Eingabe (`chkManual`/`txtIMDBID`/`btnVerify`) bleibt als einziger funktionierender Pfad.
- **Keine Fehlerunterscheidung:** `SearchMovie`/`SearchTVShow` besitzen keine eigene Fehlerbehandlung — zwei Fälle sind zu unterscheiden: Liefert `HtmlWeb.Load` ein Dokument mit unverwertbarem Markup (HTTP-202-WAF-Challenge mit leerem Body, Fehlerseiten), liefern die `SelectNodes` `Nothing` und die Ergebnislisten bleiben leer — der Dialog zeigt stillschweigend "No Matches Found". Echte Lade-Exceptions (Timeout, DNS-/Netzwerkfehler) propagieren dagegen unbehandelt aus `SearchMovie`/`SearchTVShow` über `bwIMDB_DoWork` (Z. 118–138, kein Try/Catch) und werden beim Zugriff auf `e.Result` in `bwIMDB_RunWorkerCompleted` (Z. 141) erneut geworfen — das Ergebnis-Event wird nie gefeuert. Erst die nachgelagerten Methoden loggen Exceptions (`GetSearchMovieInfo`, `Catch` → `logger.Error`, Z. 959–962).
- **Gleiche Datenquelle im Detailabruf:** In `clsScrapeIMDB.vb` wurden insgesamt 19 `HtmlWeb.Load`-Aufrufe auf `imdb.com`-Endpunkte gezählt (verifizierte Zählung, siehe `inventory.md`): `/title/{id}/reference` (Z. 209, 476, 687, 892), `/episodes` (Z. 617, 642, 860), `/releaseinfo` (Z. 1160, 1354), `/parentalguide` (Z. 1206), `/plotsummary` (Z. 1269) sowie die Suchaufrufe (Z. 1425–1442, 1559). Der Detailabruf (`GetMovieInfo`, `GetTVShowInfo`, `GetTVEpisodeInfo`, `GetMovieStudios` und die `Parse*`-Methoden auf Markup der alten IMDb-Referenzansicht) ist daher vermutlich ebenfalls defekt — siehe Folgebedarfe.
- Der Aufrufpfad der Anwendung ist korrekt und nicht die Fehlerursache: `frmMain` → Kontextmenü `(Re)Scrape Movie` → `ScrapeType.SingleScrape` → `ModulesManager.ScrapeData_Movie` → `IMDB_Data.Scraper_Movie` (`IMDB_Data.vb:437–488`) → `dlgIMDBSearchResults_Movie` (Z. 473–482) → `Scraper.SearchMovieAsync` → `bwIMDB_DoWork` → `SearchMovie`.

## Befund: TMDb-Suche ebenfalls ohne Treffer

**Kundenrückmeldung (neu):** Beim Kunden sind der IMDb- **und** der TMDb-Daten-Scraper aktiviert — die Suche liefert trotzdem keine Ergebnisse, auch nicht bei allen aktivierten Scrapern. Die bestehende, prinzipiell funktionsfähige TMDb-Integration (`clsScrapeTMDB.vb`) greift im Suchpfad beim Kunden also offenbar nicht. Das Entwicklungsprojekt hat die Ursache einzugrenzen; zwei Hypothesen sind zu prüfen:

**Hypothese (a): Die TMDb-basierte Titelsuche ist selbst defekt.**

- Das Modul `scraper.TMDB.Data` nutzt `TMDbLib` **1.9.1** (`Addons\scraper.TMDB.Data\packages.config:12`, NuGet-Release 2022-01-19). Die Bibliothek wird upstream weitergepflegt (1.9.2 vom 2022-04-27, 2.x seit 2023-01, 3.0.0 vom 2026-01); die Version 1.9.2 behebt u. a. einen Deserialisierungsfehler ("An item with the same key has already been added"). Seit 1.9.1 können Endpunkt-/Payload- oder Authentifizierungsänderungen der TMDb-API v3 die alte Bibliotheksversion betreffen — zu verifizieren.
- Der eingebettete Fallback-API-Key (`TMDB_Data.vb:57`, Konstante `_strAPIKey`) kann zwischenzeitlich ungültig sein oder rate-limitiert werden; ein eigener Key ist über das `APIKey`-Setting konfigurierbar (`TMDB_Data.vb:352–353` Film, `363–366` MovieSet, `397–400` TV).
- TLS-Hinweis: Die Anwendung aktiviert beim Start TLS 1.1/1.2 global (`EmberMediaManager\ApplicationEvents.vb:45`, `ServicePointManager.SecurityProtocol Or Tls11 Or Tls12`); alle betroffenen Projekte zielen auf .NET Framework 4.8. TLS 1.2 ist damit grundsätzlich verfügbar — dennoch ist im Rahmen der Eingrenzung zu prüfen, ob die TMDb-Aufrufe tatsächlich mit TLS 1.2 erfolgen (z. B. bei abweichender Laufzeitumgebung beim Kunden).
- **Konkrete Prüfanforderung:** Feststellen, ob `clsScrapeTMDB.vb` `SearchMovie` (Z. 1362–1449, `_client.SearchMovieAsync` Z. 1372) bzw. `SearchTVShow` (Z. 1504–1560, `_client.SearchTvShowAsync` Z. 1514) aufgerufen werden und was die TMDb-API konkret antwortet (HTTP-Status, Exception in `APIResult`, `TotalResults`). Hinweis: `SearchMovie`/`SearchTVShow` werten `APIResult.Result` ohne Exception-Prüfung aus (Z. 1374, 1516) — ein API-Fehler führt dort nicht zu einer stillen leeren Trefferliste, sondern zu einer unbehandelten Exception: `Task.Result` wirft bei einem fehlerhaften Task eine `AggregateException` bzw. bei `Nothing`-Ergebnis eine `NullReferenceException` an `Movies.TotalResults`/`Shows.TotalResults`. `bwTMDB_DoWork` (Z. 186–225, kein Try/Catch) lässt die Exception durch, und `bwTMDB_RunWorkerCompleted` (Z. 228) wirft sie beim Zugriff auf `e.Result` erneut — das Ergebnis-Event wird nie gefeuert, der Anwender erhält keine unterscheidbare Rückmeldung (der Dialog bleibt ggf. im Ladezustand hängen).

**Hypothese (b): Scrape-Order-Effekt — der IMDb-Suchdialog verdrängt den TMDb-Pfad.**

Verifizierte Mechanik (`EmberAPI\clsAPIModules.vb`, `ScrapeData_Movie` Z. 915–1007; `ScrapeData_TVShow` analog ab Z. 1215):

- Der `ModulesManager` ruft alle aktivierten Daten-Scraper sequenziell in `ModuleOrder`-Reihenfolge auf (Z. 918: `OrderBy(Function(e) e.ModuleOrder)`); jedes Modul erhält `Scraper_Movie`/`Scraper_TVShow` (Z. 947).
- Bricht ein Modul ab (`ret.Cancelled`), **kehrt `ScrapeData_Movie` sofort zurück** (Z. 949) — nachfolgende Scraper werden nie aufgerufen. Ebenso beendet `ret.breakChain` die Kette (Z. 969).
- `IMDB_Data.Scraper_Movie` öffnet bei `ScrapeType.SingleScrape`/`SingleAuto` ohne vorhandene IMDb-/TMDb-ID den Dialog `dlgIMDBSearchResults_Movie` (`IMDB_Data.vb:471–484`). Zeigt der Dialog keine Treffer, bleibt `OK_Button` deaktiviert (er wird erst nach geladenem Detail-Info aktiviert, `dlgIMDBSearchResults_Movie.vb:288`) — der Anwender kann nur **abbrechen** oder manuell eine ID eingeben. Der Abbruch liefert `Cancelled = True` (`IMDB_Data.vb:480`) → **die gesamte Scrape-Kette wird abgebrochen, bevor `TMDB_Data.Scraper_Movie` (mit `dlgTMDBSearchResults_Movie`, `TMDB_Data.vb:680–692`) überhaupt erreicht wird**, sofern `IMDB_Data` in der Scrape Order vor `TMDB_Data` liegt. Umgekehrt gilt dasselbe für den TMDb-Dialog bei vorangeordnetem TMDb-Scraper.
- Nach erfolgreicher Auswahl setzt das Modul `ScrapeModifiers.DoSearch = False` (`IMDB_Data.vb:477`, `TMDB_Data.vb:686`) für die Folge-Scraper — im Defektfall ohne Treffer entfällt dieser Pfad.
- **Konkrete Prüfanforderung:** Anhand der Kundenkonfiguration (`AdvancedSettings`, `EmberModules`-Reihenfolge) klären, welcher Daten-Scraper in der `ModuleOrder` zuerst läuft und ob der zweite Suchdialog überhaupt erreicht wird (Logeinträge `[ModulesManager] [ScrapeData_Movie] [Using] {Modulname}`, `clsAPIModules.vb:944`).

**Festlegung:** Die TMDb-API bleibt die festgelegte Zielschnittstelle (siehe unten), ist aber nur tragfähig, wenn die TMDb-Integration funktioniert bzw. vorher repariert wird. Der Befund der Eingrenzung ist im Entwicklungsprojekt zu dokumentieren; bei defekter TMDb-Integration ist die Ursache zu beheben, bevor die TMDb-API als Suchbasis für das IMDb-Modul übernommen wird.

## Funktionale Anforderungen

1. **Suche umstellen:** `Scraper.SearchMovie` und `Scraper.SearchTVShow` im Modul `scraper.Data.IMDB` sind auf die festgelegte Schnittstelle (TMDb-API, primär) umzustellen. Die IMDb-HTML-Endpunkte `/find` und `/search/title` dürfen für die Titelsuche nicht mehr verwendet werden. Vorgesehener Zielablauf Film: `SearchMovie` fragt `TMDbClient.SearchMovieAsync` ab und löst die IMDb-ID je Treffer über `FindAsync(FindExternalSource.Imdb)` auf; Treffer werden auf `MediaContainers.Movie` (`Title`, `Year`, `UniqueIDs.IMDbId`, `Lev` via `StringUtils.ComputeLevenshtein`) gemappt und in `SearchResults_Movie.ExactMatches`/`PartialMatches` eingesortiert. Serie analog über `SearchTvShowAsync` + `FindAsync` auf `SearchResults_TVShow.Matches`. `SearchResultsDownloaded_Movie`/`_TV` befüllen die Dialoge wie bisher; `IMDB_Data.Scraper_Movie`/`Scraper_TV` und die Dialoge bleiben unverändert.
2. **Ergebnisvertrag beibehalten:** `SearchResults_Movie`/`SearchResults_TVShow` und die Auswertelogik in `GetSearchMovieInfo` (Z. 902–963) / `GetSearchTVShowInfo` (Z. 978 ff.) — Levenshtein-Schwelle `Lev <= 5`, `FindYear`-Jahresabgleich, `ScrapeType`-Gestaltung (Ask → Dialog, Skip → nur eindeutiger Exact-Match, Auto → Heuristik) — laufen unverändert weiter, damit `dlgIMDBSearchResults_Movie`/`_TV` und die Auto-Match-Heuristik ohne Anpassung funktionieren.
3. **Filme und Serien gemeinsam:** `SearchMovie` und `SearchTVShow` teilen denselben Mechanismus und sind identisch betroffen; beide werden gemeinsam umgesetzt und gemeinsam abgenommen (festgelegt).
4. **Quell-Ausfälle erkennbar machen:** Abruffehler, HTTP-Fehlercodes, Rate-Limits und ungültige/fehlende API-Keys sind zu erkennen, via `logger.Error` zu protokollieren (Muster: `GetSearchMovieInfo` Z. 959–962) und dem Anwender als von "keine Treffer" unterscheidbare Meldung anzuzeigen — nicht mehr stillschweigend "No Matches Found" (festgelegt). Die konkrete UI-Form bleibt dem Entwicklungsprojekt überlassen.

## Schnittstellenentscheidung (festgelegt)

**Primär: TMDb-API** — *unter dem Vorbehalt des obigen TMDb-Befunds.*

- Begründung: Infrastruktur und Referenzimplementierung existieren im Schwestermodul `scraper.TMDB.Data`: `TMDbLib` 1.9.1 (`packages.config:12`), `TMDbClient`-Erzeugung in `CreateAPI` (`clsScrapeTMDB.vb:166, 172` inkl. `GetConfigAsync`, `MaxRetryCount`, Englisch-Fallback-Client `_clientE`), Titelsuche via `SearchMovieAsync` (Z. 1372) / `SearchTvShowAsync` (Z. 1514), IMDb-ID-Mapping via `FindAsync(FindExternalSource.Imdb)` (`GetTMDBbyIMDB`, Z. 1089–1104). Offizieller API-Vertrag, eingebetteter Fallback-Key (`TMDB_Data.vb:57`), konfigurierbares `APIKey`-Setting als Muster (`TMDB_Data.vb:352–353, 397–400`).
- Aufwand: gering bis mittel — Client-Code ist modulintern (`Private _client`, `clsScrapeTMDB.vb:100`), keine projektübergreifende Shared-Komponente vorhanden → Neuinstanz im IMDb-Modul oder bewusste Code-Duplikation (als Anforderung zu entscheiden; ein gekapselter API-Gateway für die Titelsuche ist zulässig). NuGet-Verweis auf `TMDbLib` für `scraper.IMDB.Data` neu hinzuzufügen (dort bisher nur `HtmlAgilityPack` 1.11.42 + `NLog` 4.7.14, `scraper.IMDB.Data\packages.config`).
- Risiken: siehe TMDb-Befund — veraltete `TMDbLib` 1.9.1 (ggf. aktuellere Version erforderlich), eingebetteter Fallback-Key ggf. ungültig, TMDb-Nutzungsbedingungen/Rate-Limits.
- Nutzungsaspekte: offizielle TMDb-API v3, API-Key-Pflicht (Fallback vorhanden).

**Alternativ: OMDb-API.**

- Die bereits referenzierte Bibliothek `MovieCollection.OpenMovieDatabase` 3.0.1 (`scraper.Data.OMDb\packages.config:3`) stellt eine Titelsuche bereit: `SearchMoviesAsync` (OMDb-`?s=`-) und `SearchMovieAsync` (`?t=`-Endpunkt) sind in der Bibliothek vorhanden (verifiziert in der Assembly-Dokumentation `packages\MovieCollection.OpenMovieDatabase.3.0.1\lib\*\MovieCollection.OpenMovieDatabase.xml`); OMDb liefert `imdbID` direkt in den Suchergebnissen.
- Das Modul `scraper.Data.OMDb` nutzt jedoch nur `SearchMovieByImdbIdAsync` (`clsScrapeOMDb.vb:84`, `GetRatingsByImbId`) — eine titelbasierte Suche ist dort **nicht** implementiert → Neuimplementierung im IMDb-Modul erforderlich.
- Aufwand: mittel; zusätzlich Pflicht-API-Key ohne eingebetteten Fallback (`CreateAPI` bricht ohne Key ab, `clsScrapeOMDb.vb:53–70`) → Konfigurations-Anforderung (`APIKey`-Setting, Muster wie `TMDB_Data`).
- Risiken/Nutzungsaspekte: OMDb-Key-Pflicht beim Anwender, Rate-Limits des gewählten Key-Tiers, Fehlerfeld `Response=False` in Antworten auszuwerten.

**Fallback (nur dokumentiert): IMDb-interne Endpunkte** (z. B. Suggestion-JSON `v*.sg.media-imdb.com`, GraphQL).

- Kein API-Key nötig, aber undokumentiert, technisch fragil und rechtlich unklar — nur als letzte Option.

## Ergebniskategorien und Settings (festgelegt)

- API-Treffer werden auf `ExactMatches`/`PartialMatches` (Film) bzw. `Matches` (Serie) verteilt; die Spezialkategorien `PopularTitles`, `TvTitles`, `VideoTitles`, `ShortTitles` entfallen — eine künstliche Verteilung auf sechs Kategorien wäre semantisch falsch. `dlgIMDBSearchResults_Movie` rendert die Kategorien, funktioniert aber auch mit teilweise leeren Listen; die Auto-Match-Heuristik arbeitet primär auf `ExactMatches`.
- Die fünf Settings `SearchPartialTitles`, `SearchPopularTitles`, `SearchTvTitles`, `SearchVideoTitles`, `SearchShortTitles` (`IMDB_Data.LoadSettings_Movie`, Z. 255–259; Defaults: Partial/Popular `True`, Tv/Video/Short `False`; UI `frmSettingsHolder_Movie`) werden **deprecat** — bei API-basierter Suche existieren die IMDb-Ergebnisbereiche nicht mehr. Die Anpassung der Settings-UI (Entfernen/Ausblenden der Optionen) ist als Anforderung zu benennen.
- Neuer Eintrag (vom Entwicklungsprojekt): `APIKey` im IMDb-Modul (`AdvancedSettings` + `txtApiKey` im Settings-Panel), Typ `String`, Standardwert = eingebetteter Fallback-Key; Muster exakt wie `TMDB_Data.vb:352–353, 397–400`. Validierung als Anforderung: leer/ungültig → Fallback-Key bzw. klare Fehlermeldung; API-Antworten validieren (`Response=False`/Fehlerfeld bei OMDb, Exception/leeres Ergebnis bei TMDbLib).

## Fehlerbehandlung und Logging (festgelegt)

- Abruffehler, HTTP-Fehlercodes, Rate-Limits und ungültige/fehlende API-Keys sind zu erkennen (bisher: `SearchMovie`/`SearchTVShow` ohne Try/Catch — unverwertbare Antworten enden still in "No Matches Found", Lade-Exceptions propagieren unbehandelt, siehe IST-Zustand).
- Fehler sind via `logger.Error` zu protokollieren (Muster: `GetSearchMovieInfo` Z. 959–962).
- Dem Anwender ist eine von "keine Treffer" unterscheidbare Fehlermeldung im Dialog anzuzeigen (festgelegt; konkrete UI-Form frei).

## Umfang und Abgrenzung (festgelegt)

- **Im Scope, zuerst umzusetzen:** die Titelsuche für Filme **und** Serien gemeinsam (`SearchMovie`, `SearchTVShow` samt Dialog-Befüllung und Heuristik-Vertrag); gemeinsame Abnahme.
- **Außerhalb des Scopes:** die Erneuerung des Detailabrufs (`/reference`, `/episodes`, `/releaseinfo`, `/parentalguide`, `/plotsummary`) ist ein größerer Umbau und blockiert das Akzeptanzkriterium nicht — als separater Folgebedarf dokumentiert (siehe unten).
- **Keine Änderungen** an `Enums.ScrapeType`, Scrape Order, `ScrapeModifiers` und den Such-Dialogen — sofern der Ergebnisvertrag eingehalten wird.

## Voraussetzungen für die Implementierung

- NuGet-Verweis auf `TMDbLib` für `scraper.IMDB.Data` (derzeit nicht vorhanden; `scraper.IMDB.Data\packages.config` enthält nur `HtmlAgilityPack` 1.11.42 und `NLog` 4.7.14). Die zu wählende Version hängt vom TMDb-Befund ab — ggf. ist eine aktuellere Version als 1.9.1 erforderlich (Upstream-Stand: 1.9.2/2.x/3.x).
- Alternativ bei OMDb-Option: NuGet-Verweis `MovieCollection.OpenMovieDatabase` (im Repo bereits als 3.0.1 vorhanden).
- Ggf. neues `APIKey`-Setting im IMDb-Modul (siehe oben).
- `TMDbLib`-Client-Code ist modulintern (`Private _client`, `clsScrapeTMDB.vb:100`); keine Shared-Komponente vorhanden → Neuinstanz oder gekapselte Wiederverwendung im IMDb-Modul als Anforderung zu entscheiden.

## Akzeptanzkriterien

- Beim (Re)Scrape der Referenzfilme zeigt der "Search Results"-Dialog mindestens je einen Treffer mit korrekter IMDb-ID: **"28 Days Later" → tt0289043**, **"28 Weeks Later" → tt0463854**, **"28 Years Later" → tt10548174**.
- Die Seriensuche liefert analog Treffer mit korrekter IMDb-ID für bekannte Serientitel.
- Film- und Seriensuche werden gemeinsam abgenommen.
- Die manuelle IMDb-ID-Eingabe (`chkManual`/`txtIMDBID`/`btnVerify`) bleibt funktionsfähig.
- Bei nicht erreichbarer Datenquelle erscheint eine unterscheidbare Fehlermeldung statt "No Matches Found".

## Annahmen und Folgebedarfe

- **Folgebedarf Detailabruf:** Die Detailendpunkte (`/reference`, `/episodes`, `/releaseinfo`, `/parentalguide`, `/plotsummary`) und die zugehörigen `Parse*`-Methoden sind vermutlich ebenfalls defekt (gleiche Datenquelle, 19 `HtmlWeb.Load`-Aufrufe auf `imdb.com` in `clsScrapeIMDB.vb`). Ohne Detailabruf-Fix bleibt das Scraping auch nach erfolgreicher ID-Zuordnung inhaltlich wirkungslos — als separater Folgebedarf zu bewerten.
- **Vorbedingung Schnittstellenwahl:** Die TMDb-Fehlereingrenzung (Befund oben) ist Vorbedingung der Umstellung auf die TMDb-API; ihr Ergebnis ist zu dokumentieren.
- **Nebenbefund (optional):** Die Interface-Methode `GetTMDbIdByIMDbId` des IMDb-Moduls ist ein leerer Stub (`IMDB_Data.vb:427–429`) — im Zuge der TMDb-Anbindung könnte sie sinnvoll implementiert werden (kein Bestandteil dieser Anforderung).
- **Annahme Detailabruf-Defekt:** Der Defekt der Detailpfade ist durch die Live-Endpoint-Prüfung gestützt, aber nicht per UI verifiziert.
- **Hinweis:** Weitere HTML-Scraping-Module mit potenziell gleichem Risiko (`scraper.OFDB.Data`, `scraper.MoviepilotDE.Data`, `scraper.EmberCore.XML`) sind nicht Teil dieser Anforderung.
