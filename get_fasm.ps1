[CmdletBinding()]
param(
    [string]$Version = "1.73.35"
)

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$toolsDir = Join-Path $projectRoot "tools"
$targetDir = Join-Path $toolsDir "fasm"
$zipPath = Join-Path $toolsDir "fasmw$($Version.Replace('.', '')).zip"
$url = "https://flatassembler.net/fasmw$($Version.Replace('.', '')).zip"

New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null

Write-Host "Downloading FASM $Version from the official site..."
try {
    Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $zipPath
}
catch {
    throw "FASM download failed from $url. Download the Windows package manually and extract it below tools\fasm. Original error: $($_.Exception.Message)"
}

if (Test-Path $targetDir) {
    Remove-Item -Recurse -Force $targetDir
}
New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
Expand-Archive -LiteralPath $zipPath -DestinationPath $targetDir -Force
Remove-Item -Force $zipPath

$fasmExe = Get-ChildItem -Path $targetDir -Filter fasm.exe -Recurse | Select-Object -First 1
$includeFile = Get-ChildItem -Path $targetDir -Filter win32wx.inc -Recurse | Select-Object -First 1

if (-not $fasmExe -or -not $includeFile) {
    throw "The downloaded package did not contain fasm.exe and win32wx.inc."
}

Write-Host "FASM installed locally: $($fasmExe.FullName)"
