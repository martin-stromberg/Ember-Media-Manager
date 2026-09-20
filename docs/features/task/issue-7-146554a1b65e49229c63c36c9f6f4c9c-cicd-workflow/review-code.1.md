# Code-Review

## Ergebnis

**Status:** Befunde vorhanden

## Befunde

### .github/workflows/verify-pr-source.yml

- **Fehlerbehandlung / Security-Härtung** — Zeile 15/16: `${{ github.head_ref }}` wird direkt in das Bash-Skript interpoliert. `head_ref` ist ein vom PR-Autor kontrollierter Branch-Name; Git-Refnames erlauben u. a. `;`, `$()`, Backticks — das ist das klassische Script-Injection-Anti-Pattern in GitHub Actions. Die Auswirkung ist durch `permissions: {}` stark begrenzt (Token ohne Rechte, keine Secrets), das Muster bleibt trotzdem vermeidbar.

  Empfehlung: Den Wert über eine `env:`-Variable indirekt einbinden (`env: HEAD_REF: ${{ github.head_ref }}`, dann `if [ "$HEAD_REF" != "staging" ]`), wie in allen anderen Workflows des Changesets bereits praktiziert.

### .github/actions/security-scan/action.yml und .githooks/pre-push

- **Fehlerbehandlung** — action.yml Zeile 42 (`Select-String -Pattern 'NU190\d'`) bzw. pre-push Zeile 20 (`grep -qE "NU190[0-9]"`): Das Muster matcht neben den echten Vulnerability-Warnungen NU1901–NU1904 auch **NU1900** („Fehler beim Abrufen der Vulnerability-Daten vom Package-Source"). Ein transienter Netz-/Servicefehler von api.nuget.org blockiert dann den Push bzw. das CI-Gate, obwohl keine verwundbare Dependency gefunden wurde.

  Empfehlung: Auf `NU190[1-9]` (bzw. explizit `NU190[1-4]`) einschränken oder NU1900 bewusst als fail-closed dokumentieren — aktuell ist unklar, ob die Mitnahme von NU1900 Absicht ist.

### .github/workflows/security-scan.yml

- **Namenskonventionen und Einheitlichkeit / Permissions** — Der Workflow ist der einzige der sieben neuen Workflows ohne `permissions:`-Block und läuft damit mit den Default-Berechtigungen des `GITHUB_TOKEN` statt mit least privilege.

  Empfehlung: `permissions: contents: read` ergänzen (der Job liest nur den Checkout und lädt ein Artefakt hoch — `actions: write` o. ä. wird nicht benötigt).

### .githooks/translation-check.py (bzw. .githooks/pre-commit)

- **Speculative Generality / faktisch toter Code** — Zwei der drei Prüfungen können in diesem Repository nie auslösen: (a) Der Key-Scan (`check_missing_keys`) durchsucht nur `*.cs/*.razor/*.cshtml` nach `IStringLocalizer`-Indexer-Mustern — Ember Media Manager ist eine VB.NET-WinForms-Anwendung ohne `IStringLocalizer`, die Quelldateien liegen in `*.vb`; ein Lauf über das gesamte Repo findet 0 Keys. (b) Die Paket-Konsistenzprüfung (`check_package_consistency`) setzt Satelliten-resx (`Name.<kultur>.resx`) voraus — das Repo enthält 142 Designer-resx, aber keine einzige Kultur-Variante, jede Datei bildet ihr eigenes „Paket". Wirksam ist allein die resx-Header-Validierung. Die Hook-Beschreibung („Validate localization keys and resx package consistency") verspricht damit mehr, als im Repo je geprüft werden kann.

  Empfehlung: Entweder auf die wirksame Header-Validierung reduzieren und Beschreibung/Docstring anpassen, oder die Prüfung an den tatsächlichen Lokalisierungsmechanismus von Ember (XML-Sprachdateien / `*.vb`-Ressourcen) anbinden.

### .githooks/pre-commit

- **Kopplung / Portabilität** — Zeile 4 ruft `python` auf. Auf Systemen, die nur `python3` (Linux/macOS) oder nur den `py`-Launcher (Windows ohne PATH-Eintrag) haben, schlägt der Hook mit „command not found" fehl und blockiert jeden Commit — obwohl README.md die Aktivierung explizit auch für Linux/macOS dokumentiert.

  Empfehlung: Fallback implementieren, z. B. `python3 ... || python ...`, oder den Python-Aufruf über ein kleines Wrapper-Skript kapseln.

### Branch-Benennung „main" vs. „master" (mehrere Dateien)

