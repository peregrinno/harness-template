#Requires -Version 5.1
<#
.SYNOPSIS
  Starts local runtime according to project.yaml.
  Apps are preferred from sibling ../repos/<name>; scaffolds are fallback only.
#>
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$HubRoot = Resolve-Path (Join-Path $ScriptDir "..\..\..")
$WorkspaceRoot = Split-Path -Parent $HubRoot.Path
$ComposeFile = Join-Path $ScriptDir "docker-compose.yml"
$ProjectYaml = Join-Path $HubRoot "project.yaml"

function Get-YamlScalar([string]$Raw, [string]$Key, [string]$Default) {
  if ($Raw -match "(?m)^\s*${Key}:\s*[""']?([^""'#\r\n]+)") {
    return $Matches[1].Trim().Trim('"').Trim("'")
  }
  return $Default
}

function Test-TcpPort([string]$HostName, [int]$Port, [int]$TimeoutMs = 800) {
  try {
    $client = New-Object System.Net.Sockets.TcpClient
    $async = $client.BeginConnect($HostName, $Port, $null, $null)
    $ok = $async.AsyncWaitHandle.WaitOne($TimeoutMs, $false)
    if (-not $ok) { $client.Close(); return $false }
    $client.EndConnect($async)
    $client.Close()
    return $true
  } catch {
    return $false
  }
}

function Resolve-AppPath([string]$RepoName, [string]$ScaffoldRel, [string]$YamlRaw) {
  $reposDirname = "repos"
  if ($YamlRaw -match '(?m)^\s*repos_dirname:\s*"?([A-Za-z0-9_\-]+)"?') {
    $reposDirname = $Matches[1]
  }
  $fromRepos = Join-Path (Join-Path $WorkspaceRoot $reposDirname) $RepoName
  if (Test-Path $fromRepos) { return $fromRepos }
  $fromScaffold = Join-Path $HubRoot $ScaffoldRel
  if (Test-Path $fromScaffold) { return $fromScaffold }
  return $null
}

Write-Host "==> Hub root: $HubRoot"
Write-Host "==> Workspace root: $WorkspaceRoot"

$raw = ""
if (Test-Path $ProjectYaml) { $raw = Get-Content $ProjectYaml -Raw }

$localMode = Get-YamlScalar $raw "local_mode" "bundled_infra"
$startApps = (Get-YamlScalar $raw "start_apps" "true") -match "^(true|1|yes)$"
$skipIfHealthy = (Get-YamlScalar $raw "skip_infra_if_ports_healthy" "true") -match "^(true|1|yes)$"
$mongoEnabled = $raw -match 'mongodb:\s*\r?\n(?:\s+[^\r\n]+\r?\n)*?\s+enabled:\s*true'
$pgHost = "localhost"
$pgPort = 5432
$redisPort = 6379
$rabbitPort = 5672
$mongoPort = 27017
if ($raw -match '(?ms)postgresql:.*?port:\s*(\d+)') { $pgPort = [int]$Matches[1] }
if ($raw -match '(?ms)redis:.*?port:\s*(\d+)') { $redisPort = [int]$Matches[1] }
if ($raw -match '(?ms)rabbitmq:.*?port:\s*(\d+)') { $rabbitPort = [int]$Matches[1] }
if ($raw -match '(?ms)mongodb:.*?port:\s*(\d+)') { $mongoPort = [int]$Matches[1] }

Write-Host "==> runtime.local_mode = $localMode"

function Show-Ports {
  Write-Host ""
  Write-Host "Expected dependency ports:"
  Write-Host "  PostgreSQL  ${pgHost}:${pgPort}"
  Write-Host "  Redis       ${pgHost}:${redisPort}"
  Write-Host "  RabbitMQ    ${pgHost}:${rabbitPort}"
  if ($mongoEnabled) { Write-Host "  MongoDB     ${pgHost}:${mongoPort}" }
}

function Assert-ExternalHealthy {
  $failures = @()
  if (-not (Test-TcpPort "localhost" $pgPort)) { $failures += "postgres:$pgPort" }
  if (-not (Test-TcpPort "localhost" $redisPort)) { $failures += "redis:$redisPort" }
  if (-not (Test-TcpPort "localhost" $rabbitPort)) { $failures += "rabbitmq:$rabbitPort" }
  if ($mongoEnabled -and -not (Test-TcpPort "localhost" $mongoPort)) { $failures += "mongo:$mongoPort" }
  if ($failures.Count -gt 0) {
    Write-Error ("external_infra mode but ports not listening: " + ($failures -join ", ") + ". Start them or set runtime.local_mode: bundled_infra")
  }
  Write-Host "==> External infra ports look healthy"
}

function Start-BundledInfra {
  if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker not found. Install Docker Desktop or switch to runtime.local_mode: external_infra"
  }

  $already = (Test-TcpPort "localhost" $pgPort) -and (Test-TcpPort "localhost" $redisPort) -and (Test-TcpPort "localhost" $rabbitPort)
  if ($mongoEnabled) { $already = $already -and (Test-TcpPort "localhost" $mongoPort) }

  if ($skipIfHealthy -and $already) {
    Write-Host "==> Dependency ports already healthy - skipping docker compose"
    return
  }

  $profiles = @("--profile", "infra")
  if ($mongoEnabled) {
    $profiles += @("--profile", "mongo")
    Write-Host "==> MongoDB profile enabled"
  }

  Write-Host "==> docker compose --profile infra up -d"
  & docker compose -f $ComposeFile @profiles up -d
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  Start-Sleep -Seconds 5
  & docker compose -f $ComposeFile ps
}

function Start-Apps {
  if (-not $startApps) {
    Write-Host "==> start_apps=false - not launching app windows"
    Write-Host "    Prefer: cd ..\repos\service-example && make run"
    Write-Host "            cd ..\repos\ui-example && yarn dev"
    return
  }

  $svc = Resolve-AppPath -RepoName "service-example" -ScaffoldRel "scaffolds\service-example" -YamlRaw $raw
  $ui = Resolve-AppPath -RepoName "ui-example" -ScaffoldRel "scaffolds\ui-example" -YamlRaw $raw

  if ($svc -and (Test-Path (Join-Path $svc "Makefile"))) {
    Write-Host "==> Starting service-example from $svc"
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$svc'; make run"
  } else {
    Write-Host "==> service-example not found under repos/ or scaffolds/"
  }

  if ($ui -and (Test-Path (Join-Path $ui "package.json"))) {
    Write-Host "==> Starting ui-example from $ui"
    # node_modules is not copied from scaffolds; install on first run if next is missing
    $uiBoot = @"
cd '$ui'
if (-not (Test-Path 'node_modules\.bin\next.cmd') -and -not (Test-Path 'node_modules\.bin\next')) {
  Write-Host '==> node_modules missing - running yarn install...'
  yarn install
  if (`$LASTEXITCODE -ne 0) { Write-Error 'yarn install failed'; exit 1 }
}
yarn dev
"@
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $uiBoot
  } else {
    Write-Host "==> ui-example not found under repos/ or scaffolds/"
  }
}

switch ($localMode) {
  "external_infra" {
    Assert-ExternalHealthy
    Show-Ports
    Start-Apps
  }
  "bundled_infra" {
    Start-BundledInfra
    Show-Ports
    Start-Apps
  }
  default {
    Write-Error "Unknown runtime.local_mode '$localMode'. Use external_infra or bundled_infra."
  }
}

Write-Host "==> Done. Product code lives in ../repos/; hub only orchestrates."
