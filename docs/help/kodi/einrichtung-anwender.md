← [Back to overview](index.md)

# Kodi Interface — Setup

## Purpose

For the module to synchronize, remote control must be enabled in Kodi and the hosts including path mapping must be configured in Ember.

## Settings

| Setting | Meaning |
|---------|---------|
| Host address and port | Network address of the Kodi installation (default port of the Kodi web interface) |
| Username/password | Credentials of the Kodi remote control |
| Source path mapping | Translation of local Ember paths into Kodi paths (e.g. `D:\Movies` → `smb://nas/movies`) |
| Synchronization options | Which events are reported to Kodi (edit, scrape, remove) |

## Steps

1. In Kodi under *Settings → Services → Control* enable *Allow remote control via HTTP* and *Allow remote control from applications* and note username/password if set.
2. In Ember open *Edit → Settings...* and open the Kodi interface module's section.
3. Enable the module and enter address, port and credentials of the Kodi host via the host dialog (*Host*).
4. Configure the path mapping for the sources if Kodi reaches the files via different paths than Ember.
5. Test the connection: change an entry and check whether it arrives in Kodi.

## Notes

- With multiple Kodi installations create one host per device.
- On password errors or an unreachable host the module reports errors in the error log; the Ember library is unaffected.
