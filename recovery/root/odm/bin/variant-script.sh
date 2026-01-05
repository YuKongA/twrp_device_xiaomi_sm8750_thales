#!/system/bin/sh
#=================================================
# Auto-set device properties based on hardware SKU
#=================================================
set -e

variant=$(getprop ro.boot.hardware.sku)
base_name="Xiaomi 15"
log_file="/tmp/recovery.log"

log() {
    echo "variant-props-override.sh: $1" | tee -a "$log_file"
}

#-------------------------------------------------
# Helper: set multiple vibrator-related properties
#-------------------------------------------------
set_vibrator_props() {
    resetprop ro.odm.mm.vibrator.audio_haptic_support "true"
    resetprop ro.odm.mm.vibrator.resonant_frequency "$1"
    resetprop ro.odm.mm.vibrator.slide_effect_protect_time "$2"
    resetprop ro.odm.mm.vibrator.sys_path "$3"
    resetprop ro.odm.mm.vibrator.device_type "$4"
    resetprop ro.vendor.mm.vibrator.sys_path "/sys/class/qcom-haptics"
}

#-------------------------------------------------
# Variant-specific configuration
#-------------------------------------------------
case "$variant" in
"dada")
    model="$base_name"
    resetprop ro.twrp.device_version "Xiaomi_15"
    resetprop ro.twrp.y_offset "111"
    resetprop ro.twrp.h_offset "-111"
    resetprop vendor.display.enable_spr "1"
    set_vibrator_props "170" "35" "/sys/class/qcom-haptics" "agm"
    ;;

"haotian")
    model="$base_name Pro"
    resetprop ro.twrp.device_version "Xiaomi_15_Pro"
    resetprop ro.twrp.y_offset "116"
    resetprop ro.twrp.h_offset "-116"
    resetprop vendor.display.enable_spr "1"
    resetprop ro.odm.mm.vibrator.cirrus "true"
    resetprop ro.odm.mm.vibrator.lowPowerMode "true"
    set_vibrator_props "130" "20" "/sys/bus/i2c/drivers/cs40l26/0-0043" "agm"
    ;;

"xuanyuan")
    model="$base_name Ultra"
    resetprop ro.twrp.device_version "Xiaomi_15_Ultra"
    resetprop ro.twrp.y_offset "116"
    resetprop ro.twrp.h_offset "-116"
    resetprop ro.odm.mm.vibrator.he1.0 "mihaptic"
    set_vibrator_props "170" "20" "/sys/class/qcom-haptics" "agm"
    ;;

*)
    #-----------------------------------------
    # Default configuration
    #-----------------------------------------
    log "Unknown variant: $variant, applying default configuration (SM8750)"
    variant="SM8750"
    model="SM8750"
    set_vibrator_props "170" "35" "/sys/class/qcom-haptics" "agm"
    ;;
esac

#-------------------------------------------------
# Common configuration
#-------------------------------------------------
echo "$model" >/config/usb_gadget/g1/strings/0x409/product
resetprop vendor.usb.product_string "$model"
mkdir -p /usbotg

#-------------------------------------------------
# Set product & model properties
#-------------------------------------------------
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

model_props=(
    ro.product.model
    ro.product.odm.model
    ro.product.vendor.model
    ro.product.product.model
    ro.product.system_ext.model
    ro.product.system.model
)

for prop in "${device_props[@]}"; do
    resetprop "$prop" "$variant"
done

for prop in "${model_props[@]}"; do
    resetprop "$prop" "$model"
done

#-------------------------------------------------
# Copy variant-specific files
#-------------------------------------------------
cp -rf /odm/variant/$variant/odm/* /odm
chmod -R 755 /odm/bin/*
setprop twrp.variant.files_copied "1"

#-------------------------------------------------
# Done
#-------------------------------------------------
log "Applied variant props for: $model ($variant)"
exit 0
