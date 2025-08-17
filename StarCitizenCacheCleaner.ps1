<#
.SYNOPSIS
    Clears the Star Citizen shader cache folders to resolve potential game issues.

.DESCRIPTION
    This script safely removes the Star Citizen shader cache directories to resolve potential game issues
    by moving them to the recycle bin. The script provides options for automated operation, verbose output,
    and can display detailed information about the cache folders.

.PARAMETER Silent
    Runs the script without user interaction, automatically clearing the cache.

.PARAMETER Verbose
    Displays detailed information about the operation.

.PARAMETER WhatIf
    Shows what would happen if the script runs without actually performing any actions.

.PARAMETER Force
    Forces deletion of cache folders without confirmation.

.EXAMPLE
    .\StarCitizenCacheCleaner.ps1
    Runs the script with normal user interaction.

.EXAMPLE
    .\StarCitizenCacheCleaner.ps1 -Silent
    Runs the script without user interaction, automatically clearing the cache.

.EXAMPLE
    .\StarCitizenCacheCleaner.ps1 -Verbose
    Runs the script with detailed information about each step.

.EXAMPLE
    .\StarCitizenCacheCleaner.ps1 -WhatIf
    Shows what would happen if the script runs without actually deleting anything.

.NOTES
    Author: https://robertsspaceindustries.com/en/citizens/Xzor (Original)
    Version: 2.0
    
    If you get an error "cannot be loaded because running scripts is disabled on this system," run:
	Set-ExecutionPolicy RemoteSigned -Scope process; .\StarCitizenCacheCleaner.ps1
    This will allow you to run the script for THAT SESSION ONLY (no long-term modifications of permissions).
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(HelpMessage = "Run without user interaction")]
    [switch]$Silent,
    
    [Parameter(HelpMessage = "Force deletion without confirmation")]
    [switch]$Force
)

#region Functions

function Write-ScriptLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Message,
        
        [Parameter(Position = 1)]
        [ValidateSet('Info', 'Warning', 'Error', 'Success')]
        [string]$Level = 'Info',
        
        [Parameter()]
        [switch]$NoNewline
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $colorMap = @{
        'Info' = 'White'
        'Warning' = 'Yellow'
        'Error' = 'Red'
        'Success' = 'Green'
    }
    
    $color = $colorMap[$Level]
    
    if ($NoNewline) {
        Write-Host "$Message" -ForegroundColor $color -NoNewline
    }
    else {
        Write-Host "$Message" -ForegroundColor $color
    }
    
    # If verbose is enabled, provide additional details
    if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -and $Level -ne 'Info') {
        Write-Verbose "[$timestamp] [$Level] $Message"
    }
}

function Get-FolderSize {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.DirectoryInfo[]]$Folders
    )
    
    try {
        if ($null -eq $Folders -or $Folders.Count -eq 0) {
            return 0
        }
        
        $size = ($Folders | Get-ChildItem -Recurse -ErrorAction SilentlyContinue | 
                 Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB
        
        return [math]::Round($size, 2)
    }
    catch {
        Write-ScriptLog "Error calculating folder size: $_" -Level Error
        return 0
    }
}

