#!/bin/bash -e

rm -f ${ROOTFS_DIR}/usr/lib/os-release
install -m 644 files/os-release ${ROOTFS_DIR}/usr/lib/
