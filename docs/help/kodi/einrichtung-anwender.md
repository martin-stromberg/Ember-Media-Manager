← [Zurück zur Übersicht](index.md)

# Kodi-Schnittstelle — Einrichtung

## Zweck

Damit das Modul synchronisieren kann, müssen in Kodi die Fernsteuerung aktiviert und in Ember die Hosts samt Pfad-Zuordnung hinterlegt werden.

## Einstellungen

| Einstellung | Bedeutung |
|-------------|-----------|
| Host-Adresse und -Port | Netzwerkadresse der Kodi-Installation (Standard-Port der Kodi-Weboberfläche) |
| Benutzername/Passwort | Zugangsdaten der Kodi-Fernsteuerung |
| Quell-Pfad-Zuordnung | Übersetzung lokaler Ember-Pfade in Kodi-Pfade (z. B. `D:\Filme` → `smb://nas/filme`) |
| Synchronisationsoptionen | Welche Ereignisse an Kodi gemeldet werden (Bearbeiten, Scrapen, Entfernen) |

## Vorgehen

1. In Kodi unter *Settings → Services → Control* die Optionen *Allow remote control via HTTP* und *Allow remote control from applications* aktivieren und ggf. Benutzername/Passwort notieren.
2. In Ember *Edit → Settings...* öffnen und den Bereich des Kodi-Interface-Moduls aufrufen.
3. Modul aktivieren und über den Host-Dialog (*Host*) Adresse, Port und Zugangsdaten des Kodi-Hosts eintragen.
4. Die Pfad-Zuordnung für die Quellen hinterlegen, wenn Kodi die Dateien über andere Pfade erreicht als Ember.
5. Verbindung testen: Änderung an einem Eintrag vornehmen und prüfen, ob sie in Kodi ankommt.

## Hinweise

- Bei mehreren Kodi-Installationen je Gerät einen Host anlegen.
- Bei Passwort-Fehlern oder nicht erreichbarem Host meldet das Modul Fehler im Fehlerprotokoll; die Ember-Bibliothek bleibt davon unberührt.
