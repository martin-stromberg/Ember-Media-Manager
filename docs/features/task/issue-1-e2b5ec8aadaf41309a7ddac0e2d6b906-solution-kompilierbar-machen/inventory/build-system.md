# Build-System und Umgebung

## NuGet-Infrastruktur (veraltet)

- `.nuget/NuGet.exe` — **Version 2.0.30619.9000** (committete Binary, Stand 2012).
  Kann nuget.org v3/TLS 1.2 nicht bedienen; `nuget install` schlägt fehl
  („Package restore is disabled by default" / ExitCode -1).
- `.nuget/NuGet.targets` — altes „Enable NuGet Package Restore"-Muster.
  Wird von 18 Projekten via `<Import Project="$(SolutionDir)\.nuget\nuget.targets" />`
  eingebunden. Aktiv nur, wenn `RestorePackages=true` — dies ist in mindestens
  18 vbproj-Dateien gesetzt (`<RestorePackages>true</RestorePackages>`).
  Restore-Aufruf pro Projekt:
  `nuget.exe install "<proj>\packages.config" -source "" -o "<sln>\packages"`.
- `.nuget/NuGet.Config` — enthält nur `disableSourceControlIntegration`,
  keine Paketquellen (→ Default = nuget.org).
- `packages.config` in 34 Projekten. Zentrale Pakete:
  `NLog` 4.7.14 (×30), `Newtonsoft.Json` 13.0.1 (×7), `System.Data.SQLite.Core`
  1.0.115.5 (×5), `HtmlAgilityPack` 1.11.42 (×3), `TMDbLib` 1.9.1 (×3),
  `Trakt.NET` 1.1.1 (×2), diverse `System.*` 4.3.x. Alle mit
  `targetFramework="net45"`/`net4x`-Markierung — kompatibel mit net481.

## Build-Umgebung (dieses System)

- MSBuild: `C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe`
  (Visual Studio 18 Community, einzige VS-Installation laut vswhere).
- .NET SDK: 10.0.401 (`dotnet` vorhanden, für diese Legacy-Projekte aber nicht
  primär nutzbar).
- winget: v1.29.290 vorhanden.
- Installierte .NET-Framework-Runtime: 4.8.1 (Registry `Release` 533320 und 533509).
- Installierte Referenzassemblys (`C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETFramework`):
  v4.0 – v4.8 + v4.X. **v4.8.1 fehlt** → MSB3644 beim Targeting auf 4.8.1 zu erwarten,
  ebenso bereits jetzt für v4.5 (MSB3644 im Baseline-Log).
- Verfügbare Alternativen für 4.8.1-Referenzassemblys:
  - `.NET Framework 4.8.1 Developer Pack` (Systeminstallation), oder
  - NuGet-Paket `Microsoft.NETFramework.ReferenceAssemblies.net481` (existiert,
    neueste Version 1.0.3) + `FrameworkPathOverride`/`TargetFrameworkRootPath`.

## Baseline-Build (vor Änderungen)

Befehl:
`MSBuild.exe "Ember Media Manager.sln" -v:m -nologo -m -p:Configuration=Release`

Ergebnis: Fehlschlag. Fehlergruppen:

1. `MSB3202` — `..\TheTVDBApi\src\TVDB\TVDB.csproj` nicht gefunden (Solution +
   EmberMediaManager-Metaproj).
2. `MSB3077` / „Package restore is disabled" — NuGet.exe-2.0-Restore schlägt
   für alle Projekte mit `RestorePackages=true` fehl.
3. `MSB3644` — Referenzassemblys für `v4.5` nicht gefunden (KodiAPI.csproj).

Vollständiges Log: `inventory/test-results/build-baseline.log`
