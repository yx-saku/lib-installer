#!/bin/bash

s=" \f\n\r\t"
SHELL_PATH=$(cd $(dirname $0); pwd)

COMMAND=$1

PKGTYPE=
if [ "$(which apt-get)" != "" ]; then
    PKGTYPE=debian
elif [ "$(which yum)" != "" ]; then
    PKGTYPE=rpm
fi

if [ "$PKGTYPE" == "debian" ]; then
    if ! apt-file --version > /dev/null 2>&1; then
        sudo apt-get install -y apt-file
    fi
    sudo apt-file update
fi

packages=
while true; do
    # コマンド実行
    output=$($COMMAND 2>&1)

    # ライブラリ名取得
    lib=
    for word in $output; do
        if [[ $word == *".so"* ]]; then
            # ファイル名に使えない文字を除去
            lib=$(echo "$word" | sed 's/[^a-zA-Z0-9._-]//g')
            break
        fi
    done
    
    if [ "$lib" != "" ]; then
        echo "Missing library: $lib"

        . $SHELL_PATH/install-lib.sh $lib

        packages="$packages $package"
    else
        echo "No missing libraries found"
        break
    fi
done

echo $packages
