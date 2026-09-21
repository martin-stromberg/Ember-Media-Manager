# Versionsanzeige und Update-Check (Logik)

Alle betroffenen Klassen mit den Methoden/Properties, die die angezeigte Versionsnummer erzeugen, verteilen oder vergleichen.

## `Master` (`EmberAPI/clsAPIMaster.vb`)

Zentrale statische Klasse (`EmberAPI`).

| Methode / Property | Sichtbarkeit | Zeilen | Kurzbeschreibung |
|--------------------|--------------|--------|-------------------|
| `Version` (ReadOnly Property) | `Public Shared` | 55–63 | Formatiert `"Version {Major}.{Minor}.{Build} {x86|x64}"` aus `My.Application.Info.Version` — **nur drei Komponenten**, Revision und Pre-Release-Suffix werden nicht angezeigt |
| `is32Bit` (ReadOnly Property) | `Public Shared` | 49–53 | `IntPtr.Size = 4` → wählt `x86`/`x64`-Suffix für `Master.Version` |

`My.Application.Info.Version` der Exe kommt aus `AssemblyVersion`/`AssemblyFileVersion` in `EmberMediaManager/My Project/AssemblyInfo.vb` (`1.11.1.0`).

Aufrufer von `Master.Version`:
- `ApplicationEvents.MyApplication_Startup` (`EmberMediaManager/ApplicationEvents.vb` Z. 43, 65) — Start-Logeintrag und Splashscreen (`fLoading.SetVersionMesg(Master.Version)`)
- `dlgAbout.frmAbout_Load` (`EmberMediaManager/dlgAbout.vb` Z. 78–81) — Credit-Zeile im About-Dialog
- `frmMain.bwCheckVersion_DoWork` (`EmberMediaManager/frmMain.vb` Z. 18915, 18918, 18923) — Menüeintrag `mnuVersion`

## `Functions` (`EmberAPI/clsAPICommon.vb`)

| Methode | Sichtbarkeit | Zeilen | Kurzbeschreibung |
|---------|--------------|--------|-------------------|
| `EmberAPIVersion()` | `Public Shared` | 1109–1111 | `FileVersionInfo.GetVersionInfo(Assembly.GetExecutingAssembly.Location).FileVersion` — liest `AssemblyFileVersion` der `EmberAPI.dll` |
| `CheckNeedUpdate()` | `Public Shared` | 937–965 | **Stub** — kommentierter Update-XML-Code (`pcjco.dommel.be`), liefert immer `False`; aufgerufen von `frmMain.CheckUpdatesToolStripMenuItem_Click` (Z. 18863), wodurch `dlgNewVersion` faktisch nie erscheint |
| `GetChangelog()` | `Public Shared` | 1118+ | **Stub** — liefert „Unavailable" |

## `HTTP` (`EmberAPI/clsAPIHTTP.vb`)

| Methode | Sichtbarkeit | Zeilen | Kurzbeschreibung |
|---------|--------------|--------|-------------------|
| `GetLatestVersionInfo()` | `Public Shared` | 349–359 | Lädt per `WebClient` die `AssemblyInfo.vb` des **Upstream**-Repos `DanCooper/Ember-MM-Newscraper` (`https://raw.github.com/DanCooper/Ember-MM-Newscraper/master/EmberMediaManager/My%20Project/AssemblyInfo.vb`) und gibt den Dateiinhalt zurück; bei Fehler `String.Empty` |

## `frmMain` (`EmberMediaManager/frmMain.vb`)

