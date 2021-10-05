#!/bin/bash
set -e

source .env

HOSTARCH=$(uname -m)

echo "=============="
echo "00-selftest.sh"
echo "=============="

infecho () {
    echo "[Info] $1"
}
errecho () {
    echo "[Error] $1" 1>&2
    exit 1
}

infecho "Now running selftest, please do not continue running scripts until this completes successfully."

if [[ $EUID -ne 0 ]]; then
    errecho "This script must be run as root!" 
    exit 1
fi

command -v mkfs.btrfs >/dev/null 2>&1 || { echo >&2 "I require mkfs.btrfs but it's not installed.  Aborting."; exit 1; }
command -v mkfs.vfat >/dev/null 2>&1 || { echo >&2 "I require mkfs.vfat but it's not installed.  Aborting."; exit 1; }

if [[ $HOSTARCH != "aarch64" ]]; then
    command -v qemu-aarch64-static >/dev/null 2>&1 || { echo >&2 "I require qemu-aarch64-static but it's not installed.  Aborting."; exit 1; }
fi

command -v rsync >/dev/null 2>&1 || { echo >&2 "I require rsync but it's not installed.  Aborting."; exit 1; }
command -v mkimage >/dev/null 2>&1 || { echo >&2 "I require mkimage but it's not installed.  Aborting."; exit 1; }

infecho "Selftest complete!"
