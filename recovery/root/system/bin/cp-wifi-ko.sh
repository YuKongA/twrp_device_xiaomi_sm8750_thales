#!/system/bin/sh

# Do not copy in fastbootd mode
FASTBOOTD_PROP=$(getprop ro.twrp.fastbootd)
if [ "$FASTBOOTD_PROP" = "1" ]; then
    echo "I:cp-wifi-ko.sh: Detected fastbootd (ro.twrp.fastbootd=1), exit script." >> /tmp/recovery.log
    exit 0
fi

mount /persist
cp -f /persist/wlan/wlan_mac.bin /vendor/etc/wifi/peach_v2
umount /persist
mkdir -p /vendor/firmware/wlan/qca_cld/peach_v2
ln -s /vendor/etc/wifi/peach_v2/wlan_mac.bin /vendor/firmware/wlan/qca_cld/peach_v2/wlan_mac.bin

# 初始挂载尝试
mount /vendor_dlkm
mount /system_dlkm

LOG_TAG="I:cp-wifi-ko.sh"
TARGET_DIR="/odm/wifi/modules"
SEARCH_DIRS="/vendor_dlkm /system_dlkm"
KO_FILES="cnss_prealloc.ko cnss_nl.ko wlan_firmware_service.ko cnss_plat_ipc_qmi_svc.ko cnss_utils.ko cnss2.ko gsim.ko rmnet_mem.ko ipam.ko rfkill.ko cfg80211.ko qca_cld3_peach_v2.ko smem-mailbox.ko"

log_print() {
    echo "$LOG_TAG: $1" >> /tmp/recovery.log
}

# 检查目录是否已挂载的函数
is_mounted() {
    local dir=$1
    if mount | grep -q " on $dir "; then
        return 0
    else
        return 1
    fi
}

# 挂载目录的函数
mount_directory() {
    local dir=$1
    if ! is_mounted "$dir"; then
        sleep 10
        log_print "Mounting $dir"
        mount "$dir"
        if [ $? -eq 0 ]; then
            log_print "Successfully mounted $dir"
            return 0
        else
            log_print "Failed to mount $dir"
            return 1
        fi
    else
        log_print "$dir is already mounted"
        return 0
    fi
}

if [ ! -d "$TARGET_DIR" ]; then
    log_print "Creating target dir: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
    if [ $? -ne 0 ]; then
        log_print "Error: unable to create $TARGET_DIR"
        exit 1
    fi
fi

chmod 0755 "$TARGET_DIR"

log_print "Search and copy wifi ko files..."

found_count=0
copied_count=0

for ko_file in $KO_FILES; do
    file_found=0
    retry_count=0
    max_retries=1
    
    while [ $retry_count -le $max_retries ] && [ $file_found -eq 0 ]; do
        for search_dir in $SEARCH_DIRS; do
            if [ -d "$search_dir" ]; then
                file_path=$(find "$search_dir" -type f -name "$ko_file" 2>/dev/null | head -1)
                if [ -n "$file_path" ] && [ -f "$file_path" ]; then
                    file_found=1
                    target_file="$TARGET_DIR/$ko_file"
                    if [ ! -f "$target_file" ]; then
                        log_print "Copy: $file_path -> $target_file"
                        cp "$file_path" "$target_file"
                        if [ $? -eq 0 ]; then
                            chmod 0644 "$target_file"
                            copied_count=$((copied_count + 1))
                            log_print "Copy successfully: $ko_file"
                        else
                            log_print "Error: Copy failed: $ko_file"
                        fi
                    else
                        log_print "Skip existing file: $ko_file"
                    fi
                    break
                fi
            else
                log_print "Warning: The search directory does not exist: $search_dir"
            fi
        done
        
        # 如果文件没找到且是第一次尝试，检查并挂载目录后重试
        if [ $file_found -eq 0 ] && [ $retry_count -eq 0 ]; then
            log_print "File not found in first attempt: $ko_file, checking mounts..."
            mount_attempted=0
            mount_success=0
            
            for search_dir in $SEARCH_DIRS; do
                if ! is_mounted "$search_dir"; then
                    mount_attempted=1
                    if mount_directory "$search_dir"; then
                        mount_success=1
                    fi
                fi
            done
            
            # 如果有挂载操作且至少有一个挂载成功，则重试查找
            if [ $mount_attempted -eq 1 ] && [ $mount_success -eq 1 ]; then
                log_print "Retrying search for $ko_file after mount operations"
                retry_count=$((retry_count + 1))
            else
                break
            fi
        else
            break
        fi
    done
    
    if [ $file_found -eq 1 ]; then
        found_count=$((found_count + 1))
    else
        log_print "Unable to find: $ko_file after $((retry_count + 1)) attempts"
    fi
done

log_print "Copy done: $found_count files found, $copied_count files copied."
log_print "Target dir files:"
ls -la "$TARGET_DIR" 2>/dev/null | while read line; do
    log_print "$line"
done

resetprop twrp.cpko "true"

exit 0
