← [Zurück zur Übersicht](index.md)

# Medienbibliothek — Business Rules

## Quellzuordnung und Gültigkeit

**Beschreibung:** Nur Dateien unterhalb konfigurierter Quellen gelangen in die Bibliothek; Film- und Serienquellen sind strikt getrennt.

**Bedingungen:**
- Quelle hat Typ Film (`DBSource` für Movies) oder Serie (`DBSource` für TV)
- Optionen der Quelle (rekursiv, Ausschlussmuster, Sprache)

**Verhalten:**
- Verzeichnis erfüllt `IsValidDir` (kein Ausschlussmuster, kein versteckter/systemischer Ordner): wird durchsucht
- Verzeichnis in `GetAll_ExcludedDirectories`: wird übersprungen
- Bei Filmen: `SubDirsHaveMovies` entscheidet, ob Unterordner eigene Filme sind oder zum Film gehören (z. B. `VIDEO_TS`, `BDMV`, Extras)

**Umsetzung:** `Scanner.IsValidDir`, `Scanner.ScanSubDirectory_Movie`, `Scanner.SubDirsHaveMovies` (`clsAPIScanner.vb`)

## Episoden-Erkennung

**Beschreibung:** Episodendateien werden der Serie über Dateinamen-Muster (z. B. `S01E02`, `1x02`) zugeordnet; die Muster sind konfigurierbar.

**Bedingungen:**
- Serien-Quelle gescannt, Serien-Ordner erkannt
- Regex-Profile in den Einstellungen (`dlgTVRegExProfiles`)

**Verhalten:**
- Dateiname matcht ein Episoden-Muster → `RegexGetTVEpisode` liefert Staffel-/Episodennummer(n) inkl. Mehrfach-Episoden (`S01E01E02`)
- Kein Match → Datei wird nicht als Episode übernommen
- `Season Result`-Auswertung entscheidet bei Staffelpaketen

**Umsetzung:** `Scanner.RegexGetTVEpisode` (`clsAPIScanner.vb`)

## „New"- und Bereinigungslogik

**Beschreibung:** Neu gefundene Medien werden als `IsNew` markiert; nur die Bereinigung entfernt tatsächlich gelöschte Dateien aus der Datenbank.

**Bedingungen:**
- Scan mit Update-/Clean-Auftrag (`Structures.ScanOrClean`)

**Verhalten:**
- Datei neu → Eintrag mit `IsNew` angelegt (sichtbar als „New")
- Datei im Scan nicht mehr gefunden → Eintrag bleibt bei reinem Update bestehen; bei *Clean Database*/Clean Files wird er entfernt (`Database.Clean`, `Delete_Invalid_TVEpisodes`, `Delete_Empty_TVSeasons`)
- `Database.Clear_New` hebt alle New-Markierungen auf

**Umsetzung:** `Database.Clean`, `Database.Clear_New` (`clsAPIDatabase.vb`)

## Lock/Mark

**Beschreibung:** `IsLock` schützt ein Element vor Überschreiben durch Scraper/Updates; `IsMarked` ist die Arbeitsauswahl für Batch-Operationen (ScrapeType `Marked*`, Export, Rename).

**Verhalten:**
- `IsLock` gesetzt → Scraper und Feld-Updates verändern das Element nicht
- `IsMarked` gesetzt → Element gehört zur Markiert-Menge für Bulk-Aktionen

**Umsetzung:** Flags auf `Database.DBElement`, Auswertung in `frmMain` und den Modulen
