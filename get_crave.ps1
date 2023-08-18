# Copyright (c) 2020-2023 Crave Crave.io Inc. All rights reserved

$OS="Windows"

$Env:CRAVE_URL_BASE = "https://github.com/accupara/crave/releases/download/"
$Env:CRAVE_VERSION = "0.2-6835"
$Env:CRAVE_POSTFIX = ".zip"
if ($IsWindows -or $ENV:OS) {
    Write-Host "Downloading $Env:CRAVE_VERSION for Windows"
} else {
    Write-Host "Only Windows host is supported for auto installation with this script."
    exit 1
}

$Env:CRAVE_URL = $Env:CRAVE_URL_BASE + "/" + $Env:CRAVE_VERSION + "/" + "crave-windows-" + $Env:CRAVE_VERSION + "-" + $OS + $Env:CRAVE_POSTFIX

Invoke-WebRequest $Env:CRAVE_URL -OutFile 'crave-bin.zip'
Write-Host "Download complete.. Expanding archive."
Expand-Archive -Path crave-bin.zip
Move-Item -Path "./crave-bin/crave-windows" -Destination "./crave"
Remove-Item crave-bin.zip -Force
Remove-Item crave-bin -Force
Write-Host "Crave pack expansion complete."
Write-Host "To execute crave directly use: $PWD\crave\crave.exe"
Write-Host "Or Add $PWD\crave to PATH in the environment variables"
