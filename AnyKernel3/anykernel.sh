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
device.name2=r8qxx
device.name3=r8qxxx
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

#case "$ZIPFILE" in
#   *-perf*)
#    ui_print " • Flashing performance device tree blob • "
#    mv $home/kona-perf.dtb $home/dtb
#    ;;
#   *)
#    mv $home/kona.dtb $home/dtb
#    ;;
#esac

# begin ramdisk changes

# end ramdisk changes

release=$(file_getprop /system/build.prop ro.build.version.release);
device=$(file_getprop /system/build.prop ro.product.system.device);
android=$(file_getprop /system/build.prop ro.build.version.sdk);
oneui=$(file_getprop /system/build.prop ro.build.version.oneui);

patch_cmdline "android.is_aosp" "";

if [ "$android" -lt 34 ]; then
   ui_print "";
   ui_print "Android 13 detected!";
   patch_cmdline "android.legacy_ebpf=" "android.legacy_ebpf=1";
fi

if [ -z "$device" ] && [ -z "$android" ]; then
    ui_print " ";
    ui_print "Skipping ROM detection...";
    ui_print " ";
else
    if [ -n "$oneui" ]; then
        ui_print " ";
        ui_print "OneUI ROM detected!";
        ui_print " ";
    elif [ "$device" == "generic" ]; then
        ui_print " ";
        ui_print "GSI ROM detected!";
        ui_print " ";
    else
        ui_print " ";
        ui_print "AOSP ROM detected!";
        ui_print " ";
        patch_cmdline "android.is_aosp" "android.is_aosp=1";
    fi
fi

if [ "$release" -lt 14 ]; then
    patch_cmdline "android.use_sdcardfs" "android.use_sdcardfs=1";
fi

write_boot;
## end boot install
