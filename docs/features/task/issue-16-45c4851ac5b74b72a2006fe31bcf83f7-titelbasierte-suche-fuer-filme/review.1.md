# Plan-Review

## Ergebnis

**Status:** Offene Aufgaben vorhanden

## Umgesetzte Planelemente

### `Scraper` (`Addons\scraper.IMDB.Data\Scraper\clsScrapeIMDB.vb`)

- [x] Feld `_client` (`TMDbLib.Client.TMDbClient`) — angelegt (Z. 73)
- [x] Methode `GetClient()` — vorhanden (Z. 1430–1438): lazy, `New TMDbClient(_SpecialSettings.APIKey)`, `GetConfigAsync().GetAwaiter().GetResult()`, `MaxRetryCount = 2`, Exception propagiert zum Aufrufer
- [x] Methode `SearchMovie` — vollständig auf TMDb neu implementiert (Z. 1440–1506): `SearchMovieAsync` mit Seiteniteration `Page <= TotalPages AndAlso Page <= 3`, `GetMovieExternalIdsAsync` je Treffer mit Einzelfall-Toleranz (`Try/Catch` + `logger.Error`, Treffer ohne `ImdbId` übersprungen), Mapping auf `MediaContainers.Movie` (`Title`, `Year` aus `ReleaseDate`, `UniqueIDs.IMDbId` + `TMDbId`, `Lev` via `StringUtils.ComputeLevenshtein`), Klassifikation `ExactMatches`/`PartialMatches` (exakter Titel case-insensitiv + Jahresgleichheit); sämtliche `HtmlWeb`-/`imdb.com`-Suchaufrufe und `Search*Titles`-Auswertungen entfernt; `PopularTitles`/`TvTitles`/`VideoTitles`/`ShortTitles` werden nicht mehr befüllt
- [x] Methode `SearchTVShow` — analog neu implementiert (Z. 1520–1566): `SearchTvShowAsync` + `GetTvShowExternalIdsAsync` → `SearchResults_TVShow.Matches` (`Title` aus `Name`/`OriginalName`, `Premiered` aus `FirstAirDate`, `UniqueIDs.IMDbId` + `TMDbId`)
- [x] Methode `bwIMDB_RunWorkerCompleted` — `e.Cancelled`-/`e.Error`-Prüfung vor `e.Result`, `logger.Error` + `RaiseEvent Exception(e.Error)` (Z. 143–153)
- [x] Methode `GetSearchMovieInfo` — `SearchMovie`-Aufruf in den bestehenden `Try`-Block verschoben (Z. 919)
- [x] Methode `GetSearchTVShowInfo` — `Try/Catch` mit `logger.Error` → `Nothing` ergänzt (Z. 991–1025)
- [x] Event `Public Event Exception(ByVal ex As Exception)` (Z. 92) — wird nun tatsächlich gefeuert (`bwIMDB_RunWorkerCompleted`)
- [x] `Imports TMDbLib.Client` ergänzt (Z. 26); `Imports HtmlAgilityPack` bestehen geblieben
- [x] `SearchResults_Movie`/`SearchResults_TVShow` — unverändert (Ergebnisvertrag)

### `IMDB_Data` (`Addons\scraper.IMDB.Data\IMDB_Data.vb`)

- [x] Feld `Private Const _strAPIKey As String` (Fallback-Key identisch zu `TMDB_Data.vb:57`) — Z. 49
- [x] Feld `Private strPrivateAPIKey As String` — Z. 40
- [x] `SpecialSettings.APIKey As String` — Z. 602; fünf `Search*Titles`-Felder als deprecated markiert bestehen geblieben (Z. 607–612)
- [x] `LoadSettings_Movie`/`LoadSettings_TV` — `APIKey` mit Fallback `_strAPIKey` (`Enums.ContentType.Movie`/`.TV`); fünf `Search*Titles`-`GetBooleanSetting`-Zeilen entfernt (Z. 264–265, 293–294)
- [x] `SaveSettings_Movie`/`SaveSettings_TV` — `SetSetting("APIKey", _setup_*.txtApiKey.Text.Trim, , Enums.ContentType.*)`; fünf `SetBooleanSetting`-Zeilen entfernt (Z. 320, 347)
- [x] `InjectSetupScraper_Movie`/`_TV` — `txtApiKey.Text = strPrivateAPIKey` + Unlock-Zustand nach TMDb-Muster; fünf Checkbox-Belegungen entfernt (Z. 168–174, 221–227)
- [x] `SaveSetupScraper_Movie`/`_TV` — `strPrivateAPIKey`/`_SpecialSettings_*.APIKey` aus `txtApiKey.Text.Trim` mit Fallback; fünf Checkbox-Rücklesungen entfernt (Z. 375–377, 410–411)

