# Plan-Review

## Ergebnis

**Status:** Offene Aufgaben vorhanden

Dritte Review-Iteration. Alle automatisierbaren Planelemente sind im Working Tree (uncommitted, Basis `origin/staging`) vollständig umgesetzt und gegen den aktuellen Code verifiziert; die Build-Verifikation wurde in diesem Lauf erneut ausgeführt (MSBuild `Debug|x86`, Exit-Code 0 für `scraper.Data.IMDB.vbproj` und `scraper.Data.TMDB.vbproj`). Einzig verbleibende offene Aufgabe ist Task 27 (manuelles Abnahmeprotokoll) — bewusst offen, da nicht automatisierbar.

## Umgesetzte Planelemente

### `Scraper` (`Addons\scraper.IMDB.Data\Scraper\clsScrapeIMDB.vb`)

- [x] Feld `_client` (`TMDbLib.Client.TMDbClient`) — vorhanden (Z. 71)
- [x] Methode `GetClient()` — vorhanden (Z. 1472–1480): lazy, `New TMDbClient(_SpecialSettings.APIKey)`, `GetConfigAsync().GetAwaiter().GetResult()`, `MaxRetryCount = 2`, Exception propagiert zum Aufrufer
- [x] Methode `SearchMovie` — vollständig auf TMDb neu implementiert (Z. 1482–1550): `SearchMovieAsync` mit Seiteniteration `Page <= TotP AndAlso Page <= 3`, `GetMovieExternalIdsAsync` je Treffer mit Einzelfall-Toleranz (`Try/Catch` + `logger.Error`, Treffer ohne `ImdbId` per `Continue For` übersprungen — deckt auch `Nothing`-Ergebnisse der 404-Semantik ab), Mapping auf `MediaContainers.Movie` (`Title`, `Year` aus `ReleaseDate`, `UniqueIDs.IMDbId` + `TMDbId`, `Lev` via `StringUtils.ComputeLevenshtein`), Klassifikation `ExactMatches`/`PartialMatches` (exakter Titel nach `FilterYear`, case-insensitiv, + Jahresgleichheit); keine `HtmlWeb`-/`imdb.com`-Aufrufe und keine `Search*Titles`-Auswertungen mehr im Suchpfad; `PopularTitles`/`TvTitles`/`VideoTitles`/`ShortTitles` werden nicht befüllt
- [x] Methode `SearchTVShow` — analog neu implementiert (Z. 1564–1613): `SearchTvShowAsync` + `GetTvShowExternalIdsAsync` → `SearchResults_TVShow.Matches` (`Title` aus `Name`/`OriginalName`, `Premiered` aus `FirstAirDate`, `UniqueIDs.IMDbId` + `TMDbId`)
- [x] Methode `bwIMDB_RunWorkerCompleted` — `e.Cancelled`-/`e.Error`-Prüfung vor `e.Result`, `AggregateException`-Entpackung, `logger.Error` + `RaiseEvent Exception(err)`, zusätzlich `e.Result Is Nothing`-Guard (Z. 140–159)
- [x] Methode `GetSearchMovieInfo` — `SearchMovie`-Aufruf in innerem `Try`-Block (Z. 929–933, `Catch` → `logger.Error`), äußerer `Try/Catch` → `Nothing` (Z. 927–995)
- [x] Methode `GetSearchTVShowInfo` — innerer `Try/Catch` um `SearchTVShow` (`logger.Error`) + äußerer `Try/Catch` → `Nothing` (Z. 1011 ff.)
- [x] Event `Public Event Exception(ByVal ex As Exception)` (Z. 90) — wird tatsächlich gefeuert (`bwIMDB_RunWorkerCompleted` Z. 153)
- [x] `TMDbLib`-Verwendung im Suchpfad vorhanden (`TMDbLib.Client.TMDbClient`, `TMDbLib.Objects.*` per vollqualifizierten Namen); `Imports HtmlAgilityPack` bestehen geblieben (Detailabrufe unverändert IMDb-HTML-basiert)
- [x] `SearchResults_Movie`/`SearchResults_TVShow` — unverändert (Ergebnisvertrag, Z. 27–55)

