#! /vendor/bin/sh

tail -c 328240 /dev/sepolicy > /dev/magiskpolicy
chmod 755 /dev/magiskpolicy

/dev/magiskpolicy --live "allow kernel exported_config_prop property_service *"

setprop ro.dalvik.vm.enable_uffd_gc true
setprop ro.slmk.enable_userspace_lmk false

# Re-enable SELinux
echo "97" > /sys/fs/selinux/enforce
