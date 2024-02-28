#!/bin/bash -e

# Enable SPI and force HDMI output
echo '---> Enable SPI and force HDMI output'
sed -i "s/^#dtparam=spi=on.*/dtparam=spi=on/" ${ROOTFS_DIR}/boot/firmware/config.txt
sed -i "s/^#hdmi_force_hotplug=1.*/hdmi_force_hotplug=1/" ${ROOTFS_DIR}/boot/firmware/config.txt

# Modify /usr/lib/os-release
echo '---> Customize HyperBian'
sed -i "s/^NAME=.*$/NAME=\"HyperBian\"/g" ${ROOTFS_DIR}/usr/lib/os-release
sed -i "/VERSION_ID=/d;/VERSION=/d" ${ROOTFS_DIR}/usr/lib/os-release
sed -i "s/^HOME_URL=.*$/HOME_URL=\"https:\/\/hyperion-project.org\/\"/g" ${ROOTFS_DIR}/usr/lib/os-release
sed -i "s/^SUPPORT_URL=.*$/SUPPORT_URL=\"https:\/\/hyperion-project.org\/\"/g" ${ROOTFS_DIR}/usr/lib/os-release
sed -i "s/^BUG_REPORT_URL=.*$/BUG_REPORT_URL=\"https:\/\/hyperion-project.org\/\"/g" ${ROOTFS_DIR}/usr/lib/os-release

# Custom motd
rm -f "${ROOTFS_DIR}"/etc/motd
rm -f "${ROOTFS_DIR}"/etc/update-motd.d/10-uname
install -m 755 files/motd-hyperbian "${ROOTFS_DIR}"/etc/update-motd.d/10-hyperbian

# Remove the "last login" information
sed -i "s/^#PrintLastLog yes.*/PrintLastLog no/" ${ROOTFS_DIR}/etc/ssh/sshd_config

# Add Hyperion DEB822 sources file, download public gpg key and update package information
echo '---> Integrate Hyperion Project Repository into HyperBian'
install -m 644 files/hyperion.sources ${ROOTFS_DIR}/etc/apt/sources.list.d/
on_chroot <<< "curl --silent --show-error --location 'https://releases.hyperion-project.org/hyperion.pub.key' | gpg --dearmor -o /etc/apt/keyrings/hyperion.pub.gpg && apt-get update"
