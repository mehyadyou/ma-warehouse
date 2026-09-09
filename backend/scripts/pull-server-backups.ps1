# کپی خودکار بکاپ‌های سرور به لپ‌تاپ (هر ۲ روز via Task Scheduler)
# امنیت: فقط کلید SSH استفاده می‌شود، هیچ رمزی در فایل نیست.
# استفاده دستی: .\pull-server-backups.ps1 [-KeepLast 15]

param(
    [string]$ServerHost = '100.114.246.32',
    [string]$ServerUser = 'server',
    [string]$SshKey = "$env:USERPROFILE\.ssh\ma_server",
    [string]$RemoteDir = '/opt/ma-warehouse/backups',
    [string]$LocalDir = 'D:\backup app',
    [int]$KeepLast = 15
)

$ErrorActionPreference = 'Stop'
$logFile = Join-Path $LocalDir 'pull.log'

function Write-Log([string]$msg) {
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $msg"
    Add-Content -LiteralPath $logFile -Value $line
    Write-Output $line
}

function Invoke-ServerSsh([string]$remoteCmd) {
    & ssh -i $SshKey -o BatchMode=yes -o ConnectTimeout=15 -o StrictHostKeyChecking=no `
        "$ServerUser@$ServerHost" $remoteCmd
    if ($LASTEXITCODE -ne 0) { throw "SSH failed (exit $LASTEXITCODE): $remoteCmd" }
}

# تبدیل نام سرور (میلادی) به نام لوکال (شمسی):
#   ma_warehouse_20260910_020001.dump -> ma_warehouse_14050619_020001.dump
# ساعت داخل نام، ساعت تهرانِ لحظه بکاپ است پس تبدیل مستقیم تقویمی درست است.
$persianCal = New-Object System.Globalization.PersianCalendar
function Get-JalaliLocalName([string]$serverFile) {
    $m = [regex]::Match($serverFile, '^ma_warehouse_(\d{8})_(\d{6})\.dump$')
    if (-not $m.Success) { return $serverFile } # فرمت ناآشنا: بدون تغییر
    $dt = [datetime]::ParseExact($m.Groups[1].Value + $m.Groups[2].Value, 'yyyyMMddHHmmss', $null)
    $j = '{0:D4}{1:D2}{2:D2}' -f $persianCal.GetYear($dt), $persianCal.GetMonth($dt), $persianCal.GetDayOfMonth($dt)
    return "ma_warehouse_${j}_$($m.Groups[2].Value).dump"
}

if (-not (Test-Path -LiteralPath $LocalDir)) {
    New-Item -ItemType Directory -Path $LocalDir | Out-Null
}
Write-Log '--- pull start ---'

# ۱) لیست دامپ‌های سرور
$remoteFiles = Invoke-ServerSsh "ls -1 $RemoteDir/*.dump 2>/dev/null | xargs -n1 basename 2>/dev/null" |
    Where-Object { $_ -match '\.dump$' }
if (-not $remoteFiles) { Write-Log 'WARN: no dumps found on server'; exit 1 }

$copied = 0
foreach ($file in $remoteFiles) {
    $localName = Get-JalaliLocalName $file
    $localDump = Join-Path $LocalDir $localName
    $localHash = "$localDump.sha256"
    if ((Test-Path -LiteralPath $localDump) -and (Test-Path -LiteralPath $localHash)) {
        continue # قبلاً گرفته شده
    }
    Write-Log "copy: $file -> $localName"
    & scp -i $SshKey -o BatchMode=yes -o ConnectTimeout=30 -o StrictHostKeyChecking=no `
        "$ServerUser@${ServerHost}:$RemoteDir/$file" "$localDump"
    if ($LASTEXITCODE -ne 0) { Write-Log "ERROR: scp dump failed: $file"; continue }
    & scp -i $SshKey -o BatchMode=yes -o ConnectTimeout=30 -o StrictHostKeyChecking=no `
        "$ServerUser@${ServerHost}:$RemoteDir/$file.sha256" "$localHash"
    if ($LASTEXITCODE -ne 0) { Write-Log "ERROR: scp sha256 failed: $file"; continue }

    # ۲) راستی‌آزمایی checksum (فرمت sha256sum: "<hash>  <name>")
    $expected = ((Get-Content -LiteralPath $localHash -TotalCount 1) -split '\s+')[0].Trim().ToLower()
    $actual = (Get-FileHash -LiteralPath $localDump -Algorithm SHA256).Hash.ToLower()
    if ($expected -ne $actual) {
        Write-Log "ERROR: checksum mismatch: $file (deleted)"
        Remove-Item -LiteralPath $localDump, $localHash -Force -ErrorAction SilentlyContinue
        continue
    }
    Write-Log "ok: $localName (sha256 verified)"
    $copied++
}

# ۳) هرس نسخه‌های قدیمی لوکال: فقط KeepLast تای آخری
$localDumps = Get-ChildItem -LiteralPath $LocalDir -Filter '*.dump' |
    Sort-Object LastWriteTime -Descending
if ($localDumps.Count -gt $KeepLast) {
    $localDumps | Select-Object -Skip $KeepLast | ForEach-Object {
        Write-Log "prune: $($_.Name)"
        Remove-Item -LiteralPath $_.FullName -Force
        Remove-Item -LiteralPath "$($_.FullName).sha256" -Force -ErrorAction SilentlyContinue
    }
}

Write-Log "--- pull done: copied=$copied total-local=$((Get-ChildItem -LiteralPath $LocalDir -Filter '*.dump').Count) ---"
