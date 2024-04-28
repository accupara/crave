# Copyright (c) 2020-2024 Crave Crave.io Inc. All rights reserved

$OS="Windows"

$Env:CRAVE_URL_BASE = "https://github.com/accupara/crave/releases/latest/download/"
$Env:CRAVE_POSTFIX = ".zip"

if ($IsWindows -or $ENV:OS) {
    Write-Host "Downloading latest version of Crave for Windows"
} else {
    Write-Host "Only Windows host is supported for auto installation with this script."
    exit 1
}

$Env:CRAVE_URL = (Invoke-WebRequest -Uri $Env:CRAVE_URL_BASE -UseBasicParsing | ConvertFrom-Json).assets | Where-Object { $_.name -like "*windows*" -and $_.name -like "*.zip" } | Select-Object -ExpandProperty browser_download_url

if (-not $Env:CRAVE_URL) {
    Write-Host "Unable to fetch the download link. Please try again later."
    exit 1
}

Invoke-WebRequest $Env:CRAVE_URL -OutFile 'crave-bin.zip'
Write-Host "Download complete.. Expanding archive."
Expand-Archive -Path crave-bin.zip
Move-Item -Path "./crave-bin/crave-windows" -Destination "./crave"
Remove-Item crave-bin.zip -Force
Remove-Item crave-bin -Force
Write-Host "Crave pack expansion complete."
Write-Host "To execute crave directly use: $PWD\crave\crave.exe"
Write-Host "Or Add $PWD\crave to PATH in the environment variables"
