# uninstall.ps1 — Supprime SuperClaude Installer de ce PC
$ErrorActionPreference = "SilentlyContinue"

Write-Host "==> Désinstallation SuperClaude Installer" -ForegroundColor Yellow

# 1. Désinstaller via Apps Windows (NSIS uninstaller)
$uninstReg = @(
  "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
  "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
  "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

$uninstPath = $null
foreach ($reg in $uninstReg) {
  if (Test-Path $reg) {
    $found = Get-ChildItem $reg | Where-Object {
      (Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue).DisplayName -like "*SuperClaude*"
    }
    if ($found) {
      $uninstPath = (Get-ItemProperty $found.PSPath).UninstallString
      break
    }
  }
}

if ($uninstPath) {
  Write-Host "  Lancement désinstalleur système: $uninstPath" -ForegroundColor Cyan
  Start-Process -FilePath $uninstPath -ArgumentList "/S" -Wait
  Write-Host "  ✓ App désinstallée" -ForegroundColor Green
} else {
  Write-Host "  App non trouvée dans le registre (peut-être jamais installée via .exe)" -ForegroundColor Gray
}

# 2. Supprimer dossier dist/ local
$distPath = Join-Path $PSScriptRoot "installer-app\dist"
if (Test-Path $distPath) {
  Remove-Item $distPath -Recurse -Force
  Write-Host "  ✓ installer-app\dist\ supprimé" -ForegroundColor Green
}

# 3. Supprimer node_modules local
$nodeModules = Join-Path $PSScriptRoot "installer-app\node_modules"
if (Test-Path $nodeModules) {
  Write-Host "  Suppression node_modules (peut prendre quelques secondes)..." -ForegroundColor Cyan
  Remove-Item $nodeModules -Recurse -Force
  Write-Host "  ✓ installer-app\node_modules\ supprimé" -ForegroundColor Green
}

Write-Host ""
Write-Host "==> Désinstallation terminée." -ForegroundColor Green
Write-Host "    Pour supprimer le dossier SuperClaude entier: supprimer C:\Users\$env:USERNAME\SuperClaude" -ForegroundColor Gray
