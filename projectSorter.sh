#!/bin/bash

# Function to add and commit all files in the current directory
function git_add_commit() {
    # Iterate through all files in the current directory
    for file in * .*; do
        # Skip . and ..
        if [[ "$file" == "." || "$file" == ".." ]]; then
            continue
        fi
        
        # Check if the file exists
        if [ -e "$file" ]; then
            # Check if the file is a directory
            if [ -d "$file" ]; then
                # If it's a directory, enter it and recursively call git_add_commit
                cd "$file" || exit
                git_add_commit
                cd .. || exit
            else
                # If it's a file, add it to the staging area and commit with the last modified date
                git add "$file"
                last_modified=$(stat -c %Y "$file")
                fileName=$(basename "$file")
                git commit -q -m "Commit $fileName at $(date -d @"$last_modified" +'%Y-%m-%d %H:%M:%S')" --date="$(date -d @"$last_modified" +'%Y-%m-%d %H:%M:%S')" "$file"
            fi
        fi
    done
}

# Main program
echo "Where are all the projects located?  Current Dir: $(pwd)"
printf "%s/" "$HOME"
read sourcePath

printf "\nWhere would you like to move the projects to?"
printf "\n%s/" "$HOME"
read destinationPath

# Check if source path exists
if [ ! -d "$HOME/$sourcePath" ]; then
    echo "\nSource path does not exist."
    exit 1
fi

# Check if destination path exists
if [ ! -d "$HOME/$destinationPath" ]; then
    printf "\nDestination path does not exist. Creating it now..."
    mkdir "$HOME/$destinationPath"
fi

# Check if .projekts file exists
if [ ! -f ".projekts" ]; then
    echo ".projekts file not found."
    exit 1
fi

printf "\nNow installing unzip (if not already installed), please provide sudo permissions"
sudo apt-get install unzip

# Copy .projekts to destination
cp .projekts "$HOME/$destinationPath"

# Change into destination path
cd "$HOME/$destinationPath"

printf "\nInitializing Git"
# Initialize git
git init

# Read .projekts file, line by line
while IFS= read -r line
do
    destFolder="${line%.zip}"
    printf "\nExtracting and cleaning $line"

    #! Unzip from source directly to destination and delete zip file
    unzip -q "$HOME/$sourcePath/$line" -d "$HOME/$destinationPath/$destFolder"
    # rm -rf "$HOME/$destinationPath/$line"

    #! Cleanup
    # Change into folder
    cd "$HOME/$destinationPath/$destFolder"
    
    # Delete error log file if it exists
    [ -f "replit_zip_error_log.txt" ] && rm "replit_zip_error_log.txt" 

    # Delete .git directory if it exists
    [ -d ".git" ] && rm -rf ".git"   

    # Delete .log files
    find . -name "*.log" -type f -delete

    # Delete .cache directory if it exists
    [ -d ".cache" ] && rm -rf ".cache"

    # Change back to parent directory
    cd "$HOME/$destinationPath"

    #! Old code
    # Copy each file from source to destination (switch to mv after testing)
    # cp -r "$HOME/$sourcePath/$line" "$HOME/$destinationPath"
    # git add "$HOME/$destinationPath/$destFolder"
    # git commit -m "Added $destFolder" --date="`date -r $HOME/$destinationPath/$destFolder/Main.class`"
    # git commit -m "Added $destFolder" --date="`date -r $HOME/$sourcePath/$line`"

done < ".projekts"
rm .projekts

# Loop through entire directory and sub directories, git add and commit every file and folder
# Find all files, including hidden ones, and loop through them
find . -type f -print0 | while IFS= read -r -d '' file; do
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


# git_add_commit

printf "\nAll projects have been extracted, and committed at $HOME/$destinationPath"










