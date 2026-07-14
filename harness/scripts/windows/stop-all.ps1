#Requires -Version 5.1
# Stop compose stack profiles used by the hub
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ComposeFile = Join-Path $ScriptDir "docker-compose.yml"
docker compose -f $ComposeFile --profile infra --profile mongo down
