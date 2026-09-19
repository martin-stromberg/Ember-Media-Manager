← [Zurück zur Übersicht](index.md)

# Serien — Beschreibung

## Zweck

Die Serienansicht (*TV Shows*) verwaltet Serien in drei Ebenen: Serie (Show), Staffel (Season) und Episode. Ember Media Manager pflegt pro Ebene eigene Metadaten und Artwork — z. B. Serien-Poster/Fanart/Banner, Staffel-Poster und Episoden-Thumbs — sowie Episoden-Besetzung (inkl. Gaststars), Episoden-Reihenfolgen und Mehrfach-Episoden.

## Funktionsweise

- **Hierarchie:** Serienordner → Staffelordner (`Season 01`, `Season 1`, `Staffel 1` u. a.) → Episodendateien; Specials werden als Staffel 0 geführt.
- **Episodenzuordnung:** Dateimuster wie `S01E02` oder `1x02` ordnen Dateien der Episode zu; Mehrfach-Episoden (`S01E01E02`) werden unterstützt.
- **Episodenreihenfolge:** Serien können in Aired- oder DVD-Reihenfolge geführt werden (Episode Ordering).
- **Bearbeiten:** *Edit TV Show*, *Edit Season* und *Edit Episode* öffnen eigene Bearbeitungsdialoge je Ebene; *TV Change Episode* erlaubt das Verschieben von Episoden.
- **Scraping:** *(Re)Scrape Show*, *(Re)Scrape Season* und *(Re)Scrape Episode* je Ebene; fehlende Episoden können als „Missing Episodes" angezeigt werden.
- **Bilder/Trailer/Themes:** je Ebene eigene Artwork-Typen inkl. CharacterArt/ClearLogo auf Serienebene.

## Beispiele

- Neue Staffel: Staffelordner in die Serienquelle kopieren → *Reload All TV Shows* → Staffel und Episoden erscheinen in der Hierarchie.
- Falsch zugeordnete Episode: *Edit Episode* öffnen und Staffel-/Episodennummer korrigieren oder *TV Change Episode* nutzen.
- Staffelposter setzen: Staffel wählen → im Bildbereich Poster aus Scraper-Ergebnis oder Datei setzen.

## Einschränkungen

- Episodendateien ohne erkennbares Staffel-/Episodenmuster werden nicht zugeordnet — Dateimuster müssen den konfigurierten Regex-Profilen entsprechen.
- Staffel-/Episodeninhalte hängen vom gewählten Serien-Scraper ab (TheTVDB/TMDb/IMDb) und dessen Datenlage.
- Gesperrte Serien/Staffeln/Episoden (*Lock*) werden nicht verändert.
