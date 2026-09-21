# Plan-Gegenprüfung

## Ergebnis

**Status:** Plan lückenhaft

## Abgleich Akzeptanzkriterien

| Akzeptanzkriterium | Umsetzung im Plan | Testnachweis im Plan | Status |
|--------------------|-------------------|----------------------|--------|
| Aufgelöste Release-Version `X.Y.Z` wird beim CI-Build in `AssemblyVersion`/`AssemblyFileVersion` der Exe geschrieben (release.yml-Pfad) | Schritt „Stamp assembly version" in `build-and-package/action.yml` zwischen „Restore dependencies" und „Build (Release x64)"; Regex-Ersetzung in `EmberMediaManager/My Project/AssemblyInfo.vb`; Mapping `X.Y.Z` → `X.Y.Z.0` | Erweiterter „Verify publish output"-Schritt prüft `FileVersionInfo.FileVersion` von `publish/Ember Media Manager.exe` gegen die erwartete Version; zusätzlich Log-Ausgabe und CI-Verifikation (Umsetzungsschritt 4) | Abgedeckt |
| Pre-Release-Version `X.Y.Z-rc.N` wird beim CI-Build gestempelt (staging-ci-Pfad) | Derselbe Stempel-Schritt; Mapping `X.Y.Z-rc.N` → `X.Y.Z.N` plus `AssemblyInformationalVersion` = `X.Y.Z-rc.N`; `staging-ci.yml` bleibt unverändert (Inputs bereits vorhanden, Z. 208–212) | Verify-Schritt prüft bei gesetztem `release-version` auch den RC-Fall (`X.Y.Z.N`) | Abgedeckt |
| Im Programm angezeigte Version (About-Dialog, `mnuVersion`, Splash, Start-Log) entspricht der GitHub-Release-Version | `Master.Version` (`EmberAPI/clsAPIMaster.vb` Z. 55–63) bleibt unverändert und liest `My.Application.Info.Version` der gestempelten Exe; keine Änderung am Anzeigecode | Verify-Schritt sichert die gestempelte `FileVersion`; Anzeige selbst ohne automatisierten Nachweis (kein E2E, siehe E2E-Abdeckung) | Abgedeckt — mit entschiedener Einschränkung: Bei Pre-Releases zeigt `Master.Version` nur `X.Y.Z`, die RC-Nummer ist nur über `FileVersion`-Revision und `ProductVersion` sichtbar |
| `AssemblyInformationalVersion` trägt den vollen SemVer-String | Neue Platzhalterzeile `<Assembly: AssemblyInformationalVersion("")>` in beiden `AssemblyInfo.vb`-Dateien, wird per Regex mitgestempelt | Indirekt über Verify (FileVersion) bzw. CI-Log; `ProductVersion` wird nicht explizit geprüft | Abgedeckt |
| `EmberAPI` wird mit derselben Version gestempelt (Konsistenz in `dlgVersions`/`dlgErrorViewer` via `Functions.EmberAPIVersion()`) | Stempel-Schritt ersetzt die drei Attributzeilen auch in `EmberAPI/My Project/AssemblyInfo.vb` | **Kein Nachweis:** Verify prüft nur `publish/Ember Media Manager.exe`, nicht `EmberAPI.dll` — ein still fehlschlagender Regex-Ersatz bliebe unentdeckt | Lücke |
| Builds ohne Release-Kontext bleiben unverändert / erkennbar | Bei leerem `release-version`-Input wird der Schritt übersprungen; eingecheckter Platzhalter `0.0.0.0` markiert Nicht-Release-Artefakte | Verhaltensfestlegung dokumentiert; automatisierter Nachweis nicht möglich/nicht vorgesehen | Abgedeckt |
| Ungültiges `release-version`-Format bricht den Build vor dem Compile ab | SemVer-Validierung im Stempel-Schritt (Validierungsregeln-Tabelle) | Die Validierung ist Teil der Umsetzung; ein Fehlschlag ist im CI-Lauf beobachtbar | Abgedeckt |
| Repair-Pfad `release_action == 'upload-existing'` (fehlende Assets nachträglich neu bauen/hochladen, release.yml Z. 57–80, 109–114, 145–152) | **Nicht adressiert:** Der Workflow checkt den getaggten Commit aus; `build-and-package` wird dabei aus dem getaggten Stand geladen. Für Tags vor dieser Änderung existiert dort kein Stempel-Schritt und `AssemblyInfo.vb` trägt `1.11.1.0` — das reparierte Asset würde eine Exe ausliefern, deren angezeigte Version nicht zum Release-Tag passt | — | Lücke |
| Explizite Nicht-Anforderungen: kein Rück-Commit ins Repo, keine Änderung an `release.yml`/`staging-ci.yml`/`resolve-release-version.mjs`, keine neuen Tools | Als Designentscheidungen dokumentiert und in der Umsetzungsreihenfolge eingehalten | — | Abgedeckt |
| Bewusste Ausschlüsse: Update-Check-Quelle (Upstream-Repo), ClickOnce-Felder, Addon-Assemblys, Anzeigeformat `Master.Version` | Alle vier Ausschlüsse in „Designentscheidungen"/„Offene Punkte" mit Begründung dokumentiert; Seiteneffekte (u. a. `mnuVersion`-Farbe, `dlgVersions`, lokale Builds) benannt | — | Abgedeckt |

