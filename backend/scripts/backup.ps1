param(
    [string]$Dir = ".\backups",
    [int]$RetentionDays = 30,
    [string]$RemoteDir = ""
)
$ErrorActionPreference = "Stop"

$envFile = Join-Path $PSScriptRoot "..\.env"
if (-not (Test-Path $envFile)) { throw ".env not found: $envFile" }
$envVars = @{}
Get-Content $envFile | ForEach-Object {
    if ($_ -match '^\s*([A-Z0-9_]+)\s*=\s*"?([^"]*)"?\s*$') { $envVars[$matches[1]] = $matches[2] }
}
if (-not $envVars["POSTGRES_PASSWORD"]) { throw "POSTGRES_PASSWORD missing in .env" }
if (-not $envVars["DATABASE_NAME"]) { $envVars["DATABASE_NAME"] = "ma_warehouse" }

New-Item -ItemType Directory -Force -Path $Dir | Out-Null

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$out = Join-Path $Dir "ma_warehouse_$stamp.dump"

$env:PGPASSWORD = $envVars["POSTGRES_PASSWORD"]
docker exec -e ("PGPASSWORD=" + $envVars["POSTGRES_PASSWORD"]) ma-warehouse-db pg_dump -U postgres -d $envVars["DATABASE_NAME"] -Fc -f /tmp/ma_backup.dump
if ($LASTEXITCODE -ne 0) { Remove-Item Env:PGPASSWORD; throw "pg_dump failed" }

docker cp ma-warehouse-db:/tmp/ma_backup.dump $out
if ($LASTEXITCODE -ne 0) { Remove-Item Env:PGPASSWORD; throw "docker cp failed" }

docker exec ma-warehouse-db rm -f /tmp/ma_backup.dump
Remove-Item Env:PGPASSWORD

$cutoff = (Get-Date).AddDays(-$RetentionDays)
Get-ChildItem $Dir -Filter "*.dump" |
    Where-Object { $_.LastWriteTime -lt $cutoff } |
    Remove-Item -Force

Write-Host "Backup OK: $out"

if ($RemoteDir -ne "") {
    New-Item -ItemType Directory -Force -Path $RemoteDir | Out-Null
    Copy-Item $out $RemoteDir -Force
    Write-Host "Remote copy OK: $RemoteDir"
}
