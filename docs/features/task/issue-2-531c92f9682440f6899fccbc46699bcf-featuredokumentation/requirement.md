# Übersetzte Anforderung: Featuredokumentation (Issue #2)

## Fachliche Zusammenfassung

Das Repository ist ein Fork von Ember Media Manager (WinForms, .NET Framework 4.8, VB.NET/C#). Der Großteil der Entwicklung stammt aus dem Upstream-Projekt und entstand außerhalb des eigenen Lifecycle-Workflows — es existieren daher weder Planungsartefakte noch eine vollständige Projektdokumentation. Die Dokumentation des gesamten Repositorys soll retroaktiv nachgezogen werden, so als wären die vorhandenen Features im Rahmen des Lifecycles entstanden. Grundlage ist ausschließlich der bestehende Code und die Git-Historie; es wird nichts implementiert oder am Code geändert.

## Akzeptanzkriterien

1. **Vollständige Bestandsaufnahme:** Eine Bestandsaufnahme nach dem Verfahren `/inventory` wird erstellt und unter `docs/features/{branchname}/inventory.md` samt Detaildokumenten unter `inventory/` abgelegt. Sie umfasst — anders als bei einer Einzelfeature-Anforderung — das gesamte Repository (alle Solution-Projekte, Module/Addons, Scraper, Schnittstellen, Datenmodell, Tests, Build/Deployment).
2. **Feature-Dokumentation:** Anhand der Bestandsaufnahme wird die Projektdokumentation unter `docs/help/` erstellt bzw. ergänzt — nach dem Verfahren `/update-docs` (Dokumentationsarten `beschreibung.md`, `ablauf-technisch.md`, `ablauf-anwender.md`, `api.md`, `installation.md`, `datenmodell.md`, `business-rules.md` etc. je nach Eignung). Da kein Feature im Branch implementiert wurde, wird `update-docs` flächendeckend auf alle Funktionsbereiche angewendet (retroaktive Dokumentation, vergleichbar `/backfill-docs`), statt nur ein Einzelfeature zu dokumentieren. `docs/help/index.md` wird als Gesamtübersicht aktualisiert. `changes.log` erhält retroaktive, chronologisch einsortierte Einträge.
3. **README:** `README.md` wird nach `/update-readme` aktualisiert (Badges, Features, Setup, Konfiguration, Struktur, Tests, Lizenz — nur soweit aus dem Code belegbar).
4. **Release Notes:** `docs/RELEASE_NOTES.md` wird nach `/update-release-notes` gegen den Änderungsstand `staging` ggü. `master` neu geschrieben (zweisprachig EN/DE).
5. **Abschluss als PR:** Das Ergebnis liegt als Pull Request gegen den Zielbranch `staging` vor.

## Betroffene Klassen und Komponenten

Es werden keine Klassen geändert. Betroffene **Dokumentationsartefakte**:

- `docs/features/task/issue-2-…-featuredokumentation/` — Lifecycle-Arbeitsartefakte (`requirement.md`, `inventory.md`, `inventory/`, `plan.md`, Reviews, `test-results.md`)
- `docs/help/{funktionsbereich}/` — neue bzw. ergänzte Feature-Dokumentation je Funktionsbereich; `docs/help/index.md` als Gesamtindex
- `changes.log` — retroaktive Einträge, chronologisch nach Git-Datum einsortiert
- `README.md` — Aktualisierung der Projektbeschreibung
- `docs/RELEASE_NOTES.md` — Neuerstellung gegen `master`/`staging`-Diff

Betroffene **Codebereiche** (nur lesend, als Dokumentationsgrundlage): alle Projekte der Solution (`EmberMediaManager`, `EmberAPI`, `KodiAPI`, `Trakttv`, `TheTVDBApi`, `EmberAPI_Test`, alle Addons unter `Addons/`), `BuildSetup`, `Directory.Build.props`, `.nuget`.

## Implementierungsansatz

- Keine Codeänderung; ausschließlich Markdown-Artefakte und `changes.log`.
- Funktionsbereiche aus Anwendersicht ableiten (z. B. Medienbibliothek/Scanner, Scraper, Kodi-Schnittstelle, Trakt.tv-Synchronisation, Bulk-Rename, Export, Filter, Tags, Einstellungen, Build/Deployment) und je Bereich ein `docs/help/`-Verzeichnis erstellen oder — wie bei `docs/help/build/` — erweitern.
- Entstehungsdaten für `changes.log` aus der Git-Historie (`git log --diff-filter=A`) ermitteln; ältestes Datum je Bereich verwenden.
- Anwenderhilfe (sichtbare UI-Texte, keine Klassennamen) strikt von technischer Dokumentation trennen.

## Konfiguration

Keine Konfigurationsänderungen.

## Offene Fragen

Keine — Umfang und Werkzeuge sind durch die Anforderung eindeutig vorgegeben.
