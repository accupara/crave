#!/bin/bash
# Copyright (c) 2020-2024 Crave crave.io Inc. All rights reserved

os='linux'
crave_url_base='https://github.com/accupara/crave/releases/latest/download/'
crave_arch=$(uname -m)
crave_postfix='.bin'
crave_default_location='/usr/local/bin'

if [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    os='darwin'
    crave_arch="amd64"  # For macOS, using amd64 architecture
elif [[ "$crave_arch" == "arm64" ]]; then
    # Arm architecture
    crave_arch="aarch64"
elif [[ "$crave_arch" == "x86_64" ]]; then
    # AMD64 architecture
    crave_arch="amd64"
fi

if [[ "$os" == 'unknown' ]]; then
    echo "Only OSX and Linux are supported for auto installation at this time"
    exit 1
fi

crave_url=$(wget -q -O - https://api.github.com/repos/accupara/crave/releases/latest | jq -r '.assets[] | select(.name | contains("'"$os-$crave_arch$crave_postfix"'")) | .browser_download_url')

if [[ "$crave_url" == "null" ]]; then
    echo "Unable to fetch the download link. Please try again later."
    exit 1
fi

wget "$crave_url" -O crave
chmod +x crave

if [ -p /dev/stdin ]; then
    install_crave=false
else
    echo -n "Install to system path (default: /usr/local/bin) [y]/n ? "
    read ans
    case $ans in
        Y|y|1|"" ) install_crave=true;;
        N|n|2 )  echo "Skipping crave install"; install_crave=false;;
        *     )  echo "Unknown input"; exit ;;
    esac
fi

if [[ $install_crave == true ]]; then
    echo -n "Location to install crave [/usr/local/bin]: "
    read crave_location
    if [[ "$crave_location" == "" ]]; then
       crave_location="$crave_default_location"
    fi
    echo "Installing crave to location $crave_location (will require root)"
    sudo mv ./crave "$crave_location"
fi
