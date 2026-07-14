#Requires -Version 5.1
<#
.SYNOPSIS
  Copies scaffolds into sibling ../repos/, creates GitHub polyrepos, pushes develop/stage/master.
#>
param(
  [string]$Org = "",
  [switch]$Private = $true
)

$ErrorActionPreference = "Stop"
$HubRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..\..")
$WorkspaceRoot = Split-Path -Parent $HubRoot.Path
$ProjectYaml = Join-Path $HubRoot "project.yaml"

$reposDirname = "repos"
if (Test-Path $ProjectYaml) {
  $raw = Get-Content $ProjectYaml -Raw
  if ($raw -match '(?m)^\s*repos_dirname:\s*"?([A-Za-z0-9_\-]+)"?') {
    $reposDirname = $Matches[1]
  }
}

$ReposRoot = Join-Path $WorkspaceRoot $reposDirname
New-Item -ItemType Directory -Force -Path $ReposRoot | Out-Null
Set-Location $HubRoot

if (-not $Org) {
  Write-Error "Pass -Org your-github-org"
}

function Publish-Repo([string]$Name, [string]$ScaffoldRel) {
  $scaffold = Join-Path $HubRoot $ScaffoldRel
  if (-not (Test-Path $scaffold)) { Write-Error "Missing scaffold: $scaffold" }

  $dest = Join-Path $ReposRoot $Name
  if (-not (Test-Path $dest)) {
    Write-Host "==> Copying $ScaffoldRel -> $dest"
    Copy-Item -Path $scaffold -Destination $dest -Recurse -Force
  }

  $visibility = if ($Private) { "--private" } else { "--public" }
  Write-Host "==> Publishing $Org/$Name from $dest"
  Push-Location $dest
  if (-not (Test-Path .git)) {
    git init
    git checkout -b develop
    git add .
    git commit -m "001-initial-scaffold"
  }
  gh repo create "$Org/$Name" $visibility --source=. --remote=origin --push
  git branch stage 2>$null
  git branch master 2>$null
  git push -u origin develop
  git push origin stage 2>$null
  git push origin master 2>$null
  Pop-Location
}

Publish-Repo -Name "service-example" -ScaffoldRel "scaffolds\service-example"
Publish-Repo -Name "ui-example" -ScaffoldRel "scaffolds\ui-example"

Write-Host "Update project.yaml paths to ../repos/<name> and set remotes to the new GitHub URLs."
Write-Host "Canonical layout: $WorkspaceRoot\$($HubRoot.Path | Split-Path -Leaf) + $ReposRoot"
