#!/bin/bash
# Copyright (c) 2020-2023 Crave crave.io Inc. All rights reserved

os='linux'
crave_url_base='https://github.com/accupara/crave/releases/download/'
crave_version='0.2-6798'
crave_arch='amd64'
crave_postfix='.bin'

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
echo $crave_url
curl -L $crave_url --output crave
chmod +x crave
