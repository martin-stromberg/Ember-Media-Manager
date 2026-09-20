# Plan-Gegenprüfung

## Ergebnis

**Status:** Plan vollständig

2. Lauf: Beide im 1. Lauf (`plan-check.1.md`) gemeldeten Lücken sind im aktualisierten Plan geschlossen — (1) der `.gitattributes`-Eintrag `.githooks/* text eol=lf` ist jetzt als eigener Umsetzungsschritt 2 verankert (inkl. Referenz-Abgleich, Commit-Reihenfolge-Constraint „selbes Commit wie `.githooks/`" und Deklaration als dritte Ausnahme der Additiv-Regel; zusätzlich in der Artefakt-Tabelle und Task 8); (2) die Seed-Tag-Sequenz ist korrigiert: Schritt 13 hat keine Repo-Voraussetzung mehr, sondern eine zeitliche Bedingung („Tag auf `origin`, **bevor** die Workflow-Dateien erstmals auf `staging` gemergt werden"), und der Seiteneffekt „Tag-Push auf einen Commit **mit** `release.yml` würde einen `manual`-Release-Lauf auslösen — durch die Reihenfolge ausgeschlossen, da der Tag auf den alten `master`-Tip zeigt" ist dokumentiert (Schritt 13, Risikoabschnitt, Task 29). Auch die Hinweise aus Lauf 1 sind umgesetzt: `translation-check.py`-Resolution-Pfad festgelegt (Befunde dokumentieren + Skript auf gestagte `.resx`-Pakete eingrenzen; Behebung verworfen), Trigger-Risiko je Trigger-Typ präzisiert (`pull_request` läuft aus dem PR-Merge-Commit; `schedule`/`workflow_run` erst auf Default-Branch), README-Änderung als deklarierte Ausnahme. Stichproben-Verifikation gegen das Repository bestätigt die Planbefunde: `core.autocrlf=true` gesetzt, `core.hooksPath` nicht gesetzt, keine Git-Tags, `master`=`464fd082`/`staging`=`08279a24` (enthält `master`), 9 `packages.config` mit `Newtonsoft.Json` (2× `12.0.3`, 7× `13.0.1`), exakt 2 Projektdateien mit `<Reference Version=12.0.0.0>` (Trakttv), exakt 2 `app.config` mit Redirect auf `12.0.0.0`, 142 `.resx`-Dateien, 0 `IStringLocalizer`-Vorkommen, `node_modules/` in `.gitignore` (Zeile 290).

## Abgleich Akzeptanzkriterien

