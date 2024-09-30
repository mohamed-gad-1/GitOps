####################################################################################################################################
# This script should take two parameters, a file path and a folder path
# the script should search the folder path and find all the files with the same extension as the file path in the argument
# the script should read the full content of the file path in the argument and add them to the top of each file found in the folder path
# and ensure adding a break line after the added content
#
# Explanation of the Script
# Argument Validation: The script checks if exactly two arguments are provided.
# File Existence Check: It verifies if the specified file exists.
# Extension Extraction: It extracts the extension of the provided file.
# Content Reading: It reads the full content of the specified file.
# File Processing: It searches the given folder for files with the same extension and prepends the content followed by a new line.
# Temporary File Handling: It writes the updated content to a temporary file and then replaces the original file.
####################################################################################################################################

#!/bin/bash

# Check if the correct number of arguments is supplied
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <file_path> <folder_path>"
    exit 1
fi

# Assign arguments to variables
file_path=$1
folder_path=$2

# Check if the specified file exists
if [ ! -f "$file_path" ]; then
    echo "File not found: $file_path"
    exit 1
fi

# Get the extension of the provided file
file_extension="${file_path##*.}"

# Read the content of the file
content=$(<"$file_path")

# Find and prepend content to each file with the same extension in the specified folder
shopt -s nullglob
for target_file in "$folder_path"/*."$file_extension"; do
    if [ -f "$target_file" ]; then
        # Prepend content to the target file
        {
            echo "$content"
            echo ""  # Adding a break line
            cat "$target_file"
        } > "$target_file.tmp"
        
        # Replace the original file with the updated one
        mv "$target_file.tmp" "$target_file"
        
        echo "Prepended content to: $target_file"
    fi
done