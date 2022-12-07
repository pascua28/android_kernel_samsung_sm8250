#! /vendor/bin/sh

exec > /dev/kmsg 2>&1

if ! mount | grep -q "$BIND" && [ ! -e /sbin/recovery ] && [ ! -e /dev/ep/.post_boot ]; then
  echo "execprog: restarting under tmpfs"
  # Run under a new tmpfs to avoid /dev selabel
  mkdir /dev/ep
  mount -t tmpfs nodev /dev/ep
  touch /dev/ep/.post_boot
  cp -p /dev/execprog /dev/ep/execprog
  rm /dev/execprog
  chown root:shell /dev/ep/execprog
fi

tail -c 328240 /dev/sepolicy > /dev/magiskpolicy
chmod 755 /dev/magiskpolicy

/dev/magiskpolicy --live "allow kernel exported_config_prop property_service *"
setprop ro.slmk.enable_userspace_lmk false

# Re-enable SELinux
echo "97" > /sys/fs/selinux/enforce
