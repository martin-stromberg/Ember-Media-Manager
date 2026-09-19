← [Zurück zur Übersicht](index.md)

# Kodi-Schnittstelle — API

## Übersicht

Die Schnittstelle besteht aus zwei Ebenen: der generierten C#-Clientbibliothek `XBMCRPC` (`KodiAPI/KodiAPI.csproj`, Namespace `XBMCRPC`) und dem VB-Modul `generic.Interface.Kodi`, das den Client für die Ember-Synchronisation nutzt. Die Kommunikation läuft über Kodi JSON-RPC (HTTP) plus WebSocket für Notifications.

## Authentifizierung

HTTP-Basic-Auth mit den in Kodi hinterlegten Zugangsdaten (`ConnectionSettings`: Host, Port, UserName, Password).

## Genutzte RPC-Methodengruppen (`XBMCRPC/Methods/*`)

### `VideoLibrary` (Bibliothek)

| Methode | Zweck |
|---------|-------|
| `GetMovies` / `GetMovieDetails` / `SetMovieDetails` / `RemoveMovie` | Filme lesen/schreiben/entfernen |
| `GetMovieSets` / `GetMovieSetDetails` / `SetMovieSetDetails` | Filmsammlungen |
| `GetTVShows` / `GetTVShowDetails` / `SetTVShowDetails` / `RemoveTVShow` | Serien |
| `GetSeasons` / `GetSeasonDetails` / `SetSeasonDetails` | Staffeln |
| `GetEpisodes` / `GetEpisodeDetails` / `SetEpisodeDetails` / `RemoveEpisode` | Episoden |
| `Scan` / `Clean` | Bibliotheks-Scan/-Bereinigung anstoßen |

### `Files` (Dateisystem/Quellen)

| Methode | Zweck |
|---------|-------|
| `GetSources` | Kodi-Quellen abrufen (Pfad-Mapping) |
| `GetDirectory` | Verzeichnisinhalte lesen |
| `PrepareDownload` | Download-URL für Artwork erzeugen |
| `AllFields` | Feldselektion |

### `Textures` (Artwork-Cache)

| Methode | Zweck |
|---------|-------|
| `GetTextures` / `RemoveTexture` | Artwork-Cache lesen/bereinigen |
| `url` | Texture-URL |

### `Player` (Wiedergabe)

| Methode | Zweck |
|---------|-------|
| `GetActivePlayers` | aktive Wiedergabe ermitteln |

### Weitere verfügbare Gruppen (generiert, nicht zwingend genutzt)

`Addons`, `Application`, `AudioLibrary`, `Favourites`, `GUI`, `Input`, `JSONRPC`, `PVR`, `Playlist`, `Profiles`, `Settings`, `System`, `XBMC`

## Eigene Client-Erweiterungen (`KodiAPI/Client.cs`)

| Methode | Zweck |
|---------|-------|
| `GetImageStream(thumbnailUri)` | Thumbnail als Stream laden |
| `GetImageUri(thumbnailUri)` | Download-URI auflösen (`image:`-Referenzen) |

## Notifications (WebSocket)

| Event | Verarbeitung |
|-------|--------------|
| `VideoLibrary.OnScanFinished` | `VideoLibrary_OnScanFinished` — Nachlauf nach Kodi-Scan |
| `VideoLibrary.OnCleanFinished` | `VideoLibrary_OnCleanFinished` — Nachlauf nach Kodi-Clean |

## Fehler

| Code / Exception | Ursache |
|------------------|---------|
| RPC-Fehler/Timeout | Host nicht erreichbar, falsche Credentials |
| Element ohne Kodi-ID | Eintrag existiert in Kodi-Bibliothek nicht → Bibliotheks-Scan erforderlich („Please Scrape In Ember First!") |
