# Umsetzungsplan: Wiederkehrende Review-Issues

## Scope-Klärung

### Verarbeitungseinheit

Ein geplanter Workflow-Lauf erzeugt höchstens ein Issue für genau einen Review-Typ. Die Zuordnung erfolgt über ein typbezogenes GitHub-Label, das der Workflow bei Bedarf anlegt und das als Duplikatkriterium dient.

### Auslösende Ereignisse

- Monatliches Architektur- und Sicherheitsreview: `schedule` am ersten Tag des Monats.
- Wöchentliche NuGet-Prüfung: `schedule` einmal pro Woche.
- Jährliches Compliance- und Copyright-Review: `schedule` am 1. Januar.
- Zusätzlich `workflow_dispatch` pro Workflow für kontrollierte manuelle Ausführung.

### Erwartete Wirkung

- Existiert kein offenes Issue mit dem Typ-Label: Issue mit festem Titel, Label und Repository-Template-Text anlegen; der Text beginnt mit `@softwarewerkstatt`.
- Existiert bereits ein offenes Issue mit dem Typ-Label: erfolgreich protokollieren und kein neues Issue anlegen.

### Umgang mit fehlenden Objekten

- Fehlendes Label: automatisch per `gh label create --force` anlegen.
- Fehlendes offenes Issue: neues Issue erzeugen.
- Geschlossene Issues aus früheren Zyklen bleiben unverändert und blockieren nicht.
- Fehlschlagende GitHub-Aufrufe lassen den Workflow fehlschlagen, damit der Lauf sichtbar wiederholt werden kann.

### Scope-Ausschlüsse

Keine offenen Scope-Ausschlüsse. Die inhaltlichen Review-Analysen und etwaige Update-PRs bleiben Aufgabe des erwähnten Accounts und sind nicht Teil dieser Workflow-Implementierung.

## Umsetzungsschritte

1. `scripts/New-RecurringIssue.ps1` erstellen: validiert Parameter, legt das Typ-Label an, prüft offene Issues über `gh issue list --state open --label`, erzeugt bei Bedarf das Issue über `gh issue create --body-file`.
2. Drei versionierte Issue-Textvorlagen unter `.github/recurring-issues/` anlegen, jeweils mit `@softwarewerkstatt` als erster Zeile und den geforderten Prüfpunkten.
3. Drei separate Workflows anlegen:
   - `monthly-architecture-security-review.yml` mit `0 6 1 * *`
   - `weekly-nuget-review.yml` mit `0 5 * * 1`
   - `yearly-compliance-review.yml` mit `0 7 1 1 *`
   Jeder Workflow nutzt `contents: read` + `issues: write`, checkt das Repository aus, setzt `GH_TOKEN` und ruft das gemeinsame Skript mit eigenem Label/Titel/Template auf.
4. Pro Workflow `concurrency` mit `cancel-in-progress: false` setzen, damit gleichzeitige manuelle/geplante Läufe serialisiert werden und die Duplikatprüfung wirkt.
5. Dokumentation ergänzen: neue Seite `docs/help/ci-cd/recurring-reviews.md`, Links/Regeln in `index.md`, `beschreibung.md`, `ablauf-technisch.md`, `business-rules.md`, `troubleshooting.md`, `README.md` und `docs/RELEASE_NOTES.md` aktualisieren.
6. Verifizieren: YAML-Struktur parsen, PowerShell-Skript syntaktisch kompilieren, Workflows/Skript/Templates gegen die Akzeptanzkriterien prüfen und `git diff` reviewen.

## Akzeptanzszenarien

### Happy Path: neues Issue je Typ

Ausgangszustand: Workflow-Datei liegt auf dem Default-Branch, kein offenes Issue trägt das Typ-Label.

1. Cron-Trigger oder manueller Dispatch startet die passende Action.
2. Der Job checkt das Repository aus und stellt sicher, dass das Typ-Label existiert.
3. `gh issue list` findet kein offenes Issue mit diesem Label.
4. `gh issue create` erzeugt ein Issue mit Titel, Label und Template-Text; erste Zeile ist `@softwarewerkstatt`.

### Wiederaufnahme/Duplikatfall

Ausgangszustand: ein offenes Issue trägt bereits das Typ-Label.

1. Workflow startet erneut.
2. Die Label-Abfrage findet das offene Issue.
3. Workflow endet erfolgreich ohne `gh issue create`; kein Duplikat entsteht.

### Fehlerfall

Ausgangszustand: GitHub API oder Tokenrechte schlagen fehl.

1. Der betroffene `gh`-Aufruf bricht das Skript mit Fehler ab.
2. Der Workflow-Lauf ist sichtbar fehlgeschlagen und kann nach Korrektur erneut gestartet werden.

## Offene Punkte

Keine.
