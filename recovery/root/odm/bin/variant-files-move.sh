#!/system/bin/sh
# Copy variant files

variant=$(getprop ro.boot.hardware.sku)

chmod -R 755 /odm/variant/$variant/odm/bin/*
mv /odm/variant/$variant/odm/* /odm

setprop variant.files_moved "1"

echo "$variant variant files copied." >/tmp/recovery.log

exit 0
