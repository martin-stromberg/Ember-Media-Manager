# CI/CD & Git Hooks

The repository ships a two-layer quality-and-release system: local Git hooks that catch localization and dependency problems before code leaves a developer machine, and a GitHub Actions workflow set that validates every pull request, produces release candidates on `staging`, and automates the promotion and release flow to `master`.

## Contents

- [Description](beschreibung.md)
- [Technical flow](ablauf-technisch.md)
- [API](api.md)
- [Installation & Configuration](installation.md)
- [Architecture](architektur.md)
- [Business Rules](business-rules.md)
- [Troubleshooting](troubleshooting.md)
