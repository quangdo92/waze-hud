param (
    [string]$TargetName = "CYD2.8-BLE",
    [string]$Version = "b17"
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$buildDir = Join-Path $projectRoot "waze-hud\build"
$releaseDir = Join-Path $projectRoot "releases"

$timestamp = (Get-Date).ToString("ddMMyy_HHmm")
$appSrcBin = Join-Path $buildDir "waze_hud_cyd_28.bin"

if (-not (Test-Path $appSrcBin)) {
    Write-Error "Loi: Khong tim thay $appSrcBin. Vui long build truoc!"
    exit 1
}

if (-not (Test-Path $releaseDir)) {
    New-Item -ItemType Directory -Path $releaseDir | Out-Null
}

Write-Host "Dang dong goi firmware cho: $TargetName - Phien ban: $Version (Timestamp: $timestamp)..."

$pythonExe = "C:\Espressif\python_env\idf5.5_py3.11_env\Scripts\python.exe"
if (-not (Test-Path $pythonExe)) {
    $pythonExe = (Get-ChildItem -Path "C:\Espressif\python_env\*\Scripts\python.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -First 1)
}

if (-not $pythonExe -or -not (Test-Path $pythonExe)) {
    Write-Error "Khong tim thay python trong C:\Espressif\python_env!"
    exit 1
}

$fullBin = Join-Path $releaseDir "${TargetName}-${Version}-${timestamp}_full.bin"
$appBin = Join-Path $releaseDir "${TargetName}-${Version}-${timestamp}_app.bin"

$bootloaderBin = Join-Path $buildDir "bootloader\bootloader.bin"
$partitionBin = Join-Path $buildDir "partition_table\partition-table.bin"
$otadataBin = Join-Path $buildDir "ota_data_initial.bin"

Write-Host "Running esptool merge_bin..."
& $pythonExe -m esptool --chip esp32 merge_bin `
    -o "$fullBin" `
    --flash_mode dio --flash_size 4MB --flash_freq 40m `
    0x1000 "$bootloaderBin" `
    0x8000 "$partitionBin" `
    0xf000 "$otadataBin" `
    0x20000 "$appSrcBin"

Copy-Item -Path "$appSrcBin" -Destination "$appBin" -Force

Write-Host ""
Write-Host "Dong goi hoan tat vao thu muc: $releaseDir"
Write-Host "  1. Full Flash (Nap qua USB o offset 0x0): $fullBin"
Write-Host "  2. App OTA    (Nap qua WiFi Web OTA):      $appBin"
Write-Host ""
Get-Item "$fullBin", "$appBin" | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize

