# Solution und Projekte

Datei: `Ember Media Manager.sln` (VS-Solution, Format 12.00)

## Projektübersicht

| Projekt | Datei | Sprache | TargetFrameworkVersion | In Solution |
|---------|-------|---------|------------------------|-------------|
| `EmberMediaManager` | `EmberMediaManager/EmberMediaManager.vbproj` | VB.NET (WinForms-Exe) | v4.8 | ja |
| `EmberAPI` | `EmberAPI/EmberAPI.vbproj` | VB.NET | v4.8 | ja |
| `KodiAPI` | `KodiAPI/KodiAPI.csproj` | C# | v4.5 | ja |
| `TVDB` | `..\TheTVDBApi\src\TVDB\TVDB.csproj` | C# | v4.5 (Upstream) | ja — **Datei fehlt** |
| 28 Addon-Projekte | `Addons/**/*.vbproj` | VB.NET | v4.8, außer `scraper.Image.TVDB` = v4.5 | ja |
| `EmberAPI_Test` | `EmberAPI_Test/EmberAPI_Test.vbproj` | VB.NET (MSTest) | v4.5 | nein |
| `Trakttv` | `Trakttv/Trakttv.csproj` | C# | v4.5 | nein |
| `scraper.EmberCore.XML` | `Addons/scraper.EmberCore.XML/…vbproj` | VB.NET | v3.5 | nein |

Zählung der `TargetFrameworkVersion` über alle Projekte im Repo:
`v4.8` × 30, `v4.5` × 4, `v3.5` × 1.

## Fehlende externe Projektreferenz: TVDB

- Solution-Eintrag: `Project("{FAE04EC0-…}") = "TVDB", "..\TheTVDBApi\src\TVDB\TVDB.csproj", "{A265B83F-495E-43BD-B1F5-C89B58618A84}"`
- `ProjectReference` in `Addons/scraper.Data.TVDB/scraper.Data.TVDB.vbproj` (Zeile 205)
  und `Addons/scraper.Image.TVDB/scraper.Image.TVDB.vbproj` (Zeile 199).
- Upstream-Quelle: `https://github.com/DanCooper/TheTVDBApi` (default branch `master`,
  letzter Push 2019-11-29, Lizenz GPL-3.0, Projektdatei unter `src/TVDB/TVDB.csproj`,
  GUID identisch). Upstream-Konvention: Repository neben dem EMM-Repo klonen
  (`..\TheTVDBApi`). Das Verzeichnis existiert auf diesem System nicht.
- Genutzte API-Fläche (in `clsScrapeTVDB.vb`): `TVDB.Web.WebInterface`,
  `TVDB.Model.Mirror`, `TVDB.Model.Series`, `TVDB.Model.SeriesDetails`,
  `TVDB.Model.Actor`, `TVDB.Model.Episode`.

## Toter Projektverweis außerhalb der Solution

- `EmberAPI_Test/EmberAPI_Test.vbproj` referenziert `..\UnitTests\UnitTests.vbproj`
  (Zeile 183) — nicht im Repo vorhanden. Da das Projekt nicht zur Solution gehört,
  blockiert es den Solution-Build nicht.

## Pre-/Post-Build-Events

Vorhandene `<PreBuildEvent>`/`<PostBuildEvent>`-Elemente in den vbproj-Dateien
sind leer — keine Auswirkung auf den Build.
