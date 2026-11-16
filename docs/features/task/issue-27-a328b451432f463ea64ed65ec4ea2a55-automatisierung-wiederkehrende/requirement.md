# Übersetzte Anforderung: Wiederkehrende Architektur-, Sicherheits- und Compliance-Reviews (Issue #27)

## Fachliche Zusammenfassung

Das Repository soll drei eigenständige, zeitgesteuerte GitHub Actions erhalten. Jede Aktion erzeugt bei Fälligkeit ein GitHub Issue mit einem aussagekräftigen Titel und dem vorgesehenen Prüfauftrag. Jeder Issue-Text beginnt mit der Erwähnung `@softwarewerkstatt`, damit der Account die Analyse und Bearbeitung automatisch starten kann. Vor dem Anlegen prüft jede Aktion, ob bereits ein offenes Issue desselben Review-Typs existiert; in diesem Fall wird kein Duplikat erzeugt.

## Betroffene Bereiche

- `.github/workflows/` — drei neue Workflow-Dateien, jeweils mit `schedule`-Trigger.
- Repository-Skripte bzw. Vorlagen für die gemeinsame Issue-Erstellung und Issue-Texte.
- `docs/help/ci-cd/`, `README.md` und `docs/RELEASE_NOTES.md` — Dokumentation der neuen Automatisierung.

Keine Anwendungslogik, UI-Komponenten, Datenmodelle oder NuGet-Projektdateien werden geändert.

## Fachliche Anforderungen

### 1. Monatliches Architektur- und Sicherheitsreview

- Intervall: am ersten Tag jedes Monats.
- Issue-Text: beginnt mit `@softwarewerkstatt` und fordert ein Architektur- und Sicherheitsreview an.
- Prüfpunkte: neue Sicherheitsrisiken in Frameworks/Bibliotheken, CVEs in NuGet-Abhängigkeiten, Empfehlungen für ASP.NET Core/Blazor/.NET/verwandte Technologien, Authentifizierung/Autorisierung, Design Patterns, veraltete APIs, Wartbarkeit/Erweiterbarkeit/Testbarkeit, Logging/Telemetrie/Monitoring sowie Community-, Microsoft- und Sicherheitsmeldungen.
- Ergebnisauftrag: priorisierte Liste konkreter Handlungsempfehlungen.

### 2. Wöchentliche NuGet-Prüfung

- Intervall: wöchentlich.
- Issue-Text: beginnt mit `@softwarewerkstatt` und fordert die Analyse aller verwendeten NuGet-Pakete an.
- Prüfpunkte: verfügbare Updates, Security-Updates, bekannte Schwachstellen, veraltete/ungepflegte Pakete, Nachfolgepakete und mögliche Breaking Changes.
- Ergebnisauftrag: konkrete Update-Empfehlungen mit Risikobewertung; unbedenkliche Empfehlungen sollen direkt als Pull Request umgesetzt werden, risikoreiche/aufgeschobene Punkte im PR-Body oder Folge-Issue dokumentiert werden.

### 3. Jährliches Compliance- und Copyright-Review

- Intervall: jährlich am 1. Januar.
- Issue-Text: beginnt mit `@softwarewerkstatt` und fordert das jährliche Compliance-Review an.
- Prüfpunkte: Copyright-Hinweise im Quellcode, auf Webseiten und in About-Dialogen, Impressum, Datenschutzerklärung, Drittanbieter-Lizenzen, Open-Source-Verpflichtungen, Unternehmens-/Kontaktinformationen und App-Store-Metadaten, sofern vorhanden.
- Ergebnisauftrag: konkrete Änderungsvorschläge sowie Liste erkannter Risiken oder Handlungsbedarfe.

## Duplikatvermeidung

Vor dem Anlegen eines Issues muss geprüft werden, ob aktuell ein offenes Issue desselben Typs existiert. Existiert eines, endet der Workflow erfolgreich ohne neue Issue-Erstellung. Geschlossene Issues früherer Zyklen blockieren die nächste Erstellung nicht.

## Konfiguration und Berechtigungen

- Auslösung jeweils per Cron-Trigger (`schedule`); `workflow_dispatch` ist als manueller Test-/Wartungseinstieg zulässig.
- Es werden keine zusätzlichen Secrets gefordert; der standardmäßige `GITHUB_TOKEN` bzw. `github.token` genügt.
- Die Workflows benötigen `issues: write` zum Anlegen von Issues/Labels und `contents: read` zum Auslesen von Skripten/Vorlagen.
- Die Dokumentation muss das Duplikatkriterium und die GitHub-Einschränkung beschreiben, dass geplante Workflows nur vom Default-Branch ausgeführt werden.

## Explizite Nicht-Ziele

- Die Workflows führen die inhaltlichen Reviews nicht selbst aus; sie erstellen nur die Auftrags-Issues.
- Es werden keine Paket-Updates, Code-Reviews oder Compliance-Änderungen direkt durch diese Automatisierung vorgenommen.
- Es wird keine externe Infrastruktur oder zusätzliche GitHub-App eingerichtet.

## Akzeptanzkriterien

- Für jede der drei Prüfungen existiert eine separate GitHub Action.
- Jede Action ist über einen Cron-Trigger zeitgesteuert.
- Die erzeugten Issues haben aussagekräftige Titel und erwähnen `@softwarewerkstatt`.
- Offene Issues desselben Typs werden vor der Erstellung geprüft und verhindern Duplikate.
- Die Lösung ist vollständig im Repository dokumentiert.

## Offene Fragen

Keine.
