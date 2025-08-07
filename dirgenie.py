#!/usr/bin/env python3
"""
File Organizer Script
Organizes files in a directory into folders based on their file extensions.
"""

import os
import sys
import shutil
import argparse
from pathlib import Path
from collections import defaultdict

def get_file_category(extension):
    """
    Categorize file extensions into broader categories.
    Returns the category name for a given file extension.
    """
    categories = {
        'Images': {'.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff', '.svg', '.webp', '.ico', '.raw'},
        'Documents': {'.pdf', '.doc', '.docx', '.txt', '.rtf', '.odt', '.pages', '.tex'},
        'Spreadsheets': {'.xls', '.xlsx', '.csv', '.ods', '.numbers'},
        'Presentations': {'.ppt', '.pptx', '.odp', '.key'},
        'Videos': {'.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm', '.m4v', '.3gp'},
        'Audio': {'.mp3', '.wav', '.flac', '.aac', '.ogg', '.wma', '.m4a', '.opus'},
        'Archives': {'.zip', '.rar', '.7z', '.tar', '.gz', '.bz2', '.xz', '.dmg', '.iso'},
        'Code': {'.py', '.js', '.html', '.css', '.java', '.cpp', '.c', '.h', '.php', '.rb', '.go', '.rs', '.swift'},
        'Executables': {'.exe', '.msi', '.deb', '.rpm', '.dmg', '.pkg', '.app'},
        'Data': {'.json', '.xml', '.yaml', '.yml', '.sql', '.db', '.sqlite'}
    }
    
    extension_lower = extension.lower()
    for category, extensions in categories.items():
        if extension_lower in extensions:
            return category
    
    # If no category matches, use the extension name (without the dot)
    return extension_lower[1:].upper() + '_Files' if extension_lower else 'No_Extension'

def organize_directory(directory_path, use_categories=True, dry_run=False):
    """
    Organize files in the given directory into folders based on file types.
    
    Args:
        directory_path (str): Path to the directory to organize
        use_categories (bool): If True, group by categories; if False, group by exact extensions
        dry_run (bool): If True, only show what would be done without actually moving files
    """
    directory = Path(directory_path)
    
    if not directory.exists():
        print(f"Error: Directory '{directory_path}' does not exist.")
        return False
    
    if not directory.is_dir():
        print(f"Error: '{directory_path}' is not a directory.")
        return False
    
    # Get all files in the directory (excluding subdirectories)
    files = [f for f in directory.iterdir() if f.is_file()]
    
    if not files:
        print(f"No files found in '{directory_path}'.")
        return True
    
    # Group files by their type/category
    file_groups = defaultdict(list)
    
    for file_path in files:
        extension = file_path.suffix
        if use_categories:
            group_name = get_file_category(extension)
        else:
            group_name = extension[1:].upper() + '_Files' if extension else 'No_Extension'
        
        file_groups[group_name].append(file_path)
    
    print(f"Found {len(files)} files in {len(file_groups)} different types/categories:")
    for group_name, group_files in file_groups.items():
        print(f"  {group_name}: {len(group_files)} files")
    
    if dry_run:
        print("\nDRY RUN - No files will be moved. Here's what would happen:")
    
    print()
    
    # Create folders and move files
    moved_count = 0
    for group_name, group_files in file_groups.items():
        # Create the folder for this file type
        folder_path = directory / group_name
        
        if not dry_run:
            folder_path.mkdir(exist_ok=True)
        
        print(f"{'Would create' if dry_run else 'Created'} folder: {folder_path}")
        
        # Move files to the folder
        for file_path in group_files:
            destination = folder_path / file_path.name
            
            # Handle filename conflicts
            counter = 1
            original_destination = destination
            while destination.exists():
                name_parts = original_destination.stem, counter, original_destination.suffix
                destination = folder_path / f"{name_parts[0]}_{name_parts[1]}{name_parts[2]}"
                counter += 1
            
            if dry_run:
                print(f"  Would move: {file_path.name} -> {group_name}/{destination.name}")
            else:
                try:
                    shutil.move(str(file_path), str(destination))
                    print(f"  Moved: {file_path.name} -> {group_name}/{destination.name}")
                    moved_count += 1
                except Exception as e:
                    print(f"  Error moving {file_path.name}: {e}")
    
    if not dry_run:
        print(f"\nOrganization complete! Moved {moved_count} files into {len(file_groups)} folders.")
    else:
        print(f"\nDry run complete! Would move {len(files)} files into {len(file_groups)} folders.")
    
    return True

def main():
    parser = argparse.ArgumentParser(
        description="Organize files in a directory into folders based on file types.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python file_organizer.py /path/to/directory
  python file_organizer.py ~/Downloads --extensions
  python file_organizer.py ./messy_folder --dry-run
        """
    )
    
    parser.add_argument(
        'directory',
        help='Directory path to organize'
    )
    
    parser.add_argument(
        '--extensions',
        action='store_true',
        help='Group by exact file extensions instead of categories'
    )
    
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Show what would be done without actually moving files'
    )
    
    args = parser.parse_args()
    
    # Convert relative path to absolute path
    directory_path = os.path.abspath(args.directory)
    
    print(f"Organizing directory: {directory_path}")
    print(f"Grouping by: {'Extensions' if args.extensions else 'Categories'}")
    print(f"Mode: {'Dry run' if args.dry_run else 'Execute'}")
    print("-" * 50)
    
    success = organize_directory(
        directory_path,
        use_categories=not args.extensions,
        dry_run=args.dry_run
    )
    
    if not success:
        sys.exit(1)

if __name__ == "__main__":
    main()
