# Umsetzungsplan: Featuredokumentation (retroaktive Projektdokumentation)

## Übersicht

Das gesamte Repository wird retroaktiv dokumentiert: Für jeden fachlichen Funktionsbereich aus der Bestandsaufnahme wird ein Verzeichnis unter `docs/help/` mit den passenden Dokumentationsarten angelegt (Verfahren `/update-docs`, flächendeckend angewendet wie `/backfill-docs`). Ergänzend werden `changes.log` (retroaktive, chronologisch einsortierte Einträge), `README.md` (`/update-readme`) und `docs/RELEASE_NOTES.md` (`/update-release-notes`, Änderungsbasis `staging` ggü. `master`) aktualisiert. Abschließend Pull Request gegen `staging`. Es wird kein Quellcode geändert.

## Designentscheidungen

| Komponente / Bereich | Gewählter Ansatz | Begründung |
|----------------------|-----------------|------------|
| Verfahren | `/update-docs`-Dokumentationsarten auf alle Funktionsbereiche anwenden (entspricht `/backfill-docs`) | Die Anforderung nennt explizit `/update-docs`; der Branch enthält keine Code-Änderungen, daher gilt die retroaktive Ganzprojekt-Variante |
| Funktionsbereiche | 11 Bereiche aus Anwendersicht (s. Bestandsaufnahme) + bestehender Bereich `build` | Übergeordnete fachliche Begriffe statt Einzeloperationen; `build` bleibt unverändert |
| `changes.log` | Retroaktive Einträge, chronologisch nach Git-Datum einsortiert (nicht oben angehängt) | Vorgabe des Verfahrens für nachträglich dokumentierte Bereiche; Entstehungsdaten via `git log --diff-filter=A` (s. Bestandsaufnahme) |
| Anwenderhilfe vs. Technik | `beschreibung.md`, `ablauf-anwender.md`, `einrichtung-anwender.md` strikt ohne Klassen-/API-Namen; Technik in `ablauf-technisch.md`, `api.md`, `datenmodell.md`, `architektur.md`, `business-rules.md` | Regel aus `/update-docs` Schritt 4 |
| RELEASE_NOTES | Änderungsbasis `staging` ggü. `master` (`staging`-Branch existiert) | `/update-release-notes` Schritt 1; PR-Ziel ist `staging` |
| Scraper-Doku | Ein Bereich `scraper` mit allen Scraper-Modulen als Tabelle, statt 20 Einzelbereiche | Gleichartige Funktion; übersichtlicher |
| Legacy-Projekte (`scraper.EmberCore.XML`, `scraper.TVDB.Poster`, `EmberAPI_Test`) | In `architektur`/Hinweisen der jeweiligen Bereiche dokumentiert, kein eigener Bereich | Nicht im Build, aber dokumentationsrelevant |

## Programmabläufe

Keine Programmabläufe zu implementieren — reine Dokumentation. Relevante fachliche Abläufe werden beschrieben, nicht gebaut:

### Dokumentationserstellung je Bereich

1. Quelllage aus `inventory/*` entnehmen; bei Bedarf Ziel-Quelldateien lesen (Captions, sichtbare Bezeichnungen).
2. `docs/help/{bereich}/index.md` anlegen, Inhaltsliste nur mit tatsächlich erstellten Dateien.
3. Dokumentationsdateien je Bereich gemäß Tabelle unten erstellen.
4. `docs/help/index.md` um alle neuen Bereiche ergänzen (Gruppierung: Bibliothek & Inhalte / Metadaten & Medien / Integrationen / Werkzeuge / System).

## Neue Klassen

Keine — Dokumentationsdateien statt Klassen.

## Änderungen an bestehenden Klassen

Keine.

## Datenbankmigrationen

Keine.

## Validierungsregeln

Keine.

## Konfigurationsänderungen

Keine.

## Seiteneffekte und Risiken

