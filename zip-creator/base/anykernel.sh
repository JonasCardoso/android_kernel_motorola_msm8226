# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# EDIFY properties
kernel.string=
do.devicecheck=0
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=

# shell variables
if [ -e /dev/block/bootdevice/by-name/boot ]; then
  block=/dev/block/bootdevice/by-name/boot;
else
  block=/dev/block/platform/msm_sdcc.1/by-name/boot;
fi;
is_slot_device=0;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;


## AnyKernel permissions
# set permissions for included ramdisk files
chmod -R 755 $ramdisk


## AnyKernel install
dump_boot;

# begin ramdisk changes

ui_print " "; ui_print "Tweaking ramdisk...";

replace_string init.qcom.rc "#start mpdecision" "start mpdecision" "#start mpdecision";
replace_section init.qcom.rc "service mpdecision" "disabled" "#service mpdecision /system/bin/mpdecision --avg_comp\n#   user root\n#   group root system\n#   disabled";

insert_line init.qcom.rc "init.extended" before "import init.qcom.usb.rc" "import init.extended.rc";

replace_line fstab.qcom "/dev/block/zram0                           none         swap    defaults                                                                       zramsize=268435456" "/dev/block/zram0                           none         swap    defaults                                                                       zramsize=536870912,zramstreams=3,notrim";

ui_print " ";

cmdfile=`ls $split_img/*-cmdline`;
cmdtmp=`cat $cmdfile`;
case "$cmdtmp" in
     *selinux=permissive*) ui_print "SElinux Its Already Permissive..."; ;;
     *) ui_print "Setting SElinux To Permissive..."; rm $cmdfile; echo "$cmdtmp androidboot.selinux=permissive" > $cmdfile;;
esac;

# add floppy script
insert_line init.qcom.rc "init.floppy.rc" after "import init.target.rc" "import init.floppy.rc";

# add support for spectrum
insert_line init.rc "import /init.spectrum.rc" after "import /init.floppy.rc" "import /init.spectrum.rc";

# end ramdisk changes

write_boot;

## end install