## Fehlende oder unvollständige Testanforderungen

- [ ] Verify-Nachweis für `EmberAPI.dll` fehlt: „Verify publish output" soll zusätzlich `FileVersionInfo.FileVersion` von `publish/EmberAPI.dll` gegen die erwartete Assembly-Version prüfen. Der Plan stempelt `EmberAPI` bewusst mit (Designentscheidung „Scope des Stampings"), verifiziert aber nur die Exe. PowerShell-`-replace` wirkt bei Nicht-Treffer still — ein Pfad-/Regex-Fehler in `EmberAPI/My Project/AssemblyInfo.vb` würde eine ungestempelte `EmberAPI.dll` ausliefern („Ember API" zeigt `0.0.0.0`/`1.11.1.0` neben der gestempelten App-Version) und der Build bestünde trotzdem.

## E2E-Abdeckung

| Benutzerfluss / Akzeptanzkriterium | Geplanter E2E-Test | Status |
|------------------------------------|--------------------|--------|
| Release-/Pre-Release-Lauf erzeugt Exe, deren angezeigte Version (About, `mnuVersion`, Splash) dem GitHub-Release-Tag entspricht | Kein E2E-Test geplant; Funktionsnachweis über die erweiterte „Verify publish output"-Prüfung in der Pipeline | Nicht erforderlich mit Begründung: Die Anforderung betrifft den Build-/Release-Prozess, keinen über die Anwendungs-UI auslösbaren Ablauf; es existiert keine E2E-/UI-Testinfrastruktur im Repository (Bestandsaufnahme `tests.md`: einziges Testprojekt `EmberAPI_Test` kompiliert nicht). Die Begründung im Plan ist nachvollziehbar. |
| Geändertes Verhalten von `mnuVersion`/`bwCheckVersion_DoWork` (Farbumschlag durch gestempelte lokale Version) | Kein E2E-Test | Nicht erforderlich mit Begründung: Teilweise toter Codepfad (`Functions.CheckNeedUpdate()` ist Stub), bewusster Ausschluss der Update-Check-Quelle; als Seiteneffekt im Plan benannt |

## Fehlende oder unvollständige Planbestandteile

- [ ] Repair-Pfad `release_action == 'upload-existing'` nicht behandelt: In `release.yml` checkt der Schritt „Check out release tag for asset repair" (Z. 57–80) den getaggten Commit aus; der anschließende „Build and package"-Schritt (Z. 109–114) lädt `./.github/actions/build-and-package` dann aus dem getaggten Stand. Für Tags, die vor dieser Änderung erstellt wurden, enthält die dortige `action.yml` keinen Stempel-Schritt und die dortige `AssemblyInfo.vb` trägt `1.11.1.0` — ein repariertes Asset würde die Versionsanforderung verletzen. Für Tags nach der Änderung funktioniert das Stamping (`release-version` wird auch im Repair-Pfad übergeben). Der Plan muss diesen vierten Aufrufpfad von `build-and-package` entweder abdecken oder als bewusstes Risiko/Ausschluss benennen (z. B. „Reparatur alter Releases liefert weiterhin die damalige Version — konsistent mit dem bereits publizierten Release").

## Hinweise

- Der Stempel-Schritt validiert `release-version` streng gegen `X.Y.Z`/`X.Y.Z-rc.N`. Die Geschwisterschritte „Write version manifest"/„Create update manifest" entfernen ein führendes `v` defensiv (`-replace '^v',''`, action.yml Z. 64, 103). Für Robustheit/Konsistenz könnte der Stempel-Schritt ebenfalls ein führendes `v` tolerieren statt nur abzulehnen — aktuell liefern beide aufrufenden Workflows allerdings immer ein `v`-freies Format.
- Die neue Platzhalterzeile `<Assembly: AssemblyInformationalVersion("")>` führt bei lokalen/Nicht-Release-Builds zu einem leeren `FileVersionInfo.ProductVersion` (statt Fallback auf `FileVersion`). Unschädlich, aber bei der Umsetzung kurz verifizieren.
- `Master.Version` zeigt bei Pre-Releases weiterhin nur `Major.Minor.Build` — korrekt als entschiedene Einschränkung dokumentiert; falls fachlich doch RC-Sichtbarkeit in About/Splash gewünscht wird, wäre eine Erweiterung des Anzeigecodes (außerhalb dieses Plans) nötig.
- Die Umbenennung des eingecheckten Platzhalters auf `0.0.0.0` verändert auch den `VersionList`-Eintrag und den Update-Vergleich für alle Nicht-Release-Builds (lokale Builds, `build-and-test`-Gate in `staging-ci.yml`) — als Seiteneffekt benannt und konsistent.