function Remove-StarCitizenCache {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [string]$CachePath,
        
        [Parameter()]
        [switch]$Force
    )
    
    # Add reference to Microsoft.VisualBasic assembly
    try {
        Add-Type -AssemblyName Microsoft.VisualBasic -ErrorAction Stop
    }
    catch {
        Write-ScriptLog "Failed to load Microsoft.VisualBasic assembly. Cannot use recycle bin functionality." -Level Error
        Write-ScriptLog "Error details: $_" -Level Error
        return $false
    }
    
    # Get all directories matching starcitizen_* pattern
    $foldersToDelete = Get-ChildItem -Path $CachePath -Directory -ErrorAction SilentlyContinue | 
                      Where-Object { $_.Name -like "starcitizen_*" }
    
    if ($null -eq $foldersToDelete -or $foldersToDelete.Count -eq 0) {
        Write-ScriptLog "No matching cache folders found." -Level Warning
        return $true
    }
    
    $folderCount = $foldersToDelete.Count
    $currentFolder = 0
    $successCount = 0
    
    foreach ($folder in $foldersToDelete) {
        $currentFolder++
        $percentComplete = [int](($currentFolder / $folderCount) * 100)
        
        Write-Progress -Activity "Moving cache folders to recycle bin" -Status "Processing folder $currentFolder of $folderCount" `
                      -PercentComplete $percentComplete -CurrentOperation $folder.Name
        
        if ($PSCmdlet.ShouldProcess($folder.FullName, "Move to recycle bin")) {
            try {
                if ($VerbosePreference -eq 'Continue') {
                    Write-ScriptLog "Removing folder: $($folder.FullName)" -Level Info
                }
                
                # Send to recycle bin instead of permanently deleting
                [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory(
                    $folder.FullName, 
                    'OnlyErrorDialogs', 
                    'SendToRecycleBin'
                )
                $successCount++
            }
            catch {
                Write-ScriptLog "Failed to delete folder $($folder.Name): $_" -Level Error
            }
        }
    }
    
    Write-Progress -Activity "Moving cache folders to recycle bin" -Completed
    
    return ($successCount -eq $folderCount)
}
$xzor = @"
__  __                     _____
\ \/ / _______  _ __    __|___  |
 \  / |_  / _ \| '__|  / _ \ / /
 /  \  / / (_) | |    | (_) / /
/_/\_\/___\___/|_|     \___/_/
"@
function Show-ScriptHeader {
    $host.UI.RawUI.WindowTitle = "Star Citizen Shader Cache Cleaner v2.0"

$banner = @"
 ______  ______  ______  ______  ______  ______  ______  ______  ______ 
| |__| || |__| || |__| || |__| || |__| || |__| || |__| || |__| || |__| |
|  ()  ||  ()  ||  ()  ||  ()  ||  ()  ||  ()  ||  ()  ||  ()  ||  ()  |
|______||______||______||______||______||______||______||______||______|
 ______                                                          ______ 
| |__| |              ____  _   _    _    ____  _____ ____      | |__| |
|  ()  |             / ___|| | | |  / \  |  _ \| ____|  _ \     |  ()  |
|______|             \___ \| |_| | / _ \ | | | |  _| | |_) |    |______|
 ______               ___) |  _  |/ ___ \| |_| | |___|  _ <      ______ 
| |__| |     ____    |____/|_| |_/_/ __\_\____/|_____|_| \_\    | |__| |
|  ()  |    / ___|  / \  / ___| | | | ____|                     |  ()  |
|______|   | |     / _ \| |   | |_| |  _|                       |______|
 ______    | |___ / ___ \ |___|  _  | |___                       ______ 
| |__| |    \____/_/   \_\____|_|_|_|_____| _____ ____          | |__| |
|  ()  |    / ___| |   | ____|  / \  | \ | | ____|  _ \         |  ()  |
|______|   | |   | |   |  _|   / _ \ |  \| |  _| | |_) |        |______|
 ______    | |___| |___| |___ / ___ \| |\  | |___|  _ <          ______ 
| |__| |    \____|_____|_____/_/   \_\_| \_|_____|_| \_\        | |__| |
|  ()  |                                                        |  ()  |
|______|                                                        |______|
 ______  ______  ______  ______  ______  ______  ______  ______  ______ 
| |__| || |__| || |__| || |__| || |__| || |__| || |__| || |__| || |__| |
|  ()  ||  ()  ||  ()  ||  ()  ||  ()  ||  ()  ||  ()  ||  ()  ||  ()  |
|______||______||______||______||______||______||______||______||______|

"@
    Write-Host $banner
    Write-ScriptLog "This script will move Star Citizen shader cache folders (starcitizen_*) to the recycle bin." -Level Info
    Write-ScriptLog "This can help recover disk space and potentially resolve game issues." -Level Info
    Write-ScriptLog "Use -WhatIf to preview without making changes, or -Silent for automated operation." -Level Info
    Write-Host
}

function Confirm-Operation {
    param (
        [switch]$Force
    )
    
    if ($Force -or $Silent) {
        return $true
    }
    
    $choices = @(
        [System.Management.Automation.Host.ChoiceDescription]::new("&Yes", "Move cache folders to recycle bin")
        [System.Management.Automation.Host.ChoiceDescription]::new("&No", "Cancel the operation")
    )
    
    $decision = $host.UI.PromptForChoice("Confirmation", "Do you want to move the Star Citizen cache folders to the recycle bin?", $choices, 1)
    
    return ($decision -eq 0)
}

function Show-Summary {
    param (
        [int]$OriginalCount,
        [double]$OriginalSize,
        [bool]$Success
    )
    
    Write-Host
    
    if ($Success) {
        Write-ScriptLog "Operation completed successfully!" -Level Success
        Write-ScriptLog "Removed $OriginalCount cache folders ($OriginalSize MB)" -Level Success
        Write-ScriptLog "You can now launch the game with a fresh shader cache." -Level Info
    }
    else {
        Write-ScriptLog "Operation completed with some errors." -Level Warning
        Write-ScriptLog "Some cache folders may not have been properly removed." -Level Warning
        Write-ScriptLog "You may need to run this script as administrator for full access." -Level Info
    }
}

function Wait-ForKeyPress {
    if (-not $Silent) {
        Write-Host
        Write-ScriptLog "Press any key to exit..." -Level Info -NoNewline
        $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Write-Host
    }
}
#endregion Functions

#region Main Script Execution
# Show script header if not in silent mode
if (-not $Silent) {
    Show-ScriptHeader
}

# Define the cache path
$cachePath = Join-Path $env:LOCALAPPDATA "Star Citizen"

# Check if the cache directory exists
if (-not (Test-Path -Path $cachePath)) {
    Write-ScriptLog "Star Citizen cache directory not found at: $cachePath" -Level Warning
    Write-ScriptLog "No action needed." -Level Success
    Wait-ForKeyPress
    exit 0
}

# Display folder info
try {
    # Get folders matching starcitizen_* pattern
    $cacheFolders = Get-ChildItem -Path $cachePath -Directory -ErrorAction Stop | 
                   Where-Object { $_.Name -like "starcitizen_*" }
    
    $folderCount = $cacheFolders.Count
    $folderSize = Get-FolderSize -Folders $cacheFolders
    
    Write-ScriptLog "Found Star Citizen directory: $cachePath" -Level Info
    
    if ($folderCount -gt 0) {
        Write-ScriptLog "Found $folderCount cache folders matching 'starcitizen_*'" -Level Info
        Write-ScriptLog "Current cache size: $folderSize MB" -Level Info
        
        # List individual folders if verbose is enabled
        if ($VerbosePreference -eq 'Continue') {
            Write-Host
            Write-ScriptLog "Cache folders:" -Level Info
            foreach ($folder in $cacheFolders) {
                $individualSize = Get-FolderSize -Folders $folder
                Write-ScriptLog " - $($folder.Name) ($individualSize MB)" -Level Info
            }
            Write-Host
        }
    }
    else {
        Write-ScriptLog "No cache folders found matching 'starcitizen_*'" -Level Warning
        Write-ScriptLog "No action needed." -Level Success
        Wait-ForKeyPress
        exit 0
    }
}
catch {
    Write-ScriptLog "Found Star Citizen cache directory, but couldn't analyze contents: $_" -Level Warning
}

# Ask for confirmation if not in silent/force mode
if (-not (Confirm-Operation -Force:$Force)) {
    Write-Host $xzor
    Write-ScriptLog "Operation cancelled. No files were moved to the recycle bin." -Level Warning
    Wait-ForKeyPress
    exit 0
}

# Delete the starcitizen_* directories
Write-ScriptLog "Moving Star Citizen shader cache folders to recycle bin..." -Level Info

$success = Remove-StarCitizenCache -CachePath $cachePath -Force:$Force

# Verify deletion
$remainingCacheFolders = Get-ChildItem -Path $cachePath -Directory -ErrorAction SilentlyContinue |
                         Where-Object { $_.Name -like "starcitizen_*" }

if ($null -eq $remainingCacheFolders -or $remainingCacheFolders.Count -eq 0) {
    $operationSuccess = $true
}
else {
    $operationSuccess = $false
    Write-ScriptLog "Some cache folders could not be moved to the recycle bin." -Level Warning
    Write-ScriptLog "Try running the script as administrator." -Level Warning
}

# Display summary and wait for key press
Write-Host $xzor
Show-Summary -OriginalCount $folderCount -OriginalSize $folderSize -Success $operationSuccess
Wait-ForKeyPress

exit [int](-not $operationSuccess)
#endregion Main Script Execution

# SIG # Begin signature block
# MIIFowYJKoZIhvcNAQcCoIIFlDCCBZACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUkZvRIx62lVQx5dPAlIeZuR0T
# ZPygggMsMIIDKDCCAhCgAwIBAgIQMMk2ySD+665H+kmf3bUU4zANBgkqhkiG9w0B
# AQUFADAsMSowKAYDVQQDDCFQb3dlclNoZWxsIENvZGUgU2lnbmluZyAoMTAgWWVh
# cikwHhcNMjUwODE3MTcyMTExWhcNMzUwODE3MTczMTExWjAsMSowKAYDVQQDDCFQ
# b3dlclNoZWxsIENvZGUgU2lnbmluZyAoMTAgWWVhcikwggEiMA0GCSqGSIb3DQEB
# AQUAA4IBDwAwggEKAoIBAQDJQfYVPp0K+pxyiKKaDKKN2db6ZMm2dWWZYtJXyb7M
# bLsZ6bnPVm6AanxjXgvk6UipP3UUpRr7esVzp4Nv2t9xSp7pNuEEtWonNhVaYVcC
# pEGgg2COO3dBfiyyFha1e4hGfN4WaGRzKTHEAv+sSzWe1Yfze88rMJDCPOuYVTE+
# KLehuFsgzx5wMScRyQf/4hxFlzQxfIs3ifLIA0biDr5mU6umNw3AhfP9UsQiPz+J
# VYd+YHi4iQOzf5koeEA4I0mNO25YpWn68lOTCdZO21UjVEytbSZdPFN2GS8Um9y6
# 3RgZKJd1ELsz8XI/c2w85czCSUXp3B4bHDp0ldLSRab9AgMBAAGjRjBEMA4GA1Ud
# DwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQU2vAdUPIg
# glh7xFXstX75UWhwfLQwDQYJKoZIhvcNAQEFBQADggEBAH1Uofyq/GBoHtEK7YP3
# IYe5XLLkXeSdZfbxwUorWNsqCh4In2UxEidyc8J2korOLi8MrnX27PR/IAO/aZY0
# 0Q+QRz+Zpbxz243FMWZ8/OgYTNT9crYWQ0QSTJGuvQ9Mkr7bDSo6zCbC8vSm4zrj
# AcRRO2qPS5qriDupHwGJySjFLAK0mPEau3Vq41ro2buqvCeOqDIGBUUNa8Bslg9G
# xzQZzbM/T7EDIrWUUuN7AVvphaF/bmsSvXL2FZy5EX7mfkTmyNN0J4qw5Y8zkU9R
# 27wIgihS+R3QT82vq/6H1m2hJXAdKqKnA/bKIaUJN8Grn5x6VhohsEdgkLfHKBp2
# fxYxggHhMIIB3QIBATBAMCwxKjAoBgNVBAMMIVBvd2VyU2hlbGwgQ29kZSBTaWdu
# aW5nICgxMCBZZWFyKQIQMMk2ySD+665H+kmf3bUU4zAJBgUrDgMCGgUAoHgwGAYK
# KwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU
# Gply7eu35laLu9FD2/h+BnNPYDwwDQYJKoZIhvcNAQEBBQAEggEAkxjzZqQIFB/D
# xSDTglwZg+mG/p+WccWTYuE14FE8bI/ptG5oJhWUe696sOQ6Xgyse/p+x6bUUn0V
# je8lGdYOxVLVmNQjwL0es2UsZhmzgWSNQMJWhSq1VGsdiH7RRenAH4owGkhDfyPv
# blv2Ij/iURS8hMKbssLR/FF73+XoM6UcFJ718rBkMPNRBS8bPdpNn71mgxv2v9Lx
# UaMjhF+23GQumqJ3PR3Juw68Ya//UZFCFkqfcsGleCMn+tW9Jdf6vB17S8ubPFch
# zyFMwLjfO8l0eQYNKcFQyNO5Mb+fhT3bIhlvecYQJtB/U9NlRoyDSvfZS80vyUMZ
# 12BXUHUNXw==
# SIG # End signature block
