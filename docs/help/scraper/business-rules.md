← [Zurück zur Übersicht](index.md)

# Scraper — Business Rules

## Scrape-Umfang und -Modus

**Beschreibung:** Jeder Scrape-Lauf kombiniert einen Umfang (welche Elemente) mit einem Modus (wie entschieden wird) — abgebildet in `ScrapeType`.

**Bedingungen:**
- Umfang: `All`, `New`, `Marked`, `Filter`, `Missing`
- Modus: `Auto`, `Ask`, `Skip`

**Verhalten:**
- `…Auto` → erstes Suchergebnis wird ohne Rückfrage übernommen
- `…Ask` → Such-/Auswahldialog je Element (`dlgSearchResults`, `dlgImgSelect`)
- `…Skip` → Element wird übersprungen
- `Missing*` → nur Elemente mit fehlenden Inhalten werden bearbeitet
- `Marked*`/`Filter*` → nur markierte bzw. gefilterte Elemente

**Umsetzung:** `Enums.ScrapeType` (`clsAPICommon.vb`), Auswertung in `frmMain`

## Feldübernahme durch Daten-Scraper

**Beschreibung:** Daten-Scraper laufen in *Scrape Order* nacheinander; ein Feld wird nur übernommen, wenn es im Lauf ausgewählt ist, noch leer ist und nicht gesperrt.

**Bedingungen:**
- Feld in der Custom-Scraper-/Modul-Auswahl aktiviert
- Feld im Ziel-`DBElement` leer bzw. nicht durch *Lock* geschützt

**Verhalten:**
- Früherer Scraper in der Reihenfolge gewinnt: gefüllte Felder werden von späteren Scrapern nicht überschrieben
- `Lock`-Flag → keine Feldänderung
- `NFOItem` ausgewählt → NFO wird nach dem Lauf geschrieben

**Umsetzung:** Feld-Merge in `frmMain` nach `ScraperModule_Data_*.Scraper`-Aufruf

## Bildauswahl

**Beschreibung:** Alle aktiven Bild-Scraper liefern Kandidatenlisten je `ScraperEventType`-Bildtyp; die Auswahl erfolgt zentral, nicht im Scraper.

**Verhalten:**
- `Auto`-Modus: erstes/erstplatziertes Ergebnis je Bildtyp
- `Ask`-Modus: `dlgImgSelect` zeigt alle Ergebnisse zusammengeführt; Anwender wählt je Bildtyp
- Reihenfolge der Bild-Scraper ist nur für automatische Läufe relevant (erster Scraper zuerst)

**Umsetzung:** `dlgImgSelect`, `Images`/`ImageUtils` (Download/Größenprüfung), `PreferredImagesContainer`

## Trailer- und Theme-Handling

**Beschreibung:** Trailer und Themes werden wie Bilder behandelt: Scraper liefern Quellen, zentrale Komponenten laden und speichern einmal.

**Verhalten:**
- „also use Trailer Scrapers" aktiv → Trailer-Scraper laufen zusätzlich zu Daten-Scrapern
- Download über `HTTP`/`YouTube`; Ablage als `{Datei}-trailer.*` bzw. `theme.*`

**Umsetzung:** `ScraperModule_Trailer_Movie`, `ScraperModule_Theme_*`, `clsAPIYouTube`, `clsAPIFFmpeg`
