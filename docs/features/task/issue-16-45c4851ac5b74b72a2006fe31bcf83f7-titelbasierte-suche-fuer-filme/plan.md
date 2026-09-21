# Umsetzungsplan: Titelbasierte Suche für Filme und Serien auf stabile Schnittstelle umstellen (Issue #16)

## Übersicht

Die titelbasierte Suche des Moduls `scraper.Data.IMDB` (`Addons\scraper.IMDB.Data`) wird von den defekten IMDb-HTML-Endpunkten (`imdb.com/find`, `imdb.com/search/title`) auf die TMDb-API (`TMDbLib`, Referenzimplementierung in `Addons\scraper.TMDB.Data`) umgestellt. Vorbedingung ist die Eingrenzung und Behebung des TMDb-Befunds (warum liefert beim Kunden auch der TMDb-Scraper keine Treffer). `TMDbLib` wird in beiden Modulen synchron auf **2.3.0** angehoben (aktuellste net45-kompatible stabile Version; 3.0.0 unterstützt nur net8.0/net10.0). Der Ergebnisvertrag (`SearchResults_Movie`/`SearchResults_TVShow`, Suchdialoge, `GetSearchMovieInfo`/`GetSearchTVShowInfo`-Heuristik) bleibt unverändert; Quell-Ausfälle werden als von „No Matches Found" unterscheidbare Fehlermeldung angezeigt.

## Designentscheidungen

