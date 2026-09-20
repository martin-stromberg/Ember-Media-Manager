# Code-Review

2. Lauf — Diff `08279a24..HEAD` (Commits `ad92cdc` + `65fa7eed`), Basisbranch `staging`.
Fokus: Korrektheit der 6 Fixes aus `review-code.1.md` sowie erneute kritische Prüfung des Gesamtdiffs.

## Ergebnis

**Status:** Befunde vorhanden

## Befunde

### .githooks/pre-push (bzw. README.md)

- **Fehlerbehandlung / Portabilität** — Zeile 10: `.nuget/NuGet.exe restore "Ember Media Manager.sln"` wird ohne Plattform- oder Ausführbarkeitsprüfung aufgerufen. `NuGet.exe` ist ein Windows-PE-Binary; unter Linux/macOS schlägt der Aufruf fehl, `RESTORE_EXIT != 0` und der Hook **bricht jeden Push ab**. Das steht im Widerspruch zur README, die die Hook-Aktivierung explizit auch für „Linux/macOS (Git Bash)" dokumentiert — dort funktioniert nach dem Fix aus Lauf 1 der `pre-commit`-Hook (Python-Fallback), aber `pre-push` blockiert hart. Gleiche Befundklasse wie der behobene Python-Fallback in `pre-commit`: Vorbedingung („Toolchain auf dieser Plattform lauffähig") wird vor der kritischen Operation nicht validiert.

  Empfehlung: Entweder graceful degradation im Hook (bei nicht ausführbarem NuGet — z. B. `uname`-/`-x`-Check bzw. `command -v mono`-Probe — mit Warnhinweis überspringen statt Exit 1) oder die README-/Hook-Dokumentation auf Windows einschränken. Fail-closed ist als Gate-Semantik nachvollziehbar, aber ein Push-Blocker ohne funktionierende Toolchain auf einer dokumentiert unterstützten Plattform ist ein Defekt.

## Verifizierung der Lauf-1-Fixe

Alle 6 Befunde aus `review-code.1.md` wurden in Commit `65fa7eed` korrekt und vollständig bearbeitet:

1. **Script-Injection `verify-pr-source.yml`** — `github.head_ref` wird jetzt über `env: HEAD_REF` gebunden und als `"$HEAD_REF"` gequotet verwendet; Abweichung von der Referenz ist inline dokumentiert; `permissions: {}` unverändert. ✔
2. **NU190-Muster** — `NU190[1-4]` konsistent in `.github/actions/security-scan/action.yml` (Z. 46, `Select-String -Quiet`) und `.githooks/pre-push` (Z. 23, `grep -qE`); NU1900/NU1905+ jeweils kommentiert begründet ausgeschlossen. ✔
3. **`permissions: contents: read` in `security-scan.yml`** — korrekt auf Workflow-Ebene ergänzt (Z. 21–22), ausreichend für Checkout + Artefakt-Upload. ✔
4. **`translation-check.py`** — verbatim belassen (Plan-Vorgabe); `pre-commit`-Header dokumentiert jetzt korrekt, dass nur die resx-Header-Validierung in diesem Repo wirksam ist. ✔
5. **Python-Fallback in `pre-commit`** — `for PY in python python3 "py -3"` mit `exec`; `sh -n` valide; unquotiertes `$PY` ist für das Word-Splitting von `py -3` bewusst korrekt; fail-closed mit verständlicher Fehlermeldung. ✔
6. **`main`→`master`** — Anzeigenamen (`Promote staging to master`, `Backmerge Master to Staging`) und alle Kommentare in `resolve-release-version.mjs`/`release.config.js` umgezogen. Dateinamen/Concurrency-Gruppen bewusst belassen und inline begründet — trägt keine Branch-Kopplung. Kein verbleibender `main`-Bezug zu einem Branch. ✔

## Erneut geprüft und für korrekt befunden (Auswahl)

- **workflow_run-Kopplung intakt:** `staging-to-main-promotion.yml` referenziert `workflows: ["Pre-Release"]` — das ist weiterhin exakt der Anzeigename von `staging-ci.yml`; die Umbenennung des Promotion-Workflows selbst betrifft keine Fremdreferenz (kein anderer Workflow triggert auf ihn). Kopplungs-Hinweis in beiden Dateien dokumentiert.
- **YAML-Semantik:** Alle 7 Workflows + 2 Composite Actions parsen fehlerfrei (PyYAML); `shell: pwsh` überall gesetzt; `if:`-Bedingungen in `release.yml` decken sich mit den Outputs `released`/`release_action`/`release_kind` aus `resolve-release-version.mjs`; `gh release create/upload`-Pfade werden erst von `build-and-package` erzeugt — Reihenfolge korrekt.
- **Shell-Korrektheit:** `sh -n` für `pre-commit`/`pre-push` fehlerfrei; Dateimodi 100755 für beide Hooks + `install-hooks.sh`; `mktemp`-Nutzung und Aufräum-Pfade in `pre-push` korrekt.
- **Newtonsoft.Json-Update vollständig:** Alle `packages.config` auf `13.0.3`, alle `HintPath` auf `Newtonsoft.Json.13.0.3`, alle `bindingRedirect` repo-weit auf `newVersion="13.0.0.0"` — keine Altversion-Referenzen mehr im Repo.
- **Node-Toolchain:** `package-lock.json` (lockfileVersion 3) konsistent zu `package.json` (semantic-release 25.0.7, github-Plugin 8.1.0, commit-analyzer 9.0.2, notes-generator 10.0.3); `resolve-release-version.mjs` lässt sich als ES-Modul laden, `isMainModule`-Guard intakt; `RESOLVE_DRY_RUN`-Umschaltung in `release.config.js` konsistent zum Aufruf in `runSemanticReleaseDryRun()`.
- **Referenztreue:** Bewusste Abweichungen (env-Indirektion, `permissions` in security-scan.yml, Python-Fallback, `master` statt `main`, entfallene Gates Format/Test/Coverage, NU190-Einschränkung) sind jeweils inline dokumentiert und begründet; keine undokumentierten Abweichungen gefunden.
- **Keine neuen Probleme durch `65fa7eed`:** Der Fix-Commit ändert nur die 9 genannten Dateien, ohne Seiteneffekte (verifiziert via `git show 65fa7eed`).

## Geprüfte Dateien

- `.gitattributes` (Diff: `.githooks/* text eol=lf`)
- `.githooks/install-hooks.cmd`, `.githooks/install-hooks.sh`
- `.githooks/pre-commit`, `.githooks/pre-push`, `.githooks/translation-check.py`
- `.github/actions/build-and-package/action.yml`, `.github/actions/security-scan/action.yml`
- `.github/workflows/pr-staging-ci.yml`, `release.yml`, `security-scan.yml`, `staging-ci.yml`, `staging-to-main-promotion.yml`, `sync-staging-with-main.yml`, `verify-pr-source.yml`
- `package.json`, `package-lock.json`, `release.config.js`, `scripts/resolve-release-version.mjs`
- `README.md` (Diff: neuer CI/CD-Abschnitt)
- Newtonsoft.Json-13.0.3-Update: alle `packages.config`, `*.vbproj`/`*.csproj` (Reference/HintPath), `app.config`/`App.config` (bindingRedirect) in `Addons/*`, `EmberAPI`, `EmberMediaManager`, `KodiAPI`
- Dokumentationsdateien unter `docs/features/task/issue-7-.../` (nur Sichtprüfung, kein Code)
