# Build-Toolchain, Solution und Versionierung

## Solution `Ember Media Manager.sln`

- Format: Visual Studio Solution File, Format Version 12.00 (`# Visual Studio 15`, `VisualStudioVersion = 15.0.28307.168`, VS2017)
- **33 `Project(...)`-Einträge**, davon:

| Projekttyp-GUID | Anzahl | Bedeutung |
|-----------------|--------|-----------|
| `{F184B08F-C81C-45F6-A57F-5ABD9991F28F}` | 30 | VB.NET-Projekte (`.vbproj`, Legacy-Format, nicht SDK-Style) |
| `{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}` | 2 | C#-Projekte: `KodiAPI` (`KodiAPI\KodiAPI.csproj`), `TVDB` (`TheTVDBApi\src\TVDB\TVDB.csproj`, vendored) |
| `{2150E333-8FDC-42A3-9474-1A3956D46DE8}` | 1 | Solution Folder `Addons` |

- Zielframework aller Projekte: **.NET Framework 4.8** (`<TargetFrameworkVersion>v4.8</TargetFrameworkVersion>`)
- Projektgruppen: `EmberMediaManager` (WinForms-Hauptanwendung), `EmberAPI` (Kernbibliothek), `Addons/` (Module: `generic.*`, `scraper.*`), `KodiAPI`, `TheTVDBApi/src/TVDB`

### Projektdateien außerhalb der Solution

Diese `.vbproj`/`.csproj`-Dateien existieren im Repository, sind aber **nicht** in der `.sln` eingetragen:

| Datei | Bemerkung |
|-------|-----------|
| `EmberAPI_Test/EmberAPI_Test.vbproj` | MSTest-Testprojekt, siehe [tests.md](tests.md) |
| `Trakttv/Trakttv.csproj` | C#-Trakt-API-Client (vendored Legacy-Quelle); die Addon-Projekte nutzen stattdessen das NuGet-Paket `Trakt.NET` 1.1.1 |
| `Addons/scraper.EmberCore.XML/scraper.EmberCore.XML.vbproj` | alter XML-Scraper, nicht in Solution |
| `Addons/scraper.TVDB.Poster/scraper.TVDB.Data.vbproj` | nicht in Solution (Solution nutzt `scraper.Image.TVDB` aus `Addons\scraper.Image.TVDB\`) |

## NuGet-Toolchain (packages.config-Modell)

| Artefakt | Inhalt |
|----------|--------|
| `.nuget/NuGet.exe` | NuGet CLI **6.14.0.116** (im Repo eingecheckt, ~8,9 MB) |
| `.nuget/NuGet.Config` | nur `disableSourceControlIntegration=true` |
| `.nuget/NuGet.targets` | klassisches Package-Restore-Target (`RestorePackages`, per `nuget install packages.config -o packages\`); Default `RestorePackages=false`, wird von einzelnen Projekten (u. a. `EmberAPI_Test`) auf `true` gesetzt |
| `packages.config` | **35 Dateien** (in allen Solution-Projekten plus den oben genannten nicht eingebundenen Projekten) |

Dokumentierter Restore- und Build-Ablauf (`README.md`, `docs/help/build/`):

```bat
.nuget\NuGet.exe restore "Ember Media Manager.sln"
msbuild "Ember Media Manager.sln" -p:Configuration=Release -p:Platform=x64
```

- Ausgabe: `EmberMM - <Configuration> - <Platform>\` (unterstützte Plattformen `x86` und `x64` mit nativen Abhängigkeiten; `Any CPU` kompiliert ebenfalls)
- Verifiziert in dieser Bestandsaufnahme: `nuget restore` → Exit 0, 58 Pakete installiert; dabei NU1903-Warnung: **`Newtonsoft.Json` 12.0.3 hat eine bekannte High-Severity-Vulnerability** (GHSA-5crp-9r3c-p9vr). Relevant: NuGet 6.14 prüft `packages.config`-Projekte bereits beim Restore auf Schwachstellen — eine Alternative zum referenzseitigen `dotnet list package --vulnerable` (das `packages.config` nicht unterstützt).
- Nachweis: [test-results/nuget-restore.log](test-results/nuget-restore.log)

## `Directory.Build.props`

Datei: `Directory.Build.props` (13 Zeilen). Setzt `FrameworkPathOverride` auf `packages\Microsoft.NETFramework.ReferenceAssemblies.net48.1.0.3\build\.NETFramework\v4.8\` (nur wenn das Verzeichnis existiert). Folge: Build benötigt kein installiertes .NET-4.8-Developer-Pack, aber MSBuild/Visual Studio Build Tools auf Windows.

## BuildSetup / Installer / Versionierung

Verzeichnis `BuildSetup/`:

| Datei | Zweck |
|-------|-------|
| `0_BuildSetup_x64.bat`, `0_BuildSetup_x86.bat` | Installer-Build: ruft `txDownload.bat` (Transifex-Sprachdateien), dann NSIS `makensis.exe` mit `1.4_InstallerScript.nsi`; enthält **hartcodierte** `EMM_REVISION=1.12.0`, `EMM_BRANCH=Master` |
| `1.4_InstallerScript.nsi` | NSIS-Installer-Skript |
| `tx.exe`, `txDownload.bat`, `LangAllConfig.cfg` | Transifex-CLI + Download-Skript für `Langs`-Dateien |
| `BRC32.exe`, `pcre.dll` | Hilfswerkzeuge (Bulk-Rename im Installer-Kontext) |

Versionsstände im Repository (keine automatische Versionsvergabe):

| Quelle | Version |
|--------|---------|
| `EmberMediaManager/My Project/AssemblyInfo.vb` | `AssemblyVersion`/`AssemblyFileVersion` = `1.11.1.0` |
| `BuildSetup/0_BuildSetup_*.bat` | `EMM_REVISION=1.12.0` |
| `changes.log` | datumsbasierte Einträge (zuletzt 2026-09-19) |
| `docs/RELEASE_NOTES.md` | redaktionelle Release Notes (EN/DE) |
| Git-Tags | keine |

## Dokumentation

- `README.md` — Feature-Übersicht, Build-Anleitung, Projektstruktur, ausdrücklicher Hinweis: „There are no executable automated tests at the moment."
- `docs/help/` — Feature-Dokumentation (u. a. `docs/help/build/` mit Build-Beschreibung, Installation, Troubleshooting)
- `docs/RELEASE_NOTES.md`, `changes.log`, `Changelog.txt` (Upstream-Historie)

## Lokale Werkzeugumgebung (zum Analysezeitpunkt)

| Werkzeug | Version / Pfad |
|----------|----------------|
| Visual Studio | Community 2026, `18.10.1` (`C:\Program Files\Microsoft Visual Studio\18\Community`) |
| MSBuild | `18.10.1.42706` (`MSBuild\Current\Bin\MSBuild.exe`) |
| `vstest.console.exe` | vorhanden (`Common7\IDE\CommonExtensions\Microsoft\TestWindow\vstest.console.exe`) |
| dotnet SDK | `10.0.401` (auf PATH; für Legacy-`.vbproj`/`packages.config` nicht als Build-Toolchain nutzbar) |
| Python | `3.13.14` (relevant für die Übertragbarkeit des Referenz-`pre-commit`-Hooks `translation-check.py`) |
| Git | `2.53.0.windows.2` |
