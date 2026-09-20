# Umsetzungsplan: Anforderungsanalyse "Titelbasierte IMDb-Suche für Filme und Serien wiederherstellen" (Issue #8)

## Übersicht

Kernlieferung ist gemäß Anforderung ein **Analyse-/Anforderungsdokument** (Markdown) für das zuständige Entwicklungsprojekt: Es spezifiziert die Umstellung der defekten titelbasierten Suche des Moduls `scraper.Data.IMDB` (`SearchMovie`/`SearchTVShow` in `clsScrapeIMDB.vb`) von den abgeschalteten IMDb-HTML-Endpunkten (`/find`, `/search/title`) auf eine technisch stabile Schnittstelle, bei unverändertem Ergebnisvertrag (`SearchResults_Movie`/`SearchResults_TVShow`, Dialoge, `ScrapeType`-Heuristik). **Neuer Befund aus der Kundenrückmeldung:** Beim Kunden sind sowohl der IMDb- als auch der TMDb-Daten-Scraper aktiviert — und die Suche liefert trotzdem keine Ergebnisse. Die Analyse muss daher zusätzlich festhalten, dass auch die bestehende TMDb-Integration (`clsScrapeTMDB.vb`) offenbar gestört ist bzw. im Suchpfad nicht greift, und deren Fehlereingrenzung als Anforderung formulieren. Es werden **keine Codeänderungen** umgesetzt — die Anforderung verlangt ausschließlich die Analyse; alle Implementierungsdetails werden im Dokument als Anforderungen an das Entwicklungsprojekt formuliert.

## Designentscheidungen

| Komponente / Bereich | Gewählter Ansatz | Begründung |
|----------------------|-----------------|------------|
| Analyse-Artefakt | Neue Datei `docs/features/task/issue-8-168e4a79c1c24dadb014bdd3fb7c170d-suche-nach-filmen-und-serien-l/analysis.md` | Ablage im selben Branch-Dokumentationsordner wie `requirement.md`/`inventory.md`; eigenständige Datei, damit sie dem Entwicklungsprojekt separat übergeben werden kann. |
| Ziel-Schnittstelle (Entscheidung des Anwenders, in der Analyse festzuhalten) | **TMDb-API primär**, OMDb-API alternativ, IMDb-interne Endpunkte nur als Fallback | Vom Anwender bestätigt. Infrastruktur existiert im Schwestermodul `scraper.TMDB.Data`: `TMDbLib` 1.9.1 (`SearchMovieAsync`, `SearchTvShowAsync`, `FindAsync(FindExternalSource.Imdb)` für IMDb-ID-Mapping), eingebetteter Fallback-API-Key (`TMDB_Data.vb:57`), konfigurierbares `APIKey`-Setting als Muster. **Wichtige Einschränkung, die das Dokument enthalten muss:** Die vorhandene TMDb-Integration liefert beim Kunden ebenfalls keine Suchtreffer (siehe Befund unten) — die TMDb-Empfehlung gilt daher nur unter der Bedingung, dass die Ursache dort eingegrenzt und behoben wird (veraltete `TMDbLib` 1.9.1, TLS-/API-Änderungen, ungültiger Fallback-Key oder Scrape-Order-Effekt). OMDb bleibt zweite Option: `MovieCollection.OpenMovieDatabase` 3.0.1 bietet `SearchMoviesAsync` (OMDb-`?s=`-Suche), das Modul `scraper.Data.OMDb` implementiert aber keine Titelsuche → Neuimplementierung nötig, zudem Pflicht-API-Key ohne eingebetteten Fallback. IMDb-interne Endpunkte nur als Fallback dokumentieren (undokumentiert, fragil). |
| Ergebnisvertrag-Mapping (Entscheidung des Anwenders) | API-Treffer auf `ExactMatches`/`PartialMatches` verteilen; `PopularTitles`/`TvTitles`/`VideoTitles`/`ShortTitles` entfallen; die fünf `Search*Titles`-Settings werden deprecated | Vom Anwender bestätigt. `dlgIMDBSearchResults_Movie` rendert Kategorien, funktioniert aber auch mit teilweise leeren Listen; die Auto-Match-Heuristik (`Lev <= 5`, `FindYear`) arbeitet primär auf `ExactMatches`. Künstliche Verteilung auf sechs Kategorien wäre semantisch falsch. |
| Umfang (Entscheidung des Anwenders) | Suche zuerst — für Filme **und** Serien gemeinsam; Detailabruf-Defekt als separater Folgebedarf | Vom Anwender bestätigt. `SearchMovie` und `SearchTVShow` teilen denselben Mechanismus und sind identisch betroffen. Die ebenfalls defekten Detailendpunkte (`/reference`, `/episodes` u. a.) sind ein größerer Umbau, der das Akzeptanzkriterium (Suchdialog zeigt Treffer) nicht blockiert — als Folgebedarf im Dokument benennen. |
| Fehlerkommunikation (Entscheidung des Anwenders) | Unterscheidbare Fehlermeldung statt pauschalem „No Matches Found" | Vom Anwender bestätigt. Quell-Ausfälle (HTTP-Fehler, Rate-Limit, ungültiger API-Key) müssen erkannt, geloggt (`logger.Error`) und im Dialog von „keine Treffer" unterscheidbar gemacht werden; konkrete UI-Form bleibt dem Entwicklungsprojekt überlassen. |
| Abnahmemodus (Entscheidung des Anwenders) | Film- und Seriensuche werden gemeinsam abgenommen | Vom Anwender bestätigt — identischer Mechanismus, getrennte Abnahme brächte keinen Mehrwert. |
| Befund: TMDb-Suche ohne Treffer | Als eigenen Anforderungsblock im Analysedokument führen: Ursache ist im Entwicklungsprojekt einzugrenzen | Beim Kunden sind IMDb- **und** TMDb-Daten-Scraper aktiviert und die Suche liefert dennoch keine Ergebnisse — auch nicht bei allen aktivierten Scrapern. Zwei Hypothesen sind im Dokument zu formulieren: (a) die TMDb-basierte Titelsuche ist ebenfalls defekt (veraltete `TMDbLib` 1.9.1, TLS-/API-Änderungen seitens TMDb, ungültiger eingebetteter Fallback-Key); (b) Scrape-Order-Effekt — der IMDb-Suchdialog greift in der Reihenfolge zuerst und TMDb wird nie erreicht/angezeigt. Konkrete Untersuchungsanforderung: verifizieren, ob `clsScrapeTMDB.vb` `SearchMovie`/`SearchTvShowAsync` (`_client.SearchMovieAsync`, Z. 1362–1449; `SearchTvShowAsync`, Z. 1504–1560) überhaupt aufgerufen wird und was die API antwortet. |

