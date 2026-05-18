#!/bin/sh
LIBVIRT_VAR="${LIBVIRT_VAR:-/var/lib/libvirt}"
NAME="${1:-fedora44-pacman}"
virt-install \
	--connect qemu:///system \
	--location="https://download.fedoraproject.org/pub/fedora/linux/releases/44/Everything/x86_64/os/" \
	--initrd-inject=anaconda-ks.cfg \
	--extra-args="inst.ks=file:/anaconda-ks.cfg console=hvc0" \
	--name="$NAME" --osinfo fedora44 --network=network=default \
	--vcpus=4 --memory=4096 --memorybacking="access.mode=shared,source.type=memfd" \
	--console="type=pty,target.type=virtio" \
	--rng /dev/urandom \
	--memballoon model=virtio \
	--filesystem="$LIBVIRT_VAR/filesystems/containers,containers,readonly=true,driver.type=virtiofs" \
	--disk "$LIBVIRT_VAR/images/$NAME.qcow2,size=20" \
	--video none --sound none --graphics none \
	--boot uefi
