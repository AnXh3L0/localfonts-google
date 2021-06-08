#!/usr/bin/env bash
# Downloads and installs all Google Fonts on your local machine
# Git package needs to be installed
# https://github.com/AnXh3L0

FONTS_FOLDER=./google-fonts/

mkdir -p $FONTS_FOLDER

git clone https://github.com/google/fonts repository/

function move_fonts {
    while read font_path
    do

    echo "Processing file: $font_path"

    cp $font_path $FONTS_FOLDER

    done < "${1:-/dev/stdin}"
}

find ./repository -type f | grep ".ttf" | move_fonts

echo -e "\n\033[32mPlease select all font files, right click and install them!\033[0m\n"