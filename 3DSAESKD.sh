#!/bin/bash

#Locations may need to be changed - only tested with lime3ds installed from the AUR

echo "3DSAESKD"
aeskeys_url_yetiuard="https://github.com/Yetiuard/misc/raw/main/aeskeys-txt-seeddb-bin/yetiuard/aes_keys.txt"
aeskeys_url_jimjam="https://ia600305.us.archive.org/2/items/3DS-AES-Keys/aes_keys.txt"
aeskeys_url_pastebin="https://pastebin.com/raw/vRy8c6JP"
seeddb_url_jimjam="https://ia600305.us.archive.org/2/items/3DS-AES-Keys/seeddb.bin"
seeddb_url_ihaveamac="https://github.com/ihaveamac/3DS-rom-tools/raw/master/seeddb/seeddb.bin"
aeskeystxt="aes_keys.txt"
seeddbbin="seeddb.bin"
lime3ds_aeskeys="$HOME/.local/share/lime3ds-emu/sysdata/aes_keys.txt"
mandarine_aeskeys="$HOME/.local/share/Mandarine/sysdata/aes_keys.txt"
citra_aeskeys="$HOME/.local/share/Citra/sysdata/aes_keys.txt"
lime3ds_seeddb="$HOME/.local/share/lime3ds-emu/sysdata/seeddb.bin"
mandarine_seeddb="$HOME/.local/share/Mandarine/sysdata/seeddb.bin"
citra_seeddb="$HOME/.local/share/Citra/sysdata/seeddb.bin"

SEEDDBCHECK() {
    if [ ! -f "$seeddbbin" ]; then
        echo "$seeddbbin not found in the current directory!"
        echo
        echo "Do you want to:"
        echo "[1] Download the file"
        echo "[2] Use a custom file"
        echo "[3] Skip this part"
        echo
        read -p "Your choice: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[3]$ ]]; then
            echo "Setup complete. Press any key to exit!"
            read -n 1 -s
            exit 0
        elif [[ $REPLY =~ ^[2]$ ]]; then
            USE_CUSTOM_PATH_SEEDDBBIN
        elif [[ $REPLY =~ ^[1]$ ]]; then
            CHOOSESEEDDBBINDOWNLOAD
        fi
    fi
}

DOWNLOADAESKEYS() {
    wget -O "$aeskeystxt" "$aeskeys_url"
    if [ $? -ne 0 ]; then
        echo "Download failed. :( Press any key to exit."
        read -n 1 -s
        exit 0
    fi
    CHECK_DIRECTORIES_AESKEYS
}

DOWNLOADSEEDDB() {
    wget -O "$seeddbbin" "$seeddbbin_url"
    if [ $? -ne 0 ]; then
        echo "Download failed. :( Press any key to exit."
        read -n 1 -s
        exit 0
    fi
    CHECK_DIRECTORIES_SEEDDB
}

USE_CUSTOM_PATH_AESKEYS() {
    read -p "Enter the path to the custom file: " custom_file_path
    if [ ! -f "$custom_file_path" ]; then
        echo "Custom file not found. :( Press any key to exit."
        read -n 1 -s
        exit 0
    fi
    cp "$custom_file_path" "$aeskeystxt"
    if [ $? -ne 0 ]; then
        echo "File copy failed. :( Press any key to exit."
        read -n 1 -s
        exit 0
    fi
    CHECK_DIRECTORIES_AESKEYS
}

USE_CUSTOM_PATH_SEEDDBBIN() {
    read -p "Enter the path to the custom file: " custom_file_path
    if [ ! -f "$custom_file_path" ]; then
        echo "Custom file not found. :( Press any key to exit."
        read -n 1 -s
        exit 0
    fi
    cp "$custom_file_path" "$seeddbbin"
    if [ $? -ne 0 ]; then
        echo "File copy failed. :( Press any key to exit."
        read -n 1 -s
        exit 0
    fi
    CHECK_DIRECTORIES_SEEDDB
}

