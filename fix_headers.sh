#!/bin/bash
# fix_headers.sh

TOOLCHAIN_BIN=$(which arm-linux-gnueabihf-gcc)
TOOLCHAIN_DIR=${TOOLCHAIN_BIN%/bin/arm-linux-gnueabihf-gcc}
GREP_VERSION_FILE=$(grep -nR LINUX_VERSION_CODE $(find $TOOLCHAIN_DIR  -name version.h))
VERSION_FILE=$(echo $GREP_VERSION_FILE | awk -F: '{print $1}')
CURRENT_VERSION=$(echo $GREP_VERSION_FILE | awk -F: '{print $3}' | awk '{print $3}')

#262144 = 040000(h) 对应4.0.0版本内核
EXPECTED_VERSION="262415"  # 262415 = 04010F(h) 对应4.1.15版本内核

if [ $# -lt 2 ]; then
	echo "TOOLCHAIN_DIR   : $TOOLCHAIN_DIR"
	echo "VERSION_FILE    : $VERSION_FILE"
	echo "CURRENT_VERSION : $CURRENT_VERSION(=$(printf 0x%X $CURRENT_VERSION))"
	echo "EXPECTED_VERSION: $EXPECTED_VERSION(=$(printf 0x%X $EXPECTED_VERSION))"
fi
#VERSION_FILE="$BUILDROOT_DIR/output/host/arm-buildroot-linux-gnueabihf/sysroot/usr/include/linux/version.h"

if [ ! -f "$VERSION_FILE" ]; then
	echo -e "\033[31;47mVersion file not found!\033[00;00m"
    exit 1
fi

if [[ $CURRENT_VERSION == $EXPECTED_VERSION ]]; then
	echo -e "\033[32;47mCurrent linux header has been $EXPECTED_VERSION\033[00;00m"
	exit 0
fi

cp $VERSION_FILE $VERSION_FILE.back.$CURRENT_VERSION

# 替换版本号(备份)
sed -i "s/#define LINUX_VERSION_CODE [0-9]\+/#define LINUX_VERSION_CODE $EXPECTED_VERSION/" "$VERSION_FILE"

echo -e "\033[32;47mFixed kernel headers version to $(printf 0x%X $EXPECTED_VERSION)\033[00;00m"
echo "Backup saved as $VERSION_FILE.back.$CURRENT_VERSION"

exit 0
