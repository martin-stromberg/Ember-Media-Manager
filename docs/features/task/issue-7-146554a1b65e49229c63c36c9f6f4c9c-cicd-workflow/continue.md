# Offene Aufgaben

Erstellt am: 2026-09-20
Abbruchgrund: Maximale Iterationsanzahl erreicht

Die folgenden Aufgaben konnten im automatisierten Zyklus nicht abgeschlossen werden
und müssen manuell oder in einem erneuten Lauf bearbeitet werden.
Hinweis: Alle drei Punkte sind manuelle GitHub-/Remote-Schritte außerhalb des
Repo-Inhalts — keine Code-Nacharbeit nötig.

## Offene Planelemente

- [x] Task 29: Seed-Tag `v1.12.0` auf den aktuellen `master`-Tip (`464fd082`) gesetzt und zu `origin` gepusht (erledigt 2026-09-20; der `pre-push`-Hook lief dabei live mit bestandenem NU190x-Scan)
- [x] Task 30: Branch-Protection eingerichtet — `staging`: Required Checks `static checks` + `build & test` (strict), `master`: Required Check `verify-source`; kein Force-Push/Deletion. Actions-Permissions verifiziert (`enabled: true`, `allowed_actions: all`)
- [~] Task 31: Live-Verifikation teilweise abgeschlossen — PR #9 gegen `staging` geöffnet, PR-CI „PR CI for Staging" erfolgreich durchgelaufen: `detect-backmerge` ✓ (16s, korrekt kein Back-Merge), `static checks` ✓ (2m9s, NU190x-Gate befundfrei + Debug-x86-Build), `build & test` ✓ (2m4s, Release-x64-Build). Verbleibend: „Pre-Release"-Lauf und Promotion-PR nach dem Merge

## Code-Review-Befunde

Keine.

## Usability-Befunde

Keine.

## Fehlgeschlagene Tests

Keine.
