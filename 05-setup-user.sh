#!/bin/bash
set -e

source .env

HOSTARCH=$(uname -m)

echo "================"
echo "05-setup-user.sh"
echo "================"

# Functions
infecho () {
    echo "[Info] $1"
}

# Notify User
infecho "The env vars that will be used in this script..."
infecho "PP_PARTB = $PP_PARTB"
echo

# Automatic Preflight Checks
if [[ $EUID -ne 0 ]]; then
    errecho "This script must be run as root!" 
    exit 1
fi

# Warning
echo "=== WARNING WARNING WARNING ==="
infecho "I didn't test this so it might also cause WWIII or something."
infecho "I'm not responsible for anything that happens, you should read the script first."
echo "=== WARNING WARNING WARNING ==="
echo
if [ ! -z "$PS1" ]; then
    read -p "Continue? [y/N] " -n 1 -r
else
    REPLY=y
fi
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
   infecho "Mounting rootfs..."
    mkdir -p rootfs
    mount $PP_PARTB rootfs

    infecho "Mounting bootfs..."
    mkdir -p rootfs/boot
    mount $PP_PARTA rootfs/boot

    if [[ $HOSTARCH != "aarch64" ]]; then
        infecho "Installing qemu in rootfs..."
        cp /usr/bin/qemu-aarch64-static rootfs/usr/bin
    fi

    cp phone-scripts/* rootfs/root

    infecho "Copy resolv.conf /etc/tmp-resolv.conf"
    cp /etc/resolv.conf rootfs/etc/tmp-resolv.conf

    if [[ $HOSTARCH != "aarch64" ]]; then
        infecho "Chrooting with qemu into rootfs..."
        systemd-nspawn -D rootfs qemu-aarch64-static /bin/bash /root/all.sh

        infecho "KILLING ALL QEMU PROCESSES, MAKE SURE YOU HAVE NO MORE RUNNING!"
        killall -9 /usr/bin/qemu-aarch64-static || true

        infecho "Removing qemu binary, so it doesn't stay in image"
        rm -f rootfs/usr/bin/qemu-aarch64-static
    else
        infecho "Chrooting into rootfs..."
        chroot rootfs /bin/bash /root/all.sh
    fi

    infecho "Unmounting rootfs..."
    sleep 3
    umount $PP_PARTA
    umount $PP_PARTB
    rmdir rootfs
    df -h
fi
