# Download and repackage the GPG binaries built from gpg4win.

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$rootDir = Join-Path -Resolve -Path $scriptDir -ChildPath ..

function Get-ModuleVersion ($Name)
{
  $versionFile = Join-Path -Path $rootDir -ChildPath 'versions'
  $m = Get-Content -Path $versionFile | Select-String -Pattern "${Name}:\s+([0-9.]+)"
  If ($m.Matches.Count -ge 1)
  {
    return $m.Matches[0].Groups[1].Value
  } else {
    throw "Unable to locate version for ${Name}"
  }
}

function Get-Dir-Maybe ($Path)
{
  Write-Information "Listing ${Path}"
  If (Test-Path -Path $Path -PathType Container) {
    Get-ChildItem -Path $Path -Recurse
  } else {
    Write-Error "$Path does not exist"
  }
}

$version = Get-ModuleVersion -Name gpg4win

Write-Information "Downloading gpg4win version ${version}."
Invoke-WebRequest -Uri "https://files.gpg4win.org/gpg4win-${version}.exe" -OutFile "./gpg4win-${version}.exe"

$installDir = New-Item -Path './install' -ItemType Directory
Start-Process `
  -FilePath "./gpg4win-${version}.exe" `
  -ArgumentList "/S", "/D=$($installDir.FullName)" `
  -NoNewWindow `
  -Wait

Get-Dir-Maybe -Path $installDir.FullName
Get-Dir-Maybe -Path "C:\Program Files (x86)\GnuPG"
Get-Dir-Maybe -Path "C:\Program Files (x86)\Gpg4win"