| Komponente / Bereich | Gewählter Ansatz | Begründung |
|----------------------|-----------------|------------|
| `TMDbClient`-Bereitstellung im IMDb-Modul | Neue modulinterne Instanz in `Scraper` (`clsScrapeIMDB.vb`), lazy per `GetClient()`/`EnsureClient` nach dem `CreateAPI`-Muster aus `clsScrapeTMDB.vb:162–184` (`New TMDbClient(key)`, `GetConfigAsync`, `MaxRetryCount = 2`) | `_client` in `clsScrapeTMDB.vb:100` ist `Private`; es existiert keine projektübergreifende Shared-Komponente. Ein gemeinsamer API-Gateway in `EmberAPI` würde Modulgrenzen aufbrechen und ist für zwei Verwender überdimensioniert — bewusste, kleine Duplikation des Initialisierungsmusters (vom Requirement ausdrücklich zugelassen). `Scraper` wird pro Scrape/Dialog instanziiert (`IMDB_Data.vb:444, 503`), daher lazy beim ersten Suchaufruf, nicht im Konstruktor. |
| IMDb-ID-Auflösung je Treffer (TMDb → IMDb) | `TMDbClient.GetMovieExternalIdsAsync(tmdbId)` → `ExternalIdsMovie.ImdbId` (Film) bzw. `GetTvShowExternalIdsAsync(tmdbId)` → `ExternalIdsTvShow.ImdbId` (Serie) | Beide Methoden sind in `TMDbLib` 1.9.1 und 2.3.0 vorhanden (verifiziert in `packages\TMDbLib.1.9.1\lib\*\TMDbLib.xml` sowie per Reflexion an der 2.3.0-net45-Assembly: `GetMovieExternalIdsAsync(Int32)` → `ExternalIdsMovie.ImdbId`, `GetTvShowExternalIdsAsync(Int32)` → `ExternalIdsTvShow.ImdbId`). Live-Verifikation der API v3: `GET /3/movie/170/external_ids` liefert `imdb_id: "tt0289043"`. `FindAsync(FindExternalSource.Imdb)` löst nur die Gegenrichtung (IMDb → TMDb) auf und ist ungeeignet — klärt offene Frage 2 der Anforderung. Leichtgewichtiger als `GetMovieAsync`/`GetTvShowAsync` mit `ExternalIds`-Flag (kleinere Payload, nur IDs). |
| `TMDbLib`-Version | **2.3.0** — synchron in beiden Modulen (Neuverweis in `scraper.IMDB.Data`, Upgrade 1.9.1 → 2.3.0 in `scraper.TMDB.Data`) | Anwender-Entscheidung: direkt auf die aktuelle stabile NuGet-Version. Verifikation gegen NuGet-Metadaten und Assembly-Inspektion: Die absolute Neueste 3.0.0 (2026-01) liefert nur `net8.0`/`net10.0` und ist für `TargetFrameworkVersion v4.8` **nicht verwendbar** → 2.3.0 (2025-09) ist die aktuellste net45-kompatible Version (AssemblyVersion `2.0.0.0`). Alle vom TMDb-Modul genutzten Member sind in 2.3.0 signaturkompatibel vorhanden (per Reflexion verifiziert): `TMDbClient(apiKey, useSsl:=True, baseUrl, serializer, proxy)`, `GetConfigAsync`, `MaxRetryCount`, `DefaultLanguage`, `Config.Images.BaseUrl`, `SearchMovieAsync(query, page, includeAdult, year)`, `SearchTvShowAsync(query, page, includeAdult, firstAirDateYear)`, `SearchCollectionAsync(query, page)`, `GetMovieAsync`/`GetTvShowAsync`/`GetTvSeasonAsync`/`GetTvEpisodeAsync`/`GetCollectionAsync` inkl. aller genutzten `*Methods`-Enum-Member, `FindAsync(FindExternalSource.Imdb/.TvDb)` → `FindContainer.{MovieResults,TvResults}`, `GetMovieExternalIdsAsync`/`GetTvShowExternalIdsAsync` → `ExternalIdsMovie.ImdbId`/`ExternalIdsTvShow.ImdbId`, `SearchContainer(Of T).{Results,TotalPages,TotalResults}`, `SearchMovie.{Title,OriginalTitle,ReleaseDate,Overview,PosterPath,Id}`, `SearchTv.{Name,OriginalName,FirstAirDate,Id}`, `Movie.{ImdbId,Credits,Videos,Releases}`, `TvShow.{ExternalIds,ContentRatings}`, `TvSeason`/`TvEpisode.ExternalIds`, `Collection.Parts`. Fehlersemantik identisch zu 1.9.1: 401 → `UnauthorizedAccessException` (immer), 404 → `NotFoundException` nur bei `ThrowApiExceptions = True` (Default `False` → `Nothing`-Ergebnis), Rate-Limit → `RequestLimitExceededException`, sonstige HTTP-Fehler → `GeneralHttpException`. Transitiv-Abhängigkeiten unverändert: `Newtonsoft.Json` ≥ 13.0.3 (bereits vorhanden), `System.Net.Http` ≥ 4.3.4. |
| Fehlertransport zum Dialog | `e.Error`-/`e.Cancelled`-Prüfung in `bwIMDB_RunWorkerCompleted` (`clsScrapeIMDB.vb:140–158`) + Auslösen des bereits deklarierten, bisher nie gefeuerten `Public Event Exception(ex)` (`clsScrapeIMDB.vb:90`) | Nutzt vorhandene Infrastruktur ohne Änderung am Ergebnisvertrag (`SearchResults_*` bleiben unangetastet) und deckt auch Fehler der `SearchDetails_*`-Worker-Pfade ab. Alternative `ErrorMessage`-Feld im Ergebniscontainer verworfen (Vertragsänderung, deckt Detailabruf-Fehler nicht ab). |
| UI-Form der Fehlermeldung | Eigener, unterscheidbarer Knoten im `tvResults`-Baum (statt des „No Matches Found"-Knotens), plus `pnlLoading.Visible = False`, `chkManual.Enabled = True` | Bleibt im etablierten Dialogmuster; die manuelle IMDb-ID-Eingabe bleibt als Ausweichpfad nutzbar; nicht modal blockierend wie eine MessageBox. Text über `Master.eLang.GetString` mit englischem Fallback + neuem Eintrag in `EmberAPI\Translations\en-US.xml` (nächste freie ID, aktuell max. 1492). |
| Klassifikation `ExactMatches` vs. `PartialMatches` | `ExactMatches`, wenn Titel nach `FilterYear`-Normalisierung case-insensitiv gleich **und** (kein Jahr übergeben oder `ReleaseDate`-Jahr = Suchjahr); alle übrigen Treffer `PartialMatches` | Der Ergebnisvertrag/Heuristik (`GetSearchMovieInfo`, `Lev <= 5`, `FindYear`, `ExactMatches.Count = 1`) verlangt eine eindeutige Exact-Kategorie; die stärkste von TMDb belegbare Aussage ist exakter Titel + Jahresgleichheit. `Lev` wird weiterhin via `StringUtils.ComputeLevenshtein` je Treffer gesetzt (Heuristik-Input). `PopularTitles`, `TvTitles`, `VideoTitles`, `ShortTitles` bleiben leer (Festlegung der Analyse). |
| Treffer ohne auflösbare IMDb-ID | Protokollieren (`logger.Error`) und nicht in die Ergebnislisten aufnehmen | Der Dialog (`TreeNode.Tag = UniqueIDs.IMDbId`, `dlgIMDBSearchResults_Movie.vb:358` u. a.) und die Heuristik (`GetMovieInfo(imdbId)`) können Treffer ohne IMDb-ID nicht verwerten. `UniqueIDs.TMDbId` wird zusätzlich gesetzt (kein Vertragsbruch, für Folgebedarf nutzbar). |
| API-Key-Eingabe im Settings-Panel | `lblApiKey` + `txtApiKey` + `btnUnlockAPI` + `lblEMMAPI` in `tblScraperOpts` nach `frmSettingsHolder_*`-Muster des TMDb-Moduls; `pbTMDBApiKeyInfo` entfällt | Das TMDb-Muster (Unlock-Button schaltet `txtApiKey` frei, `lblEMMAPI` signalisiert eingebetteten Key) ist die UI-Konvention für API-Keys. Das Info-Icon benötigt eine Bild-Ressource im Formular-resx und eine `urlAPIKey`-Ressource in `Resources.resx` — beides im IMDb-Modul nicht vorhanden und für die Anforderung nicht erforderlich. |
| Dialog-Abnahme bei defektem Detailabruf | Minimalziel: bei `sInfo = Nothing` die IMDb-ID des selektierten Knotens in `Result` übernehmen → Dialog liefert `DialogResult.OK` mit IMDb-ID; vollständiger Detailabruf-Fix (`GetMovieInfo` → `/reference`) ist dokumentierter Folgebedarf | Anwender-Entscheidung (Punkt 3). Der IMDb-Detailabruf bleibt defekt; ohne den Fallback wäre der `OK_Button`-Pfad (`dlgIMDBSearchResults_Movie.vb:288`) nie erreichbar und die Abnahme würde am Detailabruf scheitern, obwohl die Anforderung nur Treffer + IMDb-ID verlangt. |
| Synchroner Block der TMDb-Aufrufe | `Task`-Ergebnisse per `.GetAwaiter().GetResult()` auswerten (nicht `Task.Run(...).Result`) | `SearchMovie`/`SearchTVShow` laufen bereits auf dem `bwIMDB`-Hintergrundthread — synchrones Warten ist unproblematisch. `.Result` verpackt Fehler in `AggregateException`; `GetAwaiter().GetResult()` liefert die eigentliche Ausnahme (`TMDbLib.Objects.Exceptions.{TMDbException,APIException,NotFoundException,RequestLimitExceededException,GeneralHttpException}` sowie `UnauthorizedAccessException` bei ungültigem API-Key — verifiziert in 2.3.0) direkt in `e.Error` — aussagekräftigere Fehlermeldung. |

## Programmabläufe

### Filmsuche (Dialog-Pfad)

1. `dlgIMDBSearchResults_Movie.ShowDialog` (Z. 71–91) bzw. `btnSearch_Click` (Z. 107–122) startet `_IMDB.SearchMovieAsync(title, year, filterOptions)` → `bwIMDB.RunWorkerAsync` mit `SearchType.Movies` (unverändert).
2. `bwIMDB_DoWork` (Z. 118–138) dispatcht auf `SearchMovie(title, year)` — unverändert.
3. `SearchMovie` (neu):
   1. `GetClient()` lazy: `New TMDbLib.Client.TMDbClient(_SpecialSettings.APIKey)`, `GetConfigAsync` abwarten, `MaxRetryCount = 2`. Schlägt die Initialisierung fehl (ungültiger Key, Netzwerk), propagiert die Exception → `e.Error`.
   2. `SearchMovieAsync(strTitle, Page, includeAdult := False, iYear)` (Signatur `SearchMovieAsync(query, page:=0, includeAdult:=False, year:=0, region, primaryReleaseYear, cancellationToken)` in 2.3.0 verifiziert; `iYear` aus `Integer.TryParse(year)`, 0 = kein Jahresfilter). Seiteniteration bis `Page <= TotalPages AndAlso Page <= 3` (Referenzmuster `clsScrapeTMDB.vb:1408`).
   3. Je Treffer `GetMovieExternalIdsAsync(aMovie.Id)` → `ImdbId`; Einzelaufruf-Fehler werden toleriert (Treffer loggen + überspringen), Suchfehler selbst propagieren. Hinweis 2.3.0: bei `ThrowApiExceptions = False` (Default) liefert ein 404 `Nothing` statt einer Exception — `Nothing`-Ergebnisse und leere `ImdbId` werden ebenfalls als überspringbarer Einzelfall behandelt.
   4. Mapping auf `MediaContainers.Movie`: `Title`, `Year` aus `ReleaseDate`, `UniqueIDs.IMDbId` + `TMDbId`, `Lev` via `StringUtils.ComputeLevenshtein(StringUtils.FilterYear(strTitle).ToLower, hitTitle)`; Einsortierung `ExactMatches`/`PartialMatches` gemäß Klassifikationsregel. `PopularTitles`/`TvTitles`/`VideoTitles`/`ShortTitles` bleiben leer.
   5. Kein `HtmlWeb`-/`imdb.com`-Aufruf mehr für die Titelsuche.
4. `bwIMDB_RunWorkerCompleted` (geändert): `e.Cancelled` → Return; `e.Error` → `logger.Error` + `RaiseEvent Exception(e.Error)`; sonst unverändert `RaiseEvent SearchResultsDownloaded_Movie`.
5. `dlgIMDBSearchResults_Movie`: `SearchResultsDownloaded` befüllt `tvResults` unverändert (rendert nur `ExactMatches`/`PartialMatches`, Rest leer); neuer `SearchFailed`-Handler (auf `Exception`-Event) zeigt Fehlerknoten.
6. Knoten-Auswahl → `tvResults_AfterSelect` → `tmrWait`/`tmrLoad` → `GetSearchMovieInfoAsync(imdbId)` → `SearchMovieInfoDownloaded` → `OK_Button.Enabled = True` (Z. 288, unverändert).

Beteiligte Klassen/Komponenten: `Scraper` (`clsScrapeIMDB.vb`), `SearchResults_Movie`, `dlgIMDBSearchResults_Movie`, `TMDbLib.Client.TMDbClient`, `MediaContainers.Movie`, `MediaContainers.UniqueidContainer`, `StringUtils`.

### Filmsuche (Heuristik-Pfad, kein Dialog)

1. `IMDB_Data.Scraper_Movie` → `GetSearchMovieInfo` (Z. 902–963) → `SearchMovie` (synchron, neue TMDb-Pipeline).
2. `SearchMovie`-Aufruf wird in den bestehenden `Try`-Block verschoben (Z. 907 → innerhalb Z. 909): API-Exception → `Catch` → `logger.Error` → `Nothing` → `Scraper_Movie` meldet „no search result" ohne Absturz der `ModulesManager`-Kette.
3. `ScrapeType`-Heuristik (`Ask`/`Skip`/`Auto`, `Lev <= 5`, `FindYear`) unverändert — arbeitet auf `ExactMatches`/`PartialMatches` (leere Spezialkategorien sind im bestehenden Code sicher, alle Zweige prüfen `Count > 0`).

Beteiligte Klassen/Komponenten: `Scraper.GetSearchMovieInfo` (`clsScrapeIMDB.vb`), `SearchResults_Movie`, `IMDB_Data.Scraper_Movie`, `ModulesManager.ScrapeData_Movie` (`clsAPIModules.vb`).

### Seriensuche

Analog zum Film-Pfad: `dlgIMDBSearchResults_TV.ShowDialog` (Z. 72–93) → `SearchTVShowAsync` → `bwIMDB_DoWork` (`SearchType.TVShows`) → `SearchTVShow` (neu): `GetClient()` → `SearchTvShowAsync(title, Page)` (Seiteniteration analog) → je Treffer `GetTvShowExternalIdsAsync` → `MediaContainers.TVShow` (`Title` aus `Name`/`OriginalName`, `Premiered` aus `FirstAirDate`, `UniqueIDs.IMDbId` + `TMDbId`) → `SearchResults_TVShow.Matches`. `GetSearchTVShowInfo` (Z. 978–1007) erhält ein `Try/Catch` nach Muster `GetSearchMovieInfo` (hat aktuell keines — Exception würde bis `ModulesManager` propagieren).

Beteiligte Klassen/Komponenten: `Scraper` (`clsScrapeIMDB.vb`), `SearchResults_TVShow`, `dlgIMDBSearchResults_TV`, `IMDB_Data.Scraper_TV`, `TMDbLib.Client.TMDbClient`, `MediaContainers.TVShow`.

### Fehlerfall (Quell-Ausfall)

1. API-/Netzwerkfehler (ungültiger Key → `UnauthorizedAccessException` — TMDbLib wirft bei HTTP 401 immer, nicht `APIException`; Rate-Limit nach Ausschöpfen der Retries → `RequestLimitExceededException`; sonstige HTTP-Fehler → `GeneralHttpException`; `HttpRequestException` u. a.) propagieren aus `SearchMovie`/`SearchTVShow` → `e.Error`.
2. `bwIMDB_RunWorkerCompleted`: `logger.Error` (Muster `GetSearchMovieInfo` Z. 959–962) + `RaiseEvent Exception(e.Error)`.
3. Dialog (`SearchFailed`-Handler): `tvResults.Nodes.Clear()` + unterscheidbarer Fehlerknoten mit Fehlertext, `pnlLoading.Visible = False`, `chkManual.Enabled = True` → manuelle IMDb-ID-Eingabe bleibt möglich.

Beteiligte Klassen/Komponenten: `Scraper.bwIMDB_RunWorkerCompleted`, `dlgIMDBSearchResults_Movie`/`_TV`, `TMDbLib.Objects.Exceptions.*`, `NLog` (`logger.Error`).

### Settings (API-Key + Deprecation)

1. `LoadSettings_Movie`/`LoadSettings_TV`: `strPrivateAPIKey = AdvancedSettings.GetSetting("APIKey", String.Empty, , Enums.ContentType.Movie/.TV)`; `_SpecialSettings_*.APIKey = If(String.IsNullOrEmpty(strPrivateAPIKey), _strAPIKey, strPrivateAPIKey)` (Muster `TMDB_Data.vb:352–353, 397–400`). Die fünf `Search*Titles`-`GetBooleanSetting`-Aufrufe (Z. 255–259) entfallen.
2. `InjectSetupScraper_Movie`/`_TV`: `txtApiKey.Text = strPrivateAPIKey`; bei gesetztem Key `btnUnlockAPI`/`lblEMMAPI`/`txtApiKey.Enabled` in Unlock-Zustand (Muster `TMDB_Data.vb:215–221, 306–312`); die fünf Checkbox-Belegungen (Z. 165–169) entfallen.
3. `SaveSetupScraper_Movie`/`_TV`: `strPrivateAPIKey`/effektiver `APIKey` aus `txtApiKey.Text.Trim` übernehmen; die fünf Checkbox-Rücklesungen (Z. 367–371) entfallen. Ein `CreateAPI`-Neuaufruf bei Key-Änderung ist **nicht** nötig — das IMDb-Modul instanziiert `Scraper` pro Scrape neu (anders als `TMDB_Data` mit persistentem `_TMDBAPI_*`).
4. `SaveSettings_Movie`/`_TV`: `SetSetting("APIKey", _setup_*.txtApiKey.Text.Trim, , Enums.ContentType.*)`; die fünf `Search*Titles`-`SetBooleanSetting`-Aufrufe (Z. 309–313) entfallen. Bestehende Einträge in der Kunden-`AdvancedSettings.xml` bleiben wirkungslos stehen (keine Migration).

Beteiligte Klassen/Komponenten: `IMDB_Data` (`SpecialSettings`, `LoadSettings_*`/`SaveSettings_*`, `InjectSetupScraper_*`/`SaveSetupScraper_*`), `frmSettingsHolder_Movie`/`_TV`, `AdvancedSettings` (`clsAPIAdvancedSettings.vb`).

### TMDb-Befund und Fix (`scraper.TMDB.Data`)

1. Eingrenzung: Kundenkonfiguration (`AdvancedSettings`, `EmberModules`-Reihenfolge) und Logzeilen `[ModulesManager] [ScrapeData_Movie] [Using] {Modul}` (`clsAPIModules.vb:944`) auswerten — wird `TMDB_Data` überhaupt erreicht (Hypothese b: `Cancelled`-Abbruch, `IMDB_Data.vb:480`/`clsAPIModules.vb:949`) oder schlägt die TMDb-Integration selbst fehl (Hypothese a)?
2. Bereits verifiziert (Planlauf): eingebetteter Fallback-Key (`TMDB_Data.vb:57`) gültig, TMDb-API v3 liefert Such- und `external_ids`-Ergebnisse — Hypothese „ungültiger Key" ist aktuell widerlegt; der `Cancelled`-Kettenabbruch und die unbehandelten Exceptions sind mechanisch bestätigt.
3. Fix der bestätigten Defekte (unabhängig vom Hypothesen-Ausgang):
   - `SearchMovie`/`SearchMovieSet`/`SearchTVShow` (`clsScrapeTMDB.vb:1362–1560`): `APIResult.Result`-Zugriffe exception-sicher auswerten (`APIResult.Exception`-Prüfung bzw. Try/Catch, `AggregateException` entpacken) → `logger.Error`.
   - `bwTMDB_RunWorkerCompleted` (Z. 227–252): `e.Error`/`e.Cancelled`-Prüfung vor `e.Result`-Zugriff → `logger.Error` + Fehlerweitergabe an Dialoge (neues `Exception`-Event analog zum IMDb-Modul), damit die TMDb-Dialoge nicht im Ladezustand hängen bleiben.
   - `dlgTMDBSearchResults_Movie`/`_TV`/`_MovieSet`: `Exception`-Event abonnieren + Fehlerknoten (gleiches UI-Muster wie IMDb-Dialoge).
   - `TMDbLib`-Anhebung auf 2.3.0 erfolgt **unabhängig vom Befund-Ausgang** (Anwender-Entscheidung) und ist als eigener Schritt 2 vorgeschaltet — Signatur-Anpassungen im Modul sind nicht erforderlich, da alle genutzten Aufrufe in 2.3.0 quellkompatibel sind (verifiziert).

Beteiligte Klassen/Komponenten: `Scraper` (`clsScrapeTMDB.vb`), `TMDB_Data`, `dlgTMDBSearchResults_Movie`/`_TV`/`_MovieSet`, `ModulesManager` (`clsAPIModules.vb`, nur diagnostisch).

## Neue Klassen

Keine — alle Erweiterungen folgen bestehenden Mustern (neue Felder/Methoden in vorhandenen Klassen; neues `Exception`-Event im TMDb-`Scraper` analog zum vorhandenen, nie gefeuerten Event im IMDb-`Scraper`).

## Änderungen an bestehenden Klassen

### `Scraper` (`Addons\scraper.IMDB.Data\Scraper\clsScrapeIMDB.vb`, Klasse)

- **Neue Felder:** `_client` (`TMDbLib.Client.TMDbClient`) — modulinterne Client-Instanz.
- **Neue Methoden:** `GetClient()` — lazy Client-Erzeugung nach `CreateAPI`-Muster (`New TMDbClient(_SpecialSettings.APIKey)`, `GetConfigAsync`, `MaxRetryCount = 2`); wirft bei Fehlschlag (Exception propagiert zum Aufrufer).
- **Geänderte Methoden:**
  - `SearchMovie` (Z. 1413–1541) — vollständige Neuimplementierung auf TMDb-Basis (siehe Programmablauf). Sämtliche `HtmlWeb.Load`-Aufrufe und XPath-Auswertungen für die Titelsuche entfallen; die fünf `_SpecialSettings.Search*Titles`-Auswertungen entfallen.
  - `SearchTVShow` (Z. 1555–1581) — analoge Neuimplementierung (`SearchTvShowAsync` + `GetTvShowExternalIdsAsync` → `Matches`).
  - `bwIMDB_RunWorkerCompleted` (Z. 140–158) — `e.Cancelled`- und `e.Error`-Prüfung vor dem `e.Result`-Zugriff; bei Fehler `logger.Error` + `RaiseEvent Exception(e.Error)` (behebt den bestätigten Crash: `DirectCast(e.Result, Results)` wirft bei Worker-Exception erneut, Ergebnis-Events feuern nie).
  - `GetSearchMovieInfo` (Z. 902–963) — `SearchMovie`-Aufruf in den bestehenden `Try`-Block verschieben (Z. 907 → innerhalb Z. 909), damit API-Exceptions den bestehenden `Catch` (`logger.Error` → `Nothing`) treffen statt bis `ModulesManager` zu propagieren.
  - `GetSearchTVShowInfo` (Z. 978–1007) — `Try/Catch` ergänzen (Muster `GetSearchMovieInfo`: `logger.Error` → `Nothing`); hat aktuell keine Fehlerbehandlung.
- **Events:** `Public Event Exception(ByVal ex As Exception)` (Z. 90) wird künftig tatsächlich gefeuert — bisher deklariert, nie ausgelöst, keine Bestandsabonnenten.
- **Imports:** `TMDbLib`-Namespaces ergänzen (z. B. `Imports TMDbLib.Client`, `Imports TMDbLib.Objects.Exceptions` für die Fehlerdifferenzierung); `Imports HtmlAgilityPack` bleibt (Detailabrufe nutzen es weiterhin).

### `SearchResults_Movie` / `SearchResults_TVShow` (`clsScrapeIMDB.vb` Z. 27–55)

- Unverändert (Ergebnisvertrag). `PopularTitles`/`TvTitles`/`VideoTitles`/`ShortTitles` werden nicht mehr befüllt.

### `IMDB_Data` (`Addons\scraper.IMDB.Data\IMDB_Data.vb`, Klasse)

- **Neue Felder:** `Private Const _strAPIKey As String` (eingebetteter TMDb-Fallback-Key, Wert wie `TMDB_Data.vb:57`) und `Private strPrivateAPIKey As String` (Muster `TMDB_Data.vb:42, 57`).
- **`SpecialSettings` (Z. 591–608):** neues Feld `APIKey As String`; die fünf Felder `SearchPartialTitles`, `SearchPopularTitles`, `SearchTvTitles`, `SearchVideoTitles`, `SearchShortTitles` bleiben als deprecated markiert bestehen (werden nicht mehr geladen/gespeichert/ausgewertet).
- **Geänderte Methoden:**
  - `LoadSettings_Movie` (Z. 233–261) — `APIKey` laden mit Fallback; fünf `Search*Titles`-Ladezeilen (Z. 255–259) entfernen.
  - `LoadSettings_TV` (Z. 263–286) — `APIKey` laden mit Fallback (`Enums.ContentType.TV` nach `TMDB_Data`-Muster).
  - `SaveSettings_Movie` (Z. 288–317) — `SetSetting("APIKey", _setup_Movie.txtApiKey.Text.Trim, , Enums.ContentType.Movie)`; fünf `Search*Titles`-Zeilen (Z. 309–313) entfernen.
  - `SaveSettings_TV` (Z. 319–343) — `SetSetting("APIKey", _setup_TV.txtApiKey.Text.Trim, , Enums.ContentType.TV)`.
  - `InjectSetupScraper_Movie` (Z. 138–186) — `txtApiKey`-Belegung + Unlock-Zustand; fünf Checkbox-Belegungen (Z. 165–169) entfernen.
  - `InjectSetupScraper_TV` (Z. 188–231) — `txtApiKey`-Belegung + Unlock-Zustand.
  - `SaveSetupScraper_Movie` (Z. 345–380) — `strPrivateAPIKey`/`_SpecialSettings_Movie.APIKey` aus `txtApiKey`; fünf Checkbox-Rücklesungen (Z. 367–371) entfernen.
  - `SaveSetupScraper_TV` (Z. 382–412) — `strPrivateAPIKey`/`_SpecialSettings_TV.APIKey` aus `txtApiKey`.
- **Unverändert:** `Scraper_Movie` (Z. 437–488), `Scraper_TV` (Z. 496–550), `GetTMDbIdByIMDbId` (Z. 427–429, leerer Stub — ausdrücklich kein Bestandteil).

### `dlgIMDBSearchResults_Movie` (`Addons\scraper.IMDB.Data\Scraper\dlgIMDBSearchResults_Movie.vb`, Form)

- **Neue Event-Handler:** `SearchFailed(ex As Exception)` — abonniert `_IMDB.Exception` in `dlgIMDBSearchResults_Load` (Z. 238–253, neben den bestehenden `AddHandler`-Zeilen); setzt `pnlLoading.Visible = False`, `chkManual.Enabled = True`, `tvResults.Nodes.Clear()` + Fehlerknoten mit unterscheidbarem Text (lokalisiert via `Master.eLang.GetString` + `ex.Message`).
- **Geänderte Methoden:** `SearchMovieInfoDownloaded` (Z. 282–335) — bei `sInfo Is Nothing` und nicht-manueller Auswahl die IMDb-ID des selektierten Knotens (`tvResults.SelectedNode.Tag`) in `_tmpMovie.UniqueIDs.IMDbId` übernehmen, damit der OK-Pfad (`Result`) trotz defektem IMDb-Detailabruf die gewählte ID liefert (Minimalziel „Dialog liefert `DialogResult.OK` mit IMDb-ID").

### `dlgIMDBSearchResults_TV` (`Addons\scraper.IMDB.Data\Scraper\dlgIMDBSearchResults_TV.vb`, Form)

- Analog: `SearchFailed`-Handler + `AddHandler _IMDB.Exception` im Load-Handler (neben Z. 240–241); `_tmpTVShow.UniqueIDs.IMDbId`-Fallback bei `sInfo Is Nothing` in `SearchInfoDownloaded` (Z. 276–320).

### `frmSettingsHolder_Movie` (`Addons\scraper.IMDB.Data\frmSettingsHolder_Movie.vb` + `.Designer.vb`, Form)

- **Designer:** fünf Checkboxen `chkPopularTitles`, `chkPartialTitles`, `chkTvTitles`, `chkVideoTitles`, `chkShortTitles` entfernen (Deklarationen Z. 59–66, `Controls.Add` Z. 525–532, Initialisierungsblöcke Z. 546–643, `Friend WithEvents` Z. 766–770); `tblScraperOpts` neu arrangieren. Neu: `lblApiKey`, `txtApiKey`, `btnUnlockAPI`, `lblEMMAPI` in `tblScraperOpts` (Muster `scraper.TMDB.Data\frmSettingsHolder_Movie.Designer.vb` Z. 104–144, 146–207).
- **Code:** `CheckedChanged`-Handler der fünf Checkboxen entfernen (Z. 96–98, 104–106, 150–152, 158–164); `Setup()`-Texte der fünf Checkboxen entfernen (Z. 210–221); neu `btnUnlockAPI_Click` (Muster `scraper.TMDB.Data\frmSettingsHolder_Movie.vb:64–75`), `txtApiKey_TextChanged` → `RaiseEvent ModuleSettingsChanged` (Muster Z. 157–159); `Setup()` um `lblApiKey` (eLang 870 „TMDB API Key"), `btnUnlockAPI` (1188 „Use my own API key"), `lblEMMAPI` (1189) erweitern.

### `frmSettingsHolder_TV` (`Addons\scraper.IMDB.Data\frmSettingsHolder_TV.vb` + `.Designer.vb`, Form)

- Analog: `lblApiKey`, `txtApiKey`, `btnUnlockAPI`, `lblEMMAPI` in `tblScraperOpts` ergänzen + Handler + `Setup()`-Texte (Muster `scraper.TMDB.Data\frmSettingsHolder_TV.*`).

### `Scraper` (`Addons\scraper.TMDB.Data\Scraper\clsScrapeTMDB.vb`, Klasse) — Befund-Fix

- **TMDbLib-Upgrade 1.9.1 → 2.3.0:** Alle im Modul genutzten Aufrufe (`SearchMovieAsync`, `SearchTvShowAsync`, `SearchCollectionAsync`, `GetMovieAsync`, `GetTvShowAsync`, `GetTvSeasonAsync`, `GetTvEpisodeAsync`, `GetCollectionAsync`, `FindAsync`, `GetConfigAsync`, `Config.Images.BaseUrl`, `DefaultLanguage`, `MaxRetryCount`, `*Methods`-Enums, `FindContainer`, `SearchContainer(Of T)`, `Movie.ImdbId`, `TvShow`/`TvSeason`/`TvEpisode.ExternalIds`, `Collection.Parts`) wurden per Reflexion an `TMDbLib.2.3.0\lib\net45\TMDbLib.dll` verifiziert und sind quellkompatibel — **keine Signatur-Anpassungen am Aufrufcode erforderlich**. Neue Möglichkeit (optional, nicht erforderlich): `ThrowApiExceptions`-Property steuert 404-Verhalten (`Nothing` statt `NotFoundException`); bleibt auf Default `False`.
- **Neue Events:** `Public Event Exception(ByVal ex As Exception)` — Fehlerweitergabe an die Suchdialoge.
- **Geänderte Methoden:**
  - `SearchMovie` (Z. 1362–1449), `SearchMovieSet` (Z. 1451–1502), `SearchTVShow` (Z. 1504–1560) — `APIResult.Result`-Zugriffe exception-sicher machen (`APIResult.Exception`-Prüfung bzw. Try/Catch; `AggregateException`/`NullReferenceException` auflösen) → `logger.Error` + leeres Ergebnis statt unbehandelter Exception.
  - `bwTMDB_RunWorkerCompleted` (Z. 227–252) — `e.Cancelled`-/`e.Error`-Prüfung vor `e.Result`; bei Fehler `logger.Error` + `RaiseEvent Exception(e.Error)` (behebt Crash, Ergebnis-Events feuerten bisher nie).

### `dlgTMDBSearchResults_Movie` / `_TV` / `_MovieSet` (`Addons\scraper.TMDB.Data\Scraper\`, Forms)

- `Exception`-Event des `Scraper` im jeweiligen Load-Handler abonnieren (neben den bestehenden `AddHandler`-Zeilen, z. B. `dlgTMDBSearchResults_TV.vb:224–225`) + `SearchFailed`-Handler mit Fehlerknoten (gleiches UI-Muster wie die IMDb-Dialoge; verhindert, dass die Dialoge bei Quell-Ausfall im „Please wait"-Zustand hängen bleiben).

### Projektdateien

- `Addons\scraper.IMDB.Data\packages.config` — `TMDbLib` **2.3.0** + transitive Pakete exakt wie `scraper.TMDB.Data\packages.config` (`Newtonsoft.Json` 13.0.3, `System.IO` 4.3.0, `System.Net.Http` 4.3.4, `System.Runtime` 4.3.1, `System.Security.Cryptography.Algorithms` 4.3.1, `.Encoding` 4.3.0, `.Primitives` 4.3.0, `.X509Certificates` 4.3.2).
- `Addons\scraper.IMDB.Data\scraper.Data.IMDB.vbproj` — `<Reference>`-Einträge mit HintPaths/`Private`-Flags nach `scraper.Data.TMDB.vbproj` (Z. 127–186), jedoch `TMDbLib, Version=2.0.0.0` mit HintPath `..\..\packages\TMDbLib.2.3.0\lib\net45\TMDbLib.dll` (AssemblyVersion von Paket 2.3.0 ist `2.0.0.0` — verifiziert); `Newtonsoft.Json`/`NLog` `Private=False`, `System.*`-Shims `Private=True` + `<Import Include="System.Threading.Tasks" />`.
- `Addons\scraper.TMDB.Data\packages.config` — `TMDbLib` 1.9.1 → **2.3.0** (Z. 12); übrige Pakete unverändert (Newtonsoft.Json ≥ 13.0.3 und System.Net.Http ≥ 4.3.4 erfüllen die 2.3.0-Abhängigkeiten bereits).
- `Addons\scraper.TMDB.Data\scraper.Data.TMDB.vbproj` — `Reference Include` von `TMDbLib, Version=1.0.0.0` (Z. 184) auf `Version=2.0.0.0` anheben + HintPath auf `packages\TMDbLib.2.3.0\lib\net45\TMDbLib.dll`.
- `EmberMediaManager\app.config` — neuen `bindingRedirect` für `TMDbLib` ergänzen (`oldVersion="0.0.0.0-2.0.0.0" newVersion="2.0.0.0"`), da sich die Assembly-Identität von 1.0.0.0 auf 2.0.0.0 ändert. Der vorhandene `Newtonsoft.Json`-Redirect (`0.0.0.0-13.0.0.0 → 13.0.0.0`) bleibt unverändert ausreichend.
- `Addons\scraper.IMDB.Data\app.config` — `Newtonsoft.Json`-Redirect bereits vorhanden; optional identischen `TMDbLib`-Redirect ergänzen (wirksam ist ohnehin die Host-`app.config`).
- `EmberAPI\Translations\en-US.xml` — neuer String für den Fehlerknoten (nächste freie ID > 1492), z. B. „The search could not be completed: {0}".

## Datenbankmigrationen

Keine.

## Validierungsregeln

| Feld / Objekt | Regel | Fehlerfall |
|---------------|-------|------------|
| `APIKey` (Setting/`txtApiKey`) | Leerer Eintrag → eingebetteter Fallback-Key `_strAPIKey`; `Trim` beim Speichern | Ungültiger Key → TMDb-API 401 → `UnauthorizedAccessException` (TMDbLib wirft bei 401 immer — verifiziert in 2.3.0) → Fehlerknoten im Dialog + `logger.Error` |
| `year`-Parameter `SearchMovie` | `Integer.TryParse`; 0/Nicht-numerisch = kein Jahresfilter | — |
| TMDb-Treffer ohne `ImdbId` | Überspringen + protokollieren | Treffer ohne IMDb-ID wäre im Dialog unbrauchbar (`Tag`/`GetMovieInfo`) |
| `e.Error`/`e.Cancelled` in `*_RunWorkerCompleted` | Vor `e.Result`-Zugriff prüfen | Bisher: Crash, Ergebnis-Event feuert nie |

## Konfigurationsänderungen

| Eintrag | Typ | Standardwert | Zweck |
|---------|-----|--------------|-------|
| `APIKey` (Section `scraper.Data.IMDB`, `Enums.ContentType.Movie`) | `String` | `_strAPIKey` (eingebetteter Fallback) | Eigener TMDb-API-Key für die Filmsuche; Section-Trennung über aufrufende Assembly ist automatisch (`clsAPIAdvancedSettings.vb:90`) — keine Kollision mit `scraper.Data.TMDB` |
| `APIKey` (Section `scraper.Data.IMDB`, `Enums.ContentType.TV`) | `String` | `_strAPIKey` | dto. für die Seriensuche |
| `SearchPartialTitles`, `SearchPopularTitles`, `SearchTvTitles`, `SearchVideoTitles`, `SearchShortTitles` | `Boolean` (deprecated) | — | Werden nicht mehr gelesen/geschrieben; vorhandene Einträge bleiben wirkungslos in der Kunden-`AdvancedSettings.xml` |

## Seiteneffekte und Risiken

- **Scrape-Kette (`ModulesManager`):** Funktioniert die IMDb-Suche wieder, wählt der Anwender einen Treffer → `ScrapeModifiers.DoSearch = False` → Folge-Scraper laufen regulär weiter. Der `Cancelled`-Abbruch bei Dialog-Abbruch bleibt unverändert bestehen (ausdrücklich keine Framework-Änderung).
- **TMDb-Rate-Limits:** Bis zu 3 Suchseiten à ~20 Treffer mit je einem `*ExternalIdsAsync`-Aufruf können das TMDb-Rate-Limit erreichen → `RequestLimitExceededException` landet auf dem neuen Fehlerpfad (unterscheidbare Meldung statt stiller Leere). `MaxRetryCount = 2` mildert ab.
- **AppDomain-Assembly-Auflösung:** `TMDbLib`-Version in beiden Modulen muss identisch sein (beide DLLs laden in `EmberMediaManager.exe`) — deshalb synchron 2.3.0; die Assembly-Identität ändert sich von `1.0.0.0` auf `2.0.0.0`, daher neuer `bindingRedirect` in `EmberMediaManager\app.config`. `TMDbLib.dll` wird per CopyLocal in `Modules\scraper.data.imdb\` ausgegeben — das aktualisierte Paket muss beim Ausliefern die alte DLL ersetzen (Deployment-Hinweis).
- **`Exception`-Event wird neu gefeuert:** Keine Bestandsabonnenten (`clsScrapeIMDB.vb:90` wurde nie ausgelöst) — kein Rückwärtskompatibilitätsrisiko.
- **Manuelle IMDb-ID-Eingabe:** `btnVerify` → `GetSearchMovieInfoAsync` → `GetMovieInfo` (weiterhin defekter `/reference`-Detailabruf, außerhalb des Scopes) → `sInfo = Nothing` → „Verification Failed"-Hinweis; der „continue without verification"-Pfad (`OK_Button_Click` Z. 260–280) bleibt funktionsfähig → Akzeptanzkriterium erfüllt.
- **Ask-Pfad ohne Dialog:** Bei `ExactMatches.Count = 1` greift die Heuristik ohne Dialog — Verhalten unverändert, aber jetzt mit TMDb-Treffern.
- **Detailabruf bleibt defekt:** `/reference` u. a. sind weiterhin IMDb-HTML-basiert (Folgebedarf laut Analyse); der Dialog-Vorschau/OK-Pfad wird durch den `sInfo = Nothing`-Fallback entschärft, liefert aber keine Detaildaten.

## Umsetzungsreihenfolge

1. **TMDb-Befund eingrenzen und dokumentieren** *(geklärter Ansatz — Anwender-Entscheidung Punkt 1)*
   - Voraussetzungen: Keine.
   - Beschreibung: Kundenkonfiguration (`AdvancedSettings`, `EmberModules`-Reihenfolge) und `[Using]`-Logzeilen (`clsAPIModules.vb:944`) auswerten; Hypothese a/b entscheiden. Bereits im Planlauf verifiziert: Fallback-Key gültig, API v3 funktional → wahrscheinlichster Befund ist der `Cancelled`-Abbruch (Hypothese b) zuzüglich der bestätigten Exception-Defekte, die unabhängig gefixt werden. Ergebnis im Feature-Ordner dokumentieren (Beeinflusst nur noch die Dokumentation, nicht mehr die Versionswahl — die ist mit 2.3.0 festgelegt).

2. **`TMDbLib` 2.3.0 in beiden Modulen** *(Anwender-Entscheidung Punkt 2)*
   - Voraussetzungen: Keine (Versionsentscheid gefallen: 2.3.0 = aktuellste net45-kompatible Version; 3.0.0 nur net8.0/net10.0).
   - Beschreibung: `scraper.TMDB.Data`: `packages.config` 1.9.1 → 2.3.0, `scraper.Data.TMDB.vbproj` `Reference Include` → `TMDbLib, Version=2.0.0.0` + HintPath `packages\TMDbLib.2.3.0\lib\net45\TMDbLib.dll`. `scraper.IMDB.Data`: `packages.config` + `scraper.Data.IMDB.vbproj` um `TMDbLib` 2.3.0 und die transitiven Pakete/Referenzen nach `scraper.Data.TMDB`-Muster ergänzen; `Import System.Threading.Tasks`. `EmberMediaManager\app.config`: `bindingRedirect` `TMDbLib 0.0.0.0-2.0.0.0 → 2.0.0.0`. Build beider Projekte prüfen. Signatur-Anpassungen am Aufrufcode sind nicht erforderlich (alle genutzten Member in 2.3.0 verifiziert); tritt dennoch ein Kompilierfehler auf, ist er in diesem Schritt zu beheben.

3. **`APIKey`-Setting und Deprecation der `Search*Titles`-Settings**
   - Voraussetzungen: Keine (unabhängig von Schritt 2).
   - Beschreibung: `SpecialSettings.APIKey`, `_strAPIKey`/`strPrivateAPIKey`, Load/Save in `IMDB_Data`; `frmSettingsHolder_Movie`/`_TV` um `lblApiKey`/`txtApiKey`/`btnUnlockAPI`/`lblEMMAPI` erweitern; fünf Checkboxen samt Handler/Belegung/Speicherung entfernen.

4. **Suche im IMDb-Modul auf TMDb umstellen**
   - Voraussetzungen: Schritt 2 (TMDbLib-Referenz), Schritt 3 (`APIKey` in `SpecialSettings`).
   - Beschreibung: `_client`-Feld + `GetClient()`; `SearchMovie` und `SearchTVShow` neu implementieren (Mapping, `Lev`, Exact/Partial-Klassifikation, IMDb-ID-Auflösung je Treffer).

5. **Fehlerpfad im IMDb-Modul**
   - Voraussetzungen: Schritt 4.
   - Beschreibung: `bwIMDB_RunWorkerCompleted` (`e.Error`/`e.Cancelled`, `logger.Error`, `RaiseEvent Exception`); `Try/Catch`-Absicherung der synchronen Suchpfade (`GetSearchMovieInfo`/`GetSearchTVShowInfo`); `SearchFailed`-Handler + Fehlerknoten in beiden IMDb-Dialogen; neuer String in `en-US.xml`; `sInfo = Nothing`-Fallback für `Result`-IMDb-ID.

6. **TMDb-Modul-Fix (aus Befund)**
   - Voraussetzungen: Schritt 1 (Befund dokumentiert), Schritt 2 (TMDbLib 2.3.0 liegt bereits an).
   - Beschreibung: Exception-sichere `APIResult.Result`-Auswertung in `SearchMovie`/`SearchMovieSet`/`SearchTVShow`; `bwTMDB_RunWorkerCompleted` (`e.Error`/`e.Cancelled`, `logger.Error`, neues `Exception`-Event); `SearchFailed`-Handler + Fehlerknoten in `dlgTMDBSearchResults_Movie`/`_TV`/`_MovieSet`.

7. **Build-Verifikation**
   - Voraussetzungen: Schritte 2–6.
   - Beschreibung: `.nuget\NuGet.exe restore "Ember Media Manager.sln"` + `msbuild` für `scraper.Data.IMDB.vbproj` und `scraper.Data.TMDB.vbproj` (Debug|x86, wie CI) — fehlerfreie Kompilierung als automatisierter Nachweis (einzige vorhandene Verifikationsebene, siehe Tests).

8. **Manuelle Abnahme**
   - Voraussetzungen: Schritt 7.
   - Beschreibung: Abnahme anhand der Akzeptanzkriterien (Referenzfilme `tt0289043`/`tt0463854`/`tt10548174`, analoge Seriensuche, manuelle ID-Eingabe, unterscheidbare Fehlermeldung) — dokumentiertes Protokoll, siehe E2E-Abschnitt.

## Tests

### Neue Tests

| Test / Hilfsmethode | Testklasse | Was wird geprüft / bereitgestellt? |
|--------------------|------------|-------------------------------------|
| Keine neuen automatisierten Tests | — | Das einzige Testprojekt `EmberAPI_Test` ist nicht kompilierbar (fehlendes `UnitTests.vbproj`, 203× `BC30002`, nicht Teil der Solution, CI führt keine Tests aus); für die Addon-Module existiert keine Testinfrastruktur. Neue Testinfrastruktur ist für diese Anforderung nicht erforderlich (Anforderung sieht manuelle Abnahme vor). Automatisierter Nachweis = fehlerfreier Build beider Module (Schritt 7). |

### Betroffene bestehende Tests

Keine — `EmberAPI_Test` kompiliert nicht und ist nicht Teil der Solution; es existieren keine Tests für `scraper.Data.IMDB`/`scraper.Data.TMDB`/`scraper.Data.OMDb`. Die (nicht lauffähigen) `Test_clsAPIStringUtils`-Tests für `ComputeLevenshtein`/`FilterYear`/`GetIMDBIDFromString` bleiben unberührt, da die Hilfsfunktionen unverändert wiederverwendet werden.

### E2E-Tests (primärer Funktionsnachweis)

**Befund zur E2E-Machbarkeit:** Das Projekt ist eine WinForms-Anwendung ohne jede E2E-/UI-Automatisierungsinfrastruktur — kein UI-Test-Framework, kein automatisierbarer Dialog-Test, `EmberAPI_Test` nicht kompilierbar, CI ohne Testausführung. Die Akzeptanzkriterien verlangen zudem echte Suchtreffer der externen TMDb-API (Netzwerkabhängigkeit, API-Key, Rate-Limits) — selbst mit neuer Infrastruktur wäre ein stabiler automatisierter E2E-Test nicht ohne Weiteres erreichbar. Automatisierte E2E-Tests werden daher **nicht** geplant (Anwender-Entscheidung Punkt 4: dokumentiertes manuelles Abnahmeprotokoll als Abnahmegrundlage; FlaUI-/WinAppDriver-Smoke-Test ist dokumentierter Folgebedarf-Vorschlag, kein Scope-Bestandteil).

Als realistische E2E-Abdeckung wird ein **dokumentiertes manuelles Abnahmeprotokoll** festgeschrieben — jede Zeile ist Pflicht-Szenario der Abnahme:

| Priorität | Szenario | Testdatei / Testklasse | Abgedecktes Akzeptanzkriterium | Warum E2E nötig ist |
|-----------|----------|------------------------|-------------------------------|-------------------|
| Pflicht | (Re)Scrape „28 Days Later" → `dlgIMDBSearchResults_Movie` zeigt Treffer mit `tt0289043` | Manuell (Protokoll im Feature-Ordner) | Dialog zeigt Treffer mit korrekter IMDb-ID | Benutzerfluss über Dialog + Live-API; kein Unit-Test ersetzt ihn |
| Pflicht | (Re)Scrape „28 Weeks Later" → `tt0463854`; „28 Years Later" → `tt10548174` | Manuell | dto. | dto. |
| Pflicht | Seriensuche mit bekanntem Titel → `dlgIMDBSearchResults_TV` zeigt Treffer mit korrekter IMDb-ID | Manuell | Analoge Serien-Abnahme | dto. |
| Pflicht | `chkManual` + `txtIMDBID` + `btnVerify` in beiden Dialogen | Manuell | Manuelle ID-Eingabe bleibt funktionsfähig | UI-Interaktion |
| Pflicht | Quell-Ausfall simulieren (ungültigen `APIKey` eintragen bzw. Netzwerk trennen) → Dialog zeigt Fehlermeldung statt „No Matches Found" | Manuell | Unterscheidbare Fehlermeldung | Fehlerpfad über Worker → Event → Dialog nur als Gesamtfluss prüfbar |
| Pflicht | Scrape mit beiden aktivierten Daten-Scrapern (IMDb vor TMDb in `ModuleOrder`) → nach Trefferauswahl im IMDb-Dialog läuft die Kette weiter (`[Using]`-Logzeilen) | Manuell | Scrape-Order-Effekt (Hypothese b) behoben/entschärft | Modul-übergreifender Fluss in `ModulesManager` |

Welche bestehenden E2E-Tests müssen angepasst werden? Keine — es existiert keine E2E-Testsuite.

## Offene Punkte

Keine — die vier zuvor offenen Punkte wurden per Anwender-Entscheidung geklärt und sind eingearbeitet:

1. **TMDb-Eingrenzung:** als Schritt 1 der Umsetzung ausführen und dokumentieren; wahrscheinlichster Befund `Cancelled`-Abbruch (Hypothese b) + bestätigte Exception-Defekte, die unabhängig gefixt werden.
2. **`TMDbLib`-Version:** direkte Anhebung beider Module auf die aktuelle stabile, net45-kompatible Version **2.3.0** (3.0.0 ist nur net8.0/net10.0 und damit für .NET Framework 4.8 unverwendbar); Signaturen gegen die 2.3.0-Assembly verifiziert — quellkompatibel.
3. **Dialog-Abnahme:** Minimalziel `DialogResult.OK` mit IMDb-ID bei `sInfo = Nothing` ist eingeplant (Schritt 5); vollständiger Detailabruf-Fix = dokumentierter Folgebedarf.
4. **E2E-Infrastruktur:** dokumentiertes manuelles Abnahmeprotokoll als Abnahmegrundlage; FlaUI-/WinAppDriver-Smoke-Test als Folgebedarf-Vorschlag.
