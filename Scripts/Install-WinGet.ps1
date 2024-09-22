# Get the directory of the current script
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Construct the relative path
$pathToFunctions = Join-Path -Path $scriptDir -ChildPath "../Functions/"

. (Join-Path $pathToFunctions -ChildPath "Add-WebAppxPackage.ps1")

$WingetAppPackageUrl = 'https://aka.ms/getwinget'

Add-WebAppxPackage -Url $WingetAppPackageUrl