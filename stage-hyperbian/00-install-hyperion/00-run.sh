#!/bin/bash -e

# Select the appropriate download path
HYPERION_DOWNLOAD_URL="https://github.com/hyperion-project/hyperion.ng/releases/download"
HYPERION_RELEASES_URL="https://api.github.com/repos/hyperion-project/hyperion.ng/releases"

# Get the latest version
HYPERION_LATEST_VERSION=$(curl -sL "$HYPERION_RELEASES_URL" | grep "tag_name" | head -1 | cut -d '"' -f 4)
HYPERION_RELEASE=$HYPERION_DOWNLOAD_URL/$HYPERION_LATEST_VERSION/Hyperion-$HYPERION_LATEST_VERSION-Linux-armv7hf-rpi.tar.gz

# Download latest release
echo '           Download Hyperion'
curl -s -L --get $HYPERION_RELEASE | tar --strip-components=1 -C ${ROOTFS_DIR}/usr/share/ share/hyperion -xz

# Copy service file and cleanup
cp ${ROOTFS_DIR}/usr/share/hyperion/service/hyperion.systemd ${ROOTFS_DIR}/etc/systemd/system/hyperiond@.service
rm -r ${ROOTFS_DIR}/usr/share/hyperion/service
rm -r ${ROOTFS_DIR}/usr/share/hyperion/desktop 2>/dev/null

# Enable SPI
if ! grep -q '^dtparam=spi=on' ${ROOTFS_DIR}/boot/config.txt; then
  echo 'dtparam=spi=on' >> ${ROOTFS_DIR}/boot/config.txt
fi

# Force HDMI output
if ! grep -q '^hdmi_force_hotplug=1' ${ROOTFS_DIR}/boot/config.txt; then
  echo 'hdmi_force_hotplug=1' >> ${ROOTFS_DIR}/boot/config.txt
fi

on_chroot << EOF
echo '           Install Hyperion'
chmod +x -R /usr/share/hyperion/bin
ln -fs /usr/share/hyperion/bin/hyperiond /usr/bin/hyperiond
ln -fs /usr/share/hyperion/bin/hyperion-remote /usr/bin/hyperion-remote
ln -fs /usr/share/hyperion/bin/hyperion-v4l2 /usr/bin/hyperion-v4l2
ln -fs /usr/share/hyperion/bin/hyperion-framebuffer /usr/bin/hyperion-framebuffer 2>/dev/null
ln -fs /usr/share/hyperion/bin/hyperion-dispmanx /usr/bin/hyperion-dispmanx 2>/dev/null
ln -fs /usr/share/hyperion/bin/hyperion-x11 /usr/bin/hyperion-x11 2>/dev/null
ln -fs /usr/share/hyperion/bin/hyperion-aml /usr/bin/hyperion-aml 2>/dev/null
ln -fs /usr/share/hyperion/bin/hyperion-qt /usr/bin/hyperion-qt 2>/dev/null

echo '           Register Hyperion'
systemctl -q enable hyperiond"@pi".service
EOF
