#!/bin/bash
#:
#: name = "image"
#: variety = "basic"
#: target = "helios-latest"
#: output_rules = [
#:   "=/out/release/OVMF_CODE.fd",
#:   "=/out/release/OVMF_CODE.fd.sha256.txt",
#:   "=/out/debug/OVMF_CODE.fd",
#:   "=/out/debug/OVMF_CODE.fd.sha256.txt",
#: ]
#:
#: [[publish]]
#: series = "image_release"
#: name = "OVMF_CODE.fd"
#: from_output = "/out/release/OVMF_CODE.fd"
#:
#: [[publish]]
#: series = "image_release"
#: name = "OVMF_CODE.fd.sha256.txt"
#: from_output = "/out/release/OVMF_CODE.fd.sha256.txt"
#:
#: [[publish]]
#: series = "image_debug"
#: name = "OVMF_CODE.fd"
#: from_output = "/out/debug/OVMF_CODE.fd"
#:
#: [[publish]]
#: series = "image_debug"
#: name = "OVMF_CODE.fd.sha256.txt"
#: from_output = "/out/debug/OVMF_CODE.fd.sha256.txt"

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

banner copy
pfexec mkdir -p $release_dir
pfexec mkdir -p $debug_dir
pfexec chown "$UID" $release_dir
pfexec chown "$UID" $debug_dir
mv Build/OvmfX64/RELEASE_ILLGCC/FV/OVMF_CODE.fd \
    $release_dir/OVMF_CODE.fd
mv Build/OvmfX64/DEBUG_ILLGCC/FV/OVMF_CODE.fd \
    $debug_dir/OVMF_CODE.fd
cd $release_dir
digest -a sha256 OVMF_CODE.fd > OVMF_CODE.fd.sha256.txt
cd $debug_dir
digest -a sha256 OVMF_CODE.fd > OVMF_CODE.fd.sha256.txt
