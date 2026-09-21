# Bestandsaufnahme: Versionsnummer (Issue #23)

Bestandsaufnahme zum Versions-/Release-Prozess von Ember Media Manager: Analysiert wurden die GitHub-Actions-Workflows und Composite Actions unter `.github/`, die `AssemblyInfo.vb`-Dateien aller Projekte sowie der gesamte Codepfad, der die angezeigte Versionsnummer bestimmt (`My.Application.Info.Version`, `Master.Version`, Update-Check).

## Zusammenfassung

- **Release-Versionierung existiert bereits vollständig auf Workflow-Ebene:** `release.yml` löst die Release-Version via `scripts/resolve-release-version.mjs` (semantic-release-Dry-Run bzw. manueller `vX.Y.Z`-Tag) auf, `staging-ci.yml` ermittelt RC-Versionen (`X.Y.Z-rc.N`). Beide übergeben `release-version`/`release-tag` an die Composite Action `build-and-package`.
- **Das Versionsstempeln der Assembly fehlt komplett:** `build-and-package/action.yml` schreibt die aufgelöste Version nur in `publish/version.json` und `update.json` — kein Schritt verändert `AssemblyInfo.vb`. Die Auslieferungs-Exe trägt daher weiterhin die hartkodierte Version `1.11.1.0` (`EmberMediaManager/My Project/AssemblyInfo.vb`, Z. 34–35).
- **Anzeigepfad:** `Master.Version` (`EmberAPI/clsAPIMaster.vb`, Z. 55–63) formatiert `"Version {Major}.{Minor}.{Build} {x86|x64}"` aus `My.Application.Info.Version` — nur drei Komponenten, keine Revision, kein Pre-Release-Suffix. Verwendet in `dlgAbout`, `frmSplash`, `mnuVersion`, Start-Log.
- **Legacy-Projektformat:** Nicht-SDK-`.vbproj` (.NET Framework 4.8, `packages.config`); Versionsattribute stehen ausschließlich in `AssemblyInfo.vb`, MSBuild-Properties wie `/p:Version=` greifen nicht. `AssemblyInformationalVersion` ist in keiner `AssemblyInfo.vb` vorhanden.
- **Weitere Versionsträger:** `EmberAPI` trägt ebenfalls `1.11.1.0` (wird via `Functions.EmberAPIVersion()`/`FileVersionInfo` ausgelesen); die 30 Addon-Assemblys tragen individuelle Versionen (`1.10.x`–`1.11.1.0`), `KodiAPI`/`TVDB` (C#) `1.10.0`/`1.4.4.0`. Addon-`ModuleVersion` wird ebenfalls per `FileVersionInfo` gelesen.
- **Update-Check ist ein separater, teilweise toter Codepfad:** `bwCheckVersion_DoWork` parst `AssemblyFileVersion` aus der `AssemblyInfo.vb` des **Upstream**-Repos `DanCooper/Ember-MM-Newscraper` (`HTTP.GetLatestVersionInfo`); `Functions.CheckNeedUpdate()` ist ein Stub, der immer `False` liefert.
- Test-Ausgangszustand: **Keine ausführbaren Tests vorhanden.** Das einzige Testprojekt `EmberAPI_Test` ist nicht Teil der Solution und kompiliert nicht (203× `BC30002`, fehlendes `UnitTests`-Hilfsprojekt) — nachgewiesen im dokumentierten Ausgangslauf, siehe [Tests](inventory/tests.md). `dotnet test` findet kein testbares Projekt; `package.json` definiert kein Testskript.

## Details

- [CI/CD und Release-Prozess](inventory/ci-cd.md) — Workflows `release.yml`, `staging-ci.yml`, `pr-staging-ci.yml`, Composite Action `build-and-package`, `resolve-release-version.mjs`, `release.config.js`/`package.json`, `BuildSetup/`
- [Assembly-Versionsattribute](inventory/assembly-info.md) — alle `AssemblyInfo.vb`/`.cs`-Dateien und versionsrelevante Projektdatei-Felder
- [Versionsanzeige und Update-Check (Logik)](inventory/logic.md) — `Master.Version`, `ModulesManager`-Versionsliste, `HTTP.GetLatestVersionInfo`, `bwCheckVersion`, beteiligte Dialoge
- [Interfaces](inventory/interfaces.md) — `ModuleVersion`-Contract der Addon-Interfaces
- [Tests](inventory/tests.md) — Test-Ausgangszustand und Nachweise
