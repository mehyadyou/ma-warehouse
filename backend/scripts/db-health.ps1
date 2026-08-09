param(
    [string]$EnvFile = "..\.env",
    [string]$BackupDir = "..\backups",
    [string]$ReportDir = "..\logs",
    [int]$BackupMaxAgeHours = 30,
    [string]$TelegramToken = "",
    [string]$TelegramChatId = ""
)
$ErrorActionPreference = "Continue"

$report = [ordered]@{ timestamp = (Get-Date).ToString("o"); checks = [ordered]@{} }
$fail = 0

$envPath = Join-Path $PSScriptRoot $EnvFile
$envVars = @{}
Get-Content $envPath -ErrorAction SilentlyContinue | ForEach-Object {
    if ($_ -match '^\s*([A-Z0-9_]+)\s*=\s*"?([^"]*)"?\s*$') { $envVars[$matches[1]] = $matches[2] }
}

# 1) postgres reachable
$pgUp = $false
if ($envVars["POSTGRES_PASSWORD"]) {
    docker exec -e ("PGPASSWORD=" + $envVars["POSTGRES_PASSWORD"]) ma-warehouse-db psql -w -U postgres -d ma_warehouse -t -A -c "SELECT 1;" 2>$null | Out-Null
    $pgUp = ($LASTEXITCODE -eq 0)
}
$report.checks.postgres = $pgUp
if (-not $pgUp) { $fail++ }

# 2) pgbouncer reachable (full chain via postgres container, TLS+scram)
$pbUp = $false
if ($envVars["MA_APP_DB_PASSWORD"]) {
    docker exec -e ("PGPASSWORD=" + $envVars["MA_APP_DB_PASSWORD"]) ma-warehouse-db psql -w "host=ma-warehouse-pgbouncer port=5432 dbname=ma_warehouse user=ma_app sslmode=require" -t -A -c "SELECT 1;" 2>$null | Out-Null
    $pbUp = ($LASTEXITCODE -eq 0)
}
$report.checks.pgbouncer = $pbUp
if (-not $pbUp) { $fail++ }

# 3) WAL archiving freshness (last 12h)
$walOk = $false
if ($pgUp) {
    $lastArch = docker exec -e ("PGPASSWORD=" + $envVars["POSTGRES_PASSWORD"]) ma-warehouse-db psql -w -U postgres -d ma_warehouse -t -A -c "SELECT extract(epoch from (now() - last_archived_time)) FROM pg_stat_archiver;" 2>$null | ForEach-Object { $_.Trim() }
    if ($lastArch -match '^\d') {
        $ageMin = [math]::Round([double]$lastArch / 60)
        $walOk = ($ageMin -lt 720)
        $report.checks.wal_archive_age_min = $ageMin
    }
}
$report.checks.wal_archiving = $walOk
if (-not $walOk) { $fail++ }

# 4) backup freshness
$backupPath = Join-Path $PSScriptRoot $BackupDir
$latest = Get-ChildItem $backupPath -Filter "*.dump" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$backupOk = $false
if ($latest) {
    $ageHours = [math]::Round(((Get-Date) - $latest.LastWriteTime).TotalHours, 1)
    $backupOk = ($ageHours -le $BackupMaxAgeHours)
    $report.checks.backup_age_hours = $ageHours
    $report.checks.backup_latest = $latest.Name
} else {
    $report.checks.backup_latest = $null
}
$report.checks.backup_fresh = $backupOk
if (-not $backupOk) { $fail++ }

# 5) dead tuples / bloat summary
if ($pgUp) {
    $bloat = docker exec -e ("PGPASSWORD=" + $envVars["POSTGRES_PASSWORD"]) ma-warehouse-db psql -w -U postgres -d ma_warehouse -t -A -c "SELECT coalesce(sum(n_dead_tup),0) FROM pg_stat_user_tables;" 2>$null | ForEach-Object { $_.Trim() }
    if ($bloat -match '^\d') {
        $report.checks.total_dead_tuples = [int64]$bloat
        if ([int64]$bloat -gt 100000) { $fail++ }
    }
    $conns = docker exec -e ("PGPASSWORD=" + $envVars["POSTGRES_PASSWORD"]) ma-warehouse-db psql -w -U postgres -d ma_warehouse -t -A -c "SELECT count(*) FROM pg_stat_activity;" 2>$null | ForEach-Object { $_.Trim() }
    if ($conns -match '^\d') { $report.checks.active_connections = [int]$conns }
}

# 6) backups dir size
$dirSizeMB = 0
if (Test-Path $backupPath) {
    $dirSizeMB = [math]::Round((Get-ChildItem $backupPath -Filter "*.dump" | Measure-Object Length -Sum).Sum / 1MB, 1)
    $report.checks.backup_dir_size_mb = $dirSizeMB
}

$report.status = if ($fail -eq 0) { "ok" } else { "degraded" }
$report.fail_count = $fail

$json = $report | ConvertTo-Json -Depth 4 -Compress

New-Item -ItemType Directory -Force -Path (Join-Path $PSScriptRoot $ReportDir) | Out-Null
$reportFile = Join-Path $PSScriptRoot (Join-Path $ReportDir "db-health-$(Get-Date -Format 'yyyyMMdd').log")
Add-Content -Path $reportFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $json"

Write-Host "DB HEALTH: $($report.status) (fails=$fail)"
Write-Host $json

if ($fail -gt 0 -and $TelegramToken -ne "" -and $TelegramChatId -ne "") {
    try {
        $body = @{ chat_id = $TelegramChatId; text = "DB Health degraded: $json" } | ConvertTo-Json -Compress
        Invoke-RestMethod -Uri "https://api.telegram.org/bot$TelegramToken/sendMessage" -Method Post -ContentType "application/json" -Body $body -TimeoutSec 10 | Out-Null
        Write-Host "Telegram alert sent"
    } catch {
        Write-Host "Telegram alert FAILED: $($_.Exception.Message)"
    }
}

exit $fail
