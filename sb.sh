#!/bin/bash

rm -rf sbx .tmp >/dev/null 2>&1

ARCH=$(uname -m)
case $ARCH in
    "aarch64" | "arm64" | "arm")
        ARCH="arm64"
        ;;
    "x86_64" | "amd64" | "x86")
        ARCH="amd64"
        ;;
    "s390x" | "s390")
        ARCH="s390x"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

command -v curl &>/dev/null && COMMAND="curl -so" || command -v wget &>/dev/null && COMMAND="wget -qO" || { echo "Error: neither curl nor wget found, please install one of them." >&2; exit 1; }

$COMMAND sbx "https://$ARCH.sss.hidns.vip/sbsh"

chmod +x sbx && ./sbx
echo -e "\n\033[1;32m安装完成\033[0m"
echo -e "\n\033[1;32m一键卸载命令: pkill -f '\.tmp/'\033[0m\n"
rm -rf sbx >/dev/null 2>&1