# DirGenie

DirGenie automatically organizes messy directories by sorting files into categorized folders based on their types. Transform cluttered Downloads folders, scattered desktops, and chaotic project directories into perfectly organized spaces with a single command.

## Features
- **Smart Categorization** - Groups files into logical categories (Images, Documents, Videos, Audio, Code, etc.)
- **Safe Preview** - Dry-run mode to see changes before they happen
- **Conflict Resolution** - Automatically handles duplicate filenames
- **Flexible Sorting** - Choose between categories or specific file extensions
- **Cross-Platform** - Works on Windows, Mac, and Linux

## Quick Start
```bash
# Organize a directory
python dirgenie.py /path/to/messy/folder

# Preview changes without moving files
python dirgenie.py ~/Downloads --dry-run

# Group by exact file extensions instead of categories
python dirgenie.py ./project --extensions
```

## Requirements
- Python 3.6+
- No additional dependencies required

## License
MIT License - Free to use, modify, and distribute.


