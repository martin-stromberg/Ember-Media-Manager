<#
.SYNOPSIS
    Creates a recurring GitHub issue unless an open issue of the same type exists.

.DESCRIPTION
    Ensures the configured label exists, searches for an open issue carrying that
    label, and creates a new issue from the supplied body template only when no
    open issue was found. The label is the stable duplicate key for the review
    type; closed issues from earlier cycles do not block the next issue.

.PARAMETER Repository
    Repository in owner/name form.

.PARAMETER Label
    Label used to identify the recurring issue type.

.PARAMETER LabelColor
    Hex color for the label when it has to be created.

.PARAMETER LabelDescription
    Description for the label when it has to be created.

.PARAMETER Title
    Title of the issue to create.

.PARAMETER BodyFile
    Markdown file whose contents become the issue body.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Repository,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Label,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$LabelColor,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$LabelDescription,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Title,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$BodyFile
)

$ErrorActionPreference = 'Stop'

function Invoke-Gh {
    param(
        [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )

    $output = & gh @Arguments 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) {
        throw "gh $($Arguments -join ' ') failed: $($output.Trim())"
    }

    return $output.Trim()
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI 'gh' is required."
}

if (-not (Test-Path -LiteralPath $BodyFile -PathType Leaf)) {
    throw "Issue body template '$BodyFile' does not exist."
}

if ([string]::IsNullOrWhiteSpace((Get-Content -LiteralPath $BodyFile -Raw))) {
    throw "Issue body template '$BodyFile' is empty."
}

Invoke-Gh label create $Label --repo $Repository --color $LabelColor --description $LabelDescription --force | Out-Null

$openIssuesJson = Invoke-Gh issue list --repo $Repository --state open --label $Label --limit 1 --json 'number,url'
$openIssues = @($openIssuesJson | ConvertFrom-Json)

if ($openIssues.Count -gt 0) {
    Write-Host "Open issue #$($openIssues[0].number) already exists for label '$Label' ($($openIssues[0].url)). Skipping creation."
    exit 0
}

$createdIssue = Invoke-Gh issue create --repo $Repository --title $Title --label $Label --body-file $BodyFile
Write-Host "Created recurring issue for label '$Label': $createdIssue"
