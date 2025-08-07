#Requires -Version 5.1

<#
.SYNOPSIS
    Organizes files in a directory into folders based on their file types.

.DESCRIPTION
    This script takes a directory path and organizes all files within it into
    subfolders based on their file extensions or categories. Files are grouped
    into logical categories like Images, Documents, Videos, etc.

.PARAMETER Path
    The directory path to organize. Can be relative or absolute.

.PARAMETER UseExtensions
    If specified, group files by exact extensions instead of categories.

.PARAMETER DryRun
    If specified, show what would be done without actually moving files.

.PARAMETER WhatIf
    Alternative to DryRun - show what would be done without actually moving files.

.EXAMPLE
    .\Organize-Files.ps1 -Path "C:\Users\Username\Downloads"
    Organizes files in Downloads folder by categories.

.EXAMPLE
    .\Organize-Files.ps1 -Path ".\MessyFolder" -UseExtensions
    Organizes files by exact file extensions.

.EXAMPLE
    .\Organize-Files.ps1 -Path "C:\Temp" -DryRun
    Shows what would be organized without making changes.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Path,
    
    [Parameter(Mandatory = $false)]
    [switch]$UseExtensions,
    
    [Parameter(Mandatory = $false)]
    [switch]$DryRun
)

function Get-FileCategory {
    param([string]$Extension)
    
    $Categories = @{
        'Images' = @('.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff', '.svg', '.webp', '.ico', '.raw', '.heic', '.avif')
        'Documents' = @('.pdf', '.doc', '.docx', '.txt', '.rtf', '.odt', '.pages', '.tex', '.md', '.epub')
        'Spreadsheets' = @('.xls', '.xlsx', '.csv', '.ods', '.numbers', '.xlsm', '.xlsb')
        'Presentations' = @('.ppt', '.pptx', '.odp', '.key', '.pps', '.ppsx')
        'Videos' = @('.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm', '.m4v', '.3gp', '.ogv', '.mpg', '.mpeg')
        'Audio' = @('.mp3', '.wav', '.flac', '.aac', '.ogg', '.wma', '.m4a', '.opus', '.aiff', '.au')
        'Archives' = @('.zip', '.rar', '.7z', '.tar', '.gz', '.bz2', '.xz', '.dmg', '.iso', '.cab', '.msi')
        'Code' = @('.py', '.js', '.html', '.css', '.java', '.cpp', '.c', '.h', '.php', '.rb', '.go', '.rs', '.swift', '.ps1', '.bat', '.cmd', '.sh')
        'Executables' = @('.exe', '.msi', '.deb', '.rpm', '.dmg', '.pkg', '.app', '.run', '.appx')
        'Data' = @('.json', '.xml', '.yaml', '.yml', '.sql', '.db', '.sqlite', '.log', '.ini', '.cfg', '.conf')
        'Fonts' = @('.ttf', '.otf', '.woff', '.woff2', '.eot')
        'CAD' = @('.dwg', '.dxf', '.step', '.iges', '.stl', '.obj')
    }
    
    $ExtensionLower = $Extension.ToLower()
    
    foreach ($Category in $Categories.Keys) {
        if ($Categories[$Category] -contains $ExtensionLower) {
            return $Category
        }
    }
    
    # If no category matches, use the extension name
    if ([string]::IsNullOrEmpty($ExtensionLower)) {
        return 'No_Extension'
    } else {
        return ($ExtensionLower.Substring(1).ToUpper() + '_Files')
    }
}

function Get-UniqueFileName {
    param(
        [string]$DirectoryPath,
        [string]$FileName
    )
    
    $FullPath = Join-Path $DirectoryPath $FileName
    $Counter = 1
    $BaseName = [System.IO.Path]::GetFileNameWithoutExtension($FileName)
    $Extension = [System.IO.Path]::GetExtension($FileName)
    
    while (Test-Path $FullPath) {
        $NewFileName = "${BaseName}_${Counter}${Extension}"
        $FullPath = Join-Path $DirectoryPath $NewFileName
        $Counter++
    }
    
    return Split-Path $FullPath -Leaf
}

