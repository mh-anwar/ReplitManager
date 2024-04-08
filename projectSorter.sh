#!/bin/bash

echo "Where are all the projects located?  Current Dir: $(pwd)"
printf "%s/" "$HOME"
read sourcePath

echo "Where would you like to move the projects to?"
printf "%s/" "$HOME"
read destinationPath

# Check if source path exists
if [ ! -d "$HOME/$sourcePath" ]; then
    echo "\nSource path does not exist."
    exit 1
fi

# Check if destination path exists
if [ ! -d "$HOME/$destinationPath" ]; then
    echo "\nDestination path does not exist."
    exit 1
fi

# Check if .projekts file exists
if [ ! -f ".projekts" ]; then
    echo "\n.projekts file not found."
    exit 1
fi

# Read .projekts file, line by line
while IFS= read -r line
do 
    # Move each file from source to destination
    # Copy the file for now (later it will be mv)
    cp "$HOME/$sourcePath/$line" "$HOME/$destinationPath"
done < ".projekts"

# Now extract each .zip file into same directory

# Clean-up/delete Replit system files

# Initialize git

# Add each folder, commit, modify commit dates to match project, push to GitHub



