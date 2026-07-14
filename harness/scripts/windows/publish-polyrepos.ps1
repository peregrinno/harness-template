#Requires -Version 5.1
<#
.SYNOPSIS
  Creates GitHub polyrepos from local scaffolds and pushes initial develop/stage/master.
#>
param(
  [string]$Org = "",
  [switch]$Private = $true
)

$ErrorActionPreference = "Stop"
$HubRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..\..")
Set-Location $HubRoot

if (-not $Org) {
  Write-Error "Pass -Org your-github-org"
}

function Publish-Scaffold([string]$Name, [string]$Path) {
  $full = Join-Path $HubRoot $Path
  if (-not (Test-Path $full)) { Write-Error "Missing scaffold: $full" }

  $visibility = if ($Private) { "--private" } else { "--public" }
  Write-Host "==> Creating $Org/$Name from $Path"
  Push-Location $full
  if (-not (Test-Path .git)) {
    git init
    git checkout -b develop
    git add .
    git commit -m "001-initial-scaffold"
  }
  gh repo create "$Org/$Name" $visibility --source=. --remote=origin --push
  git branch stage
  git branch master
  git push -u origin develop
  git push origin stage
  git push origin master
  Pop-Location
}

Publish-Scaffold -Name "service-example" -Path "scaffolds\service-example"
Publish-Scaffold -Name "ui-example" -Path "scaffolds\ui-example"

Write-Host "Update project.yaml remotes to the new GitHub URLs."
