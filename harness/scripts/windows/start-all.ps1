#Requires -Version 5.1
<#
.SYNOPSIS
  Starts local runtime according to project.yaml:
    - bundled_infra  → docker compose for Postgres/Redis/Rabbit(+Mongo) then optional apps
    - external_infra → skip compose; assume deps already listening; start optional apps
#>
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$HubRoot = Resolve-Path (Join-Path $ScriptDir "..\..\..")
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

Write-Host "==> Hub root: $HubRoot"

$raw = ""
if (Test-Path $ProjectYaml) { $raw = Get-Content $ProjectYaml -Raw }

$localMode = Get-YamlScalar $raw "local_mode" "bundled_infra"
$startApps = (Get-YamlScalar $raw "start_apps" "true") -match "^(true|1|yes)$"
$skipIfHealthy = (Get-YamlScalar $raw "skip_infra_if_ports_healthy" "true") -match "^(true|1|yes)$"
$mongoEnabled = $raw -match 'mongodb:\s*\r?\n(?:\s+[^\r\n]+\r?\n)*?\s+enabled:\s*true'
$pgHost = Get-YamlScalar $raw "host" "localhost"
# Prefer nested defaults from known ports if scalar Host matched wrong block — use fixed defaults:
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
    Write-Host "==> Dependency ports already healthy — skipping docker compose"
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
    Write-Host "==> start_apps=false — not launching service/UI windows"
    Write-Host "    service-example: cd scaffolds\service-example && make run"
    Write-Host "    ui-example:      cd scaffolds\ui-example && yarn dev"
    return
  }
  $svc = Join-Path $HubRoot "scaffolds\service-example"
  $ui = Join-Path $HubRoot "scaffolds\ui-example"
  if (Test-Path (Join-Path $svc "Makefile")) {
    Write-Host "==> Starting service-example"
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$svc'; make run"
  }
  if (Test-Path (Join-Path $ui "package.json")) {
    Write-Host "==> Starting ui-example"
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$ui'; yarn dev"
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

Write-Host "==> Done. Agents must reuse these ports — do not spawn duplicate infra."
