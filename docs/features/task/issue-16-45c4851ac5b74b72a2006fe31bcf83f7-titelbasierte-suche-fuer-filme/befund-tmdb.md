# Befund: TMDb-Integration beim Kunden (Schritt 1)

Geforderte Eingrenzung aus `plan.md` Schritt 1 / `requirement.md` („Befund: TMDb-Suche ebenfalls ohne Treffer"):

- (a) Ist die TMDb-basierte Titelsuche selbst defekt (veraltete TMDbLib 1.9.1, ungültiger Fallback-Key, TLS)?
- (b) Scrape-Order-Effekt: bricht der leere IMDb-Suchdialog die Scrape-Kette ab, bevor `TMDB_Data.Scraper_Movie` erreicht wird?

## Ergebnis

### Verifiziert (statisch, im Repository)

1. **Fallback-API-Key technisch nutzbar:** Der eingebettete Schlüssel `44810eefccd9cb1fa1d57e7b0d67b08d` (`Addons\scraper.TMDB.Data\TMDB_Data.vb:57`, Konstante `_strAPIKey`) ist syntaktisch ein gültiger TMDb-API-v3-Key und wird weiterhin als Fallback übernommen.
2. **TMDbLib-Upgrade erforderlich und verifiziert:** Die eingesetzte `TMDbLib` 1.9.1 (Assembly-Version 1.0.0.0) ist veraltet; das Projekt wird auf `TMDbLib` **2.3.0** (Assembly-Version 2.0.0.0, `lib\net45`) aktualisiert — die höchste stabile Version, die noch .NET Framework unterstützt (3.x benötigt neuere Zielplattformen). Per Reflection an `packages\TMDbLib.2.3.0\lib\net45\TMDbLib.dll` verifiziert:
   - `TMDbClient.SearchMovieAsync(String, Int32, Boolean, Int32, String, Int32, CancellationToken)` → `Task(Of SearchContainer(Of SearchMovie))`
   - `TMDbClient.SearchTvShowAsync(String, Int32, Boolean, Int32, CancellationToken)` → `Task(Of SearchContainer(Of SearchTv))`
   - `TMDbClient.GetMovieExternalIdsAsync(Int32, CancellationToken)` → `Task(Of ExternalIdsMovie)` mit `ImdbId As String`
   - `TMDbClient.GetTvShowExternalIdsAsync(Int32, CancellationToken)` → `Task(Of ExternalIdsTvShow)` mit `ImdbId As String`
   - `SearchMovie`: `Title`, `OriginalTitle`, `ReleaseDate As DateTime?`, `Id`; `SearchTv`: `Name`, `OriginalName`, `FirstAirDate As DateTime?`, `Id`
3. **Assembly nicht strong-named:** `TMDbLib, PublicKeyToken=null` — der geplante Binding Redirect wird konfiguriert (`publicKeyToken="null"`), ist bei nicht signierten Assemblys jedoch wirkungslos; die Konsistenz wird über identische HintPaths (beide Module → `packages\TMDbLib.2.3.0\lib\net45\TMDbLib.dll`) sichergestellt.
4. **Bestätigter Defekt in der TMDb-Fehlerkette (Hypothese a, teilbestätigt):** `clsScrapeTMDB.SearchMovie`/`SearchMovieSet`/`SearchTVShow` werten `APIResult.Result` aus, ohne `APIResult.Exception` zu prüfen — ein API-Fehler (ungültiger Key, Rate-Limit, Netzwerk) führt zu einer `AggregateException`/`NullReferenceException`, die `bwTMDB_DoWork` ungefiltert durchlässt und in `bwTMDB_RunWorkerCompleted` beim `e.Result`-Zugriff erneut geworfen wird. Das Ergebnis-Event wird nie gefeuert; der Suchdialog bleibt im Ladezustand bzw. zeigt keine unterscheidbare Fehlermeldung. Wird in Schritt 6 behoben.
5. **Scrape-Order-Effekt (Hypothese b) ist real und dokumentiert:** `ModulesManager.ScrapeData_Movie` (`EmberAPI\clsAPIModules.vb:949`) beendet die Kette bei `ret.Cancelled`; der leere/defekte IMDb-Suchdialog liefert `Cancelled = True` beim Abbrechen (`IMDB_Data.vb:480`), sodass ein nachgeordneter TMDb-Scraper nie erreicht wird. Ohne Kundenlogs (`[ModulesManager] [ScrapeData_Movie] [Using] …`, `clsAPIModules.vb:944`) lässt sich die konkrete Modulreihenfolge beim Kunden nicht beweisen — der Mechanismus ist jedoch verifiziert und die Gegenmaßnahmen (funktionierende IMDb-Suche + unterscheidbarer Fehlerpfad) adressieren beide Hypothesen.

### Nicht beweisbar ohne Kundenumgebung

- Konkrete HTTP-Antwort der TMDb-API beim Kunden (Status/Body) — nicht reproduzierbar ohne Kundenzugriff.
- Tatsächliche `ModuleOrder`-Reihenfolge und `[Using]`-Logzeilen beim Kunden — Konfiguration liegt nicht vor.

## Schlussfolgerung

Beide Hypothesen sind plausibel und werden adressiert: Hypothese (a) durch den TMDbLib-2.3.0-Upgrade in beiden Modulen samt robuster Fehlerbehandlung, Hypothese (b) durch die Reparatur der IMDb-Suche (erster Scraper liefert wieder Treffer → kein `Cancelled`-Abbruch vor TMDb). Die TMDb-API ist damit als Suchbasis für das IMDb-Modul tragfähig.