- **Inkonsistente Schreibweisen für dasselbe Konzept** — Die Umbenennung `main` → `master` ist in allen Git-Befehlen, Triggern und Expressions korrekt umgesetzt, bleibt aber an mehreren sichtbaren Stellen stehen: Workflow-Anzeigename `Promote staging to main` (staging-to-main-promotion.yml Zeile 1) und `Backmerge Main to Staging` (sync-staging-with-main.yml Zeile 1), die Dateinamen `staging-to-main-promotion.yml`/`sync-staging-with-main.yml` selbst, sowie Kommentare in `scripts/resolve-release-version.mjs` (Zeile 6: „branch push to main", Zeile 216: „later push to main") und `release.config.js` (Zeile 28: „staging->main promotion PR"). Für Leser der Actions-UI und des Codes suggeriert das einen Branch `main`, der in diesem Repo nicht existiert.

  Empfehlung: Anzeigenamen auf „master" umziehen und die Kommentare korrigieren. Achtung: Der `workflow_run`-Trigger in staging-to-main-promotion.yml referenziert den Anzeigenamen von staging-ci.yml (`Pre-Release`) — eigene Umbenennung ist ungefährlich, aber falls `Pre-Release` je umbenannt wird, muss das Array im selben Commit mitziehen (im File bereits dokumentiert). Die Dateinamen können ggf. aus Kompatibilitätsgründen bewusst belassen werden — dann sollte die Diskrepanz zumindest nicht auch in den Anzeigenamen stehen.

## Geprüfte Dateien

- `.gitattributes` (Diff: `.githooks/* text eol=lf`)
- `.githooks/install-hooks.cmd`
- `.githooks/install-hooks.sh`
- `.githooks/pre-commit`
- `.githooks/pre-push`
- `.githooks/translation-check.py`
- `.github/actions/build-and-package/action.yml`
- `.github/actions/security-scan/action.yml`
- `.github/workflows/pr-staging-ci.yml`
- `.github/workflows/release.yml`
- `.github/workflows/security-scan.yml`
- `.github/workflows/staging-ci.yml`
- `.github/workflows/staging-to-main-promotion.yml`
- `.github/workflows/sync-staging-with-main.yml`
- `.github/workflows/verify-pr-source.yml`
- `package.json`, `package-lock.json`
- `release.config.js`
- `scripts/resolve-release-version.mjs`
- `README.md` (Diff: neuer CI/CD-Abschnitt)
- Newtonsoft.Json-13.0.3-Update: alle `packages.config`, `*.vbproj`/`*.csproj` (Reference/HintPath) und `app.config`/`App.config` (bindingRedirect) — diffs in Addons/*, EmberAPI, EmberMediaManager, KodiAPI
- Dokumentationsdateien unter `docs/features/task/issue-7-.../` (nur Sichtprüfung, kein Code)

## Geprüft und für korrekt befunden (Auswahl)

- YAML-Syntax aller 7 Workflows + 2 Composite Actions valide (PyYAML-Parse); `shell: pwsh` in allen `run:`-Schritten der Composite Actions gesetzt; Runner-Wahl (windows-latest für MSBuild) korrekt; `microsoft/setup-msbuild@v2` korrekt verwendet.
- Action-Pins (`checkout@v7`, `setup-node@v7`, `upload-artifact@v7`, `setup-msbuild@v2`) decken sich mit dem Referenz-Repo.
- NU190x-Gate grundsätzlich funktionsfähig: `.nuget/NuGet.exe` ist Version 6.14 → audits packages.config-Restore mit NU190x-Warnungen (NuGet ≥ 6.10). HintPath-/bindingRedirect-/packages.config-Änderungen vollständig konsistent, keine Altvjersions-Reste im Repo.
- Solution-Konfigurationen `Release|x64` und `Debug|x86` existieren; Output-Pfad `EmberMM - Release - x64` und `Ember Media Manager.exe` verifiziert; `EmberMM - $(Configuration) - $(Platform)`-Mapping passt.
- `workflow_run`-Trigger referenziert korrekt den Anzeigenamen `Pre-Release`; secrets/permissions in den übrigen Workflows zweckmäßig (`contents: write` nur dort, wo Releases/Tags erzeugt werden).
- `release.config.js`/`resolve-release-version.mjs`: Dry-Run-Plugin-Umschaltung via `RESOLVE_DRY_RUN`, Asset-Reparatur-Pfad und GITHUB_OUTPUT-Ausgaben konsistent zu den `if:`-Bedingungen in release.yml; isMainModule-Guard Windows-tauglich.
- `.githooks/*` haben korrekte Dateimodi (100755 für die Hooks); `translation-check.py --all` läuft fehlerfrei durch (142 resx-Header valide).
