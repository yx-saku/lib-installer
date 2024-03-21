#!/bin/bash

s=" \f\n\r\t"

COMMAND=$1

PKGTYPE=
if [ "$(which apt-get)" != "" ]; then
    PKGTYPE=debian
elif [ "$(which yum)" != "" ]; then
    PKGTYPE=rpm
fi

if [ "$PKGTYPE" == "debian" ]; then
    sudo apt-get install -y apt-file
    sudo apt-file update
fi

packages=
while true; do
    # コマンド実行
    output=$($COMMAND 2>&1)

    # ライブラリ名取得
    lib=$(echo $output | sed -E "s/^(.*?[$s])?([^$s:]+\.so[^$s:]+)?.*$/\2/")
    if [ "$lib" != "" ]; then
        echo "Missing library: $lib"

        # 対応するパッケージを探す
        if [ "$PKGTYPE" == "debian" ]; then
            package=$(apt-file search $lib | head -n 1 | cut -d ":" -f 1)
        elif [ "$PKGTYPE" == "rpm" ]; then
            package=$(sudo yum -q whatprovides $library | head -n 1 | awk '{print $1}' | sed 's/^[0-9]*://' | awk -F '-' -v OFS=- 'NF-=2')
        fi

        echo "Installing package: $package"

        # パッケージをインストール
        if [ "$PKGTYPE" == "debian" ]; then
            sudo apt-get install -y $package
        elif [ "$PKGTYPE" == "rpm" ]; then
            sudo yum -y install $package
        fi

        packages="$packages $package"
    else
        echo "No missing libraries found"
        break
    fi
done

echo $packages
