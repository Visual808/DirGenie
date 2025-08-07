# DirGenie

*Automated file organization utility*

DirGenie is a command-line utility that automatically organizes files in directories by sorting them into categorized folders based on file type. Available in both Python and PowerShell implementations, it provides a systematic approach to managing cluttered directories such as Downloads folders, project directories, and desktop files.

## Features

- **Intelligent Categorization** - Groups files into logical categories based on file extensions
- **Preview Mode** - Dry-run functionality to review changes before execution
- **Conflict Resolution** - Handles duplicate filenames through automatic renaming
- **Flexible Organization** - Option to group by broad categories or specific file extensions
- **Cross-Platform Compatibility** - Supports Windows, macOS, and Linux systems
- **Detailed Reporting** - Provides comprehensive output of all file operations

## Installation and Usage

### Python Version

#### Basic Usage
```bash
# Organize a directory
python dirgenie.py /path/to/directory

# Organize Downloads folder
python dirgenie.py ~/Downloads

# Organize current directory
python dirgenie.py .
```

#### Command Options
```bash
# Preview changes without moving files
python dirgenie.py ~/Downloads --dry-run

# Group by specific file extensions
python dirgenie.py ./project --extensions

# Display help information
python dirgenie.py --help
```

### PowerShell Version

#### Basic Usage
```powershell
# Organize a directory
.\DirGenie.ps1 -Path "C:\Users\Username\Downloads"

# Organize current directory
.\DirGenie.ps1 -Path "."
```

#### Command Options
```powershell
# Preview changes without moving files
.\DirGenie.ps1 -Path "C:\Users\Username\Downloads" -DryRun

# Group by specific file extensions
.\DirGenie.ps1 -Path ".\project" -UseExtensions

# Display help information
Get-Help .\DirGenie.ps1 -Full
```

## File Classification

DirGenie categorizes files into the following groups:

| Category | Supported Extensions |
|----------|---------------------|
| **Images** | `.jpg`, `.jpeg`, `.png`, `.gif`, `.bmp`, `.tiff`, `.svg`, `.webp`, `.ico`, `.raw` |
| **Documents** | `.pdf`, `.doc`, `.docx`, `.txt`, `.rtf`, `.odt`, `.pages`, `.tex` |
| **Spreadsheets** | `.xls`, `.xlsx`, `.csv`, `.ods`, `.numbers` |
| **Presentations** | `.ppt`, `.pptx`, `.odp`, `.key` |
| **Videos** | `.mp4`, `.avi`, `.mkv`, `.mov`, `.wmv`, `.flv`, `.webm`, `.m4v`, `.3gp` |
| **Audio** | `.mp3`, `.wav`, `.flac`, `.aac`, `.ogg`, `.wma`, `.m4a`, `.opus` |
| **Archives** | `.zip`, `.rar`, `.7z`, `.tar`, `.gz`, `.bz2`, `.xz`, `.dmg`, `.iso` |
| **Code** | `.py`, `.js`, `.html`, `.css`, `.java`, `.cpp`, `.c`, `.h`, `.php`, `.rb`, `.go`, `.rs`, `.swift` |
| **Executables** | `.exe`, `.msi`, `.deb`, `.rpm`, `.dmg`, `.pkg`, `.app` |
| **Data** | `.json`, `.xml`, `.yaml`, `.yml`, `.sql`, `.db`, `.sqlite` |

Files with unrecognized extensions are grouped using the extension name followed by `_Files`.

## System Requirements

### Python Version
- Python 3.6 or higher
- Read and write permissions for target directories
- No additional dependencies required

### PowerShell Version
- Windows PowerShell 5.1 or PowerShell Core 6.0+
- Read and write permissions for target directories
- Compatible with Windows, macOS, and Linux (PowerShell Core)

## Example Operation

### Input Directory Structure
```
Downloads/
├── presentation.pptx
├── image.jpg
├── document.pdf
├── song.mp3
├── video.mp4
└── data.csv
```

### Output Directory Structure
```
Downloads/
├── Presentations/
│   └── presentation.pptx
├── Images/
│   └── image.jpg
├── Documents/
│   └── document.pdf
├── Audio/
│   └── song.mp3
├── Videos/
│   └── video.mp4
└── Spreadsheets/
    └── data.csv
```

## Safety and Error Handling

- **Dry-run Mode**: The `--dry-run` flag allows users to preview all operations before execution
- **Conflict Resolution**: Duplicate filenames are handled by appending numeric suffixes
- **Non-destructive Operations**: Files are moved, not copied or deleted
- **Directory Preservation**: Existing subdirectories are ignored during organization
- **Error Reporting**: Clear error messages for permission issues or invalid paths

## Installation

### Python Version
#### Method 1: Repository Clone
```bash
git clone https://github.com/Visual808/DirGenie.git
cd DirGenie
python dirgenie.py --help
```

#### Method 2: Direct Download
Download the `dirgenie.py` file directly and execute it with Python.

### PowerShell Version
#### Method 1: Repository Clone
```powershell
git clone https://github.com/Visual808/DirGenie.git
cd DirGenie
.\DirGenie.ps1 -Help
```

#### Method 2: Direct Download
Download the `DirGenie.ps1` file directly and execute it with PowerShell.

#### Execution Policy (Windows)
You may need to adjust PowerShell execution policy:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## License

This project is licensed under the MIT License. See the LICENSE file for complete terms and conditions.

## Technical Notes

### Python Implementation
- Uses Python's `pathlib` library for cross-platform path handling
- Implements `shutil.move()` for reliable file operations
- Handles file system encoding differences across operating systems
- Provides comprehensive logging of all file operations

### PowerShell Implementation
- Leverages PowerShell's `Move-Item` cmdlet for file operations
- Uses `Test-Path` for file system validation
- Implements PowerShell parameter validation and help documentation
- Supports PowerShell pipeline operations

---

DirGenie provides a reliable solution for automated file organization across multiple platforms and file types.
