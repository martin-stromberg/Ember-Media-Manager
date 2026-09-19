← [Zurück zur Übersicht](index.md)

# Installation & Konfiguration

## Voraussetzungen

- Windows
- Visual Studio mit MSBuild (bzw. „Build Tools für Visual Studio")
- .NET Framework 4.8.1 **Runtime** — ein Developer Pack ist **nicht** erforderlich

## Restore

Die Solution verwendet klassisches `packages.config`-NuGet. Der Restore erfolgt über die im Repository enthaltene NuGet-CLI (`.nuget/NuGet.exe`, Version 6.14.0):

```bat
.nuget\NuGet.exe restore "Ember Media Manager.sln"
```

Dadurch werden alle Pakete in `packages/` abgelegt — einschließlich `Microsoft.NETFramework.ReferenceAssemblies.net481`, das die .NET Framework 4.8.1 Referenzassemblys enthält.

## Referenzassemblys

`Directory.Build.props` im Repository-Stamm setzt `FrameworkPathOverride` auf das Paketverzeichnis `packages\Microsoft.NETFramework.ReferenceAssemblies.net481.1.0.3\build\.NETFramework\v4.8.1\` (nur wenn das Verzeichnis existiert). Dadurch kompiliert MSBuild gegen die Paket-Referenzassemblys statt gegen ein installiertes Developer Pack.

## Build

```bat
msbuild "Ember Media Manager.sln" -p:Configuration=Release -p:Platform=x64
```

| Platform | Ergebnis |
|----------|----------|
| `x64` | `EmberMM - Release - x64\` (inkl. nativer x64-Abhängigkeiten) |
| `x86` | `EmberMM - Release - x86\` (inkl. nativer x86-Abhängigkeiten) |
| `Any CPU` | `EmberMM - Release - AnyCPU\` (ohne native Abhängigkeiten) |

## Externe Abhängigkeit TVDB

Die C#-Bibliothek `TVDB` (`DanCooper/TheTVDBApi`, GPL-3.0) ist als Vendored-Quelle unter `TheTVDBApi/src/TVDB/` im Repository enthalten. Die Solution und die beiden TVDB-Scraper-Projekte verweisen auf diesen repo-internen Pfad — ein Side-by-side-Checkout ist nicht mehr nötig.
