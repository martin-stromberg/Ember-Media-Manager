# Umsetzungsplan: Solution kompilierbar machen

## Übersicht

Die Solution `Ember Media Manager.sln` wird wieder baubar gemacht: Die fehlende
externe Projektreferenz `TVDB` wird repo-intern bereitgestellt, die defekte
NuGet-Wiederherstellung (NuGet.exe 2.0) wird repariert, alle Projekte werden auf
.NET Framework 4.8.1 angehoben und verbleibende Kompilierfehler werden
minimalinvasiv behoben. Es gibt keine fachlichen/Änderungen am Programmverhalten.

## Designentscheidungen

| Komponente / Bereich | Gewählter Ansatz | Begründung |
|----------------------|-----------------|------------|
| Bereitstellung `TVDB.csproj` | Quellen von `DanCooper/TheTVDBApi` (`src/TVDB`) ins Repo vendoren nach `TheTVDBApi/src/TVDB/`, inkl. LICENSE (GPL-3.0, mit EMM-GPL kompatibel); `.sln`-Pfad und die beiden `ProjectReference`s auf den repo-internen Pfad umbiegen | Vollständig self-contained und reproduzierbar; kein Submodule nötig; erlaubt sauberes Retargeting auf v4.8.1. Alternative (Side-by-side-Clone `..\TheTVDBApi`) bricht bei jedem frischen Clone erneut; ein Git-Submodule würde durch das nötige Retargeting verschmutzt. |
| NuGet-Restore | `.nuget/NuGet.exe` durch aktuelle Version **6.14.0** ersetzen; `NuGet.targets` belassen (per-Projekt `nuget install` bleibt funktionsfähig); zusätzlich Lösungs-Restore via `msbuild -t:restore` dokumentieren | Minimalinvasiv: eine Binärdatei statt Umbau von ~18 Projektdateien. Falls `-source ""` in NuGet 6 nicht akzeptiert wird, wird das `-source`-Argument in `NuGet.targets` entfernt. |
| Zielframework | **.NET Framework 4.8.1** für alle Projekte im Repo (Solution-Projekte + nicht-Solution-Projekte + vendored TVDB) | 4.8.1 ist die neueste und letzte Version der klassischen .NET-Framework-Linie. Einheitliches Targeting verhindert Referenzassembly-Mischzustände. |
| Referenzassemblys 4.8.1 | NuGet-Paket `Microsoft.NETFramework.ReferenceAssemblies.net481` (1.0.3) nach `packages/` restoren (über `packages.config` von `EmberAPI` — baut früh in der Abhängigkeitsreihenfolge) + `Directory.Build.props` mit `FrameworkPathOverride` auf das Paketverzeichnis | Self-contained: Der Build benötigt kein installiertes 4.8.1 Developer Pack und keine Adminrechte. Funktioniert auf jedem Rechner nach `nuget/msbuild restore`. |

## Programmabläufe

### Build-Ablauf (nach Umsetzung)

1. `git clone` des Repos (kein Submodul nötig).
2. `MSBuild.exe "Ember Media Manager.sln" -t:restore` — **Pflichtschritt vor
   jedem Build** (stellt alle Pakete inkl. der 4.8.1-Referenzassemblys vor dem
   ersten Projektbuild bereit; das Legacy-`nuget install` pro Projekt läuft
   danach nur noch als No-op mit).
3. `MSBuild.exe "Ember Media Manager.sln" -p:Configuration=Release` — alle 32
   Projekte kompilieren gegen v4.8.1 (Referenzassemblys via
   `Directory.Build.props`/`FrameworkPathOverride` aus dem NuGet-Paket).

Beteiligte Artefakte: `.sln`, alle `*.vbproj`/`*.csproj`, `.nuget/*`,
`Directory.Build.props` (neu), `TheTVDBApi/` (neu).

## Neue Dateien

