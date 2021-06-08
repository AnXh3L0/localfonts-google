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

if [[ ${machine} = "Linux" ]]
then
    mkdir ~/.fonts/
    echo "Fonts directory created!"
    echo "Moving all files to the fonts folder!"
    sleep 1.5s
    mv google-fonts/* ~/.fonts/
    rm -rf google-fonts/
    echo -e "\n\033[1;32m==========\
    Fonts copied, you can now start using them!\
    ==========\n"
elif [[ ${machine} = "Mac" ]]
then
    echo "Moving all files to the fonts folder!"
    sleep 1.5s
    mv google-fonts/* ~/Library/Fonts/
    rm -rf google-fonts/
    echo -e "\n\033[1;32m==========\
    Fonts copied, you can now start using them!\
    ==========\n"
fi