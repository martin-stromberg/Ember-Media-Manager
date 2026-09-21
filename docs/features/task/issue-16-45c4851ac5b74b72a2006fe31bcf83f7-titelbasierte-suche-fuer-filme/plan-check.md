# Plan-Gegenprüfung

## Ergebnis

**Status:** Plan vollständig

## Abgleich Akzeptanzkriterien

| Akzeptanzkriterium | Umsetzung im Plan | Testnachweis im Plan | Status |
|--------------------|-------------------|----------------------|--------|
| Filmsuche „28 Days Later" → Treffer mit `tt0289043` im Dialog | Schritt 4: `SearchMovie` auf `TMDbClient.SearchMovieAsync` umstellen, IMDb-ID-Auflösung je Treffer via `GetMovieExternalIdsAsync`, Mapping auf `MediaContainers.Movie` inkl. `UniqueIDs.IMDbId`/`Lev`, Klassifikation `ExactMatches`/`PartialMatches` (Designentscheidung + Programmablauf „Filmsuche (Dialog-Pfad)") | E2E-Tabelle Pflicht-Szenario „(Re)Scrape ‚28 Days Later' → `dlgIMDBSearchResults_Movie` zeigt Treffer mit `tt0289043`" (manuelles Abnahmeprotokoll) | Abgedeckt |
| Filmsuche „28 Weeks Later" → `tt0463854`; „28 Years Later" → `tt10548174` | dto. (gleicher Pfad) | E2E-Tabelle Pflicht-Szenario (manuell) | Abgedeckt |
| Analoge Seriensuche → Treffer mit korrekter IMDb-ID in `dlgIMDBSearchResults_TV` | Schritt 4: `SearchTVShow` über `SearchTvShowAsync` + `GetTvShowExternalIdsAsync` → `SearchResults_TVShow.Matches` (Programmablauf „Seriensuche") | E2E-Tabelle Pflicht-Szenario „Seriensuche mit bekanntem Titel → korrekte IMDb-ID" (manuell) | Abgedeckt |
| Manuelle ID-Eingabe (`chkManual`/`txtIMDBID`/`btnVerify`) bleibt funktionsfähig | Dialoge ohne Umbau; `chkManual.Enabled = True` auch im Fehlerpfad; „continue without verification"-Pfad (`OK_Button_Click` Z. 260–280) bleibt bestehen (Seiteneffekte-Abschnitt) | E2E-Tabelle Pflicht-Szenario „`chkManual` + `txtIMDBID` + `btnVerify` in beiden Dialogen" (manuell) | Abgedeckt |
| Unterscheidbare Fehlermeldung bei Quell-Ausfall statt „No Matches Found" | Schritt 5: `bwIMDB_RunWorkerCompleted` mit `e.Error`/`e.Cancelled`-Prüfung → `logger.Error` + `RaiseEvent Exception`; `SearchFailed`-Handler mit eigenem Fehlerknoten in beiden IMDb-Dialogen; neuer String in `en-US.xml`; gleiche Behandlung im TMDb-Modul (Schritt 6) | E2E-Tabelle Pflicht-Szenario „Quell-Ausfall simulieren (ungültiger `APIKey` bzw. Netzwerk trennen) → Fehlermeldung statt ‚No Matches Found'" (manuell) | Abgedeckt |
| Vorbedingung: TMDb-Befund eingrenzen und beheben | Schritt 1 (Eingrenzung via `AdvancedSettings`/`EmberModules`/Logzeilen `clsAPIModules.vb:944`, Ergebnis dokumentieren) + Schritt 6 (exception-sichere `APIResult.Result`-Auswertung, `bwTMDB_RunWorkerCompleted` mit `e.Error`-Prüfung + neuem `Exception`-Event, Fehlerknoten in `dlgTMDBSearchResults_*`) + Schritt 2 (`TMDbLib` 1.9.1 → 2.3.0 synchron in beiden Modulen) | E2E-Tabelle Pflicht-Szenario „Scrape mit beiden aktivierten Daten-Scrapern → Kette läuft weiter (`[Using]`-Logzeilen)" + Build-Verifikation Schritt 7 | Abgedeckt |
| `APIKey`-Setting je ContentType mit eingebettetem Fallback-Key und `txtApiKey` in beiden Settings-Panels | Schritt 3: `SpecialSettings.APIKey`, `_strAPIKey`/`strPrivateAPIKey`, Load/Save nach `TMDB_Data`-Muster (`GetSetting`/`SetSetting` mit `Enums.ContentType.*`), Panels um `lblApiKey`/`txtApiKey`/`btnUnlockAPI`/`lblEMMAPI` erweitert; leer → Fallback, ungültig → 401-`UnauthorizedAccessException` auf Fehlerpfad (Validierungsregeln) | Implizit durch Pflicht-Szenario „ungültigen `APIKey` eintragen" (setzt `txtApiKey` voraus) und durch die erfolgreichen Suchszenarien mit Fallback-Key | Abgedeckt |
| Deprecation der fünf `Search*Titles`-Settings inkl. Entfernen der Checkboxen | Schritt 3 + Klassenänderungen `IMDB_Data`/`frmSettingsHolder_Movie` (Checkboxen, Handler, `Setup()`-Texte, Load/Save-Zeilen entfallen; Einträge in Kunden-`AdvancedSettings.xml` bleiben wirkungslos — keine Migration) | Kein dedizierter Testnachweis nötig (kein Akzeptanzkriterium); Sichtbarkeit im manuellen Abnahmedurchlauf gegeben | Abgedeckt |
| Ergebnisvertrag unverändert (`SearchResults_*`, Dialoge, `GetSearchMovieInfo`/`GetSearchTVShowInfo`-Heuristik) | `SearchResults_Movie`/`_TVShow` explizit unverändert; Heuristik-Logik (`Lev <= 5`, `FindYear`, `ScrapeType`-Zweige) unverändert — lediglich `SearchMovie`-Aufruf in bestehenden `Try`-Block verschoben bzw. `Try/Catch` in `GetSearchTVShowInfo` ergänzt (Fehlerabsicherung, keine Logikänderung); `Scraper_Movie`/`Scraper_TV` unverändert | Erfolgreiche Dialog-Szenarien (Ask-Pfad) + Pflicht-Szenario Kettenfortsetzung | Abgedeckt |
| `TMDbLib`-Verweis in `scraper.IMDB.Data` neu (inkl. transitive Pakete) | Schritt 2 + Projektdateien-Abschnitt: `packages.config`/`vbproj` nach `scraper.Data.TMDB`-Muster, HintPath `TMDbLib.2.3.0\lib\net45`, `bindingRedirect` in `EmberMediaManager\app.config`, `Import System.Threading.Tasks` | Build-Verifikation Schritt 7 (fehlerfreie Kompilierung beider Module, Debug\|x86 wie CI) | Abgedeckt |
| Nicht-Anforderung: `GetTMDbIdByIMDbId` bleibt Stub; keine Framework-Änderung | Plan listet `GetTMDbIdByIMDbId` explizit als „Unverändert"; `ModulesManager`, `Enums.ScrapeType`, Scrape Order, `ScrapeModifiers` unverändert (`Cancelled`-Abbruch bleibt dokumentiertes Bestandsverhalten) | — | Abgedeckt |

## Fehlende oder unvollständige Testanforderungen

—

## E2E-Abdeckung

| Benutzerfluss / Akzeptanzkriterium | Geplanter E2E-Test | Status |
|------------------------------------|--------------------|--------|
| Filmsuche über Dialog: „28 Days Later" → `tt0289043` | Pflicht-Szenario des dokumentierten manuellen Abnahmeprotokolls (Setup: (Re)Scrape mit Titel, Aktion: Dialog `dlgIMDBSearchResults_Movie`, Ergebnis: Trefferknoten mit IMDb-ID) | Abgedeckt (manuell, gemäß Anwender-Entscheidung als Ersatz für automatisierte E2E-Tests akzeptiert) |
| Filmsuche: „28 Weeks Later" → `tt0463854`, „28 Years Later" → `tt10548174` | Pflicht-Szenario (manuell) | Abgedeckt |
| Seriensuche über `dlgIMDBSearchResults_TV` → Treffer mit korrekter IMDb-ID | Pflicht-Szenario (manuell) | Abgedeckt |
| Manuelle IMDb-ID-Eingabe (`chkManual`/`txtIMDBID`/`btnVerify`) in beiden Dialogen | Pflicht-Szenario (manuell) | Abgedeckt |
| Quell-Ausfall (ungültiger `APIKey`/Netzwerk getrennt) → unterscheidbare Fehlermeldung statt „No Matches Found" | Pflicht-Szenario (manuell); deckt Fehlertransport Worker → `e.Error` → `Exception`-Event → Fehlerknoten ab | Abgedeckt |
| Scrape-Order-Fluss: beide Daten-Scraper aktiv (IMDb vor TMDb) → Kette läuft nach Trefferauswahl weiter (`[Using]`-Logzeilen) | Pflicht-Szenario (manuell); verifiziert Behebung des Hypothese-b-Effekts | Abgedeckt |
| Heuristik-Pfad ohne Dialog (`ScrapeType` `Auto`/`Skip` mit `ExactMatches`/`Lev <= 5`) | Kein dediziertes Protokoll-Szenario; Verhalten laut Plan unverändert und durch die Dialog-Szenarien indirekt mitbewiesen (gleiche `SearchMovie`-Pipeline und Kategorienbefüllung) | Nicht erforderlich mit Begründung: kein eigenes Akzeptanzkriterium; die Heuristik ist explizit unverändert, lediglich die Datenquelle der Kategorien ändert sich — diese wird durch die Dialog-Pflicht-Szenarien nachgewiesen |
| Fehlerfall im synchronen Heuristik-Pfad (API-Exception → `Nothing` statt Propagieren bis `ModulesManager`) | Kein Protokoll-Szenario; über `Try/Catch`-Erweiterung in `GetSearchMovieInfo`/`GetSearchTVShowInfo` (Schritt 5) abgesichert | Nicht erforderlich mit Begründung: ohne UI auslösbar nur über gezielte Fehlerinjektion; Fehlerrobustheit der Kette wird durch das Quell-Ausfall-Szenario (Dialog-Pfad) und den unveränderten `Catch`-Rumpf abgedeckt |
| Automatisierte E2E-/UI-Tests generell | Keine geplant | Nicht erforderlich mit Begründung: kein UI-Test-Framework im Projekt, `EmberAPI_Test` nicht kompilierbar (fehlendes `UnitTests.vbproj`, 203× `BC30002`), Live-TMDb-API-Abhängigkeit; Anwender-Entscheidung: dokumentiertes manuelles Abnahmeprotokoll, FlaUI-/WinAppDriver-Smoke-Test als dokumentierter Folgebedarf |

## Fehlende oder unvollständige Planbestandteile

—

## Hinweise

- **Konkretisierung des Serien-Szenarios:** Das Pflicht-Szenario „Seriensuche mit bekanntem Titel" sollte bei der Protokollerstellung mit einem konkreten Titel und der erwarteten IMDb-ID festgelegt werden (analog zu den drei Referenzfilmen), damit das Abnahmeergebnis eindeutig prüfbar ist.
- **Settings-Panel explizit abhaken:** Das Protokoll sollte einen Checklistenpunkt für die Settings-Panels enthalten (fünf `chk*Titles`-Checkboxen entfernt, `txtApiKey`/`btnUnlockAPI`/`lblEMMAPI` vorhanden, leerer Eintrag → Fallback-Key greift — letzteres ist durch die erfolgreichen Suchszenarien implizit bewiesen, da ohne eigenen Key der Fallback genutzt wird).
- **Optionaler Protokoll-Punkt Auto/Skip:** Ein kurzer Auto-Scrape eines Referenzfilms ohne Dialog würde die Heuristik-Kompatibilität (`ExactMatches.Count = 1`, `Lev <= 5`) mit den neu befüllten Kategorien zusätzlich absichern — nicht erforderlich, aber günstig mitprüfbar.
- **Rate-Limit-Randfall:** Bis zu 3 Suchseiten à ~20 `*ExternalIdsAsync`-Aufrufe können das TMDb-Rate-Limit erreichen (im Plan als Risiko benannt, `MaxRetryCount = 2` als Milderung). Bei der Abnahme ist darauf zu achten, dass ein Rate-Limit-Fehler nicht mit einem Funktionsfehler verwechselt wird — er landet korrekt auf dem neuen Fehlerpfad.
- **Deployment-Hinweis beachten:** Die per CopyLocal ausgelieferte `TMDbLib.dll` (Assembly-Identität neu `2.0.0.0`) muss die alte Version im `Modules\scraper.data.tmdb`-Ausgabeverzeichnis ersetzen; der neue `bindingRedirect` in `EmberMediaManager\app.config` ist Voraussetzung für die gemeinsame AppDomain-Auflösung beider Module.
- **Detailabruf bleibt defekt (bewusst):** Der `sInfo = Nothing`-Fallback sichert nur das Minimalziel `DialogResult.OK` mit IMDb-ID; die Dialog-Vorschau liefert weiterhin keine Detaildaten (`/reference`-Endpunkt defekt, dokumentierter Folgebedarf). Das Protokoll sollte diesen Erwartungswert festhalten, damit die fehlende Vorschau nicht als Abnahmefehler gewertet wird.
- **Englisch-Fallback-Client (`_clientE`):** Die Anforderung nennt ihn nur optional („ggf."); der Plan verzichtet bewusst darauf — Entscheidung ist konsistent, sollte bei der Abnahme nicht als Lücke gewertet werden.
