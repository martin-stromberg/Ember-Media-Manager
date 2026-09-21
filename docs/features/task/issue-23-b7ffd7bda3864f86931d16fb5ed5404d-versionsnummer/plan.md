# Umsetzungsplan: Versionsnummer (Issue #23)

## Übersicht

Die ausgelieferte `Ember Media Manager.exe` trägt die in `EmberMediaManager/My Project/AssemblyInfo.vb` hartkodierte Version `1.11.1.0`, obwohl GitHub-Releases via `semantic-release` als `vX.Y.Z` bzw. `vX.Y.Z-rc.N` erzeugt werden. Umgesetzt wird ein Versionsstempel-Schritt in der Composite Action `.github/actions/build-and-package/action.yml`, der die bereits vorhandene Input-Variable `release-version` vor dem MSBuild-Lauf in die Assembly-Attribute von `EmberMediaManager` und `EmberAPI` schreibt. Betroffen sind ausschließlich Build-/Release-Infrastruktur sowie die `AssemblyInfo.vb`-Dateien — kein Anwendungscode, keine Datenmodelle.

## Designentscheidungen

| Komponente / Bereich | Gewählter Ansatz | Begründung |
|----------------------|-----------------|------------|
| Einfügepunkt des Stampings | Neuer Schritt „Stamp assembly version" in `.github/actions/build-and-package/action.yml` zwischen „Restore dependencies" und „Build (Release x64)" | Einzige gemeinsame Stelle für `release.yml` (stabile Releases) und `staging-ci.yml` (Pre-Releases) — keine Duplikation; `release-version`/`release-tag` stehen dort bereits als Inputs zur Verfügung |
| Technik des Stampings | PowerShell-Regex-Ersetzung direkt in den eingecheckten `AssemblyInfo.vb`-Dateien der CI-Arbeitskopie — **ohne Rück-Commit** ins Repo (kein `@semantic-release/git`/`exec`) | Legacy-`.vbproj` (nicht SDK-Style, .NET Framework 4.8): MSBuild-Properties wie `/p:Version=` greifen nicht, Versionsattribute existieren nur in `AssemblyInfo.vb`. Kein Commit nötig, da der Release-Tag auf den bereits gemergten Commit zeigt; CI-only-Stamping vermeidet eine neue Toolchain-Abhängigkeit |
| Abbildung SemVer → Assembly-Version | `X.Y.Z` → `X.Y.Z.0`; `X.Y.Z-rc.N` → `X.Y.Z.N` als `AssemblyVersion`/`AssemblyFileVersion`; zusätzlich `AssemblyInformationalVersion` mit dem vollen SemVer-String (`X.Y.Z` bzw. `X.Y.Z-rc.N`) | `AssemblyVersion`/`AssemblyFileVersion` akzeptieren nur numerische Viererteiler; die RC-Nummer bleibt in der Revision erhalten und der volle SemVer-String steht in `FileVersionInfo.ProductVersion` zur Verfügung. `Functions.EmberAPIVersion()` und `ModuleVersion`-Leser (vierteiliges Format) bleiben kompatibel |
| `AssemblyInformationalVersion` einführen | Platzhalter-Attributzeile `<Assembly: AssemblyInformationalVersion("")>` wird in die eingecheckten `AssemblyInfo.vb`-Dateien aufgenommen, der Stempel-Schritt ersetzt sie per Regex wie die anderen Attribute | Macht den Stempel-Schritt zu einer uniformen Regex-Ersetzung auf drei vorhandene Zeilen statt bedingtem Einfügen; bei Nicht-Release-Builds ohne Input bleibt das Attribut leer und greift nicht in die Anzeige ein |
| Eingecheckter Platzhalter | `AssemblyVersion`/`AssemblyFileVersion` werden in beiden `AssemblyInfo.vb`-Dateien von `1.11.1.0` auf `0.0.0.0` gesenkt | Macht versehentlich ungestempelte Builds (lokale Builds, CI-Läufe ohne Release-Kontext) eindeutig als Nicht-Release-Artefakte erkennbar (`Master.Version` zeigt dann „Version 0.0.0 x64"); die zuvor eingecheckte `1.11.1.0` würde fälschlich eine konkrete Release-Version suggerieren |
| Verhalten bei leerem `release-version` | Schritt wird übersprungen (Log-Ausgabe „no release version — skipping stamp"), `AssemblyInfo.vb` bleibt unverändert | Lokale Builds und Builds ohne Release-Kontext (z. B. `pr-staging-ci.yml` ruft die Action nicht auf) bleiben unverändert; der eingecheckte Platzhalter `0.0.0.0` wirkt als Erkennungsmerkmal |
| Scope des Stampings | `EmberMediaManager` **und** `EmberAPI` werden gestempelt; die ~30 Addon-Assemblys bleiben unverändert | `Functions.EmberAPIVersion()` wird in `dlgVersions`/`dlgErrorViewer` direkt neben „Ember Application" angezeigt — abweichende Stände wirken inkonsistent. Addons sind eigenständig versionierte Module (`ModuleVersion`), ein Überschreiben würde deren individuelle Historie zerstören |
| Anzeigeformat `Master.Version` | Bleibt unverändert dreiteilig (`Major.Minor.Build` + `x86`/`x64`) — keine Änderung am Anzeigecode | Die RC-Nummer bleibt über die `FileVersion`-Revision (`X.Y.Z.N`, sichtbar in `dlgVersions` und den Datei-Eigenschaften) und `AssemblyInformationalVersion` (`X.Y.Z-rc.N` in `FileVersionInfo.ProductVersion`) nachvollziehbar; eine Erweiterung des Anzeigecodes ist nicht erforderlich |
| Update-Check-Quelle | `HTTP.GetLatestVersionInfo` (parst die `AssemblyInfo.vb` des Upstream-Repos `DanCooper/Ember-MM-Newscraper`) bleibt in diesem Issue **unverändert** | Bewusster Ausschluss — die Quellumstellung auf den Fork bzw. `update.json` ist eine eigenständige fachliche Entscheidung und wird separat behandelt; der Pfad ist ohnehin teilweise tot (`Functions.CheckNeedUpdate()` ist ein Stub, der immer `False` liefert) |
| `v`-Toleranz beim Parsen | Der Stempel-Schritt entfernt vor der Validierung defensiv ein führendes `v` (`-replace '^v',''`) aus `release-version` | Konsistent mit den Geschwisterschritten „Write version manifest"/„Create update manifest" (action.yml Z. 64, 103), die dasselbe tun. Aktuell liefern beide aufrufenden Workflows immer ein `v`-freies Format — die Toleranz ist reine Robustheit gegen künftige Aufrufer, die Validierung gegen `X.Y.Z`/`X.Y.Z-rc.N` bleibt anschließend strikt |
| Repair-Pfad `release_action == 'upload-existing'` (`release.yml` Z. 57–80, 109–114, 145–152) | **Bewusster Ausschluss — kein Eingriff.** Der Workflow checkt den getaggten Commit aus; `build-and-package` wird dabei aus dem getaggten Stand geladen | Für Tags, die nach dieser Änderung erstellt wurden, funktioniert das Stamping im Repair-Pfad automatisch (`release-version`/`release-tag` werden auch dort übergeben, Z. 113–114). Für Tags **vor** dieser Änderung existiert im getaggten Stand kein Stempel-Schritt und `AssemblyInfo.vb` trägt `1.11.1.0` — das reparierte Asset liefert dann weiterhin die damalige Version, was mit dem bereits publizierten Release konsistent ist. Eine nachträgliche Versionskorrektur alter Releases ist nicht Ziel der Anforderung; der Verify-Schritt existiert in alten getaggten Ständen ebenfalls nicht, sodass kein falscher Build-Fehlschlag entsteht |

## Programmabläufe

### Stabiler Release-Build (`release.yml`)

1. `release.yml` löst die Release-Version über `scripts/resolve-release-version.mjs` auf (semantic-release-Dry-Run auf `master` oder manueller `vX.Y.Z`-Tag) und übergibt `version`/`tag` als `release-version`/`release-tag` an `build-and-package`.
2. In `build-and-package`: nach „Restore dependencies" liest der neue Schritt „Stamp assembly version" den Input `release-version` aus `env`, entfernt defensiv ein führendes `v` (`-replace '^v',''` — wie die Geschwisterschritte „Write version manifest"/„Create update manifest"), validiert den Rest gegen das SemVer-Muster `X.Y.Z` bzw. `X.Y.Z-rc.N` und bricht bei ungültigem Format den Build mit Fehlermeldung ab. Das Muster ist bewusst **strenger als `VERSION_PATTERN` in `resolve-release-version.mjs`** (Z. 18), das beliebige SemVer-Pre-Release-Suffixe (`-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*`) akzeptiert: Ein manuell gepushter Tag wie `v1.2.3-beta.1` passiert die Auflösung, schlägt aber hier laut fehl statt falsch gestempelt ausgeliefert zu werden — die Fehlermeldung nennt das akzeptierte Format `X.Y.Z`/`X.Y.Z-rc.N`.
3. Der Schritt berechnet die Assembly-Version `X.Y.Z.0` (stabil) bzw. `X.Y.Z.N` (RC-Nummer als Revision) sowie die Informational-Version (voller SemVer-String) und ersetzt per Regex die drei Attributzeilen `AssemblyVersion`, `AssemblyFileVersion`, `AssemblyInformationalVersion` in `EmberMediaManager/My Project/AssemblyInfo.vb` und `EmberAPI/My Project/AssemblyInfo.vb`. Die gestempelten Werte werden ins Build-Log geschrieben. Die Änderungen verbleiben in der CI-Arbeitskopie — es erfolgt kein Rück-Commit ins Repository.
4. „Build (Release x64)" kompiliert die Solution mit den gestempelten Attributen — `My.Application.Info.Version` der Exe liefert fortan die Release-Version.
5. „Verify publish output" wird erweitert: bei gesetztem `release-version`-Input werden die gestempelten Attribute der gebauten Artefakte geprüft; jede Abweichung = Build-Fehler.
   - `publish/Ember Media Manager.exe`: `FileVersionInfo.FileVersion` (= `AssemblyFileVersion`) **und** `[Reflection.AssemblyName]::GetAssemblyName('publish\Ember Media Manager.exe').Version` (= `AssemblyVersion`) gegen die erwartete Assembly-Version `X.Y.Z.0`/`X.Y.Z.N`, zusätzlich `FileVersionInfo.ProductVersion` (= `AssemblyInformationalVersion`) gegen den vollen SemVer-String `X.Y.Z`/`X.Y.Z-rc.N`. Die `AssemblyVersion`-Prüfung ist entscheidend, weil die im Programm angezeigte Version (`My.Application.Info.Version` → `Master.Version` in `dlgAbout`/`frmSplash`/`mnuVersion`/Start-Log sowie „Ember Application" in `dlgVersions`) aus `AssemblyName.Version` = `AssemblyVersion` stammt — ein still nicht greifender Regex-Ersatz nur auf der `AssemblyVersion`-Zeile würde eine Exe ausliefern, die „Version 0.0.0 x64" anzeigt, bei grünem Build.
   - `publish/EmberAPI.dll`: `FileVersionInfo.FileVersion` gegen die erwartete Assembly-Version — `Functions.EmberAPIVersion()` liest `FileVersion`, das ist dort das angezeigte Attribut; symmetrisch wird auch die `AssemblyVersion` der DLL mitgeprüft.
   Hintergrund beider Prüfungen: PowerShell-`-replace` wirkt bei Nicht-Treffer still — ein Pfad-/Regex-Fehler in einer der beiden `AssemblyInfo.vb`-Dateien oder auf einer einzelnen Attributzeile würde sonst ein ungestempeltes oder teilgestempeltes Artefakt ausliefern („Ember API" bzw. „Ember Application" zeigen `0.0.0.0` in `dlgVersions`/`dlgErrorViewer`), ohne dass der Build fehlschlägt.
6. Zur Laufzeit zeigt `Master.Version` (`EmberAPI/clsAPIMaster.vb`) „Version X.Y.Z x64" in `dlgAbout`, `frmSplash`, `mnuVersion` und Start-Log — identisch mit dem GitHub-Release `vX.Y.Z`. `dlgVersions` zeigt „Ember Application" und „Ember API" als `X.Y.Z.0`.
7. `version.json`/`update.json` bleiben unverändert (bestehende Schritte „Write version manifest"/„Create update manifest").

Beteiligte Klassen/Komponenten: `build-and-package/action.yml`, `resolve-release-version.mjs` (unverändert), `AssemblyInfo.vb` (EmberMediaManager, EmberAPI), `Master.Version`, `Functions.EmberAPIVersion()`

### Pre-Release-Build (`staging-ci.yml`)

1. `staging-ci.yml` Job `version` ermittelt `rc_version` (`X.Y.Z-rc.N`) und `rc_tag` (`vX.Y.Z-rc.N`) und übergibt beide an `build-and-package` (Job `prerelease`, Z. 208–212).
2. Der „Stamp assembly version"-Schritt parst das `-rc.N`-Suffix und schreibt `AssemblyVersion`/`AssemblyFileVersion` = `X.Y.Z.N` sowie `AssemblyInformationalVersion` = `X.Y.Z-rc.N` in beide `AssemblyInfo.vb`-Dateien.
3. Build, Verify und Packaging wie beim stabilen Release; `gh release create --prerelease` bleibt unverändert.
4. Zur Laufzeit zeigt `Master.Version` weiterhin nur `Major.Minor.Build` („Version X.Y.Z x64"); die RC-Nummer `N` ist über die `FileVersion`-Revision (`X.Y.Z.N` in `dlgVersions`/Datei-Eigenschaften) und `FileVersionInfo.ProductVersion` (`X.Y.Z-rc.N`) nachvollziehbar.

Beteiligte Klassen/Komponenten: `staging-ci.yml` (unverändert), `build-and-package/action.yml`, `AssemblyInfo.vb` (EmberMediaManager, EmberAPI)

### Asset-Reparatur (`release.yml`, `release_action == 'upload-existing'`)

1. `resolve-release-version.mjs` erkennt ein bereits existierendes Release mit fehlenden Assets und liefert `release_action = 'upload-existing'` samt `version`/`tag`.
2. „Check out release tag for asset repair" (`release.yml` Z. 57–80) checkt den getaggten Commit aus — `build-and-package` wird damit aus dem **getaggten Stand** geladen, nicht aus dem Stand des auslösenden Commits.
3. **Tag nach dieser Änderung:** Die getaggte `action.yml` enthält den Stempel-Schritt; „Build and package" (Z. 109–114) übergibt auch im Repair-Pfad `release-version`/`release-tag` → das reparierte Asset wird korrekt gestempelt und verifiziert.
4. **Tag vor dieser Änderung:** Die getaggte `action.yml` enthält keinen Stempel-Schritt und die getaggte `AssemblyInfo.vb` trägt `1.11.1.0` → das reparierte Asset liefert die damalige Assembly-Version. Bewusster Ausschluss (siehe Designentscheidung): Das Ergebnis ist konsistent mit dem bereits publizierten Release; in alten getaggten Ständen existiert auch kein Verify-Schritt, sodass kein falscher Build-Fehlschlag entsteht. Eine nachträgliche Versionskorrektur bereits veröffentlichter Releases ist nicht Ziel der Anforderung.

Beteiligte Klassen/Komponenten: `release.yml` (unverändert), `build-and-package/action.yml` (versionsabhängig aus dem getaggten Stand)

### Nicht-Release-Build (Input leer)

1. `release-version` ist leer (Default `''`) → der Schritt loggt „skipping stamp" und endet erfolgreich ohne Dateiänderung.
2. Build läuft mit dem eingecheckten Platzhalter `0.0.0.0` bzw. leerem `AssemblyInformationalVersion` weiter; das Ergebnis ist als Nicht-Release-Artefakt erkennbar („Version 0.0.0 x64").
3. Nebenwirkung der leeren Platzhalterzeile: `FileVersionInfo.ProductVersion` liefert bei Nicht-Release-Builds einen leeren String statt des bisherigen Fallbacks auf `FileVersion`. Unschädlich (`ProductVersion` wird in der Anwendung nicht angezeigt), bei der Umsetzung kurz verifizieren.

## Neue Klassen

Keine — es werden keine Klassen, Datenmodelle oder Interfaces angelegt. Die Änderung betrifft ausschließlich CI-YAML und Assembly-Attributdateien.

## Änderungen an bestehenden Klassen

### `build-and-package/action.yml` (Composite Action, `.github/actions/build-and-package/action.yml`)

- **Neuer Schritt „Stamp assembly version"** (zwischen „Restore dependencies", Z. 29–31, und „Build (Release x64)", Z. 33–35): `shell: pwsh`; liest `env: RELEASE_VERSION` aus `inputs.release-version`; bei leerem Wert Skip; entfernt defensiv ein führendes `v` (`-replace '^v',''`); Validierung gegen das SemVer-Muster `X.Y.Z`/`X.Y.Z-rc.N` — bewusst strenger als `VERSION_PATTERN` in `resolve-release-version.mjs`, das beliebige Pre-Release-Suffixe akzeptiert (andere Suffixe wie `-beta.1` schlagen hier laut fehl); Regex-Ersetzung der Attribute `AssemblyVersion`, `AssemblyFileVersion`, `AssemblyInformationalVersion` in beiden `AssemblyInfo.vb`-Dateien; Log-Ausgabe der gestempelten Werte. Kein `git commit`/`git push` — die Änderung verbleibt in der Arbeitskopie.
- **Erweiterter Schritt „Verify publish output"** (Z. 74–82): bei gesetztem `release-version`-Input zusätzliche Prüfungen — für `publish/Ember Media Manager.exe` `FileVersionInfo.FileVersion` (= `AssemblyFileVersion`) und `[Reflection.AssemblyName]::GetAssemblyName('publish\Ember Media Manager.exe').Version` (= `AssemblyVersion`, Quelle von `My.Application.Info.Version`/`Master.Version` und damit der angezeigten Version) gegen die erwartete Assembly-Version `X.Y.Z.0`/`X.Y.Z.N` sowie `FileVersionInfo.ProductVersion` (= `AssemblyInformationalVersion`) gegen den vollen SemVer-String; für `publish/EmberAPI.dll` `FileVersionInfo.FileVersion` (das von `Functions.EmberAPIVersion()` angezeigte Attribut) und symmetrisch die `AssemblyVersion` gegen `X.Y.Z.0`/`X.Y.Z.N`.

### `EmberMediaManager/My Project/AssemblyInfo.vb` (Assembly-Attributdatei)

- **Geänderte Attribute:** `AssemblyVersion`/`AssemblyFileVersion` (Z. 34–35) werden von `1.11.1.0` auf den Platzhalter `0.0.0.0` gesenkt.
- **Neues Attribut:** `AssemblyInformationalVersion` ({String}) — Platzhalterzeile `<Assembly: AssemblyInformationalVersion("")>` nach `AssemblyFileVersion`, damit der Stempel-Schritt uniform per Regex ersetzen kann.

### `EmberAPI/My Project/AssemblyInfo.vb` (Assembly-Attributdatei)

- **Geänderte Attribute:** `AssemblyVersion`/`AssemblyFileVersion` (Z. 34–35) werden analog auf `0.0.0.0` gesenkt.
- **Neues Attribut:** `AssemblyInformationalVersion` ({String}) — analoge Platzhalterzeile nach `AssemblyFileVersion`.
- Wird vom selben Stempel-Schritt mit denselben Werten wie die Haupt-Exe beschrieben.

## Datenbankmigrationen

Keine.

## Validierungsregeln

| Feld / Objekt | Regel | Fehlerfall |
|---------------|-------|------------|
| Input `release-version` (`build-and-package`) | Führendes `v` wird vorab defensiv entfernt (`-replace '^v',''`); der Rest muss bei gesetztem Wert dem Muster `X.Y.Z` oder `X.Y.Z-rc.N` entsprechen (SemVer mit optionalem RC-Suffix — dem RC-Format aus `staging-ci.yml`). **Strenger als `VERSION_PATTERN` aus `resolve-release-version.mjs` (Z. 18):** Das Auflösungs-Muster akzeptiert beliebige SemVer-Pre-Release-Suffixe (`-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*`), der Stempel-Schritt nur `X.Y.Z` und `X.Y.Z-rc.N` | Build schlägt im „Stamp assembly version"-Schritt mit klarer Fehlermeldung fehl, bevor kompiliert wird — die Meldung nennt das akzeptierte Format. Beabsichtigtes lautes Fehlschlagen: Ein manuell gepushter Tag wie `v1.2.3-beta.1` passiert die Auflösung in `release.yml`, wird aber hier abgebrochen statt falsch oder teilweise gestempelt ausgeliefert zu werden |
| `publish/Ember Media Manager.exe` | Bei gesetztem `release-version`: `FileVersionInfo.FileVersion` (= `AssemblyFileVersion`) **und** `[Reflection.AssemblyName]::GetAssemblyName('publish\Ember Media Manager.exe').Version` (= `AssemblyVersion`, Quelle von `My.Application.Info.Version`/`Master.Version` in About/Splash/`mnuVersion`/Start-Log und „Ember Application" in `dlgVersions`) müssen der erwarteten Assembly-Version (`X.Y.Z.0`/`X.Y.Z.N`) entsprechen; `FileVersionInfo.ProductVersion` (= `AssemblyInformationalVersion`) muss dem vollen SemVer-String (`X.Y.Z`/`X.Y.Z-rc.N`) entsprechen | Build schlägt im „Verify publish output"-Schritt fehl — ein still nicht greifender Regex-Ersatz auf einer einzelnen Attributzeile (insbesondere `AssemblyVersion`, die die angezeigte Version bestimmt) wird entdeckt statt eine Exe auszuliefern, die „Version 0.0.0 x64" anzeigt |
| `publish/EmberAPI.dll` | Bei gesetztem `release-version`: `FileVersionInfo.FileVersion` (das von `Functions.EmberAPIVersion()` gelesene, in `dlgVersions`/`dlgErrorViewer` angezeigte Attribut) und symmetrisch die `AssemblyVersion` müssen der erwarteten Assembly-Version (`X.Y.Z.0`/`X.Y.Z.N`) entsprechen | Build schlägt im „Verify publish output"-Schritt fehl — ein still nicht greifender Regex-Ersatz in `EmberAPI/My Project/AssemblyInfo.vb` wird entdeckt statt eine ungestempelte DLL auszuliefern |

## Konfigurationsänderungen

Keine. Die benötigten Inputs `release-version`/`release-tag` existieren bereits in `build-and-package` und werden von beiden aufrufenden Workflows befüllt; `release.yml` und `staging-ci.yml` müssen nicht geändert werden. Es wird kein zusätzliches semantic-release-Plugin eingeführt — das Stamping erfolgt ausschließlich in der CI-Arbeitskopie ohne Rück-Commit (entschieden).

## Seiteneffekte und Risiken

- **Versionsliste (`dlgVersions`/`dlgErrorViewer`):** „Ember API"-Eintrag (`Functions.EmberAPIVersion()`) zeigt künftig die Release-Version statt `1.11.1.0` — gewollte Konsistenz, verändert aber den bislang statischen Wert in Fehlerberichten.
- **`bwCheckVersion_DoWork` / `mnuVersion`:** Der Update-Vergleich parst weiterhin die `AssemblyInfo.vb` des Upstream-Repos `DanCooper/Ember-MM-Newscraper`. Mit gestempelter lokaler Version ändert sich das Vergleichsergebnis (eigene Version > Upstream-`1.11.1.0` → dauerhaft „aktuell"/`DarkGreen` statt „Update verfügbar"). Fachlich konsistent mit dem Fork-Release-Modell; die Quellumstellung ist bewusst aus diesem Issue ausgenommen und separat zu behandeln.
- **`Master.Version` bei Pre-Releases:** Zeigt weiterhin nur `Major.Minor.Build` — die RC-Nummer ist in About/Splash/`mnuVersion` nicht direkt sichtbar, bleibt aber über `FileVersion`-Revision (`X.Y.Z.N`) und `AssemblyInformationalVersion` (`X.Y.Z-rc.N` in `FileVersionInfo.ProductVersion`) nachvollziehbar. Entschiedene Einschränkung, kein offener Punkt.
- **Lokale/Nicht-Release-Builds:** Zeigen durch den gesenkten Platzhalter „Version 0.0.0 x64" — gewolltes Erkennungsmerkmal für ungestempelte Artefakte; wirkt sich auch auf `dlgVersions`-Eintrag „Ember Application"/„Ember API" und den Update-Vergleich aus (lokale Builds melden stets „Update verfügbar").
- **`EmberAPI_Test/Test_clsAPICommon.vb::Functions_EmberAPIVersion`:** Der (nicht kompilierbare) Test verlangt ein vierteiliges Versionsformat — die gestempelte `X.Y.Z.N`-Version erfüllt das weiterhin; `AssemblyInformationalVersion` wird von `FileVersionInfo.FileVersion` nicht gelesen. Keine Anpassung nötig.
- **NSIS-Installer (`BuildSetup/`):** `EMM_REVISION` bleibt hartkodiert (`1.12.0`) und ist nicht Teil der CI — Installer-Dateinamen bleiben unverändert, keine Auswirkung.
- **ClickOnce-Felder:** `ApplicationVersion 1.0.0.%2a`/`ApplicationRevision` in `EmberMediaManager.vbproj` bleiben unverändert — ClickOnce-Veröffentlichung findet in der Pipeline nicht statt, kein Einfluss auf die angezeigte Version.
- **Regex-Abhängigkeit:** Der Stempel-Schritt setzt das Zeilenformat `<Assembly: AssemblyVersion("x.y.z.r")>` voraus. Wird das Attributformat in `AssemblyInfo.vb` später geändert oder greift der Regex auf einer einzelnen Attributzeile nicht, wirkt PowerShell-`-replace` still — abgefangen durch die Verify-Prüfung, die bei der Exe `FileVersion`, `AssemblyVersion` **und** `ProductVersion` sowie bei `EmberAPI.dll` `FileVersion`/`AssemblyVersion` vergleicht (Build schlägt fehl statt falsch zu liefern). Die Ersetzungsmuster müssen attribut-scharf sein (`AssemblyVersion\(`, nicht `Assembly.*Version`), damit ein `AssemblyVersion`-Muster nicht versehentlich zuerst auf `AssemblyFileVersion`-/`AssemblyInformationalVersion`-Zeilen greift.
- **Repair-Pfad `release_action == 'upload-existing'`:** „Check out release tag for asset repair" (`release.yml` Z. 57–80) lädt `build-and-package` aus dem getaggten Commit. Reparierte Assets für Tags **vor** dieser Änderung behalten deren `AssemblyInfo.vb`-Stand (`1.11.1.0`) — die angezeigte Version entspricht dann nicht dem Release-Tag, ist aber konsistent mit dem bereits publizierten Release (bewusster Ausschluss, siehe Designentscheidung). Für Tags nach dieser Änderung ist der Pfad abgedeckt.
- **Leeres `ProductVersion` bei Nicht-Release-Builds:** Die eingecheckte Platzhalterzeile `AssemblyInformationalVersion("")` führt dazu, dass `FileVersionInfo.ProductVersion` bei lokalen/Nicht-Release-Builds leer ist statt auf `FileVersion` zurückzufallen. Unschädlich — `ProductVersion` wird in der Anwendung nirgends angezeigt; bei der Umsetzung kurz verifizieren.

## Umsetzungsreihenfolge

1. **Platzhalter in `AssemblyInfo.vb`-Dateien anpassen**
   - Voraussetzungen: Keine.
   - Beschreibung: In `EmberMediaManager/My Project/AssemblyInfo.vb` und `EmberAPI/My Project/AssemblyInfo.vb` jeweils `AssemblyVersion`/`AssemblyFileVersion` (Z. 34–35) von `1.11.1.0` auf `0.0.0.0` senken und nach `AssemblyFileVersion` die Zeile `<Assembly: AssemblyInformationalVersion("")>` einfügen.

2. **Schritt „Stamp assembly version" in `build-and-package/action.yml` einfügen**
   - Voraussetzungen: Schritt 1 (Platzhalterzeile für uniforme Regex-Ersetzung); `pwsh` auf `windows-latest` (bereits von allen Schritten genutzt); Inputs `release-version`/`release-tag` (bereits vorhanden, Z. 13–21).
   - Beschreibung: Neuer Schritt zwischen „Restore dependencies" und „Build (Release x64)": Input lesen, bei leerem Wert überspringen, führendes `v` defensiv entfernen, gegen SemVer-Muster validieren, `X.Y.Z.0`/`X.Y.Z.N` und Informational-Version berechnen, die drei Attributzeilen in beiden `AssemblyInfo.vb`-Dateien per Regex ersetzen, gestempelte Werte ins Log schreiben. Kein Rück-Commit ins Repository.

3. **Schritt „Verify publish output" um Versions-Prüfung erweitern**
   - Voraussetzungen: Schritt 2 (gestempelte Exe und `EmberAPI.dll` liegen in `publish/` vor).
   - Beschreibung: Bei gesetztem `release-version`-Input für `publish/Ember Media Manager.exe` drei Attribute vergleichen — `FileVersionInfo.FileVersion` und `[Reflection.AssemblyName]::GetAssemblyName('publish\Ember Media Manager.exe').Version` gegen die erwartete Assembly-Version `X.Y.Z.0`/`X.Y.Z.N` sowie `FileVersionInfo.ProductVersion` gegen den vollen SemVer-String — und für `publish/EmberAPI.dll` `FileVersionInfo.FileVersion` sowie `AssemblyVersion` gegen `X.Y.Z.0`/`X.Y.Z.N`; jede Abweichung → `throw`. Die `AssemblyVersion`-Prüfung der Exe ist Pflicht, weil die angezeigte Version (`My.Application.Info.Version` → `Master.Version`) aus `AssemblyVersion` stammt.

4. **Verifikation im CI-Lauf**
   - Voraussetzungen: Schritte 1–3 gemergt; ein Release-/Pre-Release-Lauf auf `staging` bzw. `master`.
   - Beschreibung: Build-Log des „Stamp assembly version"-Schritts prüfen (gestempelte Werte sichtbar), Verify-Schritt bestanden, in der ausgelieferten Exe `FileVersionInfo`/`ProductVersion` gegen den GitHub-Release-Tag abgleichen.

## Tests

### Neue Tests

Keine ausführbare Testinfrastruktur vorhanden (einzige Suite `EmberAPI_Test` kompiliert nicht, kein `test`-Skript in `package.json`, keine Node-Tests für CI-Skripte). Der Funktionsnachweis erfolgt über die in Schritt 3 eingebaute Verify-Prüfung im CI-Lauf selbst.

| Test / Hilfsmethode | Testklasse | Was wird geprüft / bereitgestellt? |
|--------------------|------------|-------------------------------------|
| Versions-Prüfung (kein Test im klassischen Sinn) | „Verify publish output"-Schritt in `build-and-package/action.yml` | Gestempelte `FileVersion` **und** `AssemblyVersion` (`[Reflection.AssemblyName]::GetAssemblyName('publish\Ember Media Manager.exe').Version` — das Attribut hinter `My.Application.Info.Version`/`Master.Version` und damit der angezeigten Version) sowie `ProductVersion` der ausgelieferten Exe und `FileVersion`/`AssemblyVersion` von `publish/EmberAPI.dll` entsprechen den erwarteten Werten — schlägt den CI-Build bei Fehlschlag des Stampings in einer der beiden `AssemblyInfo.vb`-Dateien oder auf einer einzelnen Attributzeile |

### Betroffene bestehende Tests

Keine — es existieren keine ausführbaren Tests. `EmberAPI_Test/Test_clsAPICommon.vb::Functions_EmberAPIVersion` (Z. 132–141) ist nicht kompilierbar; das von ihm geforderte vierteilige Format bleibt durch die `X.Y.Z.N`-Abbildung ohnehin erhalten.

### E2E-Tests (primärer Funktionsnachweis)

Es werden keine E2E-Tests geplant. Begründung: Die Anforderung betrifft den Build-/Release-Prozess (CI-Pipeline), nicht einen über die Anwendungs-UI auslösbaren Ablauf — der „Benutzerfluss" ist der Release-Lauf selbst. Es existiert im Repository keine E2E-/UI-Testinfrastruktur, die eine gebaute Exe starten und den About-Dialog prüfen könnte; das Anlegen einer solchen Infrastruktur wäre ein unverhältnismäßiges Extra jenseits der Anforderung. Der Funktionsnachweis wird stattdessen in der Pipeline selbst erbracht: die erweiterte „Verify publish output"-Prüfung verifiziert `FileVersion`, `AssemblyVersion` (das Attribut, aus dem `My.Application.Info.Version`/`Master.Version` die angezeigte Version liest) und `ProductVersion` der ausgelieferten Exe sowie `FileVersion`/`AssemblyVersion` der `EmberAPI.dll` gegen die erwarteten Werte und lässt den Build bei Abweichung fehlschlagen — damit ist der Stempel-Erfolg automatisiert und bei jedem Release-Lauf nachgewiesen.

## Offene Punkte

Keine — alle Punkte wurden geklärt und sind als Designentscheidungen im Plan eingearbeitet.

Dokumentierte bewusste Ausschlüsse (kein Klärungsbedarf):

- **Update-Check-Quelle:** `HTTP.GetLatestVersionInfo` (`clsAPIHTTP.vb` Z. 349–359) parst weiterhin das Upstream-Repo `DanCooper/Ember-MM-Newscraper`; die Umstellung auf den Fork bzw. `update.json` ist bewusst nicht Teil dieses Issues und wird separat behandelt.
- **ClickOnce-Felder:** `ApplicationVersion 1.0.0.%2a`/`ApplicationRevision` in `EmberMediaManager.vbproj` (Z. 33–34) bleiben unverändert — ClickOnce ist ungenutzt.
- **Addon-Assemblys:** Die ~30 Addon-`AssemblyInfo.vb`-Dateien werden nicht gestempelt — sie bleiben eigenständig über `ModuleVersion` versioniert.
- **Anzeigeformat:** `Master.Version` bleibt bewusst dreiteilig; die RC-Nummer ist über `FileVersion`-Revision und `AssemblyInformationalVersion` nachvollziehbar.
- **Repair-Pfad `release_action == 'upload-existing'`:** Reparaturen von Releases, deren Tag **vor** dieser Änderung erstellt wurde, liefern weiterhin die im getaggten Stand eingecheckte Assembly-Version (`1.11.1.0`) — konsistent mit dem bereits publizierten Release, keine nachträgliche Versionskorrektur alter Releases. Reparaturen von Tags nach dieser Änderung sind automatisch abgedeckt.