| Akzeptanzkriterium | Umsetzung im Plan | Testnachweis im Plan | Status |
|--------------------|-------------------|----------------------|--------|
| `.githooks/` mit `install-hooks.cmd`/`.sh`, `pre-commit`, `pre-push`, `translation-check.py` (Referenz-Übernahme, Ember-angepasst) | Schritt 3 + „Neue Artefakte": alle 5 Dateien; `pre-push` als NU190x-Spiegel statt Format-Gate (begründete Abweichung); `translation-check.py` verbatim mit festgelegtem Resolution-Pfad bei Bestandsbefunden | Lokal-Verifikation in Schritt 3 / Task 14: `translation-check.py --all` vor Aktivierung, `install-hooks.cmd`, Probe-Commit | Abgedeckt |
| `.gitattributes`-EOL-Schutz für Shell-Hooks (Lücke aus Lauf 1) | Schritt 2 + eigener Abschnitt „Änderungen an bestehenden Klassen → `.gitattributes`" + Artefakt-Tabelle: `.githooks/* text eol=lf` inkl. Kommentarblock, Commit-Reihenfolge festgelegt, als dritte deklarierte Ausnahme dokumentiert | Wirksamkeit implizit über Schritt-3-Verifikation (Hook-Ausführung setzt LF-Checkout voraus) | Abgedeckt |
| 7 Workflows unter `.github/workflows/` (PR-CI, Staging-CI, Verify-PR-Source, Back-Merge, Promotion, Security-Scan, Release) | Schritte 7–11 (inkl. 9 für die drei Automatisierungs-Workflows); alle 7 Dateien in „Neue Artefakte"; Programmabläufe je Workflow beschrieben | Live-Verifikation (Schritt 15 / Task 31): PR → PR-CI-Gates, Push auf `staging` → „Pre-Release"-Kette, Promotion/Back-Merge beobachten | Abgedeckt |
| `.github/actions/security-scan/` Composite Action, wiederverwendet in 3 Workflows | Schritt 4; Umimplementierung auf `nuget restore` + `NU190x`-Parsing; Aufrufe in `pr-staging-ci`, `staging-ci`, `security-scan.yml` | Gate-Verhalten in Live-Verifikation; befundfreier Restore nach Schritt 1 (Task 7) | Abgedeckt |
| `.github/actions/build-and-package/` Composite Action | Schritt 5; `msbuild Release\|x64` → `publish/` → `version.json` → `release.zip` + `update.json` | Nutzung in `staging-ci`/`release`-Pfaden der Live-Verifikation | Abgedeckt |
| Hauptbranch-Mapping `main` → `master` | Designentscheidung + Schritte 6–11: Trigger, `git fetch`/`rev-parse`, PR-Bases, `release.config.js` (`branches: ["master"]`), `resolve-release-version.mjs` (`AUTOMATIC_RELEASE_BRANCHES`) | Indirekt über Live-Verifikation | Abgedeckt |
| Toolchain-Ersatz: `nuget restore` + MSBuild/`windows-latest` statt `dotnet`-CLI | Designentscheidung „Build-Toolchain"; `microsoft/setup-msbuild@v2`; Solution-Name gequotet; `Debug\|x86`/`Release\|x64` | Release-x64-Kompiliernachweis (Schritt 1), Gate-Jobs in CI | Abgedeckt |
| Upstream-Neutralität / rein additive Änderungen | Drei entschiedene Ausnahmen deklariert (`Newtonsoft.Json`-Update, `.gitattributes`-Eintrag, README-Abschnitt); alle anderen Artefakte additiv | `git diff`-Sichtbarkeit implizit | Abgedeckt |
| `Newtonsoft.Json`-Update auf 13.0.3 (Anwenderentscheidung) | Schritt 1 + Detailtabelle (9 `packages.config`, 9 `<HintPath>`, 2× `<Reference Version>`, 2 `app.config`-Redirects) — gegen Repo verifiziert | `nuget restore` ohne NU190x + `msbuild Release\|x64` (Schritt 1, Task 7) | Abgedeckt |
| Security-Gate von Anfang an blockierend | `fail-on-vulnerabilities` Default `'true'` an allen drei Aufrufstellen + blockierender `pre-push`-Hook | Gate 2 in Live-Verifikation | Abgedeckt |
| Seed-Tag `v1.12.0` vor erstem produktivem Lauf (Lücke aus Lauf 1) | Schritt 13 mit zeitlicher Bedingung statt falscher Repo-Voraussetzung; Seiteneffekt „Tag-Push löst `release.yml` nur auf Commits mit Workflow-File aus" dokumentiert; Risikoabschnitt konsistent | Erwartete RC-Version `v1.12.x-rc.1` in Live-Verifikation | Abgedeckt |
| Kein NSIS-Installer in der Pipeline | `build-and-package` ohne NSIS-Schritt; Nicht-Anforderung begründet (kein `tx.exe`/Transifex-Secret, kein `makensis`) | n/a | Abgedeckt |
| Format-Gate / `.editorconfig`: Entscheidung | Entfällt, begründet (Legacy-Projektformat; Referenz hat selbst keine `.editorconfig`); `pre-push` spiegelt stattdessen das Security-Gate | n/a | Abgedeckt |
| Test-/Coverage-Gates: Entscheidung | Gates 4/5 entfallen, begründet (`EmberAPI_Test` baut nicht — Inventar-nachgewiesen); erklärende Kommentare im YAML geplant | n/a | Abgedeckt |
| `pre-commit`-Inhalt für Ember (offene Frage 7) | Festgelegt: Skript verbatim, bei `.resx`-Bestandsbefunden Eingrenzung auf gestagte Pakete (dokumentierte Abweichung) statt Befundbehebung oder Deaktivierung | `--all`-Verifikation in Schritt 3 | Abgedeckt |
| Weitere offene Fragen der Anforderung | Alle entschieden: Pattern-Collection nicht abrufbar → Softwareschmiede als Referenz (Annahme dokumentiert); `master`-Mapping statt Branch-Umbenennung; `EmberAPI_Test`-Reparatur ausdrücklich nicht Teil; volles Workflow-Set inkl. `release.yml`/semantic-release | — | Abgedeckt |