## Programmabläufe

Es wird kein Programmablauf implementiert (reine Dokumentationsaufgabe). Das Analysedokument muss jedoch die folgenden **Zielabläufe** und **Untersuchungsanforderungen** an das Entwicklungsprojekt spezifizieren:

### Zielablauf: Titelsuche Film (zu spezifizieren)

1. `IMDB_Data.Scraper_Movie` öffnet bei `ScrapeType.SingleScrape`/`SingleAuto` ohne vorhandene IMDb-/TMDb-ID den Dialog `dlgIMDBSearchResults_Movie` (unverändert, `IMDB_Data.vb:473–482`).
2. Der Dialog ruft `Scraper.SearchMovieAsync` → `bwIMDB_DoWork` → `Scraper.SearchMovie` (unverändert).
3. `SearchMovie` fragt statt `imdb.com/find` + `/search/title` die neue Schnittstelle ab (festgelegt: `TMDbClient.SearchMovieAsync` + `FindAsync(FindExternalSource.Imdb)` zur IMDb-ID-Auflösung).
4. API-Treffer werden auf `MediaContainers.Movie` gemappt (`Title`, `Year`, `UniqueIDs.IMDbId`, `Lev` via `StringUtils.ComputeLevenshtein`) und in `SearchResults_Movie.ExactMatches`/`PartialMatches` eingesortiert (festgelegt: Spezialkategorien entfallen).
5. `SearchResultsDownloaded_Movie` befüllt den Dialog wie bisher; `GetSearchMovieInfo` wendet die `ScrapeType`-Heuristik unverändert an.
6. Fehlerfall (HTTP-Fehler, Rate-Limit, fehlender/ungültiger API-Key): Fehler wird geloggt (`logger.Error`, Muster aus `GetSearchMovieInfo` Z. 959–962) und dem Anwender als von „keine Treffer" unterscheidbare Meldung angezeigt (festgelegt — nicht mehr stillschweigend „No Matches Found").

