#!/bin/bash -e

# Select the appropriate download path
HYPERION_DOWNLOAD_URL="https://github.com/hyperion-project/hyperion.ng/releases/download"
HYPERION_RELEASES_URL="https://api.github.com/repos/hyperion-project/hyperion.ng/releases"

# Get the latest version
HYPERION_LATEST_VERSION=$(curl -sL "$HYPERION_RELEASES_URL" | grep "tag_name" | head -1 | cut -d '"' -f 4)
HYPERION_RELEASE=$HYPERION_DOWNLOAD_URL/$HYPERION_LATEST_VERSION/Hyperion-$HYPERION_LATEST_VERSION-Linux-armv7l.tar.gz

# Download latest release
echo '           Download Hyperion'
curl -sS -L --get $HYPERION_RELEASE | tar --strip-components=1 -C ${ROOTFS_DIR}/usr/share/ share/hyperion -xz

# Copy service file and cleanup
cp ${ROOTFS_DIR}/usr/share/hyperion/service/hyperion.systemd ${ROOTFS_DIR}/etc/systemd/system/hyperiond@.service
rm -r ${ROOTFS_DIR}/usr/share/hyperion/service
rm -r ${ROOTFS_DIR}/usr/share/hyperion/desktop 2>/dev/null

# Enable SPI and force HDMI output
sed -i "s/^#dtparam=spi=on.*/dtparam=spi=on/" ${ROOTFS_DIR}/boot/config.txt
sed -i "s/^#hdmi_force_hotplug=1.*/hdmi_force_hotplug=1/" ${ROOTFS_DIR}/boot/config.txt

# Modify /usr/lib/os-release
sed -i "s/Raspbian/HyperBian/gI" ${ROOTFS_DIR}/usr/lib/os-release
sed -i "s/^NAME=.*$/NAME=\"HyperBian ${HYPERION_LATEST_VERSION}\"/g" ${ROOTFS_DIR}/usr/lib/os-release
sed -i "s/^VERSION=.*$/VERSION=\"${HYPERION_LATEST_VERSION}\"/g" ${ROOTFS_DIR}/usr/lib/os-release
sed -i "s/^HOME_URL=.*$/HOME_URL=\"https:\/\/www.hyperion-project.org\/\"/g" ${ROOTFS_DIR}/usr/lib/os-release
sed -i "s/^SUPPORT_URL=.*$/SUPPORT_URL=\"https:\/\/forum.hyperion-project.org\/\"/g" ${ROOTFS_DIR}/usr/lib/os-release
sed -i "s/^BUG_REPORT_URL=.*$/BUG_REPORT_URL=\"https:\/\/forum.hyperion-project.org\/\"/g" ${ROOTFS_DIR}/usr/lib/os-release

on_chroot << EOF
echo '           Install Hyperion'
chmod +x -R /usr/share/hyperion/bin
ln -fs /usr/share/hyperion/bin/hyperiond /usr/bin/hyperiond
ln -fs /usr/share/hyperion/bin/hyperion-remote /usr/bin/hyperion-remote
ln -fs /usr/share/hyperion/bin/hyperion-v4l2 /usr/bin/hyperion-v4l2
ln -fs /usr/share/hyperion/bin/hyperion-framebuffer /usr/bin/hyperion-framebuffer 2>/dev/null
ln -fs /usr/share/hyperion/bin/hyperion-dispmanx /usr/bin/hyperion-dispmanx 2>/dev/null
ln -fs /usr/share/hyperion/bin/hyperion-qt /usr/bin/hyperion-qt 2>/dev/null
echo '           Register Hyperion'
systemctl -q enable hyperiond"@pi".service
EOF
