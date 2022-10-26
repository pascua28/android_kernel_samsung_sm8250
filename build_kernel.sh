#!/bin/bash

export ARCH=arm64
mkdir out

BUILD_CROSS_COMPILE=/home/pascua14/gcc7/bin/aarch64-linux-gnu-
CLANG_TRIPLE=aarch64-linux-gnu-
KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

CLANG_VERSION=16
LLVM_BIN=/home/pascua14/llvm-$CLANG_VERSION/bin/

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE \
	CLANG_DIR=$LLVM_BIN LLVM=1 LLVM_IAS=1 CLANG_TRIPLE=$CLANG_TRIPLE r8q_defconfig

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE LLVM=1 LLVM_IAS=1 \
	CLANG_DIR=$LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE oldconfig

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE LLVM=1 LLVM_IAS=1 \
	CLANG_DIR=$LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE

IMAGE="out/arch/arm64/boot/Image.gz"
DTB_OUT="out/arch/arm64/boot/dts/vendor/qcom"

cat $DTB_OUT/kona.dtb $DTB_OUT/kona-v2.dtb $DTB_OUT/kona-v2.1.dtb > AnyKernel3/dtb

if [[ -f "$IMAGE" ]]; then
	rm AnyKernel3/Image.gz > /dev/null 2>&1
	rm AnyKernel3/*.zip > /dev/null 2>&1
	cp $IMAGE AnyKernel3/Image.gz
	cd AnyKernel3
	zip -r9 Kernel-G780G-G781B.zip .
fi
