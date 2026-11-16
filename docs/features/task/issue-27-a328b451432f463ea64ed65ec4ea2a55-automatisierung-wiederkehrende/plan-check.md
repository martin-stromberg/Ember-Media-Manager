# Planprüfung: Wiederkehrende Review-Issues

## Ergebnis

**Status:** Plan vollständig

## Abgleich Anforderung ↔ Planelemente

| Anforderung | Abdeckung |
|-------------|-----------|
| Separate GitHub Action je Prüfung | Drei eigene Workflow-Dateien geplant |
| Cron-Trigger | Monatlich, wöchentlich und jährlich mit konkreten UTC-Cron-Ausdrücken geplant |
| Aussagekräftige Issue-Titel | Feste, typbezogene Titel pro Workflow geplant |
| `@softwarewerkstatt` erwähnen | Erste Zeile jeder versionierten Issue-Vorlage |
| Duplikatprüfung offener Issues | Typ-Label plus `gh issue list --state open --label` vor `gh issue create` |
| Repository-interne Dokumentation | Neue CI/CD-Dokumentationsseite plus Updates vorhandener Doku- und Release-Dateien |
| Keine zusätzlichen Secrets | Standard-`github.token` mit minimalen Permissions geplant |
| Keine inhaltliche Review-Ausführung | Explizit als Nicht-Ziel dokumentiert |

## Abhängigkeitsprüfung

Die geplanten Schritte sind sequentiell konsistent: erst gemeinsames Skript und Vorlagen, dann die drei Workflow-Aufrufer, danach Dokumentation und Verifikation. Es gibt keine Zyklen oder unbekannten externen Abhängigkeiten.

## Fehlende oder unvollständige Punkte

Keine.

## Hinweise

- Die konkreten Cron-Uhrzeiten sind innerhalb der geforderten Intervalle frei wählbar und wurden bewusst gestreut, um Lastspitzen zu vermeiden.
- Label-basierte Duplikatprüfung ist robuster als eine Titelsuche, weil spätere Titelergänzungen den Typ nicht verändern.
- Ein echter Scheduled-Run kann erst nach Erreichen des Default-Branchs beobachtet werden; lokale Verifikation bleibt auf Syntax und Review beschränkt.
