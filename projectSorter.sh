#!/bin/bash

# Patterns of files to be deleted
file_patterns=(
    "*.log"
    "*.class"
    "*.project"
    ".breakpoints"
    ".classpath"
    ".replit"
    "replit.nix"
)

# Directories to be removed
directories=(
    ".settings"
    ".upm"
    "target/dependency"
    ".git"
    ".cache"
)

# $ UTILITY FUNCTIONS
# Function to echo text in red color
function echo_red {
    echo -e "\e[91m$@\e[0m"
}

# Function to echo text in blue color
function echo_blue {
    echo -e "\e[94m$@\e[0m"
}

# Function to echo text in green color
function echo_green {
    echo -e "\e[92m$@\e[0m"
}

# Function to echo text in yellow color
function echo_yellow {
    echo -e "\e[93m$@\e[0m"
}
echo_blue "Welcome to Project Sorter - this will sort, clean, add and commit your projects to a git repository"

# ! Let user select what files and directories to delete
echo_red "By default the following files and directories will be deleted:"
echo "Files: ${file_patterns[@]}"
echo "Directories: ${directories[@]}"
echo
echo_red "Pressing enter will choose yes"
echo
# Ask user for file deletions with default "y"
deleted_files=()
for pattern in "${file_patterns[@]}"; do
    read -p "Do you want to delete files matching '$pattern'? (Y/n): " -r choice
    choice=${choice:-Y}  # default to "Y" if no input provided
    if [[ $choice == [yY] ]]; then
        deleted_files+=("$pattern")
    fi
done

# Ask user for directory deletions with default "y"
deleted_directories=()
for dir in "${directories[@]}"; do
    read -p "Do you want to delete directory '$dir'? (Y/n): " -r choice
    choice=${choice:-Y}  # default to "Y" if no input provided
    if [[ $choice == [yY] ]]; then
        deleted_directories+=("$dir")
    fi
done

# Display selected deletions
echo
echo_yellow "Selected files to delete: ${deleted_files[@]}"
echo_yellow "Selected directories to delete: ${deleted_directories[@]}"

# ! Ask user for source and destination paths
echo ""
echo_blue "Where are all the projects located?  Current Dir: $(pwd)"
printf "%s/" "$HOME"
read sourcePath

echo_blue "\nWhere would you like to move the projects to?"
printf "%s/" "$HOME"
read destinationPath

# ! Check to see that paths exist
# Check if source path exists
if [ ! -d "$HOME/$sourcePath" ]; then
    echo
    echo "Source path does not exist."
    exit 1
fi

# Check if destination path exists
if [ ! -d "$HOME/$destinationPath" ]; then
    echo
    echo "Destination path does not exist. Creating it now..."
    mkdir "$HOME/$destinationPath"
fi

# Check if .projekts file exists
if [ ! -f ".projekts" ]; then
    echo ".projekts file not found."
    exit 1
fi

# ! Install prerequisites
echo_yellow "\nNow installing unzip (if not already installed), please provide sudo permissions"
sudo apt-get install unzip

# ! Do base setup
# Copy .projekts to destination
cp .projekts "$HOME/$destinationPath"

# Change into destination path
cd "$HOME/$destinationPath"
echo
echo_blue "Initializing Git"
# Initialize git
git init

# ! Start extracting and cleaning out folders
# Read .projekts file, line by line
while IFS= read -r line
do
    destFolder="${line%.zip}"
    echo
    echo_green "Extracting and cleaning $line"

    #! Unzip from source directly to destination and delete zip file
    unzip -q "$HOME/$sourcePath/$line" -d "$HOME/$destinationPath/$destFolder"
    # rm -rf "$HOME/$destinationPath/$line"

    #! Cleanup
    # Change into folder
    cd "$HOME/$destinationPath/$destFolder" || { echo "Failed to change directory to $HOME/$destinationPath/$destFolder"; exit 1; }
   
    # Delete error log file if it exists
    [ -f "replit_zip_error_log.txt" ] && rm "replit_zip_error_log.txt"

    # Delete files matching patterns
    for pattern in "${deleted_files[@]}"; do
        find . -name "$pattern" -type f -delete
    done

    # Remove directories
    for dir in "${deleted_directories[@]}"; do
        if [ -d "$dir" ]; then
            echo "Removing directory: $dir"
            rm -rf "$dir"
        else
            echo "Directory not found: $dir"
        fi
    done

    # Change back to parent directory
    cd "$HOME/$destinationPath"

done < ".projekts"
rm .projekts

# ! Git add and commit all files
# Loop through entire directory and sub directories, git add and commit every file and folder
# Find all files, including hidden ones, and loop through them
find . -type f -print0 | while IFS= read -r -d '' file; do
    echo_green "Adding and committing $file"
    # Add the file to git
    git add "$file"

    # Get the last modified date of the file
    last_modified=$(stat -c %Y "$file")
    formatted_date=$(date -d "@$last_modified" +"%a, %d %b %Y %H:%M:%S %z")
    echo "Last modified: $formatted_date"

    # Commit the file with a meaningful message and correct date
    git commit -q -m "Add code from $formatted_date" --date="$formatted_date"
    GIT_COMMITTER_DATE="$formatted_date" git commit -q --amend --date="$formatted_date" --no-edit
done


printf "\nAll projects have been extracted, and committed at $HOME/$destinationPath"