- **`docs/help/index.md`:** wird erweitert, bestehender `build`-Eintrag bleibt erhalten.
- **`changes.log`:** Einträge werden chronologisch einsortiert — der bestehende 2026-09-19-Eintrag bleibt ganz oben; Retro-Einträge landen dahinter in Datumsreihenfolge.
- **`README.md`:** bestehender Inhalt (Flattr/Donate, Goals, Links, Contribution-Regeln, Scraper-Designprinzipien) bleibt erhalten; Ergänzung um Features, Struktur, Tests, Lizenz, Dokumentationsverweis.
- **`docs/RELEASE_NOTES.md`:** wird vollständig neu geschrieben (Verfahrensvorgabe) — Inhalt muss alle Änderungen `staging` ggü. `master` abdecken (Build-Arbeit + Dokumentation).

## Umsetzungsreihenfolge

1. **Funktionsbereich `medienbibliothek` dokumentieren**
   - Voraussetzungen: `inventory/models.md`, `inventory/architektur.md`, `inventory/logic.md`
   - Beschreibung: `docs/help/medienbibliothek/` mit `index.md`, `beschreibung.md`, `ablauf-anwender.md` (Quelle anlegen, Scan, Filter, Offline-Medien), `ablauf-technisch.md` (`Scanner`, `Database`, `FileUtils`), `business-rules.md` (Ordner-/Datei-Erkennung, Regex, Ausschlussregeln)

2. **Funktionsbereich `filme` dokumentieren**
   - Voraussetzungen: `inventory/models.md`, `inventory/logic.md`
   - Beschreibung: `docs/help/filme/` mit `index.md`, `beschreibung.md`, `ablauf-anwender.md` (Bearbeiten, Markieren, Sperren, Bilder/Trailer zuweisen)

3. **Funktionsbereich `serien` dokumentieren**
   - Voraussetzungen: wie 2
   - Beschreibung: `docs/help/serien/` mit `index.md`, `beschreibung.md`, `ablauf-anwender.md` (Serien/Staffeln/Episoden bearbeiten), `business-rules.md` (Episoden-Erkennung per Regex, `EpisodeOrdering`, Staffel-Sonderfälle)

4. **Funktionsbereich `filmsammlungen` dokumentieren**
   - Voraussetzungen: wie 2
   - Beschreibung: `docs/help/filmsammlungen/` mit `index.md`, `beschreibung.md`, `ablauf-anwender.md` (Sets anlegen, zuordnen, bearbeiten)

5. **Funktionsbereich `scraper` dokumentieren**
   - Voraussetzungen: `inventory/addons.md`, `inventory/enums.md`, `inventory/interfaces.md`
   - Beschreibung: `docs/help/scraper/` mit `index.md`, `beschreibung.md` (Scraper-Gruppen + Modultabelle), `einrichtung-anwender.md` (Aktivierung, Reihenfolge, API-Keys/Konten), `ablauf-technisch.md` (Interface-Verträge, sequentiell/parallel, `dlgImgSelect`), `business-rules.md` (`ScrapeType`-Matrix, nur leere Felder füllen)

6. **Funktionsbereich `kodi` dokumentieren**
   - Voraussetzungen: `inventory/projekte.md`, `inventory/logic.md`
   - Beschreibung: `docs/help/kodi/` mit `index.md`, `beschreibung.md`, `einrichtung-anwender.md` (Host anlegen, Konto), `ablauf-technisch.md` (`XBMCRPC.Client`, JSON-RPC-Methoden, Notifications), `api.md` (genutzte RPC-Methodengruppen)

7. **Funktionsbereich `trakt` dokumentieren**
   - Voraussetzungen: wie 6
   - Beschreibung: `docs/help/trakt/` mit `index.md`, `beschreibung.md`, `einrichtung-anwender.md` (Autorisierung), `ablauf-technisch.md` (`TraktAPI`, Sync-Endpunkte), `api.md` (Endpunktgruppen)

8. **Funktionsbereich `werkzeuge` dokumentieren**
   - Voraussetzungen: `inventory/addons.md`
   - Beschreibung: `docs/help/werkzeuge/` mit `index.md`, `beschreibung.md` (Abschnitt je Modul: Bulk Rename, Export, Media File Manager, Tag Manager, Medienlisten-Editor, Mapping, Metadaten-Editor, Kontextmenü, Video Source Mapping), `ablauf-anwender.md` (typische Bedienung der Dialoge)

