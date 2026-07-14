#Requires -Version 5.1
<#
.SYNOPSIS
  Starts shared Docker infra (Postgres 17, Redis, RabbitMQ, optional Mongo).
#>
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$HubRoot = Resolve-Path (Join-Path $ScriptDir "..\..\..")
$ComposeFile = Join-Path $ScriptDir "docker-compose.yml"
$ProjectYaml = Join-Path $HubRoot "project.yaml"

Write-Host "==> Hub root: $HubRoot"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Write-Error "Docker not found. Install Docker Desktop."
}

$mongoEnabled = $false
if (Test-Path $ProjectYaml) {
  $raw = Get-Content $ProjectYaml -Raw
  if ($raw -match 'mongodb:\s*\r?\n(?:\s+[^\r\n]+\r?\n)*?\s+enabled:\s*true') {
    $mongoEnabled = $true
  }
}

$profiles = @()
if ($mongoEnabled) {
  $profiles += "--profile"
  $profiles += "mongo"
  Write-Host "==> MongoDB profile enabled (project.yaml)"
}

Write-Host "==> docker compose up -d"
& docker compose -f $ComposeFile @profiles up -d
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "==> Waiting for health..."
Start-Sleep -Seconds 5
& docker compose -f $ComposeFile ps

Write-Host ""
Write-Host "Ports (default):"
Write-Host "  PostgreSQL  localhost:5432  (platform/platform)"
Write-Host "  Redis       localhost:6379"
Write-Host "  RabbitMQ    localhost:5672  mgmt :15672"
if ($mongoEnabled) { Write-Host "  MongoDB     localhost:27017" }

Write-Host ""
Write-Host "Optional app processes (scaffolds):"
Write-Host "  service-example: cd scaffolds\service-example && make run"
Write-Host "  ui-example:      cd scaffolds\ui-example && yarn dev"

# Optionally start scaffold apps if present and START_APPS=1
if ($env:START_APPS -eq "1") {
  $svc = Join-Path $HubRoot "scaffolds\service-example"
  $ui = Join-Path $HubRoot "scaffolds\ui-example"
  if (Test-Path (Join-Path $svc "Makefile")) {
    Write-Host "==> Starting service-example in new window"
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$svc'; make run"
  }
  if (Test-Path (Join-Path $ui "package.json")) {
    Write-Host "==> Starting ui-example in new window"
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$ui'; yarn dev"
  }
}

Write-Host "==> Done."
