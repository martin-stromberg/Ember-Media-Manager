← [Zurück zur Übersicht](index.md)

# Kodi-Schnittstelle — Beschreibung

## Zweck

Das Modul *Kodi Interface* hält Ember Media Manager und Kodi-Medienbibliotheken synchron: Nach dem Scannen, Scrapen oder Bearbeiten in Ember können die Änderungen direkt an Kodi-Hosts übertragen werden — Kodi muss seine Bibliothek dafür nicht komplett neu einlesen. Umgekehrt können Informationen aus Kodi (z. B. der Watched-Status) in Ember übernommen werden.

## Funktionsweise

- **Hosts:** Es können mehrere Kodi-Hosts mit Adresse, Port und Zugangsdaten verwaltet werden; jeder Host kann eigene Quellen-Zuordnungen haben (lokaler Ember-Pfad ↔ Kodi-Pfad).
- **Echtzeit-Abgleich:** Das Modul reagiert auf Bearbeitungs-, Scrape- und Löschvorgänge in Ember und meldet sie an Kodi — z. B. Details aktualisieren, Bibliotheks-Scan oder -Clean anstoßen, Einträge entfernen.
- **Bidirektional:** Inhalte können von Ember nach Kodi geschrieben und Kodi-Bibliotheksdaten (inkl. Wiedergabestatus) zurückgelesen werden.
- **Benachrichtigungen:** Kodi sendet Ereignisse (z. B. Scan/Clean abgeschlossen), die das Modul auswertet.

## Beispiele

- Film in Ember gescrapt → Änderung wird automatisch an den konfigurierten Kodi-Host gemeldet, ohne dass in Kodi manuell aktualisiert werden muss.
- Auf einem anderen Gerät gesehene Folge → Watched-Status kann von Kodi nach Ember synchronisiert werden.
- Mehrere Kodi-Clients (Wohnzimmer, Schlafzimmer) → ein Host pro Gerät anlegen und synchron halten.

## Einschränkungen

- Der Kodi-Host muss per Netzwerk erreichbar sein und die Fernsteuerung (HTTP/WebSocket) muss in Kodi aktiviert sein.
- Die Pfad-Zuordnung ist erforderlich, wenn Ember und Kodi die Medien über unterschiedliche Pfade sehen (lokal vs. Netzwerkfreigabe).
- In Ember noch nicht gescrapte Inhalte können nicht sinnvoll an Kodi gemeldet werden — erst scrapen, dann synchronisieren.
