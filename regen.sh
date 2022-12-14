#!/bin/bash

mkdir out

KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc"

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 \
	CROSS_COMPILE=aarch64-linux-gnu- \
	oldconfig

cp out/.config arch/arm64/configs/r8q_defconfig
