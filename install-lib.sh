#!/bin/bash

LIB_NAME=$1

PKGTYPE=
if [ "$(which apt-get)" != "" ]; then
    PKGTYPE=debian
elif [ "$(which yum)" != "" ]; then
    PKGTYPE=rpm
fi

# 対応するパッケージを探す
if [ "$PKGTYPE" == "debian" ]; then
    package=$(apt-file search $LIB_NAME | head -n 1 | cut -d ":" -f 1)
elif [ "$PKGTYPE" == "rpm" ]; then
    package=$(sudo yum -q whatprovides $LIB_NAME | head -n 1 | awk '{print $1}' | sed 's/^[0-9]*://' | awk -F '-' -v OFS=- 'NF-=2')
fi

echo "Installing package: $package"

# パッケージをインストール
if [ "$PKGTYPE" == "debian" ]; then
    sudo apt-get install -y $package
elif [ "$PKGTYPE" == "rpm" ]; then
    sudo yum -y install $package
fi
