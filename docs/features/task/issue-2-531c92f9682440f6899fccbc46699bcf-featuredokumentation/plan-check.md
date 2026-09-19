# Plan-Gegenprüfung

## Ergebnis

**Status:** Plan vollständig

## Abgleich Akzeptanzkriterien

| Akzeptanzkriterium | Umsetzung im Plan | Testnachweis im Plan | Status |
|--------------------|-------------------|----------------------|--------|
| Vollständige Bestandsaufnahme mit `/inventory` | Bereits ausgeführt: `inventory.md` + 8 Detaildokumente + Test-Baseline | Nachweisartefakte existieren (`inventory/`, Build-Log) | Abgedeckt |
| Dokumentation via `/update-docs` für das Repository | Schritte 1–11: 11 `docs/help/`-Bereiche mit je passenden Dokumentationsarten; Schritt 12: Gesamtindex | `review-plan` prüft Existenz aller geplanten Dateien; Code-Review prüft Doku-Qualität | Abgedeckt |
| README via `/update-readme` | Schritt 14 | `review-plan` prüft aktualisierte `README.md` | Abgedeckt |
| Release Notes via `/update-release-notes` | Schritt 15 (Basis `staging` ggü. `master`) | `review-plan` prüft `docs/RELEASE_NOTES.md` zweisprachig | Abgedeckt |
| PR gegen `staging` | Schritt 16 | `review-plan` prüft Vorhandensein des PRs bzw. Abschlussmeldung | Abgedeckt |
| „als wären Features im Lifecycle entstanden" | Lifecycle-Artefakte (`requirement`, `inventory`, `plan`, Reviews) + `changes.log` retroaktiv | Artefakte im Feature-Verzeichnis | Abgedeckt |

## E2E-Abdeckung

| Benutzerfluss / Akzeptanzkriterium | Geplanter E2E-Test | Status |
|------------------------------------|--------------------|--------|
| Kein Benutzerfluss — reine Dokumentationsanforderung ohne Code-/UI-Änderung | — | Nicht erforderlich: Anforderung erzeugt ausschließlich Markdown-Artefakte; es gibt keinen auslösbaren UI-Fluss. Zusätzlich fehlt im Projekt jede E2E-/UI-Testinfrastruktur (einzige Testsuite nicht kompilierbar, s. `inventory/tests.md`). Nachweis erfolgt über `/review-plan` (Dateiexistenz) und Review-Schritte. |

## Fehlende oder unvollständige Testanforderungen

Keine — für eine reine Dokumentationsanforderung ohne Codeänderung gibt es keine testbaren Akzeptanzkriterien; die Verifikation erfolgt über Plan-Review (Existenz aller geplanten Dateien) und Code-Review (Qualität der Markdown-Artefakte).

## Fehlende oder unvollständige Planbestandteile

Keine — nach Kreuzverhör (`plan-review`-Skill): Annahmen sind durch die Bestandsaufnahme belegt; Designentscheidungen (11 Funktionsbereiche, konsolidierter `scraper`-Bereich, chronologische `changes.log`-Einsortierung, Trennung Anwenderhilfe/Technik) sind jeweils begründet.

## Hinweise

Zur Nachplanung beachten:

- **`docs/help/index.md` existiert noch nicht** (nur `docs/help/build/index.md`) — Schritt 12 muss sie neu erstellen, nicht nur erweitern.
- **Externe Scraper-Quellen sind möglicherweise defunct** (z. B. `api-v2launch.trakt.tv` Beta-Endpoint, Moviepilot, OFDb, Apple/hd-trailers). Dokumentation beschreibt den Code-Stand; `beschreibung.md` des `scraper`-Bereichs sollte im Abschnitt „Einschränkungen" vermerken, dass Drittanbieter-Verfügbarkeit außerhalb der Kontrolle des Projekts liegt.
- **Kleinteilige Dialoge einordnen:** `dlgDVDProfilerSelect`/`clsAPIDVDProfiler` (DVD-Profiler-Import) → Bereich `filme`; `dlgOfflineHolder`/`MediaStub` (Offline-Medien) → Bereich `medienbibliothek`; `dlgTagManager` (Haupt-App) vs. TagManager-Addon → Bereich `werkzeuge` (Unterscheidung erläutern).
- **`changes.log`-Reihenfolge:** Retro-Einträge hinter dem bestehenden 2026-09-19-Eintrag in Datumsreihenfolge (ältestes zuerst der Retro-Einträge, dann aufsteigend), nicht alphabetisch.
- **Keine UI-Begriffserfindung:** Captions aus `.resx`/Designer-Dateien entnehmen, nicht raten (Update-docs-Regel).
