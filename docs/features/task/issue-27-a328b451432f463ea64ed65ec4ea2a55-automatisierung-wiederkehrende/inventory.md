# Bestandsaufnahme: Wiederkehrende Review-Issues

## Ist-Stand

- Der Branch `task/issue-27-a328b451432f463ea64ed65ec4ea2a55-automatisierung-wiederkehrende` basiert auf `origin/staging`; `origin/staging` ist Vorfahre von `HEAD`.
- Unter `.github/workflows/` existieren bereits sieben Workflows für PR-CI, Staging-CI, Release, Promotion, Back-Merge und einen wöchentlichen Security-Scan.
- Es existiert noch keine Automatisierung, die zeitgesteuert GitHub Issues erzeugt.
- `security-scan.yml` demonstriert den bestehenden `schedule`-Trigger (`0 4 * * 1`) plus `workflow_dispatch`.
- `staging-to-main-promotion.yml` und `sync-staging-with-main.yml` verwenden `GH_TOKEN: ${{ github.token }}` mit der GitHub CLI, deklarieren `issues: write` und erstellen Labels per `gh label create --force`.
- Für externe API-/Issue-Aktionen werden schlanke `ubuntu-latest`-Jobs mit `shell: pwsh` verwendet; PowerShell ist auf GitHub-Runnern verfügbar.
- `scripts/` enthält bereits repositoryseitige Hilfsskripte; `.github/` enthält noch keine benutzerdefinierten Issue-Textvorlagen.
- Die CI/CD-Dokumentation liegt unter `docs/help/ci-cd/` und beschreibt Workflows, Business Rules und Troubleshooting. `README.md` verlinkt diesen Bereich und fasst die Workflow-Landschaft zusammen.
- Es gibt keine ausführbare Test-Suite; `EmberAPI_Test` ist nicht Teil der Solution und kann nicht gebaut werden. Für Workflow-Änderungen sind Syntaxprüfung und Code-Review die verfügbaren lokalen Verifikationen.

## Relevante Details

- [GitHub-Actions-Konventionen](inventory/github-actions.md)

## Einschränkungen

- GitHub führt `schedule`-Trigger nur für Workflows auf dem Default-Branch aus. Die neue Automatisierung wird daher erst nach Integration bis `master` aktiv; ein vollständiger echter Scheduled-Run kann lokal nicht ausgelöst werden.
- Eine echte Issue-Erstellung zur Verifikation würde remote Daten erzeugen und ist ohne expliziten Auftrag nicht Teil der lokalen Prüfung.