| Methode | Sichtbarkeit | Zeilen | Kurzbeschreibung |
|---------|--------------|--------|-------------------|
| `Dialog_Load` | `Private` | ~341–351 | startet `bwCheckVersion.RunWorkerAsync()` beim Laden des Hauptfensters |
| `bwCheckVersion_DoWork` | `Private` | 18890–18929 | ruft `HTTP.GetLatestVersionInfo()`, parst `AssemblyFileVersion("X.Y.Z[.R]")` per Regex aus dem Upstream-File, vergleicht Major/Minor/Build mit `My.Application.Info.Version` und setzt `mnuVersion`-Text/Farbe (`DarkRed` = Update verfügbar, `DarkGreen` = aktuell, `DarkBlue` = kein Netz) |
| `UpdatemnuVersion` + `UpdatemnuVersionDel` | `Private`/`Public Delegate` | 18931–18936 | UI-Thread-Marshal für `mnuVersion.Text`/`.ForeColor` |
| `mnuVersion_Click` | `Private` | 18853–18855 | öffnet `My.Resources.urlReleaseThread` im Browser |
| `VersionsToolStripMenuItem_Click` | `Private` | 18834–18836 | `mnuMainHelpVersions` → `ModulesManager.Instance.GetVersions()` |
| `CheckUpdatesToolStripMenuItem_Click` | `Private` | 18862–18872 | `mnuMainHelpUpdate` → `Functions.CheckNeedUpdate()` (Stub, immer `False`) |

`bwCheckVersion` ist als `Friend WithEvents`-`BackgroundWorker` deklariert (Z. 33).

## `ModulesManager` (`EmberAPI/clsAPIModules.vb`)

| Methode / Member | Sichtbarkeit | Zeilen | Kurzbeschreibung |
|------------------|--------------|--------|-------------------|
| `VersionList` | `Public Shared` (Field) | 33 | `List(Of VersionItem)` aller Assembly-Versionen |
| `BuildVersionList()` | `Private` | 85–146 | befüllt `VersionList`: „Ember Application" = `My.Application.Info.Version.ToString()` (Z. 87), „Ember API" = `Functions.EmberAPIVersion()` (Z. 88), danach `ProcessorModule.ModuleVersion` aller geladenen Addon-Module |
| `GetVersions()` | `Public` | 200–211 | zeigt `dlgVersions` mit allen `VersionList`-Einträgen |
| `VersionItem` (Structure) | `Public` | 1948–1958 | Felder `AssemblyFileName`, `Name`, `NeedUpdate`, `Version` (String) |

`VersionList` wird außerdem von `dlgErrorViewer.BuildErrorLog` (`EmberMediaManager/dlgErrorViewer.vb` Z. 90–96) in den Abschnitt `<Assembly Versions>` des Fehlerberichts geschrieben.

## Weitere beteiligte Klassen

| Klasse | Datei | Rolle |
|--------|-------|-------|
| `dlgAbout` | `EmberMediaManager/dlgAbout.vb` | zeigt `Master.Version` als Credit-Zeile (Z. 78–81); nutzt außerdem `My.Application.Info.Description`/`.Copyright` (Z. 83, 85) |
| `frmSplash` | `EmberAPI/frmSplash.vb` | `SetVersionMesg(strVersion)` (Z. 48–54) schreibt `Master.Version` in das Label `VersionNumber` (Designer-Default `"Version {0}.{1}.{2}.{3}"`, `frmSplash.Designer.vb` Z. 48) |
| `dlgVersions` | `EmberAPI/dlgVersions.vb` | ListView aller `VersionItem`-Einträge; `btnCopy_Click` formatiert `"{Name} (Revision: {Version})"` (Z. 28–35) |
| `dlgNewVersion` | `EmberMediaManager/dlgNewVersion.vb` | toter Update-Dialog (`CheckNeedUpdate` ist Stub); lädt `EmberSetup.exe` von `pcjco.dommel.be` (Z. 70–76) |
| `MyApplication` (`ApplicationEvents`) | `EmberMediaManager/ApplicationEvents.vb` | loggt `Master.Version` beim Start (Z. 43), setzt Splash-Text (Z. 65) |

## Zusammenhang der Versionspfade

```
AssemblyInfo.vb (EmberMediaManager)            AssemblyInfo.vb (EmberAPI)      Addons/*/AssemblyInfo.vb
        | AssemblyVersion/FileVersion                  | FileVersion                | FileVersion
        v                                              v                          v
My.Application.Info.Version ──► Master.Version   EmberAPIVersion()          ModuleVersion (Interface)
        |   (3 Komponenten + x86/x64)                    |                          |
        ├─► dlgAbout, frmSplash, mnuVersion, Log         └──────────┬───────────────┘
        │                                                          v
        └─► bwCheckVersion_DoWork: Vergleich mit             VersionList (dlgVersions,
            Upstream-AssemblyFileVersion (raw.github.com)    dlgErrorViewer)
```
