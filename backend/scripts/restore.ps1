param(
    [Parameter(Mandatory = $true)][string]$File,
    [switch]$DropFirst
)
$ErrorActionPreference = "Stop"

if (-not (Test-Path $File)) { throw "Backup file not found: $File" }

$envFile = Join-Path $PSScriptRoot "..\.env"
if (-not (Test-Path $envFile)) { throw ".env not found: $envFile" }
$envVars = @{}
Get-Content $envFile | ForEach-Object {
    if ($_ -match '^\s*([A-Z0-9_]+)\s*=\s*"?([^"]*)"?\s*$') { $envVars[$matches[1]] = $matches[2] }
}
if (-not $envVars["POSTGRES_PASSWORD"]) { throw "POSTGRES_PASSWORD missing in .env" }
if (-not $envVars["DATABASE_NAME"]) { $envVars["DATABASE_NAME"] = "ma_warehouse" }

$env:PGPASSWORD = $envVars["POSTGRES_PASSWORD"]
try {
    if ($DropFirst) {
        Write-Host "Dropping and recreating database..."
        docker exec -e ("PGPASSWORD=" + $envVars["POSTGRES_PASSWORD"]) ma-warehouse-db psql -U postgres -d postgres -c "DROP DATABASE IF EXISTS $($envVars["DATABASE_NAME"]) WITH (FORCE);"
        if ($LASTEXITCODE -ne 0) { throw "DROP DATABASE failed" }
        docker exec -e ("PGPASSWORD=" + $envVars["POSTGRES_PASSWORD"]) ma-warehouse-db psql -U postgres -d postgres -c "CREATE DATABASE $($envVars["DATABASE_NAME"]);"
        if ($LASTEXITCODE -ne 0) { throw "CREATE DATABASE failed" }
    }

    $cmdLine = 'docker exec -i -e PGPASSWORD=' + $envVars["POSTGRES_PASSWORD"] + ' ma-warehouse-db pg_restore -w -U postgres -d ' + $envVars["DATABASE_NAME"] + ' --no-owner --clean --if-exists < "' + $File + '"'
    & cmd.exe /c $cmdLine
    if ($LASTEXITCODE -ne 0) { throw "pg_restore failed" }

    Write-Host "Restore OK from: $File"
}
finally {
    Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
}
