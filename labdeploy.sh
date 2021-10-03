#!/bin/bash

VMNAME="${1:-alpine-playground}"
DISK_SIZE="${2:-20G}"
VMDIR="${3:-/data/virt/vms}"

yum -y install jq

kvm-install-vm remove alpine-playground

IMG="$(curl -Ls https://api.github.com/repos/tuxpeople/libvirt-alpine-playground/releases/latest | jq '.assets[].browser_download_url' -r)"
# Create image directory if it doesn't already exist
mkdir -p ${VMDIR}
check_vmname_set
# Start clean
[ -d "${VMDIR}/${VMNAME}" ] && rm -rf ${VMDIR}/${VMNAME}
mkdir -p ${VMDIR}/${VMNAME}
pushd ${VMDIR}/${VMNAME}
DISK=${VMNAME}.qcow2
wget ${IMG} -O /data/virt/images/alpine-playground.qcow2
qemu-img create -q -f qcow2 -F qcow2 -b /data/virt/images/alpine-playground.qcow2 $DISK
qemu-img resize $DISK $DISK_SIZE
virsh \
    pool-create-as \
    --name=${VMNAME} \
    --type=dir \
    --target=${VMDIR}/${VMNAME} \

virt-install \
    --import \
    --name=${VMNAME} \
    --memory=2048 \
    --vcpus=1 \
    --cpu=host \
    --disk=${VMNAME}.qcow2,bus=virtio \
    --network=bridge=bridge99,model=virtio \
    --os-variant=alpinelinux3.7 \
    --noautoconsole \
    --graphics=spice,port=-1,listen=localhost
