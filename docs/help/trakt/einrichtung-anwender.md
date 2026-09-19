← [Zurück zur Übersicht](index.md)

# Trakt.tv — Einrichtung

## Zweck

Die Verbindung zum Trakt.tv-Konto wird einmalig autorisiert; danach stehen die Sync-Funktionen im Menü und in den Kontextmenüs zur Verfügung.

## Einstellungen

| Einstellung | Bedeutung |
|-------------|-----------|
| Konto-Autorisierung | PIN-/OAuth-Freigabe des Trakt-Kontos |
| Token | wird nach Autorisierung gespeichert und bei Ablauf erneuert |
| Sync-Optionen | Welche Daten (Watched, Listen, Ratings) abgeglichen werden |

## Vorgehen

1. Trakt.tv-Konto auf trakt.tv anlegen (falls noch nicht vorhanden).
2. In Ember *Edit → Settings...* → Trakt-Modul aktivieren und den Autorisierungsdialog öffnen.
3. Den angezeigten Code auf trakt.tv eingeben und die Anwendung freigeben.
4. Zurück in Ember: die Autorisierung wird bestätigt, das Token gespeichert.
5. Über den *Trakt.tv Manager* (Tools-Menü) die gewünschten Sync-Aktionen ausführen.

## Hinweise

- Nach erfolgreicher Autorisierung erscheinen die Trakt-Kontextmenü-Einträge an Filmen, Serien, Staffeln und Episoden.
- Bei abgelaufenem Token erneuert das Modul die Anmeldung automatisch; schlägt dies fehl, ist eine erneute Autorisierung nötig.
