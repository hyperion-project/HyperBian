#!/bin/bash -e

# Select the appropriate download path
HYPERION_DOWNLOAD_URL="https://github.com/hyperion-project/hyperion.ng/releases/download"
HYPERION_RELEASES_URL="https://api.github.com/repos/hyperion-project/hyperion.ng/releases"

# Get the latest version
HYPERION_LATEST_VERSION=$(curl -sL "$HYPERION_RELEASES_URL" | grep "tag_name" | head -1 | cut -d '"' -f 4)
HYPERION_RELEASE=$HYPERION_DOWNLOAD_URL/$HYPERION_LATEST_VERSION/Hyperion-$HYPERION_LATEST_VERSION-Linux-armv6l.deb

# Download latest release
echo 'Downloading Hyperion ........................'
mkdir -p "$ROOTFS_DIR"/tmp
curl -L $HYPERION_RELEASE --output "$ROOTFS_DIR"/tmp/hyperion.deb

# Enable SPI and force HDMI output
sed -i "s/^#dtparam=spi=on.*/dtparam=spi=on/" ${ROOTFS_DIR}/boot/config.txt
sed -i "s/^#hdmi_force_hotplug=1.*/hdmi_force_hotplug=1/" ${ROOTFS_DIR}/boot/config.txt

# Modify /usr/lib/os-release
sed -i "s/Raspbian/HyperBian/gI" ${ROOTFS_DIR}/usr/lib/os-release
sed -i "s/^NAME=.*$/NAME=\"HyperBian ${HYPERION_LATEST_VERSION}\"/g" ${ROOTFS_DIR}/usr/lib/os-release
sed -i "s/^VERSION=.*$/VERSION=\"${HYPERION_LATEST_VERSION}\"/g" ${ROOTFS_DIR}/usr/lib/os-release
sed -i "s/^HOME_URL=.*$/HOME_URL=\"https:\/\/hyperion-project.org\/\"/g" ${ROOTFS_DIR}/usr/lib/os-release
sed -i "s/^SUPPORT_URL=.*$/SUPPORT_URL=\"https:\/\/hyperion-project.org\/\"/g" ${ROOTFS_DIR}/usr/lib/os-release
sed -i "s/^BUG_REPORT_URL=.*$/BUG_REPORT_URL=\"https:\/\/hyperion-project.org\/\"/g" ${ROOTFS_DIR}/usr/lib/os-release

# Custom motd
rm "${ROOTFS_DIR}"/etc/motd
rm "${ROOTFS_DIR}"/etc/update-motd.d/10-uname
install -m 755 files/motd-hyperbian "${ROOTFS_DIR}"/etc/update-motd.d/10-hyperbian

# Remove the "last login" information
sed -i "s/^#PrintLastLog yes.*/PrintLastLog no/" ${ROOTFS_DIR}/etc/ssh/sshd_config

on_chroot << EOF
echo 'Installing Hyperion ........................'
apt install /tmp/hyperion.deb
rm /tmp/hyperion.deb
mv /etc/systemd/system/hyperiond@.service /etc/systemd/system/hyperion@.service
echo 'Registering Hyperion ........................'
systemctl -q enable hyperion"@pi".service
EOF
