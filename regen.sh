#!/bin/bash

mkdir out

KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc"

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 \
	CROSS_COMPILE=/home/pascua14/gcc-arm64/bin/aarch64-elf- \
	oldconfig

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 \
	CROSS_COMPILE=/home/pascua14/gcc-arm64/bin/aarch64-elf- \
	savedefconfig

cp out/defconfig arch/arm64/configs/r8q_defconfig