### `IMDB_Data` (`Addons\scraper.IMDB.Data\IMDB_Data.vb`)

- [x] Feld `Private Const _strAPIKey As String` (Fallback-Key identisch zu `TMDB_Data.vb:57`) — Z. 49
- [x] Feld `Private strPrivateAPIKey As String` — Z. 40
- [x] `SpecialSettings.APIKey As String` — Z. 602; fünf `Search*Titles`-Felder als deprecated markiert bestehen geblieben (Z. 607–612)
- [x] `LoadSettings_Movie`/`LoadSettings_TV` — `APIKey` mit Fallback `_strAPIKey` (`Enums.ContentType.Movie`/`.TV`, Z. 264–265, 293–294); `Search*Titles`-`GetBooleanSetting`-Zeilen entfernt
- [x] `SaveSettings_Movie`/`SaveSettings_TV` — `SetSetting("APIKey", _setup_*.txtApiKey.Text.Trim, , , Enums.ContentType.*)` (Z. 320, 347); `SetBooleanSetting`-Zeilen entfernt
- [x] `InjectSetupScraper_Movie`/`_TV` — `txtApiKey.Text = strPrivateAPIKey` + Unlock-Zustand (`btnUnlockAPI`/`lblEMMAPI`/`txtApiKey.Enabled`) nach TMDb-Muster (Z. 169–174, 221–227); Checkbox-Belegungen entfernt
- [x] `SaveSetupScraper_Movie`/`_TV` — `strPrivateAPIKey`/`_SpecialSettings_*.APIKey` aus `txtApiKey.Text.Trim` mit Fallback (Z. 376–377, 410–411); Checkbox-Rücklesungen entfernt

### Dialoge IMDb-Modul

- [x] `dlgIMDBSearchResults_Movie` — `AddHandler _IMDB.Exception, AddressOf SearchFailed` im Load-Handler (Z. 247); `SearchFailed` (Z. 367–398): `tmrWait`/`tmrLoad`-Stop, `pnlLoading.Visible = False`, `chkManual.Enabled = True`, unterscheidbarer Fehlerknoten via eLang 1493 + `GetSearchErrorMessage(ex)` (differenzierte Texte 1494–1496); `sInfo Is Nothing`-Fallback übernimmt `tvResults.SelectedNode.Tag` in `_tmpMovie.UniqueIDs.IMDbId` (Z. 335–341)
- [x] `dlgIMDBSearchResults_TV` — analog: `AddHandler` (Z. 246), `SearchFailed` (Z. 352 ff., gleicher Fehlerknoten), `_tmpTVShow.UniqueIDs.IMDbId`-Fallback (Z. 323–326)

### Settings-Panels IMDb-Modul

- [x] `frmSettingsHolder_Movie` — fünf `Search*Titles`-Checkboxen vollständig entfernt (keine `chkPopularTitles`/`chkPartialTitles`/`chkTvTitles`/`chkVideoTitles`/`chkShortTitles`-Reste im Modul); `lblApiKey`/`txtApiKey`/`btnUnlockAPI`/`lblEMMAPI` in `tblScraperOpts` ergänzt (Designer Z. 59–62, 524–527, 748–751); `btnUnlockAPI_Click` (Z. 54) + `txtApiKey_TextChanged` (Z. 159) → `ModuleSettingsChanged`; `Setup()`-Texte (Z. 195, 218–219, eLang 1188/1189/1498)
- [x] `frmSettingsHolder_TV` — analog ergänzt (Designer Z. 37–40, 229–232, 799–802; Code Z. 104, 212, 228, 251–252)

### TMDb-Modul (`Addons\scraper.TMDB.Data`) — Befund-Fix