Beteiligte Klassen/Komponenten: `Scraper`, `SearchResults_Movie`, `IMDB_Data`, `dlgIMDBSearchResults_Movie`, `TMDbLib.Client.TMDbClient` (Referenz: `clsScrapeTMDB.vb`).

### Zielablauf: Titelsuche Serie (zu spezifizieren)

Analog: `IMDB_Data.Scraper_TV` → `dlgIMDBSearchResults_TV` → `SearchTVShowAsync` → `Scraper.SearchTVShow` → neue Schnittstelle (`SearchTvShowAsync` + `FindAsync`) → `SearchResults_TVShow.Matches` (einzige Kategorie) → `SearchResultsDownloaded_TV`. Wird gemeinsam mit der Filmsuche umgesetzt und abgenommen (festgelegt).

Beteiligte Klassen/Komponenten: `Scraper`, `SearchResults_TVShow`, `IMDB_Data`, `dlgIMDBSearchResults_TV`.

### Untersuchungsanforderung: TMDb-Suchpfad beim Kunden (zu spezifizieren)

Das Analysedokument muss das Entwicklungsprojekt beauftragen, den TMDb-Suchpfad einzugrenzen:

1. Prüfen, ob bei der Kundenkonfiguration (IMDb- und TMDb-Scraper aktiv) der TMDb-Pfad überhaupt erreicht wird — d.h. ob `ModulesManager`/Scrape Order bei mehreren aktivierten Daten-Scrapern beide aufruft oder der IMDb-Dialog (`dlgIMDBSearchResults_Movie`/`_TV`) den TMDb-Dialog (`dlgTMDBSearchResults_Movie`) verdrängt.
2. Falls `clsScrapeTMDB.vb` `SearchMovie`/`SearchTVShow` aufgerufen wird: API-Antwort von `_client.SearchMovieAsync`/`SearchTvShowAsync` prüfen — Kompatibilität von `TMDbLib` 1.9.1 mit der aktuellen TMDb-API (Endpunkt-/Payload-Änderungen, TLS-Mindestversion), Gültigkeit des eingebetteten Fallback-Keys (`TMDB_Data.vb:57`).
3. Ergebnis als Befund dokumentieren; bei defekter TMDb-Integration ist die Ursache zu beheben, bevor die TMDb-API als Zielschnittstelle für das IMDb-Modul übernommen wird.

Beteiligte Klassen/Komponenten: `ModulesManager`, `TMDB_Data`, `clsScrapeTMDB.vb` (`Scraper`), `dlgTMDBSearchResults_Movie`, `TMDbLib.Client.TMDbClient`.

### Ablauf dieser Umsetzung (Dokumentationsarbeit)

1. Recherche-Fakten im Repo verifizieren (NuGet-Referenzen, Bibliotheksfähigkeiten, Wiederverwendbarkeit des TMDb-Client-Codes, Scrape-Order-Mechanik für die TMDb-Hypothesen).
2. `analysis.md` mit der unten festgelegten Gliederung erstellen.
3. Konsistenzprüfung gegen `requirement.md` (Referenzfälle, Akzeptanzkriterien, alle Punkte der abgeleiteten Anforderungsbeschreibung abgedeckt, TMDb-Befund enthalten).

## Neue Klassen

Keine — reine Dokumentationsaufgabe. (Klassen, die das Entwicklungsprojekt später anlegen soll, werden im Analysedokument nur als Anforderung beschrieben, z. B. ein gekapselter API-Gateway für die Titelsuche.)

## Änderungen an bestehenden Klassen

Keine — reine Dokumentationsaufgabe.

## Datenbankmigrationen

Keine.

## Validierungsregeln

Keine — reine Dokumentationsaufgabe. (Die Analyse soll jedoch als Anforderung festhalten: Validierung eines konfigurierbaren API-Keys — leer/ungültig → Fallback-Key bzw. klare Fehlermeldung; Validierung von API-Antworten — `Response=False`/Fehlerfeld bei OMDb, Exception/Empty bei TMDbLib.)

## Konfigurationsänderungen

