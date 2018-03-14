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

$version = Get-ModuleVersion -Name gpg4win

Write-Information "Downloading gpg4win version ${version}."
Invoke-WebRequest -Uri "https://files.gpg4win.org/gpg4win-${version}.exe" -OutFile "$rootDir/gpg4win-${version}.exe"

$installDir = New-Item -Path "$rootDir/install" -ItemType Directory

Start-Process `
  -FilePath "./gpg4win-${version}.exe" `
  -ArgumentList "/S", "/D=$($installDir.FullName)" `
  -NoNewWindow `
  -Wait

$gpgDir = Join-Path -Resolve -Path $rootDir -ChildPath "GnuPG"
Compress-Archive `
  -Path ["$gpgDir/bin/gpg.exe", "$gpgDir/bin/gpg-agent.exe"] `
  -CompressionLevel Optimal `
  -DestinationPath "$rootDir/gnupg-windows.zip"
