function Add-WebAppxPackage {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Url,

        [switch]$Force
    )

    $supportedExtensions = @('.appx', '.appxbundle', '.msix', '.msixbundle')

    # Suppress Progress Bar for faster Invoke-WebRequest
    $ProgressPreference = 'SilentlyContinue'

    # Performing the web request
    # - Avoiding Internet Explorer Engine with -UseBasicParsing
    if ($PSCmdlet.ShouldProcess($Url, "Download")) {
        Write-Host -NoNewline "Downloading: $Url .."
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing
        Write-Host "`rDownloading: $Url .. Done!"
    }

    # Attempt to extract the filename from the Content-Disposition header
    $response.Headers["Content-Disposition"] -match 'filename=(.+)' | Out-Null;
    $fileName = $matches[1]

    # Fallback to extracing the file name from the URL
    if (-not $fileName) {
        $fileName = [System.IO.Path]::GetFileName($Url)
    }

    $fileExtension = [System.IO.Path]::GetExtension($fileName)

    # Ensure valid file extension
    if ($supportedExtensions -notcontains $fileExtension) {
        Write-Error "The file name: $fileName has an invalid file extension. Valid extensions are: $supportedExtensions"
    }

    try {
        # Save the file
        $tempFilePath = Join-Path -Path $env:TEMP -ChildPath $fileName
        Write-Debug "Saving the app package to: $tempFilePath"
        [System.IO.File]::WriteAllBytes($tempFilePath, $response.Content)

        # Install the app package
        if ($PSCmdlet.ShouldProcess($fileName, "Install")) {
            Write-Host -NoNewline "Installing the app package: $fileName .."
            Add-AppxPackage -Path $tempFilePath -Confirm:$false
            Write-Host "`rInstalling the app package: $fileName .. Done!"
        } else {
            Write-Host "Installation of the app package: $fileName was cancelled."
        }
    }
    finally {
        # Delete the app package
        if (Test-Path $tempFilePath)
        {
            Remove-Item -Path $tempFilePath -Force -Confirm:$false
        }
    }
}
