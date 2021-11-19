#!/bin/sh
# Copyright (c) 2020-2021 crave.io Inc. All rights reserved

OS='linux'
crave_url_base='https://github.com/accupara/crave/releases/download/'
crave_version='0.2-6451'
crave_postfix='amd64.bin'


if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    os='linux'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    os='darwin'
else
    # Unknown.
    os='unknown'
fi

if [[ "OS" == 'unknown' ]]; then
    echo Only OSX and Linux are supported for auto installation at this time
    exit 1
fi

crave_url="$crave_url_base/$crave_version/crave-$crave_version-$os-$crave_postfix"

curl -L $crave_url --output crave
chmod +x crave
