← [Zurück zur Übersicht](index.md)

# Beschreibung

Ember Media Manager wird als Visual-Studio-Solution (`Ember Media Manager.sln`) gebaut. Alle rund 30 Projekte der Solution — Hauptanwendung, `EmberAPI`, `KodiAPI`, `Trakttv` und alle Addon-Module — zielen einheitlich auf **.NET Framework 4.8**.

Nach einem frischen `git clone` genügen zwei Schritte, um die vollständige Solution zu kompilieren: NuGet-Pakete wiederherstellen und die Solution mit MSBuild bauen. Es ist weder ein separates .NET Framework 4.8 Developer Pack noch ein externer Checkout der TVDB-Bibliothek erforderlich — beides liegt im Repository bzw. wird per NuGet bezogen.

Die unterstützten Ausgabe-Plattformen sind **x86** und **x64**; nur diese liefern die plattformspezifischen nativen Abhängigkeiten mit aus. `Any CPU` kompiliert ebenfalls, enthält aber keine nativen Komponenten.

## Beispiel

```bat
.nuget\NuGet.exe restore "Ember Media Manager.sln"
msbuild "Ember Media Manager.sln" -p:Configuration=Release -p:Platform=x64
```

Das fertige Build-Ergebnis liegt danach unter `EmberMM - Release - x64\`.
