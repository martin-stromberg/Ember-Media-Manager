# Tasks: Solution kompilierbar machen

| # | Bereich | Aufgabe | Status | Testnachweis |
|---|---------|---------|--------|--------------|
| 1 | Externe Abhängigkeit | `DanCooper/TheTVDBApi` `src/TVDB` + LICENSE nach `TheTVDBApi/` vendoren | Offen | — |
| 2 | Externe Abhängigkeit | `.sln`-Pfad für `TVDB` auf repo-internen Pfad umbiegen | Offen | — |
| 3 | Externe Abhängigkeit | `ProjectReference` in `scraper.Data.TVDB.vbproj` umbiegen | Offen | — |
| 4 | Externe Abhängigkeit | `ProjectReference` in `scraper.Image.TVDB.vbproj` umbiegen | Offen | — |
| 5 | NuGet | `.nuget/NuGet.exe` auf 6.14.0 aktualisieren | Offen | — |
| 6 | NuGet | `Microsoft.NETFramework.ReferenceAssemblies.net481` 1.0.3 in `EmberAPI/packages.config` ergänzen | Offen | — |
| 7 | Framework | `Directory.Build.props` mit `FrameworkPathOverride` anlegen | Offen | — |
| 8 | Framework | `TargetFrameworkVersion` in allen 35 Repo-Projekten + `TVDB.csproj` auf `v4.8.1` setzen | Offen | — |
| 9 | Framework | `supportedRuntime`-`sku` in `app.config`-Dateien auf `v4.8.1` angleichen | Offen | — |
| 10 | Build | `msbuild -t:restore` erfolgreich ausführen | Offen | — |
| 11 | Build | `NuGet.targets` `-source`-Argument prüfen/entfernen falls NuGet 6 es ablehnt | Offen | — |
| 12 | Build | Release-Build der Solution auf 0 Fehler bringen (iterativ) | Offen | — |
| 13 | Doku | Build-Anleitung in `README.md` ergänzen | Offen | — |
