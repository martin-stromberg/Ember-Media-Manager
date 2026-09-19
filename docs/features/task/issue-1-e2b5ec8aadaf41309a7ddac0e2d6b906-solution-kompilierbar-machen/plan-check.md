# Plan-Gegenprüfung

## Ergebnis

**Status:** Plan vollständig

## Abgleich Akzeptanzkriterien

| Akzeptanzkriterium | Umsetzung im Plan | Testnachweis im Plan | Status |
|--------------------|-------------------|----------------------|--------|
| Die gesamte Solution muss kompilierbar sein | Schritte 1–6: TVDB vendoren, Referenzen umbiegen, NuGet.exe 6.14, Retarget v4.8.1, Referenzassemblys-Paket + `Directory.Build.props`, iterativer Restfehler-Fix | Solution-Release-Build mit 0 Fehlern als Funktionsnachweis | Abgedeckt |
| Die Solution muss auf das neueste .NET Framework hochgezogen sein | Schritt 4: `TargetFrameworkVersion` = `v4.8.1` in allen Projekten (inkl. vendored TVDB); `supportedRuntime`-`sku` angleichen | Build auf v4.8.1-Referenzassemblys; MSB3644-frei | Abgedeckt |

## Fehlende oder unvollständige Testanforderungen

— (Status: Plan vollständig)

## E2E-Abdeckung

| Benutzerfluss / Akzeptanzkriterium | Geplanter E2E-Test | Status |
|------------------------------------|--------------------|--------|
| — | — | Nicht erforderlich: ausschließlich Build-Infrastruktur; kein über UI/Nutzeraktion erreichbarer Ablauf geändert. Primärer Funktionsnachweis = erfolgreicher Solution-Build. |

## Fehlende oder unvollständige Planbestandteile

— (Status: Plan vollständig)

## Hinweise

- Das Referenzassemblys-Paket wurde bewusst in `EmberAPI/packages.config`
  platziert; der Solution-Restore (`msbuild -t:restore`) ist Pflichtschritt
  vor dem Build, damit `FrameworkPathOverride` ab dem ersten kompilierten
  Projekt (u. a. `TVDB`, kein Projekt-Dependency) greift.
- Vendored TVDB-Quellen werden mit dem Upstream-Stand `master`
  (letzter Push 2019-11-29, GUID `{A265B83F-…}` identisch) eingefroren —
  reproduzierbar durch Commit im Repo.
- Risiko „weitere Kompilierfehler nach Restore-Fix" ist als eigener
  Iterationsschritt (Schritt 6) vorgesehen.
- `EmberAPI_Test` bleibt außerhalb des Scopes (nicht in Solution, tote
  `UnitTests`-Referenz) — dokumentierte Testlücke, keine Planlücke.
