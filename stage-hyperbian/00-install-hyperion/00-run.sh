#!/bin/bash -e

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
echo '---> Import the public GPG key from the APT server into HyperBian'
wget -qO- https://apt.hyperion-project.org/hyperion.pub.key | gpg --dearmor -o /usr/share/keyrings/hyperion.pub.gpg
echo '---> Add Hyperion to the APT sources'
echo "deb [signed-by=/usr/share/keyrings/hyperion.pub.gpg] https://apt.hyperion-project.org/ stable main" | sudo tee /etc/apt/sources.list.d/hyperion.list
echo '---> Update the APT sources and installing Hyperion'
apt-get update && apt-get -y install hyperion
EOF