Keine — reine Dokumentationsaufgabe. Im Analysedokument ist als Anforderung zu dokumentieren:

| Eintrag (künftig, vom Entwicklungsprojekt) | Typ | Standardwert | Zweck |
|---------|-----|--------------|-------|
| `APIKey` (IMDb-Modul, `AdvancedSettings` + `txtApiKey` im Settings-Panel) | `String` | eingebetteter Fallback-Key | Eigener TMDb-API-Key; Muster exakt wie `TMDB_Data.vb:352–353, 397–400` |
| `SearchPartialTitles`/`SearchPopularTitles`/`SearchTvTitles`/`SearchVideoTitles`/`SearchShortTitles` | `Boolean` | unverändert | **Festgelegt:** deprecaten (bei API-basierter Suche existieren die IMDb-Ergebnisbereiche nicht mehr); Settings-UI-Anpassung als Anforderung benennen |

## Seiteneffekte und Risiken

- **Keine Code-Seiteneffekte:** Es wird kein Code geändert; Build, Tests und Laufzeitverhalten bleiben unberührt.
- **Risiko defekte Zielinfrastruktur:** Die empfohlene/entschiedene Zielschnittstelle (TMDb-API) ist im Ist-System selbst betroffen — liefert die bestehende TMDb-Integration keine Treffer, muss deren Ursache (veraltete `TMDbLib` 1.9.1, TLS-/API-Änderungen, Fallback-Key, Scrape-Order-Effekt) vor oder parallel zur Umstellung eingegrenzt werden. Das Analysedokument muss diese Untersuchung explizit als Anforderung enthalten, sonst besteht das Risiko, dass das Entwicklungsprojekt auf eine ebenfalls defekte Basis migriert.
- **Risiko veraltete Empfehlung:** Die Analyse dokumentiert die Schnittstellenentscheidung; weicht das Entwicklungsprojekt davon ab, muss das Dokument nachgezogen werden.
- **Risiko unvollständiger Scope:** Dokumentiert die Analyse nur die Suche, bleibt der (vermutlich ebenfalls defekte) Detailabruf ein offenes Restrisiko — daher als Folgebedarf explizit im Dokument benennen (festgelegt: Suche zuerst, Detailabruf separat).

## Umsetzungsreihenfolge

1. **Recherche: API-Infrastruktur und TMDb-Befund im Repo verifizieren**
   - Voraussetzungen: Keine (nur Lesezugriff auf das Repo).
   - Beschreibung: Folgende Fakten verifizieren und mit Fundstellen belegen: (a) `TMDbLib`-Version und Client-Erzeugung in `scraper.TMDB.Data` (`packages.config`: `TMDbLib` 1.9.1; `clsScrapeTMDB.vb:166,172`; Fallback-Key `TMDB_Data.vb:57`); (b) Titelsuche-Fähigkeit der OMDb-Bibliothek — `MovieCollection.OpenMovieDatabase` 3.0.1 enthält `SearchMoviesAsync`/`SearchMovieAsync` (OMDb-`?s=`/`?t=`), das Modul `scraper.Data.OMDb` nutzt aber nur `SearchMovieByImdbIdAsync` (`clsScrapeOMDb.vb:84`); (c) `scraper.IMDB.Data` referenziert aktuell nur `HtmlAgilityPack` 1.11.42 — für die TMDb-Option wäre ein NuGet-Verweis auf `TMDbLib` neu hinzuzufügen (als Voraussetzung im Analysedokument benennen); (d) Wiederverwendbarkeit: TMDb-Client-Code ist modulintern (`Private _client` in `clsScrapeTMDB.vb`) — keine projektübergreifende Shared-Komponente vorhanden, daher Code-Duplikation oder Neuinstanz im IMDb-Modul als Anforderung beschreiben; (e) **neu — Scrape-Order-Mechanik:** im `ModulesManager`/Aufrufpfad prüfen, ob bei mehreren aktivierten Daten-Scrapern beide Suchdialoge nacheinander greifen oder der erste (`IMDB_Data` vs. `TMDB_Data`) den weiteren Aufruf unterbindet — Grundlage für Hypothese (b) des TMDb-Befunds; (f) **neu — `TMDbLib`-Kompatibilität:** Alter und bekannte Brüche von `TMDbLib` 1.9.1 gegenüber der aktuellen TMDb-API v3 dokumentieren (z. B. TLS-1.2-Erfordernis bei .NET-Framework-Standardwerten, geänderte Endpunkte/Auth), als Grundlage für Hypothese (a).

