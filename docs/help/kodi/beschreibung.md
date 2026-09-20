← [Back to overview](index.md)

# Kodi Interface — Description

## Purpose

The *Kodi Interface* module keeps Ember Media Manager and Kodi media libraries in sync: after scanning, scraping or editing in Ember the changes can be pushed directly to Kodi hosts — Kodi does not have to re-read its entire library. Conversely, information from Kodi (e.g. watched state) can be taken back into Ember.

## How it works

- **Hosts:** Several Kodi hosts with address, port and credentials can be managed; each host can have its own source mappings (local Ember path ↔ Kodi path).
- **Real-time sync:** The module reacts to edit, scrape and delete operations in Ember and reports them to Kodi — e.g. update details, trigger library scan or clean, remove entries.
- **Bidirectional:** Content can be written from Ember to Kodi and Kodi library data (including play state) read back.
- **Notifications:** Kodi sends events (e.g. scan/clean finished) which the module evaluates.

## Examples

- Movie scraped in Ember → the change is automatically reported to the configured Kodi host without a manual update in Kodi.
- Episode watched on another device → watched state can be synced from Kodi to Ember.
- Several Kodi clients (living room, bedroom) → create one host per device and keep them in sync.

## Limitations

- The Kodi host must be reachable over the network and remote control (HTTP/WebSocket) must be enabled in Kodi.
- Path mapping is required when Ember and Kodi see the media via different paths (local vs. network share).
- Content not yet scraped in Ember cannot be meaningfully reported to Kodi — scrape first, then sync.
