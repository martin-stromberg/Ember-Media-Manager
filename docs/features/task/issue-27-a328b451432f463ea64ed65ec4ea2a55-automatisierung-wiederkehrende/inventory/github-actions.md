# Inventory-Detail: GitHub-Actions-Konventionen

## Beobachtete Konventionen

- Workflow-Dateien liegen in `.github/workflows/` und tragen sprechende englische `name:`-Werte.
- Zeitgesteuerte Automatisierung verwendet `schedule` mit UTC-Cron und optional `workflow_dispatch`.
- Externe GitHub-Aktionen laufen auf `ubuntu-latest` mit `shell: pwsh`.
- `GH_TOKEN` wird aus `${{ github.token }}` gespeist; Berechtigungen werden minimal pro Workflow deklariert.
- Label- und PR-Duplikatschutz wird bereits mit `gh label create --force` bzw. `gh pr list --state open` umgesetzt.
- `concurrency` wird verwendet, um parallele Läufe derselben Automatisierung zu steuern.
- Kommentare in den Workflow-Dateien dokumentieren nicht offensichtliche Entscheidungen und operative Fallstricke.

## Wiederverwendbare Bausteine

- `gh issue list --state open --label <label>` kann offene Issues eines Typs prüfen.
- `gh issue create --title <title> --body-file <file> --label <label>` kann Issues mit einem versionierten Repository-Template anlegen.
- Ein gemeinsames PowerShell-Hilfsskript kann Label-Erstellung, Duplikatprüfung und Issue-Erstellung kapseln, während jede Workflow-Datei nur Zeitplan, Titel, Label und Vorlage konfiguriert.

## Dokumentationsorte

- Übersicht und Aufnahme neuer CI/CD-Dokumentationsseiten: `docs/help/ci-cd/index.md`
- Technischer Workflow-Katalog: `docs/help/ci-cd/ablauf-technisch.md`
- Operative Regeln: `docs/help/ci-cd/business-rules.md`
- Fehlerdiagnose: `docs/help/ci-cd/troubleshooting.md`
- Kurzübersicht für Benutzer: `README.md`
