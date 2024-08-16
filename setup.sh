#!/bin/bash

echo "THE DOT FILES"
echo "============="
echo ""
echo "Setting up NeoVim..."

SOURCE_FOLDER="$HOME/thedotfiles"
DEST_FOLDER="$HOME/.config"

# Check if the config folder exists
if [ ! -d "$DEST_FOLDER" ]; then
    mkdir "$DEST_FOLDER"
fi

# Check if the destination folder exists
if [ -d "$DEST_FOLDER/nvim" ]; then
    echo "Destination folder exists. Removing it..."
    rm -rf "$DEST_FOLDER/nvim"
fi

# Create symbolic link to the source folder at the destination path
ln -s "$SOURCE_FOLDER/nvim" "$DEST_FOLDER/nvim"

echo "Finished setting up NeoVim"

echo ""

echo "Setting up Dicts..."
ln -s "$SOURCE_FOLDER/dicts" "$DEST_FOLDER/dicts"

echo "Done..."
