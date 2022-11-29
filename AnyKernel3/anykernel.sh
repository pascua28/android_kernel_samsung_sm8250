# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=Kernel for S20 FE (Snapdragon) by pascua28 @ xda-developers
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=r8q
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
'; } # end properties

# shell variables
block=/dev/block/platform/soc/1d84000.ufshc/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 755 644 $ramdisk/*;
set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;

## AnyKernel boot install
dump_boot;

case "$ZIPFILE" in
   *-perf*)
    ui_print " • Flashing performance device tree blob • "
    mv $home/kona-perf.dtb $home/dtb
    ;;
   *)
    mv $home/kona.dtb $home/dtb
    ;;
esac

ui_print " "

AKBB="$home/tools/busybox"
SLMK_PROP=ro.slmk.enable_userspace_lmk

patchProps() {
	ui_print "Patching $1"
	ui_print " "
	$AKBB echo -e "\nro.slmk.enable_userspace_lmk=false" >> "$1"
	$AKBB echo "persist.sys.fuse.passthrough.enable=true" >> "$1"

	if grep -q "$SLMK_PROP" "$1"; then
		ui_print "build.prop successfully patched!"
		ui_print " "
	else
		ui_print " "
		ui_print "Patching build.prop failed!"
		ui_print " "
		ui_print " "
		ui_print "################################################"
		ui_print "Please reflash this zip to fix bootloop on OneUI"
		ui_print " "
		ui_print "Press volume up/down to confirm you have read the above instruction"
		ui_print "################################################"
		while true; do
			KEY_EVENT="$(getevent -lc 1 2>&1 | grep VOLUME)"
			if [ ! -z "$KEY_EVENT" ]; then
				break
			 fi
		done
	fi
}

SYSTEM=/system
BUILD_PROP=/system/build.prop

if grep -q "$SLMK_PROP" "$BUILD_PROP"; then
	ui_print "build.prop already patched"
else
	ui_print "Remounting $SYSTEM as rw"
	ui_print " "
	$AKBB mount -o rw,remount "$SYSTEM"

	sleep 1

	patchProps "$BUILD_PROP"
fi

write_boot;
