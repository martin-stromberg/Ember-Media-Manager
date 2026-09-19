← [Zurück zur Übersicht](index.md)

# Datenbank — Beschreibung

## Zweck

Die lokale SQLite-Datenbank hält den kompletten Bibliotheksstand: Filme, Filmsammlungen, Serien, Staffeln, Episoden samt allen verknüpften Daten (Personen, Genres, Studios, Länder, Bewertungen, Artwork, Tags, externe IDs, Datei- und Stream-Informationen, Quellverzeichnisse). Die Tabellen folgen der Kodi-Namenskonvention (`MyVideos`), damit bleibt die Bibliothek zu Kodi-kompatiblen Strukturen abbildbar.

## Funktionsweise

- **Datei:** `MyVideos{Profil}.emm` im Profilverzeichnis; Zugriff ausschließlich über die Klasse `Database` (`System.Data.SQLite`).
- **Schema:** Initialschema in `MyVideosDBSQL.txt`; Weiterentwicklung über nummerierte Patch-Dateien (`MyVideosDBSQL_v2` … `v47`), die beim Öffnen der Datenbank angewendet werden.
- **Transaktionen:** Batch-Operationen (Scan, Multi-Scrape) laufen transaktional (`CommandsTransaction`), Einzelaktionen direkt (`CommandsNoTransaction`).
- **Flags:** Einträge tragen Status wie New, Marked, Lock sowie Quell- und Dateiverweise.
- **Bereinigung:** Aufräumfunktionen entfernen verwaiste Einträge (fehlende Dateien, leere Staffeln, ungenutzte Genres/Studios/Länder).

## Einschränkungen

- Die Datenbank ist nicht für direkten externen Schreibzugriff vorgesehen; Änderungen gehören über die Anwendung.
- Ein Schema-Upgrade ist unidirektional — Backups der `.emm`-Datei vor Versionswechseln sind sinnvoll.
- Bei beschädigter Datenbank hilft nur Backup-Rücksicherung oder Neuaufbau per Scan.
