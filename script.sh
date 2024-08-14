#!/usr/bin/env bash
# Downloads and installs all Google Fonts on your local machine
# Git package needs to be installed
# https://github.com/AnXh3L0

FONTS_FOLDER=./google-fonts/

mkdir -p $FONTS_FOLDER

# Shallow clone of only the latest commit without the full history
git clone --depth=1 https://github.com/google/fonts repository/

function move_fonts {
    while read font_path
    do
        echo "Processing file: $font_path"
        cp $font_path $FONTS_FOLDER
    done < "${1:-/dev/stdin}"
}

# Find only .ttf files and move them directly
find ./repository -type f -name "*.ttf" | move_fonts

echo ""
read -p "Do you want to delete the cloned folder? [Y/n]: " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then 
    rm -rf repository/
    echo -e "\n\nFolder deleted!"
elif [[ $REPLY =~ ^[Nn]$ ]]
then
    echo -e "\n\nOkay, not touching the folder!"
fi

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac
echo -e "\n\033[33m==> Operating system detected as ${machine}\033[0m\n"

# Function to move files with checks for existing files
function move_fonts_to_system {
    local system_fonts_folder=$1
    
    # Create the fonts folder if it doesn't exist
    if [ ! -d "$system_fonts_folder" ]; then
        mkdir -p "$system_fonts_folder"
        echo "Fonts directory created at $system_fonts_folder"
    fi

    echo "Moving all files to the system fonts folder..."

    for font_file in $FONTS_FOLDER/*; do
        base_font_file=$(basename "$font_file")
        
        # Check if the file already exists
        if [ -f "$system_fonts_folder/$base_font_file" ]; then
            echo "File $base_font_file already exists in the system fonts folder. Skipping..."
        else
            mv "$font_file" "$system_fonts_folder/"
            echo "Moved $base_font_file to $system_fonts_folder"
        fi
    done
}

if [[ ${machine} = "Linux" ]]
then
    move_fonts_to_system ~/.fonts/
    rm -rf google-fonts/
    echo -e "\n\033[1;32m==========\
    Fonts copied, you can now start using them!\
    ==========\n"
elif [[ ${machine} = "Mac" ]]
then
    move_fonts_to_system ~/Library/Fonts/
    rm -rf google-fonts/
    echo -e "\n\033[1;32m==========\
    Fonts copied, you can now start using them!\
    ==========\n"
fi
