# Creates or updates every label in .github/labels.json on the GitHub repository.
# Labels not in the file are left alone; delete those by hand, because removing a label strips it
# from every issue that carries it.
#
# Requires: gh, logged in with write access to the repository.

param(
    [string]$Repo = 'vbc-proteomics-org/ProteomicsSoftwareIssueTracker'
)

$ErrorActionPreference = 'Stop'

$labelsPath = Join-Path $PSScriptRoot '../.github/labels.json'
$labels = Get-Content -Raw $labelsPath | ConvertFrom-Json

foreach ($label in $labels) {
    gh label create $label.name --repo $Repo --color $label.color --description $label.description --force
    if ($LASTEXITCODE -ne 0) { throw "Failed on label '$($label.name)'" }
}

Write-Host "Synced $($labels.Count) labels to $Repo"