## Fehlende oder unvollständige Testanforderungen

Keine. Die Anforderung verlangt ausdrücklich keine neuen Testklassen; der Plan begründet nachvollziehbar, warum keine Unit-/Integrations-/E2E-Tests möglich bzw. erforderlich sind (keine ausführbare Testbasis — `EmberAPI_Test` baut nicht, nachgewiesen in `inventory/tests.md`). Der Funktionsnachweis ist über Schritt 1 (befundfreier Restore + Release-x64-Build), Schritt 3 (Hook-Verifikation inkl. festgelegtem Befund-Pfad) und Schritt 15 (Live-Pipeline-Ausführung) verankert.

## E2E-Abdeckung

| Benutzerfluss / Akzeptanzkriterium | Geplanter E2E-Test | Status |
|------------------------------------|--------------------|--------|
| Keine Anwendungs-Benutzerflüsse betroffen — ausschließlich CI/CD-Infrastruktur außerhalb der Anwendung | — | Nicht erforderlich mit Begründung: Der Plan enthält eine nachvollziehbare E2E-Begründung (kein UI-/Nutzerfluss geändert, kein E2E-Framework im Repo); der nächstliegende End-to-End-Nachweis ist die beobachtete Pipeline-Ausführung (PR → Gates → Staging-CI → Promotion/Back-Merge) als Umsetzungsschritt 15 |

## Fehlende oder unvollständige Planbestandteile

Keine.

## Hinweise

- **Konsistenz Plan ↔ Taskliste geprüft:** Tasks 1–31 in `…-cicd-workflow-tasks.md` decken die Umsetzungsschritte 1–15 vollständig ab (Paketupdate 1–7, `.gitattributes` 8, GitHooks 9–14, Composite Actions 15–16, Release-Tooling 17–20, Workflows 21–27, README 28, Seed-Tag 29, Branch-Protection 30, Live-Verifikation 31) — keine verwaisten Plan- oder Task-Einträge.
- **Verifikationsnachweise dieses Laufs:** `.gitattributes`-Ist-Zustand (nur `* text=auto` + VS-`merge`/`diff`-Einträge — Plan-Beschreibung stimmt), `core.autocrlf=true` und fehlendes `core.hooksPath` lokal bestätigt, keine Git-Tags, Branch-Spitzen `master`=`464fd082` / `staging`=`08279a24`, `Newtonsoft.Json`-Befunde per Grep exakt wie im Plan (2× `12.0.3`, 7× `13.0.1`; 2 Projektdateien mit `Reference 12.0.0.0`; 2 `app.config` mit `newVersion="12.0.0.0"`), 142 `.resx`-Dateien, kein `IStringLocalizer` im Repo, `node_modules/` in `.gitignore` Zeile 290.
- **Nachplanung (optional, keine Lücke):** Der festgelegte `translation-check.py`-Resolution-Pfad enthält eine bedingte Abweichung (Eingrenzung auf gestagte `.resx`-Pakete nur bei Bestandsbefunden) — das Ergebnis der `--all`-Verifikation in Schritt 3 entscheidet, ob das Skript verbatim bleibt; die Entscheidungslogik ist im Plan ausreichend dokumentiert.
- **Manuelle Schritte außerhalb des Repos** (Seed-Tag-Push, Branch-Protection, Actions-Permissions) sind als Schritte 13/14 benannt und zeitlich korrekt eingeordnet; sie entziehen sich der Commit-Verifikation und sollten bei der Umsetzung explizit abgehakt werden.
