#!/bin/bash

export ARCH=arm64
mkdir out

BUILD_CROSS_COMPILE=aarch64-linux-gnu-
KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE \
	r8q_defconfig

    scripts/configcleaner "
CONFIG_LTO_GCC
CONFIG_HAVE_ARCH_PREL32_RELOCATIONS
"

case $1 in
   lto)
    echo "

################# Compiling LTO build #################

"
    echo "CONFIG_LTO_GCC=y
" >> out/.config
   ;;

   *)
    echo "# CONFIG_LTO_GCC is not set
CONFIG_HAVE_ARCH_PREL32_RELOCATIONS=y
" >> out/.config
   ;;
esac

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE \
	oldconfig

DATE_START=$(date +"%s")

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE

IMAGE="out/arch/arm64/boot/Image.gz"
DTB_OUT="out/arch/arm64/boot/dts/vendor/qcom"

cat $DTB_OUT/kona.dtb $DTB_OUT/kona-v2.dtb $DTB_OUT/kona-v2.1.dtb > AnyKernel3/kona.dtb

patch -p1 --merge < patches/freqtable.diff

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE dtbs

cat $DTB_OUT/kona.dtb $DTB_OUT/kona-v2.dtb $DTB_OUT/kona-v2.1.dtb > AnyKernel3/kona-perf.dtb

patch -p1 -R --merge < patches/freqtable.diff

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))

echo "Time wasted: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."

if [[ -f "$IMAGE" ]]; then
	rm AnyKernel3/*.zip > /dev/null 2>&1
	cp $IMAGE AnyKernel3/Image.gz
	cd AnyKernel3
	zip -r9 Kernel-G780G-G781B.zip .
fi
