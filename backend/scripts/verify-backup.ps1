param(
    [Parameter(Mandatory = $true)][string]$File,
    [string]$VerifyDb = "ma_warehouse_verify"
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

function Invoke-Psql([string]$db, [string]$sql) {
    docker exec -e ("PGPASSWORD=" + $envVars["POSTGRES_PASSWORD"]) ma-warehouse-db psql -w -U postgres -d $db -t -A -c $sql
    if ($LASTEXITCODE -ne 0) { throw "psql failed on db=$db" }
}

function Get-RowCounts([string]$db) {
    $tables = @(Invoke-Psql $db "SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE' AND table_name NOT LIKE 'pg%' ORDER BY table_name;")
    $sql = ($tables | ForEach-Object { "SELECT '$_' AS t, count(*) FROM quote_ident('$_')" }) -join " UNION ALL "
    $rows = @(Invoke-Psql $db $sql)
    $total = 0
    $map = @{}
    foreach ($r in $rows) {
        $parts = $r.Split('|')
        $map[$parts[0]] = [int64]$parts[1]
        $total += [int64]$parts[1]
    }
    return @{ Map = $map; Total = $total; Count = $tables.Count }
}

$env:PGPASSWORD = $envVars["POSTGRES_PASSWORD"]
try {
    Invoke-Psql "postgres" "DROP DATABASE IF EXISTS $VerifyDb WITH (FORCE);" | Out-Null
    Invoke-Psql "postgres" "CREATE DATABASE $VerifyDb;" | Out-Null

    $cmdLine = 'docker exec -i -e PGPASSWORD=' + $envVars["POSTGRES_PASSWORD"] + ' ma-warehouse-db pg_restore -w -U postgres -d ' + $VerifyDb + ' --no-owner --clean --if-exists < "' + $File + '"'
    & cmd.exe /c $cmdLine
    if ($LASTEXITCODE -ne 0) { throw "pg_restore into verify db failed" }

    $real = Get-RowCounts $envVars["DATABASE_NAME"]
    $restored = Get-RowCounts $VerifyDb

    Invoke-Psql "postgres" "DROP DATABASE IF EXISTS $VerifyDb WITH (FORCE);" | Out-Null

    $tablesMatch = $real.Count -eq $restored.Count
    $rowsMatch = $real.Total -eq $restored.Total
    $perTableMatch = $true
    foreach ($k in $real.Map.Keys) {
        if ($real.Map[$k] -ne $restored.Map[$k]) { $perTableMatch = $false; Write-Host "  MISMATCH $k : real=$($real.Map[$k]) restored=$($restored.Map[$k])" }
    }

    Write-Host "VERIFY OK: backup=$File"
    Write-Host "  tables: real=$($real.Count) restored=$($restored.Count) -> $(if ($tablesMatch) { 'MATCH' } else { 'MISMATCH' })"
    Write-Host "  rows:   real=$($real.Total) restored=$($restored.Total) -> $(if ($rowsMatch) { 'MATCH' } else { 'MISMATCH' })"
    Write-Host "  per-table: $(if ($perTableMatch) { 'MATCH' } else { 'MISMATCH' })"
    if (-not ($tablesMatch -and $rowsMatch -and $perTableMatch)) { throw "Verify mismatch!" }
    Write-Host "VERIFY PASSED"
}
finally {
    Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
}
