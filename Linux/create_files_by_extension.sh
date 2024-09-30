#!/bin/bash

# Check if the correct number of arguments is supplied
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <file_extension> <file_path>"
    exit 1
fi

# Assign arguments to variables
file_extension=$1
file_path=$2

# Check if the specified file exists
if [ ! -f "$file_path" ]; then
    echo "File not found: $file_path"
    exit 1
fi

# Get the directory of the file path
directory=$(dirname "$file_path")

# Read the file line by line
while IFS= read -r line; do
    # Create a valid filename by replacing whitespace and special characters with _
    filename=$(echo "$line" | tr -s ' ' '_' | tr -dc '[:alnum:]_' | tr '[:upper:]' '[:lower:]')
    
    # Append the specified file extension
    new_file="$directory/$filename.$file_extension"
    
    # Create the new file
    touch "$new_file"
    
    echo "Created: $new_file"
done < "$file_path"