function Organize-Files {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$DirectoryPath,
        [bool]$UseExtensions,
        [bool]$DryRun
    )
    
    # Validate directory
    if (-not (Test-Path $DirectoryPath -PathType Container)) {
        if (Test-Path $DirectoryPath) {
            Write-Error "Error: '$DirectoryPath' is not a directory."
        } else {
            Write-Error "Error: Directory '$DirectoryPath' does not exist."
        }
        return $false
    }
    
    # Get all files (not directories)
    $Files = Get-ChildItem -Path $DirectoryPath -File
    
    if ($Files.Count -eq 0) {
        Write-Host "No files found in '$DirectoryPath'." -ForegroundColor Yellow
        return $true
    }
    
    # Group files by type/category
    $FileGroups = @{}
    
    foreach ($File in $Files) {
        $Extension = $File.Extension
        
        if ($UseExtensions) {
            if ([string]::IsNullOrEmpty($Extension)) {
                $GroupName = 'No_Extension'
            } else {
                $GroupName = $Extension.Substring(1).ToUpper() + '_Files'
            }
        } else {
            $GroupName = Get-FileCategory -Extension $Extension
        }
        
        if (-not $FileGroups.ContainsKey($GroupName)) {
            $FileGroups[$GroupName] = @()
        }
        $FileGroups[$GroupName] += $File
    }
    
    Write-Host "Found $($Files.Count) files in $($FileGroups.Count) different types/categories:" -ForegroundColor Cyan
    foreach ($Group in $FileGroups.Keys | Sort-Object) {
        Write-Host "  $Group`: $($FileGroups[$Group].Count) files" -ForegroundColor Gray
    }
    
    if ($DryRun -or $WhatIfPreference) {
        Write-Host "`nDRY RUN - No files will be moved. Here's what would happen:" -ForegroundColor Yellow
    }
    
    Write-Host ""
    
    $MovedCount = 0
    $ErrorCount = 0
    
    foreach ($GroupName in $FileGroups.Keys | Sort-Object) {
        $GroupFiles = $FileGroups[$GroupName]
        $FolderPath = Join-Path $DirectoryPath $GroupName
        
        # Create folder
        if ($DryRun -or $WhatIfPreference) {
            Write-Host "Would create folder: $FolderPath" -ForegroundColor Yellow
        } else {
            if (-not (Test-Path $FolderPath)) {
                try {
                    New-Item -Path $FolderPath -ItemType Directory -Force | Out-Null
                    Write-Host "Created folder: $FolderPath" -ForegroundColor Green
                } catch {
                    Write-Error "Failed to create folder '$FolderPath': $_"
                    $ErrorCount++
                    continue
                }
            } else {
                Write-Host "Using existing folder: $FolderPath" -ForegroundColor Cyan
            }
        }
        
        # Move files
        foreach ($File in $GroupFiles) {
            $UniqueFileName = Get-UniqueFileName -DirectoryPath $FolderPath -FileName $File.Name
            $Destination = Join-Path $FolderPath $UniqueFileName
            
            if ($DryRun -or $WhatIfPreference) {
                Write-Host "  Would move: $($File.Name) -> $GroupName\$UniqueFileName" -ForegroundColor Gray
            } else {
                try {
                    if ($PSCmdlet.ShouldProcess($File.FullName, "Move to $Destination")) {
                        Move-Item -Path $File.FullName -Destination $Destination -Force
                        Write-Host "  Moved: $($File.Name) -> $GroupName\$UniqueFileName" -ForegroundColor White
                        $MovedCount++
                    }
                } catch {
                    Write-Error "  Error moving $($File.Name): $_"
                    $ErrorCount++
                }
            }
        }
    }
    
    # Summary
    Write-Host ""
    if ($DryRun -or $WhatIfPreference) {
        Write-Host "Dry run complete! Would move $($Files.Count) files into $($FileGroups.Count) folders." -ForegroundColor Yellow
    } else {
        if ($ErrorCount -eq 0) {
            Write-Host "Organization complete! Moved $MovedCount files into $($FileGroups.Count) folders." -ForegroundColor Green
        } else {
            Write-Host "Organization completed with errors. Moved $MovedCount files, $ErrorCount errors occurred." -ForegroundColor Yellow
        }
    }
    
    return $true
}

# Main execution
try {
    # Convert to absolute path
    $AbsolutePath = Resolve-Path $Path -ErrorAction Stop
    
    Write-Host "Organizing directory: $AbsolutePath" -ForegroundColor Cyan
    Write-Host "Grouping by: $(if ($UseExtensions) { 'Extensions' } else { 'Categories' })" -ForegroundColor Cyan
    Write-Host "Mode: $(if ($DryRun -or $WhatIfPreference) { 'Dry run' } else { 'Execute' })" -ForegroundColor Cyan
    Write-Host ("-" * 50) -ForegroundColor Gray
    
    $Success = Organize-Files -DirectoryPath $AbsolutePath -UseExtensions $UseExtensions.IsPresent -DryRun ($DryRun.IsPresent -or $WhatIfPreference)
    
    if (-not $Success) {
        exit 1
    }
} catch {
    Write-Error "Error: $_"
    exit 1
}