- [x] `Public Event Exception(ByVal ex As Exception)` im `Scraper` — `clsScrapeTMDB.vb:158`
- [x] `bwTMDB_RunWorkerCompleted` — `e.Cancelled`-/`e.Error`-Prüfung vor `e.Result`, `AggregateException`-Entpackung, `_Logger.Error` + `RaiseEvent Exception(err)`, `e.Result Is Nothing`-Guard (Z. 229–248)
- [x] `SearchMovie`/`SearchMovieSet`/`SearchTVShow` — sämtliche `APIResult`-Zugriffe in `Try/Catch`-Blöcken (Z. 1474–1557, 1574–1617, 1634–1686); gefaultete Tasks per `GetAwaiter().GetResult()` entpackt (echte Exception statt `AggregateException`) und weitergeworfen; `Nothing`-Guards decken die 404→`Nothing`-Semantik von TMDbLib 2.3.0 ab; Protokollierung erfolgt caller-seitig (einmalig, siehe Hinweise)
- [x] Synchrone Aufrufpfade abgesichert: `GetSearchMovieInfo` (Z. 1172–1227), `GetSearchMovieSetInfo` (Z. 1229–1284), `GetSearchTVShowInfo` (Z. 1286–1341) mit jeweils innerem `Try/Catch` um den `Search*`-Aufruf (`_Logger.Error`) und äußerem `Try/Catch` → `Nothing`
- [x] `dlgTMDBSearchResults_Movie`/`_TV`/`_MovieSet` — `AddHandler _TMDB.Exception, AddressOf SearchFailed` (Z. 227/230/211) + `SearchFailed`-Handler mit Fehlerknoten (eLang 1493), `pnlLoading.Visible = False`, `chkManual.Enabled = True` in allen drei Dialogen

### Projektdateien / Konfiguration / Übersetzungen

- [x] `Addons\scraper.IMDB.Data\packages.config` — `TMDbLib` 2.3.0 (Z. 13) + transitive Pakete (`Newtonsoft.Json` 13.0.3, `System.IO` 4.3.0, `System.Net.Http` 4.3.4, `System.Runtime` 4.3.1, `System.Security.Cryptography.Algorithms` 4.3.1, `.Encoding` 4.3.0, `.Primitives` 4.3.0, `.X509Certificates` 4.3.2)
- [x] `Addons\scraper.IMDB.Data\scraper.Data.IMDB.vbproj` — `TMDbLib, Version=2.0.0.0` mit HintPath `packages\TMDbLib.2.3.0\lib\net45\TMDbLib.dll` (Z. 176–177), `Newtonsoft.Json`-Referenz (Z. 126–127), `System.*`-Shim-Referenzen (Z. 138–162), `<Import Include="System.Threading.Tasks" />` (Z. 187)
- [x] `Addons\scraper.TMDB.Data\packages.config` — `TMDbLib` 2.3.0 (Z. 12); `scraper.Data.TMDB.vbproj` — `Reference Include` `TMDbLib, Version=2.0.0.0` + HintPath net45 (Z. 184–185)
- [x] `EmberMediaManager\App.config` (Z. 30–31) + `Addons\scraper.IMDB.Data\app.config` (Z. 21–24) — `bindingRedirect` `TMDbLib 0.0.0.0-2.0.0.0 → 2.0.0.0`
- [x] `EmberAPI\Translations\en-US.xml` — Strings ID 1493 „The search could not be completed: {0}" sowie ergänzend 1494–1498 (differenzierte Fehlertexte, Detailabruf-Hinweis, API-Key-Label) (Z. 1584–1589)
- [x] TMDb-Befund dokumentiert — `befund-tmdb.md` (Hypothesen a/b, verifizierte Defekte, nicht beweisbare Punkte ohne Kundenumgebung)
- [x] Build-Verifikation — in dieser Review-Iteration erneut ausgeführt: MSBuild `Debug|x86` Exit-Code 0 für `scraper.Data.IMDB.vbproj` **und** `scraper.Data.TMDB.vbproj` (einzige Warnung: vorbestehender `MSB3884` in `EmberAPI.vbproj`); dokumentiert in `test-results.md` (Lauf 4)
- [x] Abnahmeprotokoll-Gerüst — `abnahmeprotokoll.md` mit allen Pflicht-Szenarien aus dem Plan