### Dialoge IMDb-Modul

- [x] `dlgIMDBSearchResults_Movie` — `AddHandler _IMDB.Exception, AddressOf SearchFailed` im Load-Handler (Z. 243); `SearchFailed`-Handler mit `tmrWait`/`tmrLoad`-Stop, `pnlLoading.Visible = False`, `chkManual.Enabled = True`, unterscheidbarer Fehlerknoten via eLang 1493 (Z. 342–359); `sInfo Is Nothing`-Fallback übernimmt `tvResults.SelectedNode.Tag` in `_tmpMovie.UniqueIDs.IMDbId` (Z. 331–335)
- [x] `dlgIMDBSearchResults_TV` — analog: `AddHandler` (Z. 242), `SearchFailed` (Z. 325–342), `_tmpTVShow.UniqueIDs.IMDbId`-Fallback (Z. 319–323)

### Settings-Panels IMDb-Modul

- [x] `frmSettingsHolder_Movie` — fünf `Search*Titles`-Checkboxen vollständig entfernt (Deklarationen, `Controls.Add`, Init-Blöcke, `Friend WithEvents`, `CheckedChanged`-Handler, `Setup()`-Texte); `lblApiKey`/`txtApiKey`/`btnUnlockAPI`/`lblEMMAPI` in `tblScraperOpts` ergänzt; `btnUnlockAPI_Click` + `txtApiKey_TextChanged` → `RaiseEvent ModuleSettingsChanged`; `Setup()`-Texte (eLang 870/1188/1189)
- [x] `frmSettingsHolder_TV` — analog ergänzt (Designer + Code + `SetUp()`-Texte)

### TMDb-Modul (`Addons\scraper.TMDB.Data`)

- [x] `Public Event Exception(ByVal ex As Exception)` im `Scraper` — `clsScrapeTMDB.vb:158`
- [x] `bwTMDB_RunWorkerCompleted` — `e.Cancelled`-/`e.Error`-Prüfung vor `e.Result`, `logger.Error` + `RaiseEvent Exception(e.Error)`, zusätzlich `e.Result Is Nothing`-Guard (Z. 229–242)
- [x] `SearchMovie`/`SearchMovieSet`/`SearchTVShow` — `Nothing`-sichere Auswertung der `APIResult.Result`-Ergebnisse (`Is Nothing`-Guards vor allen `TotalResults`/`Results`-Zugriffen; deckt die 404→`Nothing`-Semantik von TMDbLib 2.3.0 ab) — *siehe offene Aufgabe 22 für die fehlende Faulted-Task-Absicherung*
- [x] `dlgTMDBSearchResults_Movie`/`_TV`/`_MovieSet` — `AddHandler _TMDB.Exception` + `SearchFailed`-Handler mit Fehlerknoten in allen drei Dialogen

### Projektdateien / Konfiguration / Übersetzungen

- [x] `Addons\scraper.IMDB.Data\packages.config` — `TMDbLib` 2.3.0 + transitive Pakete (`Newtonsoft.Json` 13.0.3, `System.IO` 4.3.0, `System.Net.Http` 4.3.4, `System.Runtime` 4.3.1, `System.Security.Cryptography.*`)
- [x] `Addons\scraper.IMDB.Data\scraper.Data.IMDB.vbproj` — Referenzen mit HintPaths/`Private`-Flags, `TMDbLib, Version=2.0.0.0` mit HintPath `packages\TMDbLib.2.3.0\lib\net45\TMDbLib.dll`, `<Import Include="System.Threading.Tasks" />`
- [x] `Addons\scraper.TMDB.Data\packages.config` + `scraper.Data.TMDB.vbproj` — `TMDbLib` 1.9.1 → 2.3.0, `Reference Include` → `Version=2.0.0.0` + HintPath net45
- [x] `EmberMediaManager\App.config` + `Addons\scraper.IMDB.Data\app.config` — `bindingRedirect` `TMDbLib 0.0.0.0-2.0.0.0 → 2.0.0.0`
- [x] `EmberAPI\Translations\en-US.xml` — neuer String ID 1493 „The search could not be completed: {0}"
- [x] TMDb-Befund dokumentiert — `befund-tmdb.md` (Hypothesen a/b, verifizierte Defekte, nicht beweisbare Punkte ohne Kundenumgebung)
- [x] Build-Verifikation — `test-results.md`; im Review erneut ausgeführt: MSBuild `Debug|x86` Exit-Code 0 für `scraper.Data.IMDB.vbproj` und `scraper.Data.TMDB.vbproj`
- [x] Abnahmeprotokoll-Gerüst — `abnahmeprotokoll.md` mit allen 7 Pflicht-Szenarien aus dem Plan

