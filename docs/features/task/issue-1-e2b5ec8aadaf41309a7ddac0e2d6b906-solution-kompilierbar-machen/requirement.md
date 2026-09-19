# Übersetzte Anforderung: Solution kompilierbar machen

Quelle: `issue.md` (Issue #1, frischer Fork eines fremden Repositorys – Ember Media Manager)

## Fachliche Zusammenfassung

Die gesamte Solution `Ember Media Manager.sln` soll auf einem aktuellen Buildsystem
fehlerfrei kompilieren. Zusätzlich sind alle Projekte der Solution auf das neueste
.NET Framework anzuheben. Mit ".NET Framework" ist die klassische .NET-Framework-Linie
gemeint; deren neueste (und finale) Version ist **.NET Framework 4.8.1**. Eine
Migration auf .NET (Core) 8+ ist nicht Teil dieser Anforderung und wäre für eine
VB.NET-WinForms-Anwendung mit `packages.config`-Verwaltung ein eigenes Großprojekt.

## Betroffene Klassen und Komponenten

- `Ember Media Manager.sln` – zentrale Solution mit ~35 Projekten
- Alle `.vbproj`- und `.csproj`-Dateien der Solution:
  - `EmberMediaManager` (WinForms-Hauptanwendung, VB.NET)
  - `EmberAPI` (VB.NET-Bibliothek)
  - `EmberAPI_Test` (Testprojekt)
  - `KodiAPI`, `Trakttv` (C#-Bibliotheken)
  - ~29 Addon-/Scraper-Projekte unter `Addons/` (VB.NET)
- `.nuget/NuGet.exe` (Version 2.0 – veraltet, vermutlich nicht mehr nuget.org-fähig)
- `.nuget/NuGet.targets` – altes "Enable NuGet Package Restore"-Muster, von 18 Projekten importiert
- `packages.config` in 34 Projekten – NuGet-Wiederherstellung muss funktionieren

## Aktueller Ziel-Framework-Zustand

- 30 Projekte: `v4.8`
- 4 Projekte: `v4.5`
- 1 Projekt: `v3.5`

→ Alle sind einheitlich auf `v4.8.1` anzuheben.

## Implementierungsansatz

1. Build-Ausgangszustand ermitteln (MSBuild aus VS 18 Community ist installiert:
   `C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe`).
2. NuGet-Paketwiederherstellung lauffähig machen (NuGet.exe 2.0 durch aktuelle Version
   ersetzen oder MSBuild-integriertes Restore verwenden).
3. `TargetFrameworkVersion` aller Projekte auf `v4.8.1` setzen
   (Referenzassemblys für 4.8.1 ggf. über Developer Pack oder
   `Microsoft.NETFramework.ReferenceAssemblies.net481` bereitstellen).
4. Verbliebene Kompilierfehler beheben (Minimalinvasiv – keine fachlichen Änderungen).
5. Solution-Build erfolgreich abschließen; vorhandene Tests (`EmberAPI_Test`) ausführen.

## Konfiguration

Keine fachliche Konfiguration erforderlich. Betroffen sind nur Build-/Projektdateien.

## Offene Fragen

- Soll neben `.NET Framework 4.8.1` auch die veraltete NuGet-Infrastruktur modernisiert
  werden (NuGet.exe aktualisieren, `NuGet.targets`-Importe bereinigen), soweit für den
  Build nötig? Annahme: ja, minimalinvasiv – nur was für einen erfolgreichen Build nötig ist.
- Ist die Installation des .NET Framework 4.8.1 Developer Pack auf dem Buildsystem
  zulässig, oder sollen Referenzassemblys repo-seitig via NuGet-Paket
  (`Microsoft.NETFramework.ReferenceAssemblies`) aufgelöst werden?
  Empfehlung: NuGet-Paket, damit der Build ohne Systeminstallation reproduzierbar bleibt.
