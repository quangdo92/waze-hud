$ErrorActionPreference = "Stop"

$idfPath = "C:\Espressif\frameworks\esp-idf-v5.5.5"
$env:IDF_PATH = $idfPath
$env:PYTHONUTF8 = "1"

# Find paths to tools
$ninjaExe = (Get-ChildItem -Path "C:\Espressif\tools\ninja\*\ninja.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -First 1)
$ninjaDir = Split-Path -Parent $ninjaExe

$cmakeExe = (Get-ChildItem -Path "C:\Espressif\tools\cmake\*\bin\cmake.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -First 1)
$cmakeDir = Split-Path -Parent $cmakeExe

$xtensaExe = (Get-ChildItem -Path "C:\Espressif\tools\xtensa-esp-elf\*\xtensa-esp32-elf-gcc.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -First 1)
$xtensaDir = Split-Path -Parent $xtensaExe

$ccacheExe = (Get-ChildItem -Path "C:\Espressif\tools\ccache\*\ccache.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -First 1)
$ccacheDir = Split-Path -Parent $ccacheExe

$pythonScripts = "C:\Espressif\python_env\idf5.5_py3.11_env\Scripts"

Write-Host "Toolchain configuration:"
Write-Host "  Ninja:  $ninjaExe"
Write-Host "  CMake:  $cmakeDir"
Write-Host "  GCC:    $xtensaDir"
Write-Host "  Ccache: $ccacheDir"
Write-Host "  Python: $pythonScripts"

$pathsToAdd = @($pythonScripts, $ninjaDir, $cmakeDir, $xtensaDir, $ccacheDir) | Where-Object { $_ -and (Test-Path $_) }
$env:PATH = ($pathsToAdd -join ";") + ";" + $env:PATH

$buildDir = "d:\waze-hud-CYD2.8-V2USB\waze-hud\build"
Set-Location $buildDir

Write-Host "Starting build with ninja..."
& $ninjaExe all
if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}
Write-Host "Build finished successfully!"

