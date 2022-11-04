#!/bin/bash

export ARCH=arm64
mkdir out

KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

CLANG_VERSION=12
LLVM_BIN=/home/pascua14/llvm-$CLANG_VERSION/bin/
CLANG_CC=$LLVM_BIN/clang

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 \
	CC=$CLANG_CC \
	oldconfig

cp out/.config arch/arm64/configs/r8q_defconfig
