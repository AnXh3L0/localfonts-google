#!/usr/bin/env bash
# Automatically checks and installs new Google Fonts every 7 days
# Git package needs to be installed
# https://github.com/AnXh3L0

FONTS_FOLDER=./google-fonts/
REPO_FOLDER=./repository/
TRACKER_FILE=./installed_fonts.txt
CHECK_INTERVAL_DAYS=7

mkdir -p $FONTS_FOLDER

# Check if the repository exists and clone or update it accordingly
if [ ! -d "$REPO_FOLDER" ]; then
    echo "Cloning Google Fonts repository..."
    git clone --depth=1 https://github.com/google/fonts $REPO_FOLDER
else
    echo "Updating Google Fonts repository..."
    git -C $REPO_FOLDER pull --ff-only
fi

# Initialize tracker file if it doesn't exist
if [ ! -f "$TRACKER_FILE" ]; then
    touch "$TRACKER_FILE"
fi

# Function to install new fonts
function install_new_fonts {
    while read -r font_path; do
        base_font_file=$(basename "$font_path")
        
        if ! grep -q "$base_font_file" "$TRACKER_FILE"; then
            echo "Processing new font: $base_font_file"
            rsync -a "$font_path" "$FONTS_FOLDER/"
            echo "$base_font_file" >> "$TRACKER_FILE"
        else
            echo "Font $base_font_file already installed. Skipping..."
        fi
    done < <(find "$REPO_FOLDER" -type f -name "*.ttf")
}

install_new_fonts

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac
echo -e "\n\033[33m==> Operating system detected as ${machine}\033[0m\n"

# Function to move fonts to the system fonts folder
function move_fonts_to_system {
    local system_fonts_folder=$1
    
    # Create the fonts folder if it doesn't exist
    if [ ! -d "$system_fonts_folder" ]; then
        mkdir -p "$system_fonts_folder"
        echo "Fonts directory created at $system_fonts_folder"
    fi

    echo "Moving all new fonts to the system fonts folder..."
    rsync -a --ignore-existing "$FONTS_FOLDER/" "$system_fonts_folder/"
}

if [[ ${machine} = "Linux" ]]; then
    move_fonts_to_system ~/.fonts/
elif [[ ${machine} = "Mac" ]]; then
    move_fonts_to_system ~/Library/Fonts/
fi

# Clean up
rm -rf "$FONTS_FOLDER"

echo -e "\n\033[1;32m==========\
Fonts copied, you can now start using them!\
==========\n"

# Set up cron job for automatic updates
cron_job="0 0 */$CHECK_INTERVAL_DAYS * * $PWD/$(basename $0)"

# Check if cron job already exists
if ! crontab -l | grep -q "$PWD/$(basename $0)"; then
    (crontab -l; echo "$cron_job") | crontab -
    echo "Cron job added to check for new fonts every $CHECK_INTERVAL_DAYS days."
else
    echo "Cron job already exists."
fi
