← [Back to overview](index.md)

# Trakt.tv — Setup

## Purpose

The connection to the Trakt.tv account is authorized once; afterwards the sync functions are available in the menu and the context menus.

## Settings

| Setting | Meaning |
|---------|---------|
| Account authorization | PIN/OAuth approval of the Trakt account |
| Token | stored after authorization and renewed on expiry |
| Sync options | Which data (watched, lists, ratings) is synchronized |

## Steps

1. Create a Trakt.tv account on trakt.tv (if not already present).
2. In Ember *Edit → Settings...* → enable the Trakt module and open the authorization dialog.
3. Enter the displayed code on trakt.tv and approve the application.
4. Back in Ember: the authorization is confirmed, the token stored.
5. Run the desired sync actions via the *Trakt.tv Manager* (Tools menu).

## Notes

- After successful authorization the Trakt context-menu entries appear on movies, shows, seasons and episodes.
- When the token expires the module renews the sign-in automatically; if that fails, re-authorization is required.
