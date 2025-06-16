# TWRP device tree for Xiaomi SM8750

## Features
- [X] Decryption
- [X] ADB
- [X] Display
- [X] Fasbootd
- [X] Flashing
- [X] MTP
- [X] Sideload
- [X] USB OTG
- [X] Vibrator
- [X] Mount /data

## Build it yourself
1. Fix wrong screen colors -> [commit](https://github.com/YuKongA/android_bootable_recovery_twrp-14.1/commit/edf59d8b504a4b3db197286aeac1c73727708175)

2. Fix `E: Unknown File System: mifs` -> [commit](https://github.com/YuKongA/android_bootable_recovery_twrp-14.1/commit/d7167c4d7b9cd341c049d62c876f365b58a39542)

3. Fix switch slot A/B -> [commit](https://github.com/YuKongA/android_bootable_recovery_twrp-14.1/commit/1648204cb0ffba48ef1ccb88fe5a6b4d451a0159)

4. Fix check is use weaver -> [commit](https://github.com/YuKongA/android_system_vold/commit/7851be52cd539bf2364b84084516cabd86a50b62)
