# Download and repackage the GPG binaries built from gpg4win.

$scriptDir = $MyInvocation.PSScriptRoot
$rootDir = Join-Path -Resolve -Path $scriptDir -ChildPath ..

function Get-Module-Version ($Name)
{
  $versionFile = Join-Path -Path $rootDir -ChildPath 'versions'
  $m = Get-Content -Path $versionFile | Select-String -List -Pattern "${Name}:\\s+([0-9.]+)"
  If ($ms.Success)
  {
    return $m.Matches[0].Groups[1].Value
  } else {
    throw "Unable to locate version for ${Name}"
  }
}

$version = Get-Module-Version -Name gpg4win

Write-Information "Downloading gpg4win version ${version}."
Invoke-WebRequest -Uri "https://files.gpg4win.org/gpg4win-${version}.exe" -OutFile "./gpg4win-${version}.exe"

$installDir = New-Item -Path './install' -ItemType Directory
Start-Process `
  -FilePath "./gpg4win-${version}.exe" `
  -ArgumentList "/S", "/D=$($installDir.FullName)" `
  -NoNewWindow `
  -Wait
