#!/bin/bash
set -ex -o pipefail

echo "======================"
echo "01-create-sudo-user.sh"
echo "======================"

# Functions
infecho () {
    echo "[Info] $1"
}

infecho "Adding user \"pine\"..."

adduser pine
passwd pine
groupadd feedbackd
usermod -aG wheel,video,feedbackd pine
