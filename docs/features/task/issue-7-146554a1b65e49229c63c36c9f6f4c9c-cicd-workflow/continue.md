# Offene Aufgaben

Erstellt am: 2026-09-20
Abbruchgrund: Maximale Iterationsanzahl erreicht

Die folgenden Aufgaben konnten im automatisierten Zyklus nicht abgeschlossen werden
und müssen manuell oder in einem erneuten Lauf bearbeitet werden.
Hinweis: Alle drei Punkte sind manuelle GitHub-/Remote-Schritte außerhalb des
Repo-Inhalts — keine Code-Nacharbeit nötig.

## Offene Planelemente

- [ ] Task 29: Seed-Tag `v1.12.0` auf den aktuellen `master`-Tip (`464fd082`) setzen und zu `origin` pushen — **zeitkritisch vor dem ersten Merge der Workflow-Dateien auf `staging`** (sonst startet semantic-release bei 1.0.0 bzw. löst ein Tag-Push auf einem Commit mit `release.yml` einen manuellen Release-Lauf aus)
- [ ] Task 30: Branch-Protection für `staging` und `master` einrichten (Required Checks = Gate-Jobs; für `master` zusätzlich „Verify PR Source"); sicherstellen, dass GitHub Actions im Fork erlaubt sind
- [ ] Task 31: Live-Verifikation der Workflow-Kette (PR gegen `staging`, „Pre-Release"-Lauf, Promotion-PR) — hängt von Task 29 ab

## Code-Review-Befunde

Keine.

## Usability-Befunde

Keine.

## Fehlgeschlagene Tests

Keine.
