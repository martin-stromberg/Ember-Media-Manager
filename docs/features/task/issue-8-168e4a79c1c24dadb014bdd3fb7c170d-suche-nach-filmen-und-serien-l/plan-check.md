# Plan-Gegenprüfung

## Ergebnis

**Status:** Plan vollständig

## Abgleich Akzeptanzkriterien

| Akzeptanzkriterium | Umsetzung im Plan | Testnachweis im Plan | Status |
|--------------------|-------------------|----------------------|--------|
| Referenzfilme „28 Days Later" → tt0289043, „28 Weeks Later" → tt0463854, „28 Years Later" → tt10548174 zeigen im „Search Results"-Dialog je mind. einen Treffer mit korrekter IMDb-ID (requirement.md, Implementierungsansatz Punkt 5) | Festgelegte Zielschnittstelle TMDb-API mit IMDb-ID-Auflösung via `FindAsync(FindExternalSource.Imdb)`; Zielablauf „Titelsuche Film" spezifiziert Mapping auf `UniqueIDs.IMDbId`; die drei Referenzfälle werden wörtlich in den Abschnitt „Akzeptanzkriterien" der `analysis.md` übernommen (Umsetzungsreihenfolge Schritt 2) | Keine Testausführung in dieser Umsetzung (reines Dokumentationsartefakt, begründet); als Nachweis dient Schritt 3 „Konsistenzprüfung" (Referenzfälle wörtlich übernommen). Die E2E-Abnahme ist als Akzeptanzkriterium im Analysedokument an das Entwicklungsprojekt weitergegeben | Abgedeckt |
| Seriensuche liefert analog Treffer für bekannte Serientitel (Punkt 5) | Zielablauf „Titelsuche Serie" (`SearchTVShow` → `SearchTvShowAsync` + `FindAsync` → `SearchResults_TVShow.Matches`); gemeinsame Umsetzung und Abnahme mit Filmsuche festgelegt (Designentscheidungen „Umfang"/„Abnahmemodus") | Wie oben — Konsistenzprüfung Schritt 3; E2E-Abnahme an Entwicklungsprojekt delegiert | Abgedeckt |
| `SearchMovie`/`SearchTVShow` dürfen IMDb-HTML-Endpunkte `/find` und `/search/title` nicht mehr verwenden; stabile Schnittstelle stattdessen (Punkt 1) | Funktionale Anforderung (1) in der verbindlichen `analysis.md`-Gliederung; Schnittstellenentscheidung mit Bewertung aller drei Optionen (TMDb primär, OMDb alternativ, IMDb-intern als Fallback) inkl. Aufwand/Risiken/Fundstellen; Voraussetzung „NuGet `TMDbLib` für `scraper.IMDB.Data`" genannt | Dokumentationsanforderung — Abdeckung wird in Schritt 3 geprüft („alle 5 Punkte der abgeleiteten Anforderungsbeschreibung abgedeckt") | Abgedeckt |
| Ergebnisvertrag beibehalten: `SearchResults_Movie`/`SearchResults_TVShow`, `GetSearchMovieInfo`/`GetSearchTVShowInfo`-Heuristik (Lev ≤ 5, `FindYear`, `ScrapeType`) (Punkt 2) | Funktionale Anforderung (2); festgelegtes Mapping auf `ExactMatches`/`PartialMatches`, Spezialkategorien entfallen; Abschnitt „Ergebniskategorien & Settings" verbindlich | Dokumentationsanforderung — Schritt 3 | Abgedeckt |
| Fehlerbehandlung: Quell-Ausfälle erkennen, loggen, von „keine Treffer" unterscheidbar machen (Punkt 3) | Festgelegt in Designentscheidung „Fehlerkommunikation"; eigener `analysis.md`-Abschnitt „Fehlerbehandlung & Logging" (`logger.Error`-Muster, HTTP-Fehler, Rate-Limits, ungültige API-Keys); zusätzlich als Akzeptanzkriterium („unterscheidbare Fehlermeldung statt ‚No Matches Found'") aufgenommen | Dokumentationsanforderung — Schritt 3; sichtbarer Fehlerfall als Akzeptanzkriterium/E2E-Szenario ans Entwicklungsprojekt dokumentiert | Abgedeckt |
| Detailabruf separat bewerten (Punkt 4) | Festgelegt: Suche (Film+Serie) zuerst, Detailabruf-Erneuerung als dokumentierter Folgebedarf; Abschnitte „Umfang & Abgrenzung" und „Annahmen & Folgebedarfe"; Risiko „unvollständiger Scope" benannt | Dokumentationsanforderung — Schritt 3 | Abgedeckt |
| Manuelle IMDb-ID-Eingabe (`chkManual`/`txtIMDBID`/`btnVerify`) bleibt funktionsfähig | In den zu übernehmenden Akzeptanzkriterien der `analysis.md` explizit enthalten | Dokumentationsanforderung — Schritt 3 | Abgedeckt |
| Entscheidung zu `SearchPartialTitles`/`SearchPopularTitles`/`SearchTvTitles`/`SearchVideoTitles`/`SearchShortTitles` (Konfiguration) | Festgelegt: deprecaten, Settings-UI-Anpassung als Anforderung benennen; in Konfigurationsänderungen-Tabelle und `analysis.md`-Abschnitt „Ergebniskategorien & Settings" | Dokumentationsanforderung — Schritt 3 | Abgedeckt |
| Keine Änderungen an `Enums.ScrapeType`, Scrape Order, `ScrapeModifiers`, Dialogen (Konfiguration/Nicht-Anforderung) | Explizit im `analysis.md`-Abschnitt „Umfang & Abgrenzung" festgehalten | Dokumentationsanforderung — Schritt 3 | Abgedeckt |
| Klärung „Aktiver Scraper beim Kunden" (Offene Frage 1) — Kundenrückmeldung: IMDb- **und** TMDb-Scraper aktiv, dennoch keine Treffer | Verbindlicher `analysis.md`-Abschnitt „Befund: TMDb-Suche ebenfalls ohne Treffer" mit beiden Hypothesen ((a) defekte TMDb-Integration — `TMDbLib` 1.9.1, TLS-/API-Änderungen, Fallback-Key; (b) Scrape-Order-Effekt) und konkreter Untersuchungsanforderung; Recherche-Schritt 1 (e)/(f) verifiziert die Faktenbasis | Dokumentationsanforderung — Schritt 3 prüft explizit, dass der TMDb-Befund mit beiden Hypothesen enthalten ist | Abgedeckt |

