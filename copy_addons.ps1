﻿$WOW_TYPE = "_ptr_"
$ADDONS_LIST = ("Pulsar")
$scriptPath = split-path -parent $MyInvocation.MyCommand.ScriptBlock.File
$WOW_INSTALL = "HKLM:\SOFTWARE\WOW6432Node\Blizzard Entertainment\World of Warcraft"
$WOW_DIR = (Get-ItemProperty -Path $WOW_INSTALL -Name "InstallPath").InstallPath
$WOW_DIR = (Get-Item $WOW_DIR).Parent.FullName

Function CopyAddon($addonFolder) {
    $addonName = $addonFolder.Name;
    $addonSrcFullPath = $addonFolder.FullName
    $addonDstFullPath = Join-Path -Path $WOW_DIR -ChildPath "$WOW_TYPE\Interface\AddOns\$addonName"

    Write-Output "Cleanup addon path: $addonDstFullPath"
    if (Test-Path -Path $addonDstFullPath) {
        Remove-Item -LiteralPath $addonDstFullPath -Force -Recurse
    }

    Write-Output "Copy addon from '$addonSrcFullPath' to '$addonDstFullPath'"
    Copy-Item -Path $addonSrcFullPath -Filter "*.*" -Recurse -Destination $addonDstFullPath -Container
}

$folderList = Get-ChildItem -Path $scriptPath -Directory -Force -ErrorAction SilentlyContinue
foreach ($addonFolder in $folderList) {
    if ($addonFolder.Name -in $ADDONS_LIST) {
        CopyAddon $addonFolder
    }
}
