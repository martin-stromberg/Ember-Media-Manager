← [Zurück zur Übersicht](index.md)

# Serien — Business Rules

## Episoden-Dateizuordnung

**Beschreibung:** Episoden werden ausschließlich über Dateinamen-Muster zugeordnet; das konfigurierbare Regex-Profil entscheidet, welche Dateien als Episode gelten.

**Bedingungen:**
- Datei liegt unterhalb eines erkannten Serienordners
- Dateiname matcht ein aktives Regex-Profil (`dlgTVRegExProfiles`)

**Verhalten:**
- `S01E02`-Muster → Staffel 1, Episode 2
- `1x02`-Muster → Staffel 1, Episode 2
- `S01E01E02`/Range-Muster → Mehrfach-Episode (eine Datei deckt mehrere Episoden ab)
- Kein Muster-Match → Datei wird ignoriert (kein Episoden-Eintrag)

**Umsetzung:** `Scanner.RegexGetTVEpisode` (`clsAPIScanner.vb`)

## Staffel-Logik

**Beschreibung:** Staffeln entstehen aus Staffelordnern und/oder den Episoden-Metadaten; leere und ungültige Staffeln werden bereinigt.

**Bedingungen:**
- Staffelnummer aus Ordnername bzw. Datei-Erkennung
- Specials → Staffel 0

**Verhalten:**
- `Delete_Invalid_TVSeasons`/`Delete_Invalid_TVEpisodes` entfernen Staffeln/Episoden, deren Dateien nicht mehr existieren
- `Delete_Empty_TVSeasons` entfernt Staffeln ohne Episoden
- `Season Result`-Auswertung entscheidet bei mehrdeutigen Staffelpaketen

**Umsetzung:** `Database.Delete_Invalid_TVSeasons`, `Database.Delete_Invalid_TVEpisodes`, `Database.Delete_Empty_TVSeasons` (`clsAPIDatabase.vb`)

## Episodenreihenfolge

**Beschreibung:** Pro Serie ist wählbar, ob Episoden in Aired- oder DVD-Reihenfolge sortiert und gespeichert werden (`EpisodeOrdering`).

**Verhalten:**
- Aired: Erstausstrahlungsreihenfolge des Scrapers
- DVD: DVD-Reihenfolge, sofern vom Scraper geliefert

**Umsetzung:** `Enums.EpisodeOrdering`, `EpisodeDetails`/`SeasonDetails` (`clsAPIMediaContainers.vb`)

## Episoden-Flags

**Beschreibung:** Episoden tragen dieselben Status-Flags wie Filme (`IsNew`, `IsMarked`, `IsLock`); Staffel- und Serien-Sperrung wirkt auf untergeordnete Ebenen.

**Umsetzung:** `Database.DBElement`-Flags; Auswertung in `frmMain` und Modulen