## Fehlende oder unvollständige Testanforderungen

— (Status `Plan vollständig`; keine fehlenden Testanforderungen festgestellt)

## E2E-Abdeckung

| Benutzerfluss / Akzeptanzkriterium | Geplanter E2E-Test | Status |
|------------------------------------|--------------------|--------|
| „Search Results"-Dialog zeigt Treffer für Referenzfilme (UI-Fluss: `(Re)Scrape Movie` → `dlgIMDBSearchResults_Movie`) | Kein E2E-Test in dieser Umsetzung | Nicht erforderlich — Begründung im Plan nachvollziehbar: Die Umsetzung berührt keinen Benutzerfluss, da ausschließlich ein Analyse-/Anforderungsdokument (`analysis.md`) erstellt wird; es wird kein Code geändert. Die Anforderung verlangt selbst eine Analyse („Die Kundenanforderung sieht eine Analyse vor"). Die E2E-Abnahmekriterien werden als Akzeptanzkriterien an das Entwicklungsprojekt weitergegeben |
| Seriensuche via `dlgIMDBSearchResults_TV` analog | Kein E2E-Test | Nicht erforderlich — gleiche Begründung |
| Unterscheidbare Fehlermeldung bei nicht erreichbarer Datenquelle (sichtbarer Fehlerfall) | Kein E2E-Test | Nicht erforderlich — gleiche Begründung; als Akzeptanzkriterium im Analysedokument festgehalten |
| Manuelle IMDb-ID-Eingabe bleibt funktionsfähig | Kein E2E-Test | Nicht erforderlich — gleiche Begründung; als Akzeptanzkriterium im Analysedokument festgehalten |

## Fehlende oder unvollständige Planbestandteile

— (Status `Plan vollständig`; keine fehlenden Planbestandteile festgestellt)

## Hinweise

- Die Planinterpretation (Kernlieferung = `analysis.md`, keine Codeänderung) ist konsistent mit `requirement.md` („Die Kundenanforderung sieht eine Analyse vor; die abgeleitete Anforderungsbeschreibung für das zuständige Entwicklungsprojekt lautet: …") und wurde laut Plan durch bestätigte Anwenderentscheidungen abgesichert. Die fehlende E2E-Abdeckung ist damit gemäß Prüfkriterium „nachvollziehbar begründet" zulässig.
- Als verifikatorischer Nachweis für das Dokumentartefakt dient Umsetzungsschritt 3 (Konsistenzprüfung gegen `requirement.md` mit konkreter Checkliste); er erfüllt die Funktion des „Testnachweises" für eine reine Dokumentationsaufgabe.
- Alle sechs offenen Fragen aus `requirement.md` sind im Plan als getroffene Entscheidungen geführt (Schnittstelle, Mapping, Umfang, Fehlerkommunikation, Abnahmemodus, aktive Scraper via TMDb-Befund); Abschnitt „Offene Punkte" ist zutreffend leer.
- Optional für die Nachplanung: Der leere Stub `GetTMDbIdByIMDbId` (`IMDB_Data.vb:427–429`, siehe `inventory/interfaces.md`) könnte in `analysis.md` erwähnt werden, falls das Entwicklungsprojekt das IMDb↔TMDb-Mapping modulübergreifend nutzen will — keine Lücke, da das Mapping für die Suche über `TMDbLib.FindAsync` spezifiziert ist.
- Risiken sind benannt (defekte Zielinfrastruktur TMDb, veraltete Empfehlung, unvollständiger Scope) und durch den verbindlichen Untersuchungsauftrag zum TMDb-Befund adressiert.
