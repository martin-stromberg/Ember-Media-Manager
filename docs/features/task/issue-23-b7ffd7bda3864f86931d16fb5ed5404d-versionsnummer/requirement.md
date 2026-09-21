# Übersetzte Anforderung: Versionsnummer (Issue #23)

## Fachliche Zusammenfassung

Die in der Anwendung angezeigte Versionsnummer stimmt nicht mit der Version des jeweiligen GitHub-Releases überein: GitHub-Releases werden per `semantic-release` als `vX.Y.Z` (bzw. `vX.Y.Z-rc.N` als Pre-Release) erzeugt, die ausgelieferte `Ember Media Manager.exe` trägt aber weiterhin die in `EmberMediaManager/My Project/AssemblyInfo.vb` hartkodierte Version `1.11.1.0` — der Release-Workflow stampelt die aufgelöste Version bislang nur in `publish/version.json` und `update.json`, nicht in die Assembly. Der Release-/Pre-Release-Prozess ist so anzupassen, dass die aufgelöste Release-Version beim CI-Build in die Assembly-Attribute (`AssemblyVersion`/`AssemblyFileVersion`, ggf. `AssemblyInformationalVersion`) geschrieben wird, sodass die im Programm angezeigte Version (u. a. About-Dialog, Versionsmenüeintrag) der GitHub-Release-Version entspricht.

## Betroffene Klassen und Komponenten

Keine Datenmodellklassen und keine Interfaces betroffen. Betroffen sind Build-/Release-Infrastruktur sowie eine bestehende Assembly-Attributdatei:

### Versionsanzeige (lesend relevant, nicht zu ändern)

- `EmberAPI/clsAPIMaster.vb` — `Master.Version` (Z. 55–63) formatiert `"Version {Major}.{Minor}.{Build} {x86|x64}"` aus `My.Application.Info.Version`; zeigt nur drei Versionskomponenten an.
- `EmberMediaManager/dlgAbout.vb` — About-Dialog zeigt `Master.Version` (Z. 78–81).
- `EmberMediaManager/frmMain.vb` — Menüeintrag `mnuVersion` via `UpdatemnuVersion`/`bwCheckVersion_DoWork` (Z. 18890–18936); der Update-Vergleich parst `AssemblyFileVersion` aus der `AssemblyInfo.vb` des **Upstream**-Repos `DanCooper/Ember-MM-Newscraper` (`EmberAPI/clsAPIHTTP.vb`, `GetLatestVersionInfo`, Z. 349–359).
- `EmberAPI/clsAPICommon.vb` — `Functions.EmberAPIVersion()` (Z. 1109–1111) liest `FileVersionInfo` der `EmberAPI`-Assembly.

### Zu ändernde / neu zu erstellende Artefakte

- `EmberMediaManager/My Project/AssemblyInfo.vb` — enthält hartkodiert `AssemblyVersion("1.11.1.0")`/`AssemblyFileVersion("1.11.1.0")` (Z. 34–35); diese Attribute bestimmen `My.Application.Info.Version` der Exe und müssen beim Build mit der Release-Version überschrieben werden.
- `.github/actions/build-and-package/action.yml` — gemeinsame Composite Action für `staging-ci.yml` (Job `prerelease`) und `release.yml` (Job `release`); erhält bereits die Inputs `release-version`/`release-tag` (Z. 13–21). Hier ist der naheliegende einzige Einfügepunkt für einen „Stamp version"-Schritt **vor** dem MSBuild-Schritt (Z. 33–35), damit beide Pipelines ohne Duplikation versorgt werden.
- `EmberAPI/My Project/AssemblyInfo.vb` — ebenfalls `1.11.1.0` (Z. 34–35); Mit-Stamping zu entscheiden, da `EmberAPIVersion()` diese Dateiversion ausliest.
- Tests: keine Testklassen vorhanden/erforderlich; Verifikation über gebaute Exe (`FileVersionInfo`/`My.Application.Info.Version`) bzw. Überprüfung des Versionsstempels im Build-Log.

### Bestehender Mechanismus (Referenz)

- `scripts/resolve-release-version.mjs` — liefert in `release.yml` die aufgelöste `version`/`tag` (automatisch via `semantic-release`-Dry-Run auf `master`, manuell via gepushtem `vX.Y.Z`-Tag).
- `.github/workflows/staging-ci.yml` — Job `version` (Z. 127–196) ermittelt `rc_version` (`X.Y.Z-rc.N`) und `rc_tag` für Pre-Releases und übergibt beide an `build-and-package` (Z. 208–213).
- `.github/workflows/release.yml` — übergibt `steps.version.outputs.version`/`tag` an `build-and-package` (Z. 109–114). Der vorgelagerte Release-Gate-Build (Debug x86, Z. 87–99) ist nicht Teil der Auslieferung und benötigt kein Stamping.
- `release.config.js`/`package.json` — `semantic-release`-Konfiguration (`branches: ["master"]`, `tagFormat: "v${version}"`).

