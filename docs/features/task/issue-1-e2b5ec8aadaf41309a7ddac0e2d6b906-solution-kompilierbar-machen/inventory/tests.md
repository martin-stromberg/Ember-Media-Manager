# Test-Ausgangszustand vor der Umsetzung

- Zeitpunkt (mit Zeitzone): 2026-09-19, ~20:20 Uhr (lokale Systemzeit, CEST)
- Branch und Commit-ID: `task/issue-1-e2b5ec8aadaf41309a7ddac0e2d6b906-solution-kompilierbar-machen`,
  HEAD `c7235061` („code: cleanup")
- Uncommittete Änderungen im getesteten Stand: `.gitignore` (ergänzt `issue.md`),
  untracked `.agents/` und `docs/` (Lifecycle-Artefakte). Keine Quellcodeänderungen.
- Testumgebung und Runtime-/SDK-Versionen: Windows, VS 18 Community MSBuild,
  .NET Framework 4.8.1 Runtime, .NET SDK 10.0.401
- Ermittelte Testsuiten und Quellen der Testbefehle: einziges Testprojekt
  `EmberAPI_Test/EmberAPI_Test.vbproj` (MSTest,
  `Microsoft.VisualStudio.QualityTools.UnitTestFramework` v10). Kein CI-Workflow,
  keine Build-/Testskripte mit Testaufruf im Repo.

## Testläufe

| Lauf | Befehl inkl. Filter | Arbeitsverzeichnis | Exit-Code | Erfolgreich | Fehlgeschlagen | Übersprungen | Nachweis |
|------|--------------------|--------------------|-----------|-------------|----------------|--------------|----------|
| Solution-Build (Vorbedingung für jeden Testlauf) | `MSBuild.exe "Ember Media Manager.sln" -v:m -nologo -m -p:Configuration=Release` | Repo-Root | 1 | n/a | n/a | n/a | [build-baseline.log](test-results/build-baseline.log) |

## Nachgewiesene bestehende Testfehler

Keine. Es konnte kein Testlauf ausgeführt werden, weil die Solution nicht
kompiliert und das einzige Testprojekt nicht Teil der Solution ist und selbst
einen toten Projektverweis (`..\UnitTests\UnitTests.vbproj`) enthält.

## Testlücken und Ausführungsprobleme

- **Solution-Build schlägt fehl** (MSB3202 fehlendes TVDB.csproj, NuGet-Restore
  mit NuGet.exe 2.0 defekt, MSB3644 fehlende v4.5-Referenzassemblys) → kein
  Test überhaupt ausführbar.
- `EmberAPI_Test` ist nicht in `Ember Media Manager.sln` enthalten und
  referenziert das nicht vorhandene `..\UnitTests\UnitTests.vbproj`
  → derzeit nicht kompilierbar.
- Es existieren **keine ausführbaren Tests** im Ausgangszustand.

## Testklassen (in EmberAPI_Test, derzeit nicht ausführbar)

`Test_clsAPICommon`, `Test_clsAPIErrorLog`, `Test_clsAPIFileUtils`,
`Test_clsAPIHTTP`, `Test_clsAPIImageUtils`, `Test_clsAPIImages`,
`Test_clsAPINumUtils`, `Test_clsAPIStringUtils`, `Test_clsTrailers`,
`Test_clsYouTube` — allesamt MSTest-`TestClass`en für `EmberAPI`-Hilfsklassen;
teils UI-Forms (`ImageFeedback`, `PixelRuler`).
