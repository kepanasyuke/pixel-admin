<#
    Включает запуск настоящих программ из игры «Пиксельный админ».
    Что делает:
      1. скачивает launcher.ps1 в %LOCALAPPDATA%\PixelAdmin
      2. прописывает обработчик ссылки sysadminlab:// в HKCU (без прав администратора)
    Как запустить: правой кнопкой по файлу → «Выполнить с помощью PowerShell»,
    либо: powershell -ExecutionPolicy Bypass -File install-handler.ps1
    Как отключить: powershell -ExecutionPolicy Bypass -Command "Remove-Item HKCU:\Software\Classes\sysadminlab -Recurse"
#>

$ErrorActionPreference = "Stop"
$dir = Join-Path $env:LOCALAPPDATA "PixelAdmin"
New-Item -ItemType Directory -Path $dir -Force | Out-Null

$raw = "https://raw.githubusercontent.com/kepanasyuke/pixel-admin/main/launcher.ps1"
$launcher = Join-Path $dir "launcher.ps1"

Write-Host "Скачиваю лаунчер..."
Invoke-WebRequest -Uri $raw -OutFile $launcher -UseBasicParsing

# пересохраняем с BOM, чтобы PowerShell 5.1 читал русский текст в файле
$text = [System.IO.File]::ReadAllText($launcher, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText($launcher, $text, (New-Object System.Text.UTF8Encoding($true)))

$cmd = "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$launcher`" `"%1`""

New-Item -Path "HKCU:\Software\Classes\sysadminlab" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Classes\sysadminlab" -Name "(default)" -Value "URL:sysadminlab"
New-ItemProperty -Path "HKCU:\Software\Classes\sysadminlab" -Name "URL Protocol" -Value "" -PropertyType String -Force | Out-Null
New-Item -Path "HKCU:\Software\Classes\sysadminlab\shell\open\command" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Classes\sysadminlab\shell\open\command" -Name "(default)" -Value $cmd

Write-Host ""
Write-Host "Готово. Обработчик sysadminlab:// зарегистрирован." -ForegroundColor Green
Write-Host "Лаунчер: $launcher"
Write-Host "Проверка: открой игру и нажми «Запустить настоящую программу» в окне программы."
Write-Host "Браузер спросит разрешение — выбери «Открыть»."
Write-Host ""
Write-Host "Отключить: Remove-Item HKCU:\Software\Classes\sysadminlab -Recurse"
