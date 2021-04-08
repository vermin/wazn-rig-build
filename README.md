WAZNRig build script
======================

[![License](https://img.shields.io/badge/license-GPL--3.0-blue)](https://opensource.org/licenses/GPL-3.0)

Simple automated script to build WAZNRig from source on x86-64, ARMv7, and ARMv8 devices.

It is made to speed up the process for installing and updating WAZNRig on Android devices.

It should work for just about any device running a Debian-based Linux.

It has been tested on following devices with success:
- Ubuntu 18.04 (Bionic) [x86-64] [ARMv7] [ARMv8]
- Ubuntu 20.04 (Focal) [x86-64]
- Debian 9 (Stretch) [x86-64]
- Raspbian (Stretch) [ARMv7]
- Armbian (Stretch) [ARMv7] [ARMv8]

* Script fails on Raspbian (Buster).

![Alt text](/waznrig-build.jpg?raw=true "Screenshot")

### x86-64 (Default)
Usage: `./waznrig-build.sh` (No argument or anything other than `7` and `8`)

### ARMv7 & ARMv8
Usage: `./waznrig-build.sh #`
(where `#` is a `7` for ARMv7 or `8` for ARMv8)

## What Does This Script Do?

#### Dependencies...
- apt update && apt upgrade -y
- apt install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev screen p7zip-full -y

#### Backup...
- rm ./wazn-rig/waznrig-build.7z.bak
- rm ./wazn-rig/waznrig.bak
- mv ./wazn-rig/waznrig-build.7z ./wazn-rig/waznrig-build.7z.bak
- mv ./wazn-rig/waznrig ./wazn-rig/waznrig.bak

#### Setup...
- mkdir ./_source
- cd ./_source
- git clone https://github.com/project-wazn/wazn-rig.git
- cd wazn-rig && mkdir build && cd build

#### Compiling/Building...
- For ARMv7 - cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=7 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF
- For ARMv8 - cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=8 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF
- For x86-64 - cmake .. -DCMAKE_BUILD_TYPE=Release
- make

#### Compressing/Moving...
- 7z a waznrig-build.7z ./wazn-rig
- cp waznrig-build.7z ./wazn-rig/waznrig-build.7z
- cp ./_source/wazn-rig/build/waznrig ./wazn-rig/waznrig

#### Cleanup...
- cd ./
- rm -r _source

Upon successful completion of this script, you should end up with an `waznrig` directory with the following contents:
1. `waznrig` - WAZNRig binary
2. `start-example.sh` - Example start script.
3. `waznrig-build.7z` - 7zip archive of file #1 and file #2
4. *`waznrig.bak` - Backup of last `waznrig` binary
5. *`waznrig-build.7z.bak` - Backup of last `waznrig-build.7z` archive.

*Note: File #4 and file #5 will only exist after running this script at least twice.

## License
```
Licensed under the GPL-3.0
Copyright (c) 2021 Wazn Project
Copyright (c) 2020 DocDrydenn
```