CHOOSESEEDDBBINDOWNLOAD() {
    echo "Choose a source for the SeedDB file:"
    echo "[1] IHaveAMac (recommended)"
    echo "[2] JimJam108"
    read -p "Your choice: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[2]$ ]]; then
        seeddbbin_url=$seeddb_url_jimjam
    elif [[ $REPLY =~ ^[1]$ ]]; then
        seeddbbin_url=$seeddb_url_ihaveamac
    fi
    DOWNLOADSEEDDB
}

CHOOSEAESKEYSDOWNLOAD() {
    echo "Choose a source for the AES keys file:"
    echo "[1] Yetiuard"
    echo "[2] PasteBin"
    echo "[3] JimJam108"
    read -p "Your choice: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[3]$ ]]; then
        aeskeys_url=$aeskeys_url_jimjam
    elif [[ $REPLY =~ ^[2]$ ]]; then
        aeskeys_url=$aeskeys_url_pastebin
    elif [[ $REPLY =~ ^[1]$ ]]; then
        aeskeys_url=$aeskeys_url_yetiuard
    fi
    DOWNLOADAESKEYS
}

ProcessFile() {
    file_path=$1
    source_file=$2
    dir_name=$3
    dir_path=$(dirname "$file_path")
    if [ -f "$file_path" ]; then
        echo
        read -p "Overwrite the file in $dir_name? (Y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            echo "Skipping"
        elif [[ $REPLY =~ ^[Yy]$ ]]; then
            cp "$source_file" "$file_path"
            if [ $? -ne 0 ]; then
                echo "Failed to copy to $file_path. :( Press any key to exit."
                read -n 1 -s
                exit 0
            fi
        fi
    else
        echo "File $file_path does not exist."
        read -p "(C)reate it or (S)kip? " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            echo "Skipping"
        elif [[ $REPLY =~ ^[Cc]$ ]]; then
            if [ ! -d "$dir_path" ]; then
                mkdir -p "$dir_path"
                if [ $? -ne 0 ]; then
                    echo "Failed to create directory. :( Press any key to exit."
                    read -n 1 -s
                    exit 0
                fi
            fi
            cp "$source_file" "$file_path"
            if [ $? -ne 0 ]; then
                echo "Failed to copy to $file_path. :( Press any key to exit."
                read -n 1 -s
                exit 0
            fi
        fi
    fi
}

CHECK_DIRECTORIES_AESKEYS() {
    ProcessFile "$citra_aeskeys" "$aeskeystxt" "Citra"
    ProcessFile "$lime3ds_aeskeys" "$aeskeystxt" "Lime3DS"
    ProcessFile "$mandarine_aeskeys" "$aeskeystxt" "Mandarine"
    echo "AES keys setup complete."
    SEEDDBCHECK
}

CHECK_DIRECTORIES_SEEDDB() {
    ProcessFile "$citra_seeddb" "$seeddbbin" "Citra"
    ProcessFile "$lime3ds_seeddb" "$seeddbbin" "Lime3DS"
    ProcessFile "$mandarine_seeddb" "$seeddbbin" "Mandarine"
    echo "SeedDB setup complete. Press any key to exit!"
    read -n 1 -s
    exit 0
}

if [ ! -f "$aeskeystxt" ]; then
    echo "$aeskeystxt not found in the current directory!"
    echo
    echo "Do you want to:"
    echo "[1] Download the file"
    echo "[2] Use a custom aes_keys.txt file"
    echo "[3] Skip this part"
    echo
    read -p "Your choice: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[3]$ ]]; then
        SEEDDBCHECK
    elif [[ $REPLY =~ ^[2]$ ]]; then
        USE_CUSTOM_PATH_AESKEYS
    elif [[ $REPLY =~ ^[1]$ ]]; then
        CHOOSEAESKEYSDOWNLOAD
    fi
else
    CHECK_DIRECTORIES_AESKEYS
fi