9. **Funktionsbereich `einstellungen` dokumentieren**
   - Voraussetzungen: `inventory/models.md`, `inventory/logic.md`
   - Beschreibung: `docs/help/einstellungen/` mit `index.md`, `beschreibung.md` (Einstellungsdialog, Modul-Panels, Sprachen), `einrichtung-anwender.md` (Profile, Mehrbenutzer), `installation.md` (Settings.xml/AdvancedSettings.xml-Ablage, Defaults)

10. **Funktionsbereich `module-system` dokumentieren** (Entwickler-Doku)
    - Voraussetzungen: `inventory/architektur.md`, `inventory/interfaces.md`
    - Beschreibung: `docs/help/module-system/` mit `index.md`, `beschreibung.md`, `architektur.md` (Lademechanismus, Event-Fluss), `api.md` (`GenericModule`, Scraper-Interfaces, `ModuleEventType`)

11. **Funktionsbereich `datenbank` dokumentieren** (Entwickler-/Admin-Doku)
    - Voraussetzungen: `inventory/models.md`
    - Beschreibung: `docs/help/datenbank/` mit `index.md`, `beschreibung.md`, `datenmodell.md` (ERM: Kern- und Verknüpfungstabellen, Mermaid)

12. **`docs/help/index.md` aktualisieren**
    - Voraussetzungen: Schritte 1–11 abgeschlossen, `docs/help/build/index.md` gelesen
    - Beschreibung: Alle Bereiche gruppiert eintragen (bestehender `build`-Eintrag bleibt unverändert)

13. **`changes.log` retroaktiv ergänzen**
    - Voraussetzungen: Git-Daten aus `inventory.md`/`projekte.md`
    - Beschreibung: Einträge chronologisch einsortieren: 2013-05-17 Kernimport (App, EmberAPI, Scraper, Rename, Export, FileManager), 2013-09-29 Trakttv-Bibliothek, 2014-04-03 BuildSetup, 2015-03 Tag-Manager + Medienlisten-Editor, 2015-06 TVDB-Scraper, 2015-07 Kodi-Integration, 2018-03 Trakt-Synchronisation, 2020-05 Mapping-Editor — jeweils kurze fachliche Stichpunkte

14. **`README.md` aktualisieren** (`/update-readme`)
    - Voraussetzungen: `docs/help/index.md` vorhanden
    - Beschreibung: Features-Liste, Projektstruktur, Tests-Abschnitt (ehrlicher Stand: Testprojekt nicht im Build), Lizenz (GPL-3.0), Verweis auf `docs/help/` und `changes.log`; Badges nur soweit belegbar (kein CI → kein CI-Badge; .NET-Badge möglich); bestehende Abschnitte erhalten

15. **`docs/RELEASE_NOTES.md` neu schreiben** (`/update-release-notes`)
    - Voraussetzungen: `git log`/`git diff` `master..staging` ausgewertet
    - Beschreibung: Zweisprachig EN/DE; wichtige Hinweise (.NET 4.8 erforderlich, NuGet-Restore), Neuerungen (Build-Fixes, Dokumentation)

16. **Pull Request gegen `staging`**
    - Voraussetzungen: Commit abgeschlossen
    - Beschreibung: `gh pr create --base staging` mit Zusammenfassung der Dokumentationsbereiche

## Tests

### Neue Tests

Keine — die Anforderung ändert keinen Codepfad.

### Betroffene bestehende Tests

Keine — es existieren keine ausführbaren Tests (s. `inventory/tests.md`); Dokumentationsdateien beeinflussen keine Tests.

### E2E-Tests (primärer Funktionsnachweis)

Nicht erforderlich — Begründung: Die Anforderung erzeugt ausschließlich Markdown-Dokumentation. Es wird kein Benutzerfluss, keine UI, kein Button und keine Navigation geändert oder hinzugefügt. Der „Nachweis" ist die Existenz und Vollständigkeit der Dokumentationsdateien (geprüft über `/review-plan` und Review der `docs/help/`-Struktur), nicht das Verhalten der Anwendung. Zusätzlich existiert im Projekt keine E2E-/UI-Testinfrastruktur (einzige Testsuite nicht kompilierbar).

## Offene Punkte

Keine.
