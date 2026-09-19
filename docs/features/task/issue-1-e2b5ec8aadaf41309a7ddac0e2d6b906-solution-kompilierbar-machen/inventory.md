# Bestandsaufnahme: Solution kompilierbar machen

Analysiert wurde die Build-Konfiguration der Solution `Ember Media Manager.sln`
(Ember Media Manager, VB.NET-WinForms-Anwendung mit C#-Nebenprojekten) sowie die
vorhandene NuGet-Infrastruktur und die Build-Umgebung, bezogen auf die Anforderung
„gesamte Solution kompilierbar + neuestes .NET Framework".

## Zusammenfassung

- Die Solution enthält **32 echte Projekte** (+ 1 Solution-Ordner „Addons").
- **Build-Blocker 1:** Die Solution referenziert das externe Projekt
  `..\TheTVDBApi\src\TVDB\TVDB.csproj` (Projekt-GUID `{A265B83F-495E-43BD-B1F5-C89B58618A84}`),
  das im Repository nicht enthalten ist. Es stammt aus dem separaten Repository
  `DanCooper/TheTVDBApi` (GPL-3.0); die GUID in der Solution stimmt mit dem
  dortigen `TVDB.csproj` überein. `scraper.Data.TVDB` und `scraper.Image.TVDB`
  haben `ProjectReference`s darauf und nutzen die Namespaces `TVDB.Web`,
  `TVDB.Model` (`WebInterface`, `Mirror`, `Series`, `SeriesDetails`, `Actor`,
  `Episode`).
- **Build-Blocker 2:** NuGet-Wiederherstellung ist defekt. `.nuget/NuGet.exe`
  ist Version 2.0 (2012) und kann nuget.org (v3-API, TLS 1.2) nicht mehr
  bedienen. 18+ Projekte importieren `.nuget/NuGet.targets` und setzen
  `<RestorePackages>true</RestorePackages>`, wodurch beim Build pro Projekt
  `nuget.exe install packages.config -source "" -o packages` aufgerufen wird
  und fehlschlägt. MSBuild-integriertes Restore (`msbuild -t:restore`) scheitert
  aktuell nur am fehlenden TVDB-Projekt.
- **Build-Blocker 3:** Veraltete Zielframeworks ohne installierte
  Referenzassemblys: 1 Projekt zielt auf `v3.5`, 4 auf `v4.5` (MSB3644).
  Installierte Referenzassemblys reichen bis `v4.8`; **4.8.1 ist nicht
  installiert** (Runtime 4.8.1 ist vorhanden, Release 533320/533509).
- **Test-Ausgangszustand:** Es existiert ein einziges Testprojekt
  `EmberAPI_Test` (MSTest, QualityTools v10), das **nicht** in der Solution
  enthalten ist und selbst einen toten Projektverweis auf
  `..\UnitTests\UnitTests.vbproj` enthält → derzeit nicht kompilierbar, keine
  ausführbaren Tests. Nachweis: [tests.md](inventory/tests.md),
  [build-baseline.log](inventory/test-results/build-baseline.log).
- Weitere nicht-solution Projekte auf der Festplatte: `EmberAPI_Test`,
  `Trakttv/Trakttv.csproj`, `Addons/scraper.EmberCore.XML` — außerhalb des
  Solution-Scopes.

## Details

- [Solution und Projekte](inventory/solution.md)
- [Build-System und Umgebung](inventory/build-system.md)
- [Tests](inventory/tests.md)