2. **Analysedokument `analysis.md` erstellen**
   - Voraussetzungen: Schritt 1 (verifizierte Faktenbasis); `requirement.md` und `inventory.md` liegen vor.
   - Beschreibung: Datei `docs/features/task/issue-8-168e4a79c1c24dadb014bdd3fb7c170d-suche-nach-filmen-und-serien-l/analysis.md` anlegen mit folgender verbindlicher Gliederung:
     - **Titel & Kontext:** Issue #8, betroffenes Modul `scraper.Data.IMDB`, Zielgruppe = zuständiges Entwicklungsprojekt.
     - **Problemstellung / IST-Zustand:** `SearchMovie` (Z. 1413–1541) und `SearchTVShow` (Z. 1555–1581) parsen IMDb-HTML (`/find`, `/search/title`); WAF-Challenge (HTTP 202, `x-amzn-waf-action: challenge`) bzw. React-Umbau → alle `SelectNodes` liefern `Nothing` → Dialog zeigt „No Matches Found"; 15 `HtmlWeb.Load`-Stellen auf `imdb.com` gesamt, Detailabruf (`/reference`, `/episodes`, `/releaseinfo`, `/parentalguide`, `/plotsummary`) vermutlich ebenfalls defekt.
     - **Befund: TMDb-Suche ebenfalls ohne Treffer (neu, verbindlich aufzunehmen):** Beim Kunden sind IMDb- **und** TMDb-Daten-Scraper aktiviert; die Suche liefert trotzdem keine Ergebnisse — auch nicht bei allen aktivierten Scrapern. Zu formulierende Anforderung an das Entwicklungsprojekt: Ursache eingrenzen — (a) prüfen, ob `clsScrapeTMDB.vb` `SearchMovie`/`SearchTvShowAsync` überhaupt aufgerufen wird (Scrape-Order-Effekt: greift der IMDb-Suchdialog zuerst, sodass TMDb nie erreicht/angezeigt wird?) und (b) was die TMDb-API antwortet (veraltete `TMDbLib` 1.9.1, TLS-/API-Änderungen, ungültiger eingebetteter Fallback-Key `TMDB_Data.vb:57`). Ergebnis dokumentieren; die TMDb-API bleibt die festgelegte Zielschnittstelle, ist aber nur unter der Bedingung einer funktionierenden bzw. zu reparierenden TMDb-Integration tragfähig.
     - **Funktionale Anforderungen:** (1) `SearchMovie`/`SearchTVShow` auf die festgelegte Schnittstelle (TMDb-API primär) umstellen, IMDb-HTML-Endpunkte für die Suche nicht mehr verwenden; (2) Ergebnisvertrag `SearchResults_Movie`/`SearchResults_TVShow` und `GetSearchMovieInfo`/`GetSearchTVShowInfo`-Heuristik (Lev ≤ 5, `FindYear`, `ScrapeType`-Gestaltung) unverändert beibehalten; (3) Filme und Serien gemeinsam umsetzen und gemeinsam abnehmen (festgelegt); (4) Quell-Ausfälle erkennbar machen — Fehler loggen und dem Anwender als von „keine Treffer" unterscheidbare Meldung anzeigen (festgelegt).
     - **Schnittstellenentscheidung (festgelegt, mit Bewertung zu dokumentieren):** TMDb-API primär (vorhandene Infrastruktur, offizieller Vertrag, IMDb-ID-Mapping via `FindAsync(FindExternalSource.Imdb)` — unter dem Vorbehalt des TMDb-Befunds), OMDb-API alternativ (Bibliothek kann `SearchMoviesAsync`, Modul ohne Titelsuche → Neuimplementierung; Pflicht-API-Key ohne Fallback), IMDb-interne Endpunkte nur als Fallback (undokumentiert, fragil). Jede Option mit Aufwand, Risiken, rechtlichen/Nutzungsaspekten und Repo-Fundstellen.
     - **Ergebniskategorien & Settings (festgelegt):** Mapping auf `ExactMatches`/`PartialMatches`; die vier Spezialkategorien entfallen; die fünf `Search*Titles`-Settings werden deprecated (Settings-UI-Anpassung als Anforderung).
     - **Fehlerbehandlung & Logging (festgelegt):** Abruffehler, HTTP-Fehlercodes, Rate-Limits und ungültige API-Keys erkennen, via `logger.Error` protokollieren und im Dialog als unterscheidbare Fehlermeldung anzeigen — nicht mehr als „No Matches Found".
     - **Umfang & Abgrenzung (festgelegt):** Suche (Film+Serie) im Scope und zuerst umzusetzen; Detailabruf-Erneuerung als dokumentierten separaten Folgebedarf; keine Änderungen an `Enums.ScrapeType`, Scrape Order, `ScrapeModifiers`, Dialogen.
     - **Voraussetzungen für die Implementierung:** NuGet `TMDbLib` für `scraper.IMDB.Data` (Version abhängig vom TMDb-Befund — ggf. aktuellere Version als 1.9.1 erforderlich) bzw. `MovieCollection.OpenMovieDatabase` (bei OMDb-Option); ggf. `APIKey`-Setting.
     - **Akzeptanzkriterien:** Referenzfälle „28 Days Later" → tt0289043, „28 Weeks Later" → tt0463854, „28 Years Later" → tt10548174 zeigen im „Search Results"-Dialog je mind. einen Treffer mit korrekter IMDb-ID; Seriensuche analog für bekannte Serientitel; Film- und Seriensuche werden gemeinsam abgenommen; manuelle IMDb-ID-Eingabe (`chkManual`/`txtIMDBID`/`btnVerify`) bleibt funktionsfähig; bei nicht erreichbarer Datenquelle erscheint eine unterscheidbare Fehlermeldung statt „No Matches Found".
     - **Annahmen & Folgebedarfe:** Detailabruf-Erneuerung (`/reference`, `/episodes` u. a.) als Folgebedarf; TMDb-Fehlereingrenzung als Vorbedingung der Schnittstellenwahl dokumentiert.