| Datei | Typ | Zweck |
|-------|-----|-------|
| `TheTVDBApi/src/TVDB/**` | vendored C#-Quellen (GPL-3.0, aus `DanCooper/TheTVDBApi@master`) | fehlende Projektreferenz `TVDB` bereitstellen |
| `TheTVDBApi/LICENSE` | Lizenztext | GPL-3.0-Attribution des vendored Codes |
| `Directory.Build.props` | MSBuild-Props | `FrameworkPathOverride` → `packages/Microsoft.NETFramework.ReferenceAssemblies.net481/build/.NETFramework/v4.8.1` (nur gesetzt, wenn Verzeichnis existiert) |

## Änderungen an bestehenden Dateien

### `Ember Media Manager.sln`

- Projektpfad `..\TheTVDBApi\src\TVDB\TVDB.csproj` → `TheTVDBApi\src\TVDB\TVDB.csproj`.

### `Addons/scraper.Data.TVDB/scraper.Data.TVDB.vbproj` und `Addons/scraper.Image.TVDB/scraper.Image.TVDB.vbproj`

- `ProjectReference Include="..\..\..\TheTVDBApi\..."` → `"..\..\TheTVDBApi\src\TVDB\TVDB.csproj"`.

### Alle `*.vbproj` / `*.csproj` im Repo (35 Dateien)

- `<TargetFrameworkVersion>` → `v4.8.1` (betrifft v4.8, v4.5, v3.5 gleichermaßen;
  vereinheitlicht Solution- und Nicht-Solution-Projekte).

### `TheTVDBApi/src/TVDB/TVDB.csproj` (vendored)

- `<TargetFrameworkVersion>` → `v4.8.1`.

### `.nuget/NuGet.exe`

- Binärupdate 2.0 → 6.14.0 (Download von dist.nuget.org).

### `.nuget/NuGet.targets` (nur falls nötig)

- `-source $(PackageSources)`-Argument aus `RestoreCommand` entfernen, falls
  NuGet 6 den leeren `-source ""`-Wert nicht akzeptiert (wird bei Implementierung verifiziert).

### `EmberAPI/packages.config`

- Paket `Microsoft.NETFramework.ReferenceAssemblies.net481` Version `1.0.3`
  ergänzen (reines Build-Asset, keine Assembly-Referenz).

### `app.config`-Dateien (falls `supportedRuntime`-`sku` gesetzt)

- `sku=".NETFramework,Version=v4.8"` o. ä. → `v4.8.1` angleichen.

## Datenbankmigrationen

Keine.

## Validierungsregeln

Keine.

## Konfigurationsänderungen

| Eintrag | Typ | Standardwert | Zweck |
|---------|-----|--------------|-------|
| `FrameworkPathOverride` in `Directory.Build.props` | MSBuild-Property | `$(MSBuildThisFileDirectory)packages\Microsoft.NETFramework.ReferenceAssemblies.net481\build\.NETFramework\v4.8.1` | 4.8.1-Referenzassemblys ohne Developer Pack auflösen |
| `Microsoft.NETFramework.ReferenceAssemblies.net481` in `EmberAPI/packages.config` | NuGet-Paket (Build-Asset) | 1.0.3 | Referenzassemblys per Restore bereitstellen |

## Seiteneffekte und Risiken

- **NuGet-Binärupdate:** `nuget.exe` 6.14 ändert ggf. Restore-Verhalten
  (v3-API, andere Ordnerstruktur bleibt gleich); `nuget pack`-Funktion des
  alten `BuildPackage`-Targets wird nicht genutzt → kein Risiko.
- **`FrameworkPathOverride` global:** Gilt für alle Projekte unterhalb des
  Repo-Roots. Da einheitlich auf v4.8.1 kompiliert wird, unkritisch. Projekte
  außerhalb des Repos sind nicht betroffen.
- **Retargeting v3.5/v4.5 → v4.8.1:** Kann neue Compilerwarnungen/-fehler
  erzeugen (z. B. entfernte APIs, `System.Web`-Verhalten, VB-Sprachfeatures).
  Werden in der Implementierung iterativ behoben.
