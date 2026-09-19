← [Zurück zur Übersicht](index.md)

# Fehlerbehebung

Bekannte Build-Probleme und ihre Lösungen:

| Fehlermeldung | Ursache | Lösung |
|---------------|---------|--------|
| `MSB3202: Die Projektdatei "..\TheTVDBApi\src\TVDB\TVDB.csproj" wurde nicht gefunden` | Veralteter Verweis auf einen Side-by-side-Checkout | Aktueller Stand: `TVDB.csproj` liegt unter `TheTVDBApi\src\TVDB\` im Repository — Solution und ProjectReferences zeigen dorthin. |
| `MSB3644: Die Verweisassemblys für ".NETFramework,Version=v4.8.1" wurden nicht gefunden` | Paket-Referenzassemblys fehlen | `.nuget\NuGet.exe restore "Ember Media Manager.sln"` ausführen; `Directory.Build.props` aktiviert danach `FrameworkPathOverride` automatisch. |
| „Package restore is disabled" / NuGet-Fehler beim Restore | Veraltete NuGet.exe (2.x) | `.nuget/NuGet.exe` wurde auf 6.14.0 aktualisiert; `nuget restore` statt `msbuild -t:restore` verwenden (Letzteres deckt `packages.config` nicht ab). |
| `MSB3073 ... xcopy ... AnyCPU` im PostBuildEvent von `EmberAPI` | Plattformverzeichnis für native Deps fehlt | Das PostBuildEvent kopiert nur noch, wenn `$(ProjectDir)$(PlatformName)` existiert — AnyCPU besitzt kein natives Verzeichnis und ist damit unkritisch. |
| `BC31392: /platform:anycpu32bitpreferred kann nur mit /t:exe ... verwendet werden` | `Prefer32Bit=true` in Bibliotheksprojekten | In den betroffenen Addon-Projekten auf `false` gesetzt (nur bei `*-exe`-Ausgaben zulässig). |
