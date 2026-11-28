### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string="Scythe Kernel: Reborn by NitroGear504"
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=RMX1911
device.name2=
device.name3=
device.name4=
device.name5=
device.name6=
device.name7=
supported.versions=10-17
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties

# boot shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;
patch_vbmeta_flag=auto;

# Import AnyKernel3 core once.
. tools/ak3-core.sh;

# Validate the payload and resolved boot partition.
[ -s "$AKHOME/Image.gz-dtb" ] || abort "Missing kernel image.";
[ -b "$BLOCK" ] || abort "Invalid boot block device.";

# Dump and validate the existing boot image.
split_boot;
[ -s "$BOOTIMG" ] || abort "Unable to read existing boot image.";

# Optional recovery backup when internal storage is accessible.
if mountpoint -q /data && [ -d /sdcard ] && [ -w /sdcard ]; then
    BACKUP_DIR=$(mktemp -d /sdcard/r5x-kernel-backup-XXXXXX);

    if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
        ui_print " " "[+] Backing up current boot image...";

        if cp "$BOOTIMG" "$BACKUP_DIR/boot.img" &&
           [ -s "$BACKUP_DIR/boot.img" ] &&
           cmp -s "$BOOTIMG" "$BACKUP_DIR/boot.img"; then
            ui_print "[+] Boot backup verified.";
        else
            rm -f "$BACKUP_DIR/boot.img";
            ui_print "[!] Boot backup failed.";
        fi;

        DTBO_BLOCK=/dev/block/by-name/dtbo;

        if [ -b "$DTBO_BLOCK" ]; then
            if dd if="$DTBO_BLOCK" of="$BACKUP_DIR/dtbo.img" &&
               [ -s "$BACKUP_DIR/dtbo.img" ]; then
                ui_print "[+] DTBO backup created.";
            else
                rm -f "$BACKUP_DIR/dtbo.img";
                ui_print "[!] DTBO backup failed.";
            fi;
        fi;

        ui_print "[+] Backup directory: $BACKUP_DIR";
    else
        ui_print "[!] Unable to create backup directory.";
    fi;
else
    ui_print "[!] Internal storage unavailable; skipping backup.";
fi;

# Install using the existing AnyKernel3 implementation.
flash_boot;
flash_dtbo;
## end install
