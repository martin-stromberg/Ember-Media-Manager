# Code-Review

3. Lauf — Diff `08279a24..HEAD` (Commits `ad92cdc`, `65fa7eed`, `4e39a1ff`), Basisbranch `staging`.
Fokus: Korrektheit des Plattform-Fixes für `.githooks/pre-push` aus `4e39a1ff` (Shell-Syntax, unverändert blockierende Gate-Semantik unter Windows, Skip nur bei fehlender Toolchain) sowie stichprobenartige Nachprüfung des Gesamtdiffs.

## Ergebnis

**Status:** Keine Befunde

## Verifizierung des Fixes aus `4e39a1ff`

Der einzige Befund aus `review-code.2.md` (pre-push ohne Plattform-Check blockierte Linux/macOS-Pushes) wurde korrekt behoben. Der Commit ändert ausschließlich `.githooks/pre-push` (+37/−1), ohne Seiteneffekte:

- **Shell-Syntax valide:** `sh -n` fehlerfrei; `case`-Konstrukt, `command -v mono` und alle verwendeten Builtins sind POSIX-konform zum Shebang `#!/usr/bin/env sh`. Dateimodus weiterhin `100755`; `.gitattributes` (`*.githooks/* text eol=lf`) stellt LF-Zeilenenden sicher.
- **Plattform-Erkennung korrekt:** `uname -s` liefert unter Git Bash `MINGW*_NT-*`, unter MSYS2 `MSYS_NT-*` bzw. `MINGW*`, unter Cygwin `CYGWIN_NT-*` — alle durch `MINGW*|MSYS*|CYGWIN*|Windows_NT` abgedeckt → `NUGET_RUN=direct`. Linux/macOS/WSL (`Linux`, `Darwin`) fallen in den `*`-Zweig → `mono`-Probe. Fehlt `uname` ganz (stderr umgeleitet, leerer String), landet man ebenfalls im `*`-Zweig — graceful.
- **Gate-Semantik unter Windows unverändert blockierend:** Bei `NUGET_RUN=direct` wird `"$NUGET" restore` wie zuvor direkt ausgeführt; `RESTORE_EXIT != 0` → Exit 1, `NU190[1-4]`-Treffer → Exit 1. Keine Änderung an der Block-Logik (Z. 50–63).
- **Skip nur bei fehlender Toolchain:** Übersprungen wird nur, wenn (a) `.nuget/NuGet.exe` nicht existiert (im Repo eingecheckt — nur bei Sparse-/Teil-Checkout relevant) oder (b) weder Windows-PE-Ausführung noch `mono` verfügbar ist. Beide Skip-Pfade warnen auf stderr und verweisen auf das serverseitige CI-Gate — keine stille Degradierung.
- **Keine neuen Probleme:** Der `else`-Zweig (Z. 44–45) ist nur mit `NUGET_RUN=direct` erreichbar (Leer-Check in Z. 35 vorher); `mktemp`/Aufräum-Pfade unverändert korrekt. Verhaltensänderung „fehlende NuGet.exe → Skip statt Block" ist im Sinne der graceful-degradation-Zielsetzung konsistent und begründet kommentiert.

## Anmerkungen (unter Befund-Schwelle)

- **`Windows_NT`-Pattern:** `uname -s` liefert diesen Wert nie (das ist die `OS`-Umgebungsvariable); der Pattern-Zweig ist defensiv toter Code, aber harmlos und schadet nicht.
- **Mono-Teilfähigkeit:** Unter Linux/macOS mit installiertem `mono` läuft der Restore über `mono NuGet.exe` (gebündelt: NuGet 6.14). Scheitert der Lauf aus Mono-spezifischen Gründen, blockiert der Hook — das ist die spezifizierte Semantik „Toolchain vorhanden → Gate läuft" und deckt sich mit der Fail-Closed-Begründung aus Lauf 2. Eine Probeausführung zum Validieren der Lauffähigkeit wäre überzogen (Speculative Generality).
- **README:** Der CI/CD-Abschnitt beschreibt den pre-push-Hook als „blocking"-Gate, ohne den lokalen Skip-Fallback zu erwähnen. Da der Hook den Skip selbst aussagekräftig auf stderr meldet, ist das eine akzeptable Vereinfachung — kein Befund.

## Stichprobenartig erneut geprüft (Gesamtdiff, ohne neue Befunde)

- **YAML:** Alle 7 Workflows + 2 Composite Actions parsen fehlerfrei (PyYAML).
- **Script-Injection:** `verify-pr-source.yml` bindet `github.head_ref` weiterhin nur über `env: HEAD_REF` und nutzt `"$HEAD_REF"` gequotet (Z. 18–21).
- **NU190-Konsistenz:** `NU190[1-4]` identisch in `.githooks/pre-push` (Z. 59, `grep -qE`) und `.github/actions/security-scan/action.yml`; Ausschluss von NU1900/NU1905+ kommentiert.
- **workflow_run-Kopplung:** `staging-to-main-promotion.yml` → `workflows: ["Pre-Release"]` deckt sich exakt mit `name: Pre-Release` in `staging-ci.yml`.
- **Newtonsoft.Json-Update:** Alle `packages.config` auf `13.0.3`, alle `HintPath` auf `Newtonsoft.Json.13.0.3`, alle betroffenen `bindingRedirect` auf `newVersion="13.0.0.0"` (27 Dateien); keine Altversion-Referenzen. Abweichende `newVersion`-Werte in den app.config-Dateien gehören zu anderen Assemblies (u. a. SQLite).
- **`main`/`master`-Referenzen:** Kein verbliebener Branch-Bezug auf `main`; verbliebene Vorkommen sind Dateinamen/Concurrency-Gruppen (inline begründet) oder die `main()`-Funktion in `resolve-release-version.mjs`.

## Geprüfte Dateien

- `.gitattributes`
- `.githooks/install-hooks.cmd`, `.githooks/install-hooks.sh`
- `.githooks/pre-commit`, `.githooks/pre-push`, `.githooks/translation-check.py`
- `.github/actions/build-and-package/action.yml`, `.github/actions/security-scan/action.yml`
- `.github/workflows/pr-staging-ci.yml`, `release.yml`, `security-scan.yml`, `staging-ci.yml`, `staging-to-main-promotion.yml`, `sync-staging-with-main.yml`, `verify-pr-source.yml`
- `package.json`, `package-lock.json`, `release.config.js`, `scripts/resolve-release-version.mjs`
- `README.md` (Diff: CI/CD-Abschnitt)
- Newtonsoft.Json-13.0.3-Update: alle `packages.config`, `*.vbproj`/`*.csproj`, `app.config`/`App.config` in `Addons/*`, `EmberAPI`, `EmberMediaManager`, `KodiAPI`
- Dokumentationsdateien unter `docs/features/task/issue-7-.../` (nur Sichtprüfung, kein Code)
