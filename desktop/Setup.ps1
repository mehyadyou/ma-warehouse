# ══════════════════════════════════════════════════════════════
#  MA Warehouse — Windows Setup & Runner
#  فقط یک‌بار اجرا کنید؛ بعد از آن فایل Run.bat را دابل‌کلیک کنید
# ══════════════════════════════════════════════════════════════

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "  ██████╗  ███╗   ██╗ █████╗ ██████╗ " -ForegroundColor Green
Write-Host "  ██╔══██╗ ████╗  ██║██╔══██╗██╔══██╗" -ForegroundColor Green
Write-Host "  ███████║ ██╔██╗ ██║███████║██████╔╝" -ForegroundColor Green
Write-Host "  ██╔══██║ ██║╚██╗██║██╔══██║██╔══██╗" -ForegroundColor Green
Write-Host "  ██║  ██║ ██║ ╚████║██║  ██║██║  ██║" -ForegroundColor Green
Write-Host "  ╚═╝  ╚═╝ ╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝" -ForegroundColor Green
Write-Host ""
Write-Host "  MA Warehouse Desktop App — Setup" -ForegroundColor Cyan
Write-Host "  ────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

# Check Python
$pythonCmd = $null
foreach ($cmd in @("python", "python3", "py")) {
    try {
        $ver = & $cmd --version 2>&1
        if ($ver -match "Python 3") { $pythonCmd = $cmd; break }
    } catch {}
}

if (-not $pythonCmd) {
    Write-Host "  [!] Python 3 پیدا نشد." -ForegroundColor Red
    Write-Host "  لطفاً Python 3.11+ را از https://python.org نصب کنید." -ForegroundColor Yellow
    Write-Host "  (گزینه 'Add Python to PATH' را حتماً تیک بزنید)" -ForegroundColor Yellow
    Read-Host "  برای خروج Enter بزنید"
    exit 1
}

Write-Host "  [✓] Python پیدا شد: $(&$pythonCmd --version)" -ForegroundColor Green

# Install dependencies
Write-Host "  نصب وابستگی‌ها..." -ForegroundColor Cyan
& $pythonCmd -m pip install --quiet -r (Join-Path $PSScriptRoot "requirements.txt")

Write-Host "  [✓] وابستگی‌ها نصب شدند" -ForegroundColor Green

# Create Run.bat
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$batPath   = Join-Path $scriptDir "Run.bat"
$batContent = "@echo off`r`nchcp 65001 >nul`r`ncd /d `"%~dp0`"`r`n$pythonCmd app.py`r`npause"
Set-Content -Path $batPath -Value $batContent -Encoding ASCII

Write-Host ""
Write-Host "  ══════════════════════════════════" -ForegroundColor Green
Write-Host "  [✓] آماده است!" -ForegroundColor Green
Write-Host "  فایل Run.bat را دابل‌کلیک کنید" -ForegroundColor Yellow
Write-Host "  ══════════════════════════════════" -ForegroundColor Green
Write-Host ""

# Ask to run now
$ans = Read-Host "  الان اجرا شود؟ (y/n)"
if ($ans -eq "y" -or $ans -eq "Y" -or $ans -eq "بله") {
    Write-Host "  در حال اجرا..." -ForegroundColor Cyan
    Start-Process -FilePath $pythonCmd -ArgumentList "app.py" -WorkingDirectory $scriptDir
}