## Implementierungsansatz

1. **Versionstempel im Build**: Da es sich um Legacy-`.vbproj` (nicht SDK-Style, .NET Framework 4.8, `packages.config`) handelt, sind die Versionsattribute ausschließlich in `AssemblyInfo.vb` definiert — MSBuild-Properties wie `/p:Version=` greifen nicht. Der `release-version`-Input von `build-and-package` ist vor dem MSBuild-Aufruf per PowerShell-Regex-Ersetzung in `EmberMediaManager/My Project/AssemblyInfo.vb` zu schreiben (in der CI-Arbeitskopie; kein Commit erforderlich, da der Tag auf den bereits gemergten Commit zeigt).
2. **Versionsmapping**: `AssemblyVersion`/`AssemblyFileVersion` akzeptieren nur numerische Viererteiler → SemVer `X.Y.Z` wird zu `X.Y.Z.0`. Für Pre-Releases `X.Y.Z-rc.N` ist zu entscheiden, ob `N` als Revision (`X.Y.Z.N`) abgebildet wird; die Vollversion inkl. `-rc.N` kann zusätzlich als `AssemblyInformationalVersion` gesetzt werden (wird von `My.Application.Info.Version`/`Master.Version` allerdings nicht angezeigt).
3. **Reihenfolge in `build-and-package`**: Neuer Schritt „Stamp assembly version" zwischen „Restore dependencies" und „Build (Release x64)"; ohne `release-version`-Input (Default `''`) entweder kein Stamping oder auf `0.0.0` — Verhalten festlegen, damit lokale/nicht-release Builds unverändert bleiben.
4. **Abhängigkeiten**: Keine neuen Tools nötig (PowerShell auf `windows-latest` vorhanden). `resolve-release-version.mjs` und `staging-ci.yml` müssen nicht angepasst werden, wenn das Stamping in der Composite Action erfolgt.

## Konfiguration

Keine Anwendungs- oder Benutzereinstellungen betroffen. Die Version ergibt sich ausschließlich aus dem bestehenden `release-version`-Input der `build-and-package`-Action (bereits von beiden Workflows befüllt). Optional wäre ein semantic-release-Plugin (z. B. `@semantic-release/exec`/`@semantic-release/git`) denkbar, das die eingecheckte `AssemblyInfo.vb` beim Release zurück-committet — neue Toolchain-Abhängigkeit, siehe offene Fragen.

## Offene Fragen

1. **Anzeigeformat bei Pre-Releases**: `Master.Version` zeigt nur `Major.Minor.Build`. Soll bei `vX.Y.Z-rc.N` die RC-Nummer sichtbar sein (z. B. `Master.Version` um Revision/InformationalVersion erweitern oder `X.Y.Z.N` als FileVersion), oder genügt `X.Y.Z`?
2. **Eingecheckte `AssemblyInfo.vb`**: Soll der Versionsstempel nur im CI-Build erfolgen (eingecheckter Wert bleibt ein Platzhalter wie `1.11.1.0` oder `0.0.0.0`), oder soll der Release-Prozess die aktuelle Version ins Repository zurück-committen? Relevanz u. a. für den Update-Check, der `AssemblyFileVersion` aus einer `AssemblyInfo.vb` auf GitHub parst (aktuell allerdings vom Upstream-Repo, nicht vom Fork — siehe Punkt 4).
3. **EmberAPI und Addon-Assemblys**: Soll nur die Haupt-Exe (`EmberMediaManager`) gestempelt werden, oder auch `EmberAPI` (wird von `Functions.EmberAPIVersion()` gelesen) und die ~30 Addon-Assemblys mit eigenen Versionsnummern?
4. **Update-Check-Quelle**: `HTTP.GetLatestVersionInfo` liest die `AssemblyInfo.vb` des Upstream-Repos `DanCooper/Ember-MM-Newscraper` — nicht des Forks. Ist im Rahmen dieses Issues auch die Quelle auf den Fork bzw. `update.json` umzustellen, oder ist das separat zu behandeln?
5. **ClickOnce-Felder**: `EmberMediaManager.vbproj` enthält `ApplicationVersion 1.0.0.%2a` (Z. 34) — ungenutzt ohne ClickOnce-Veröffentlichung; bestätigen, dass keine Anpassung nötig ist.
