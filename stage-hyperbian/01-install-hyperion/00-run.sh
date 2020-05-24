#!/bin/bash -e

# Select the appropriate download path
HYPERION_DOWNLOAD_URL="https://github.com/hyperion-project/hyperion.ng/releases/download"
HYPERION_RELEASES_URL="https://api.github.com/repos/hyperion-project/hyperion.ng/releases"

# Get the latest version
HYPERION_LATEST_VERSION=$(curl -sL "$HYPERION_RELEASES_URL" | grep "tag_name" | head -1 | cut -d '"' -f 4)
HYPERION_RELEASE=$HYPERION_DOWNLOAD_URL/$HYPERION_LATEST_VERSION/Hyperion-$HYPERION_LATEST_VERSION-Linux-armv7hf-rpi.deb

# Download latest release
wget -q $HYPERION_RELEASE -O ${ROOTFS_DIR}/tmp/hyperion.deb

on_chroot << EOF
echo '>>> Install latest Hyperion'
dpkg -i /tmp/hyperion.deb
EOF

