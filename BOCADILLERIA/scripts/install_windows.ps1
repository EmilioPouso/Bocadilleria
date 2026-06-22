# Instala Bocadilleria en Windows (Aparece en Configuracion > Aplicaciones)
param(
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"
$AppName = "Bocadilleria Premium"
$AppId = "BocadilleriaPremium"
$Publisher = "Bocadilleria"
$Version = "1.0.0"
$Root = Split-Path $PSScriptRoot -Parent
$SourceDir = Join-Path $Root "build\windows\x64\runner\Release"
$InstallDir = Join-Path $env:LOCALAPPDATA "Programs\Bocadilleria"
$ExePath = Join-Path $InstallDir "bocadilleria.exe"
$StartMenuDir = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs"
$ShortcutPath = Join-Path $StartMenuDir "$AppName.lnk"
$DesktopShortcut = Join-Path ([Environment]::GetFolderPath("Desktop")) "$AppName.lnk"
$UninstallKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\$AppId"
$UninstallScript = Join-Path $InstallDir "uninstall.ps1"

function Remove-Install {
    if (Test-Path $ShortcutPath) { Remove-Item $ShortcutPath -Force }
    if (Test-Path $DesktopShortcut) { Remove-Item $DesktopShortcut -Force }
    if (Test-Path $UninstallKey) { Remove-Item $UninstallKey -Force }
    if (Test-Path $InstallDir) { Remove-Item $InstallDir -Recurse -Force }
    Write-Host "Bocadilleria desinstalada."
}

if ($Uninstall) {
    Remove-Install
    exit 0
}

if (-not (Test-Path (Join-Path $SourceDir "bocadilleria.exe"))) {
    Write-Host "ERROR: No existe la compilacion. Ejecuta antes: flutter build windows --release"
    exit 1
}

Write-Host "Instalando $AppName en $InstallDir ..."
if (Test-Path $InstallDir) { Remove-Item $InstallDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Copy-Item -Path "$SourceDir\*" -Destination $InstallDir -Recurse -Force

$uninstallContent = @"
param([switch]`$Uninstall)
& "$Root\scripts\install_windows.ps1" -Uninstall
"@
Set-Content -Path $UninstallScript -Value $uninstallContent -Encoding UTF8

$wsh = New-Object -ComObject WScript.Shell
foreach ($path in @($ShortcutPath, $DesktopShortcut)) {
    $sc = $wsh.CreateShortcut($path)
    $sc.TargetPath = $ExePath
    $sc.WorkingDirectory = $InstallDir
    $sc.Description = $AppName
    $sc.Save()
}

New-Item -Path $UninstallKey -Force | Out-Null
Set-ItemProperty -Path $UninstallKey -Name DisplayName -Value $AppName
Set-ItemProperty -Path $UninstallKey -Name Publisher -Value $Publisher
Set-ItemProperty -Path $UninstallKey -Name DisplayVersion -Value $Version
Set-ItemProperty -Path $UninstallKey -Name InstallLocation -Value $InstallDir
Set-ItemProperty -Path $UninstallKey -Name UninstallString -Value "powershell.exe -ExecutionPolicy Bypass -File `"$UninstallScript`" -Uninstall"
Set-ItemProperty -Path $UninstallKey -Name QuietUninstallString -Value "powershell.exe -ExecutionPolicy Bypass -File `"$UninstallScript`" -Uninstall"
Set-ItemProperty -Path $UninstallKey -Name NoModify -Value 1 -Type DWord
Set-ItemProperty -Path $UninstallKey -Name NoRepair -Value 1 -Type DWord

Write-Host ""
Write-Host "Instalacion completada."
Write-Host "  - Acceso directo en el Escritorio y en Inicio"
Write-Host "  - Aparece en Configuracion > Aplicaciones > Aplicaciones instaladas"
Write-Host "  - Ejecutable: $ExePath"