## Offene Aufgaben

- [ ] **Task 22 — `APIResult.Result` exception-sicher in `clsScrapeTMDB.SearchMovie`/`SearchMovieSet`/`SearchTVShow`** — teilweise umgesetzt: Es wurden nur `Is Nothing`-Guards ergänzt (`clsScrapeTMDB.vb:1392, 1399, 1403, 1410, 1414, 1422, 1425, 1481, 1487, 1491, 1534, 1537, 1543 u. a.). Gefaultete Tasks sind weiterhin ungesichert: `Movies = APIResult.Result` (Z. 1390, 1394, 1401, 1405, 1412, 1416, 1456, 1459 sowie analog in `SearchMovieSet` Z. 1479/1483 und `SearchTVShow` Z. 1531/1535) wirft bei API-/Netzwerkfehlern weiterhin `AggregateException` — es gibt weder eine `APIResult.Exception`-Prüfung noch ein Try/Catch, kein Entpacken der `AggregateException` und kein `logger.Error` innerhalb der drei Methoden (Plan: „`logger.Error` + leeres Ergebnis statt unbehandelter Exception"). Der Dialog-Pfad ist indirekt über `e.Error` in `bwTMDB_RunWorkerCompleted` abgedeckt; der synchrone Pfad (`GetSearchMovieInfo` Z. 1167, `GetSearchMovieSetInfo` Z. 1198, `GetSearchTVShowInfo` Z. 1229 → `TMDB_Data.Scraper_*` → `ModulesManager.ScrapeData_*`) hat keinerlei Try/Catch, die Exception propagiert weiterhin unbehandelt bis in die Scrape-Kette.
- [ ] **Task 27 — Manuelle Abnahme** — teilweise umgesetzt: `abnahmeprotokoll.md` enthält alle 7 Pflicht-Szenarien aus dem Plan, aber kein Szenario ist als durchgeführt dokumentiert (alle Ergebnis-Checkboxen „☐ bestanden ☐ fehlgeschlagen" unmarkiert). Die manuelle Abnahme gegen die Live-TMDb-API steht noch aus.

## Hinweise

- **Abhängigkeit der offenen Aufgaben:** Task 22 ist unabhängig nachimplementierbar (reine Ergänzung von `APIResult.Exception`-Prüfung/Try-Catch um die `.Result`-Zugriffe in den drei Suchmethoden); Task 27 erfordert eine laufende Anwendung mit gültigem TMDb-Key.
- **Binding-Redirect funktional neutral:** `TMDbLib` 2.3.0 ist nicht strong-named (`PublicKeyToken=null`) — die eingetragenen Redirects sind wirkungslos, aber harmlos; dokumentiert in `test-results.md`. Konsistenz wird über identische HintPaths in beiden Modulen sichergestellt.
- **Plankonforme Abweichung im Detail:** `SearchMovie` übergibt `strTitleFiltered` (Jahr via `FilterYear` entfernt) als Query an `SearchMovieAsync` und reicht das Jahr separat als `iYear` — konsistent zur Klassifikationsregel; zusätzlich wird das Jahr aus einem „Titel (yyyy)"-Suffix extrahiert, falls `year` leer/nicht numerisch ist. `Lev` wird wie geplant über `ComputeLevenshtein(FilterYear(strTitle).ToLower, hitTitle)` gesetzt; die Exact-Prüfung normalisiert den Treffertitel via `FilterYear` — erfüllt die Regel „exakter Titel + Jahresgleichheit".
- **`System.Net.Http`-Referenz** im IMDB-vbproj ohne HintPath (GAC/Framework-Referenz) — identisch zum Muster in `scraper.Data.TMDB.vbproj:146`; Build erfolgreich.
- **Detailabruf bleibt plangemäß defekt** (IMDb-HTML `/reference` u. a.) — dokumentierter Folgebedarf; der `sInfo = Nothing`-Fallback sichert den OK-Pfad mit IMDb-ID.