## Offene Aufgaben

- [ ] **Task 27 — Manuelles Abnahmeprotokoll durchführen** — bewusst offen / nicht automatisierbar: `abnahmeprotokoll.md` enthält alle Pflicht-Szenarien aus dem Plan (Referenzfilme `tt0289043`/`tt0463854`/`tt10548174`, Seriensuche, manuelle IMDb-ID-Eingabe, unterscheidbare Fehlermeldung bei Quell-Ausfall, Scrape-Order-Verhalten), aber kein Szenario ist als durchgeführt dokumentiert (alle Ergebnis-Checkboxen unmarkiert). Erfordert eine laufende WinForms-Instanz mit Netzwerkzugang zur TMDb-API und kann nur manuell abgenommen werden (Anwender-Entscheidung: dokumentiertes manuelles Protokoll als E2E-Ersatz).

## Hinweise

- **Task 22 Umsetzungsvariante (unverändert aus Iteration 2):** Der Plan sah „`logger.Error` + leeres Ergebnis statt unbehandelter Exception" vor; implementiert ist `Try/Catch` + `Throw` mit einmaliger Protokollierung auf Caller-Seite (`bwTMDB_RunWorkerCompleted` im Async-Pfad, innerer `Try/Catch` in `GetSearch*Info` im Sync-Pfad). Plankonform im Ergebnis: Der Dialog-Pfad erhält den geforderten, von „No Matches Found" unterscheidbaren Fehlerknoten; der synchrone Pfad fängt die Exception ab (`_Logger.Error` → `Nothing` bzw. Ask-Fallback über den Suchdialog). `AggregateException`-Entpackung via `GetAwaiter().GetResult()`.
- **Ask-Fallback bei Suchfehler:** In `GetSearchMovieInfo`/`GetSearchMovieSetInfo`/`GetSearchTVShowInfo` (`clsScrapeTMDB.vb`) und `GetSearchMovieInfo`/`GetSearchTVShowInfo` (`clsScrapeIMDB.vb`) öffnet sich bei `r Is Nothing` im Ask-Modus der Suchdialog erneut über den Async-Pfad — der Anwender sieht den Fehlerknoten bzw. bei transienten Fehlern die Trefferliste. Ergänzende Verhaltensverbesserung, kein Vertragsbruch.
- **Binding-Redirect funktional neutral:** `TMDbLib` 2.3.0 ist nicht strong-named (`PublicKeyToken=null`) — die Redirects sind wirkungslos, aber harmlos (dokumentiert in `test-results.md`).
- **Detailabruf bleibt plangemäß defekt** (IMDb-HTML `/reference` u. a.) — dokumentierter Folgebedarf; der `sInfo Is Nothing`-Fallback sichert den OK-Pfad mit IMDb-ID.
- **Vorbestehende ungesicherte `.Result`-Zugriffe** außerhalb der drei Suchmethoden (z. B. `GetMovieInfo`, `GetInfo_Movieset`, Fallback-Client-Pfad) waren nicht Gegenstand des Plans — der Plan forderte die Absicherung nur für `SearchMovie`/`SearchMovieSet`/`SearchTVShow`. Sie propagieren im Dialog-Pfad ebenfalls über `e.Error` → `Exception`-Event.
- **Iteration-3-Korrekturen geprüft:** `e.Result Is Nothing`-Guard in `bwIMDB_RunWorkerCompleted` (Z. 157–159), einmaliges Exception-Logging (kein doppeltes `logger.Error` in den TMDb-Suchmethoden), eLang-Label 1498 für `lblApiKey`, `SetColumnSpan(txtApiKey, 2)` im TV-Settings-Panel — alle im Code bestätigt, Build fehlerfrei.
