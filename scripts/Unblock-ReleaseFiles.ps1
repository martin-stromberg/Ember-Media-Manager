<#
.SYNOPSIS
    Entblockt aus einem GitHub-Release heruntergeladene Dateien.

.DESCRIPTION
    Windows versieht Dateien aus dem Internet (z. B. ein entpacktes release.zip)
    mit dem Zone.Identifier (Mark-of-the-Web), wodurch z. B. SmartScreen- oder
    Ausfuehrungswarnungen erscheinen. Dieses Skript entfernt die Blockierung
    rekursiv fuer alle Dateien im Zielverzeichnis.

    Ohne Parameter wird das Verzeichnis entblockt, in dem das Skript liegt.
    Das Skript kann also direkt in den entpackten Release-Ordner kopiert und
    dort ausgefuehrt werden.

.PARAMETER Path
    Optionales Zielverzeichnis. Standard: Verzeichnis dieses Skripts.

.EXAMPLE
    .\Unblock-ReleaseFiles.ps1
    Entblockt alle Dateien im Skriptverzeichnis.

.EXAMPLE
    .\Unblock-ReleaseFiles.ps1 -Path "C:\Tools\Ember Media Manager"
    Entblockt alle Dateien im angegebenen Verzeichnis rekursiv.
#>
[CmdletBinding()]
param(
    [string]$Path = $PSScriptRoot
)

$files = Get-ChildItem -LiteralPath $Path -Recurse -File
$count = 0

foreach ($file in $files) {
    Unblock-File -LiteralPath $file.FullName
    $count++
}

Write-Host "$count Datei(en) in '$Path' entblockt."
