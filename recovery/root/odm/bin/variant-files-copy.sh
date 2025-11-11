#!/system/bin/sh
# Copy variant files

variant=$(getprop ro.boot.hardware.sku)

cp -rf /vendor/variant/$variant/vendor/* /vendor
cp -rf /vendor/variant/$variant/odm/* /odm
chmod -R 755 /vendor/bin/*
chmod -R 755 /odm/bin/*

resetprop variant.files_copied "1"

echo "$variant variant files copied." >/tmp/recovery.log

exit 0