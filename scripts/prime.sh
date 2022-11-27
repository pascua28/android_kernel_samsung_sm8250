#! /vendor/bin/sh

exec > /dev/kmsg 2>&1

BIND=/vendor/bin/prime.sh

if ! mount | grep -q "$BIND" && [ ! -e /sbin/recovery ] && [ ! -e /dev/ep/.post_boot ]; then
  echo "execprog: restarting under tmpfs"
  # Run under a new tmpfs to avoid /dev selabel
  mkdir /dev/ep
  mount -t tmpfs nodev /dev/ep
  touch /dev/ep/.post_boot
  cp -p /dev/execprog /dev/ep/execprog
  rm /dev/execprog
  chown root:shell /dev/ep/execprog

  mount --bind /dev/ep/execprog "$BIND"
  chcon "u:object_r:vendor_file:s0" "$BIND"
fi

# Re-enable SELinux
echo "97" > /sys/fs/selinux/enforce
