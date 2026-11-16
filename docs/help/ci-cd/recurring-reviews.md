← [Back to overview](index.md)

# CI/CD & Git Hooks — Recurring review issues

## Purpose

Three scheduled GitHub Actions create recurring review issues and mention `@softwarewerkstatt` so the configured account can start the requested analysis automatically. The workflows only create the assignment issue; they do not perform the architecture, dependency or compliance review themselves.

## Workflows

| Workflow file | Schedule (UTC) | Duplicate label | Issue title | Body template |
|---------------|----------------|-----------------|-------------|---------------|
| `.github/workflows/monthly-architecture-security-review.yml` | `0 6 1 * *` — first day of every month, 06:00 | `automated-review-architecture-security` | `Monatliches Architektur- und Sicherheitsreview` | `.github/recurring-issues/architecture-security-review.md` |
| `.github/workflows/weekly-nuget-review.yml` | `0 5 * * 1` — every Monday, 05:00 | `automated-review-nuget` | `Wöchentliche NuGet-Paketprüfung` | `.github/recurring-issues/nuget-review.md` |
| `.github/workflows/yearly-compliance-review.yml` | `0 7 1 1 *` — every January 1, 07:00 | `automated-review-compliance` | `Jährliches Compliance- und Copyright-Review` | `.github/recurring-issues/compliance-review.md` |

Each workflow also supports `workflow_dispatch` for a controlled manual run.

## How issue creation works

All three workflows call `scripts/New-RecurringIssue.ps1` with their own label, title and body template:

1. `actions/checkout` provides the script and the versioned Markdown body template.
2. `gh label create --force` creates the review-type label if it does not exist yet.
3. `gh issue list --state open --label <label> --limit 1` checks for an open issue of that type.
4. If an open issue exists, the run ends successfully without creating a duplicate.
5. Otherwise `gh issue create` creates the issue with the configured title, label and body. The first body line is always `@softwarewerkstatt`.

The label — not the issue title — is the stable duplicate key. Closed issues from earlier cycles do not block the next cycle. Each workflow has its own `concurrency` group with `cancel-in-progress: false`, so simultaneous scheduled and manual runs are serialized and the duplicate check remains effective.

## Permissions

The workflows use only the built-in `github.token` as `GH_TOKEN`:

- `contents: read` for the checkout of script and body templates.
- `issues: write` for labels and issue creation.

No additional secret or GitHub App is required.

## Activation and limitations

GitHub runs scheduled workflows only from the repository's default branch (`master`). The actions become active after the workflow files reach `master`; a merge to `staging` alone does not start the schedules. Manual `workflow_dispatch` runs are also evaluated from the branch selected in the GitHub UI, so they can be used to test the workflow once it exists there.

If the GitHub API rejects the label, search or create call, the PowerShell script fails the job visibly instead of silently skipping the cycle.