- **Vendored TVDB:** Code-Duplikat ohne Upstream-Bindung; akzeptabel, da
  Upstream seit 2019 unverändert (Letzter Push 2019-11-29).
- **EmberAPI_Test:** Bleibt außerhalb der Solution und wegen totem
  `..\UnitTests\UnitTests.vbproj`-Verweis weiterhin nicht baubar — kein
  Scope dieser Anforderung (wird retargeted, aber nicht repariert).

## Umsetzungsreihenfolge

1. **TheTVDBApi vendoren**
   - Voraussetzungen: Netzwerkzugriff auf github.com (vorhanden)
   - Beschreibung: `DanCooper/TheTVDBApi@master` herunterladen, `src/TVDB/`
     und `LICENSE` nach `TheTVDBApi/` kopieren.

2. **Solution- und Projektreferenzen umbiegen**
   - Voraussetzungen: Schritt 1
   - Beschreibung: `.sln`-Pfad und die zwei `ProjectReference`-Pfade auf
     `TheTVDBApi\src\TVDB\TVDB.csproj` aktualisieren.

3. **NuGet.exe aktualisieren**
   - Voraussetzungen: Netzwerkzugriff auf dist.nuget.org (vorhanden)
   - Beschreibung: `.nuget/NuGet.exe` durch Version 6.14.0 ersetzen.

4. **Alle Projekte auf v4.8.1 retargeten**
   - Voraussetzungen: keine (unabhängig)
   - Beschreibung: `TargetFrameworkVersion` in allen `*.vbproj`/`*.csproj`
     (inkl. vendored `TVDB.csproj`) auf `v4.8.1`; `supportedRuntime`-`sku`
     in `app.config`-Dateien angleichen.

5. **Referenzassemblys-Paket + `Directory.Build.props`**
   - Voraussetzungen: Schritt 3 (funktionierender Restore)
   - Beschreibung: `Microsoft.NETFramework.ReferenceAssemblies.net481` 1.0.3 in
     `EmberMediaManager/packages.config` aufnehmen; `Directory.Build.props`
     mit `FrameworkPathOverride` anlegen.

6. **Solution-Build durchführen und Restfehler beheben**
   - Voraussetzungen: Schritte 1–5
   - Beschreibung: `msbuild -t:restore` + Release-Build; verbliebene
     Kompilierfehler minimalinvasiv beheben (z. B. `NuGet.targets`-Anpassung,
     veraltete API-Aufrufe, VB.NET-Sprachversionen). Iterativ bis 0 Fehler.

7. **Build-Dokumentation**
   - Voraussetzungen: Schritt 6
   - Beschreibung: Build-Anleitung (Restore + Build) in `README.md` verankern.

## Tests

### Neue Tests

| Test / Hilfsmethode | Testklasse | Was wird geprüft / bereitgestellt? |
|--------------------|------------|-------------------------------------|
| Solution-Release-Build | — (Build-Nachweis, kein Code-Test) | `MSBuild.exe "Ember Media Manager.sln" -t:restore` + `-p:Configuration=Release` endet mit 0 Fehlern; alle 32 Projekte erzeugen Outputs |

### Betroffene bestehende Tests

Keine — `EmberAPI_Test` ist nicht Teil der Solution und im Ausgangszustand
nicht kompilierbar (tote `..\UnitTests\UnitTests.vbproj`-Referenz).

### E2E-Tests (primärer Funktionsnachweis)

Keine erforderlich — Begründung: Die Anforderung berührt ausschließlich
Build-Infrastruktur (Projektdateien, NuGet-Restore, Zielframework). Es wird
kein über UI oder Nutzeraktion erreichbarer Programmablauf geändert oder
hinzugefügt; das Laufzeitverhalten der Anwendung bleibt unverändert. Der
primäre Funktionsnachweis ist der erfolgreiche Solution-Build.

## Offene Punkte

Keine.
