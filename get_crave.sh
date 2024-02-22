#!/bin/bash
# Copyright (c) 2020-2024 Crave crave.io Inc. All rights reserved

os='linux'
crave_url_base='https://github.com/accupara/crave/releases/download/'
crave_version='0.2-6920'
crave_arch='amd64'
crave_postfix='.bin'
crave_default_location='/usr/local/bin'

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    os='linux'
    crave_arch=`uname -m`
    if [[ "$crave_arch" == "arm64" ]]; then
        crave_arch="aarch64"
    fi
    if [[ "$crave_arch" == "x86_64" ]]; then
        crave_arch="amd64"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    os='darwin'
else
    # Unknown.
    os='unknown'
fi

if [[ "os" == 'unknown' ]]; then
    echo Only OSX and Linux are supported for auto installation at this time
    exit 1
fi

crave_url="$crave_url_base/$crave_version/crave-$crave_version-$os-$crave_arch$crave_postfix"

curl -L $crave_url --output crave
chmod +x crave


if [ -p /dev/stdin ] ; then
    install_crave=false
else
    echo -n "Install to system path (default: /usr/local/bin) [y]/n ? "
    read ans
    case $ans in
        Y|y|1|"" ) install_crave=true;;
        N|n|2 )  echo "Skpping crave install"; install_crave=false;;
        *     )  echo "Unknow input"; exit ;;
    esac
fi

if [[ $install_crave == true ]]; then
    echo -n "Location to install crave [/usr/local/bin]: "
    read crave_location
    if [[ "$crave_locatin" == "" ]]; then
       crave_location="$crave_default_location"
    fi
    echo "Installing crave to location $crave_location (will require root)"
    sudo mv ./crave "$crave_location"
fi
