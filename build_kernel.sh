#!/bin/bash

export ARCH=arm64
mkdir out

BUILD_CROSS_COMPILE=/home/pascua14/gcc7/bin/aarch64-linux-gnu-
CLANG_TRIPLE=aarch64-linux-gnu-
KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

echo "**********************************"
echo "Select variant (Snapdragon only)"
echo "(1) ThinLTO build"
echo "(2) Full LTO build"
read -p "Selected variant: " variant

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE \
	CLANG_DIR="/home/pascua14/llvm-12/bin/" LLVM=1 CLANG_TRIPLE=$CLANG_TRIPLE r8q_defconfig

if [ $variant == "1" ]; then

scripts/configcleaner "CONFIG_THINLTO"

echo "CONFIG_THINLTO=y" >> out/.config

elif [ $variant == "2" ]; then

scripts/configcleaner "CONFIG_THINLTO"

echo "CONFIG_THINLTO=n" >> out/.config

fi

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE LLVM=1 \
	CLANG_DIR="/home/pascua14/llvm-12/bin/" CLANG_TRIPLE=$CLANG_TRIPLE oldconfig

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE LLVM=1 \
	CLANG_DIR="/home/pascua14/llvm-12/bin/" CLANG_TRIPLE=$CLANG_TRIPLE

IMAGE="out/arch/arm64/boot/Image.gz-dtb"

if [[ -f "$IMAGE" ]]; then
	rm AnyKernel3/zImage > /dev/null 2>&1
	rm AnyKernel3/*.zip > /dev/null 2>&1
	cp $IMAGE AnyKernel3/zImage
	cd AnyKernel3
	zip -r9 Kernel-r8q.zip .
fi
