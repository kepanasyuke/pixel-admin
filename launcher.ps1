param(
    [string]$Uri = ""
)

$ErrorActionPreference = "SilentlyContinue"

# Разбор ссылки вида sysadminlab://open?app=keepassxc
$app = ""
if ($Uri -match "app=([a-z0-9\-]+)") { $app = $matches[1].ToLower() }

$user = $env:USERNAME
$map = @{
    keepassxc = @(
        "D:\SysAdminLab\apps\KeePassXC\KeePassXC-2.8.0-x64\KeePassXC.exe",
        "D:\SysAdminLab\apps\KeePassXC\KeePassXC.exe",
        "C:\Program Files\KeePassXC\KeePassXC.exe"
    )
    mremoteng = @(
        "D:\SysAdminLab\apps\mRemoteNG\mRemoteNG.exe",
        "C:\Program Files\mRemoteNG\mRemoteNG.exe"
    )
    vscode = @(
        "D:\Microsoft VS Code\Code.exe",
        "C:\Users\$user\AppData\Local\Programs\Microsoft VS Code\Code.exe",
        "C:\Program Files\Microsoft VS Code\Code.exe"
    )
    joplin = @(
        "C:\Users\$user\AppData\Local\Programs\Joplin\Joplin.exe",
        "C:\Program Files\Joplin\Joplin.exe"
    )
    drawio = @(
        "C:\Program Files\draw.io\draw.io.exe",
        "C:\Users\$user\AppData\Local\Programs\draw.io\draw.io.exe"
    )
    rustdesk = @(
        "C:\Program Files\RustDesk\rustdesk.exe",
        "C:\Users\$user\AppData\Local\Programs\RustDesk\rustdesk.exe"
    )
    aspia = @(
        "D:\SysAdminLab\apps\Aspia\PFiles\Aspia\client\aspia_client.exe",
        "D:\SysAdminLab\apps\Aspia\Aspia\client\aspia_client.exe",
        "C:\Program Files\Aspia\client\aspia_client.exe"
    )
}

function Show-Message($text, $title) {
    $shell = New-Object -ComObject WScript.Shell
    $shell.Popup($text, 8, $title, 64) | Out-Null
}

if (-not $app -or -not $map.ContainsKey($app)) {
    Show-Message "Ссылка не распознана: $Uri`nОжидается sysadminlab://open?app=keepassxc" "Пиксельный админ"
    exit 1
}

$target = $null
foreach ($candidate in $map[$app]) {
    if (Test-Path -LiteralPath $candidate) { $target = $candidate; break }
}

if ($target) {
    Start-Process -FilePath $target
    exit 0
}

# Не нашли — ищем по всему диску D и в Program Files, затем предлагаем установку
$guesses = @{
    keepassxc = "KeePassXC.exe"; mremoteng = "mRemoteNG.exe"; vscode = "Code.exe"
    joplin = "Joplin.exe"; drawio = "draw.io.exe"; rustdesk = "rustdesk.exe"; aspia = "aspia_client.exe"
}
$found = Get-ChildItem -Path "D:\", "C:\Program Files", "C:\Users\$user\AppData\Local\Programs" `
    -Filter $guesses[$app] -Recurse -Depth 5 -ErrorAction SilentlyContinue | Select-Object -First 1

if ($found) {
    Start-Process -FilePath $found.FullName
    exit 0
}

$shell = New-Object -ComObject Shell.Application
$shell.Open("D:\SysAdminLab\install")
Show-Message "Программа '$app' не установлена.`nОткрыла папку D:\SysAdminLab\install — поставь её оттуда." "Пиксельный админ"
exit 2
