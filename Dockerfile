FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y jq curl wget unzip sudo

# chrome
RUN PACKAGE_URL=$( \
    curl "https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json" | \
    jq -r '.channels.Stable.downloads.chrome[] | select(.platform == "linux64") | .url') && \
    wget $PACKAGE_URL && \
    unzip chrome-linux64.zip && \
    ln -sf "$(pwd)/chrome-linux64/chrome" /usr/bin/chrome

# lib-installerを使ってインストールする
# libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libxcomposite1 libxdamage1 libdrm2 libxfixes3 libxrandr2 libgbm1 libxkbcommon0 libasound2
COPY install-dependencies.sh /install-dependencies.sh
COPY install-lib.sh /install-lib.sh

ENTRYPOINT [ "/install-dependencies.sh", "chrome --version" ]