#!/system/bin/sh
# Copy variant files

variant=$(getprop ro.boot.hardware.sku)

cp -rf /odm/variant/$variant/odm/* /odm
chmod -R 755 /odm/bin/*

setprop variant.files_copied "1"

echo "$variant variant files copied." >/tmp/recovery.log

exit 0
