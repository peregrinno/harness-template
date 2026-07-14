#Requires -Version 5.1
# Stop compose stack
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ComposeFile = Join-Path $ScriptDir "docker-compose.yml"
docker compose -f $ComposeFile --profile mongo down
