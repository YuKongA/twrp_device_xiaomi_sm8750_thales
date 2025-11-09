#!/system/bin/sh
# Auto-set device props based on hardware SKU

variant=$(getprop ro.boot.hardware.sku)
base_name="Xiaomi 15"

case "$variant" in
    "dada")
        model="$base_name"
        resetprop vendor.display.enable_spr "1"
        ;;
    "haotian")
        model="$base_name Pro"
        resetprop vendor.display.enable_spr "1"
        resetprop ro.odm.mm.vibrator.audio_haptic_support "true"
	    resetprop ro.odm.mm.vibrator.cirrus "true"
	    resetprop ro.odm.mm.vibrator.device_type "agm"
	    resetprop ro.odm.mm.vibrator.lowPowerMode "true"
	    resetprop ro.odm.mm.vibrator.resonant_frequency "130"
	    resetprop ro.odm.mm.vibrator.slide_effect_protect_time "20"
	    resetprop ro.odm.mm.vibrator.sys_path "/sys/bus/i2c/drivers/cs40l26/0-0043"
	    resetprop ro.vendor.mm.vibrator.sys_path "/sys/class/qcom-haptics"
        ;;
    "xuanyuan")
        model="$base_name Ultra"
        ;;
    *)
        echo "Unknown variant: $variant"
        exit 1
        ;;
esac

# Set USB name
echo "$model" > /config/usb_gadget/g1/strings/0x409/product

# device
device_props=(
    ro.build.product
    ro.product.device
    ro.product.odm.device
    ro.product.vendor.device
    ro.product.product.device
    ro.product.system_ext.device
    ro.product.system.device
    ro.product.bootimage.device
    ro.product.name
    ro.product.odm.name
    ro.product.vendor.name
    ro.product.product.name
    ro.product.system_ext.name
    ro.product.system.name
)

# Set device
for prop in "${device_props[@]}"; do
    resetprop "$prop" "$variant"
done

# model
model_props=(
    ro.product.model
    ro.product.odm.model
    ro.product.vendor.model
    ro.product.product.model
    ro.product.system_ext.model
    ro.product.system.model
)

# Set model
for prop in "${model_props[@]}"; do
    resetprop "$prop" "$model"
done

# Copy variant files
cp -rf /vendor/variant/$variant/vendor/* /vendor
chmod -R 755 /vendor/bin/*

echo "Variant props applied for $model ($variant)." > /tmp/recovery.log
exit 0
