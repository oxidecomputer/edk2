#!/bin/bash
#:
#: name = "image"
#: variety = "basic"
#: target = "helios-latest"
#: output_rules = [
#:   "/out/*",
#: ]
#:
#: [[publish]]
#: series = "image_release"
#: name = "OVMF_CODE.tar.gz"
#: from_output = "/out/release/OVMF_CODE.tar.gz"
#:
#: [[publish]]
#: series = "image_release"
#: name = "OVMF_CODE.tar.gz.sha256.txt"
#: from_output = "/out/release/OVMF_CODE.tar.gz.sha256.txt"
#:
#: [[publish]]
#: series = "image_debug"
#: name = "OVMF_CODE.tar.gz"
#: from_output = "/out/debug/OVMF_CODE.tar.gz"
#:
#: [[publish]]
#: series = "image_debug"
#: name = "OVMF_CODE.tar.gz.sha256.txt"
#: from_output = "/out/debug/OVMF_CODE.tar.gz.sha256.txt"

set -o errexit
set -o pipefail
set -o xtrace

release_dir="/out/release"
debug_dir="/out/debug"

# The build relies on submodules that aren't initially part of a fresh clone.
banner checkout
git submodule init
git submodule update

banner build
chmod +x illumos/build.sh
illumos/build.sh DEBUG
illumos/build.sh RELEASE

banner contents
tar -czvf Build/OvmfX64/RELEASE_ILLGCC/FV/OVMF_CODE.tar.gz \
    -C Build/OvmfX64/RELEASE_ILLGCC/FV OVMF_CODE.fd

tar -czvf Build/OvmfX64/DEBUG_ILLGCC/FV/OVMF_CODE.tar.gz \
    -C Build/OvmfX64/DEBUG_ILLGCC/FV OVMF_CODE.fd

banner copy
pfexec mkdir -p $release_dir
pfexec mkdir -p $debug_dir
pfexec chown "$UID" $release_dir
pfexec chown "$UID" $debug_dir
mv Build/OvmfX64/RELEASE_ILLGCC/FV/OVMF_CODE.tar.gz \
    $release_dir/OVMF_CODE.tar.gz
mv Build/OvmfX64/DEBUG_ILLGCC/FV/OVMF_CODE.tar.gz \
    $debug_dir/OVMF_CODE.tar.gz
cd $release_dir
digest -a sha256 OVMF_CODE.tar.gz > OVMF_CODE.tar.gz.sha256.txt
cd $debug_dir
digest -a sha256 OVMF_CODE.tar.gz > OVMF_CODE.tar.gz.sha256.txt
