$WOW_TYPE = ("_classic_era_:11501", "_retail_:100205")
$ADDONS_LIST = ("Pulsar")
$scriptPath = split-path -parent $MyInvocation.MyCommand.ScriptBlock.File
$WOW_INSTALL = "HKLM:\SOFTWARE\WOW6432Node\Blizzard Entertainment\World of Warcraft"
$WOW_DIR = (Get-ItemProperty -Path $WOW_INSTALL -Name "InstallPath").InstallPath
$WOW_DIR = (Get-Item $WOW_DIR).Parent.FullName

Function CopyAddon($addonFolder, $type) {
    $name = $type.Split(":")[0]
    $ver = $type.Split(":")[1]

    $addonName = $addonFolder.Name;
    $addonSrcFullPath = $addonFolder.FullName
    $addonDstFullPath = Join-Path -Path $WOW_DIR -ChildPath "$name\Interface\AddOns\$addonName"

    Write-Output "Cleanup addon path: $addonDstFullPath"
    if (Test-Path -Path $addonDstFullPath) {
        Remove-Item -LiteralPath $addonDstFullPath -Force -Recurse
    }

    Write-Output "Copy addon from '$addonSrcFullPath' to '$addonDstFullPath'"
    Copy-Item -Path $addonSrcFullPath -Filter "*.*" -Recurse -Destination $addonDstFullPath -Container

    $toc = Join-Path -Path $addonDstFullPath -ChildPath "$addonName.toc"
    $tocText = Get-Content -Path $toc

    $tocText = $tocText -replace "## Interface: (\d+)", "## Interface: $ver"

    Set-Content -Path $toc -Value $tocText
}

$folderList = Get-ChildItem -Path $scriptPath -Directory -Force -ErrorAction SilentlyContinue
foreach ($addonFolder in $folderList) {
    if ($addonFolder.Name -in $ADDONS_LIST) {
        foreach ($wtype in $WOW_TYPE) {
            CopyAddon $addonFolder $wtype
        }
    }
}