3. **Konsistenzprüfung des Analysedokuments**
   - Voraussetzungen: Schritt 2.
   - Beschreibung: `analysis.md` gegen `requirement.md` prüfen: alle 5 Punkte der abgeleiteten Anforderungsbeschreibung abgedeckt, Referenzfälle und Akzeptanzkriterium wörtlich übernommen, technische Bezeichner korrekt (`clsScrapeIMDB.vb`-Zeilen, Klassen-/Methodennamen), keine Implementierungsdetails/Code im Dokument (nur Struktur und Absicht), OMDb-Befund (Modul ohne Titelsuche) korrekt dargestellt, **TMDb-Befund (beide Scraper aktiv, dennoch keine Treffer) mit beiden Hypothesen und der Untersuchungsanforderung enthalten**, alle sechs geklärten Punkte als Entscheidungen — nicht als offene Fragen — geführt.

## Tests

### Neue Tests

Keine — die Umsetzung besteht ausschließlich aus einem Dokumentationsartefakt; es gibt nichts Testbares. Zudem ist die vorhandene Testinfrastruktur defekt (`EmberAPI_Test` kompiliert nicht, fehlendes `UnitTests`-Projekt — siehe `inventory/tests.md`).

### Betroffene bestehende Tests

Keine.

### E2E-Tests (primärer Funktionsnachweis)

Keine E2E-Tests erforderlich, da diese Umsetzung **keinen Benutzerfluss berührt**: Die Anforderung verlangt ausschließlich die Erstellung eines Analyse-/Anforderungsdokuments; es wird kein Code geändert und kein über UI erreichbarer Ablauf modifiziert. Die tatsächliche Funktionsänderung obliegt dem zuständigen Entwicklungsprojekt — dafür enthält das Analysedokument die Akzeptanzkriterien (Referenzfälle tt0289043/tt0463854/tt10548174, Seriensuche, unterscheidbare Fehlermeldung), aus denen dort E2E-Abnahmeszenarien abzuleiten sind. Ein bloßer Verweis auf Unit-/Integrationstests wäre hier ohnehin nicht möglich (keine Tests für das IMDb-Modul vorhanden, Testsuite kompiliert nicht).

## Offene Punkte

Keine.
