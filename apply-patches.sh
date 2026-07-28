#!/bin/bash

set -e

DEVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANDROID_ROOT="${ANDROID_BUILD_TOP:-$(cd "$DEVICE_DIR/../../.." && pwd)}"
PATCH_DIR="$DEVICE_DIR/patches/bootable-recovery"
TARGET_DIR="$ANDROID_ROOT/bootable/recovery"

for patch in "$PATCH_DIR"/*.patch; do
    if git -C "$TARGET_DIR" apply --check "$patch" 2>/dev/null; then
        echo "Applying device patch: $(basename "$patch")"
        git -C "$TARGET_DIR" apply "$patch"
    elif git -C "$TARGET_DIR" apply --reverse --check "$patch" 2>/dev/null; then
        echo "Device patch already applied: $(basename "$patch")"
    else
        echo "Failed to apply device patch: $patch" >&2
        exit 1
    fi
done
