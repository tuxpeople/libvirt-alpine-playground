    Based on https://gist.github.com/nrocco/072ea98cca82e4721b2289cb75558da1

First download alpine-make-vm-image from https://github.com/alpinelinux/alpine-make-vm-image

    wget https://raw.githubusercontent.com/alpinelinux/alpine-make-vm-image/v0.7.0/alpine-make-vm-image \
        && echo '9803170e07b05b97eb6712e6a9097ad656954d0f  alpine-make-vm-image' | sha1sum -c \
        || exit 1
    mv alpine-make-vm-image /usr/local/bin/
    chmod +x /usr/local/bin/alpine-make-vm-image


Create a new alpine qcow2 image

    alpine-make-vm-image --image-format qcow2 --image-size 5G \
        --repositories-file repositories \
        --packages "$(cat packages)" \
        --script-chroot alpine-base.qcow2 -- configure.sh


Import that image into libvirt (https://askubuntu.com/questions/299570/how-do-i-import-a-disk-image-into-libvirt)

    # Get the image size
    qemu-img info --output json alpine-base.qcow2 | jq -r .[\"virtual-size\"]
    
    # Get the image type
    qemu-img info --output json alpine-base.qcow2 | jq -r .format

    virsh vol-create-as default alpine-base 5368709120 --format qcow2
    virsh vol-upload --pool default --vol alpine-base ./alpine-base.qcow2
    
    rm alpine-base.qcow2


Create a new domain based on the above base image (https://jlk.fjfi.cvut.cz/arch/manpages/man/virt-install.1)

    virt-install --name alpine \
        --os-variant alpinelinux3.7 \
        --memory 512 \
        --disk pool=default,size=5,backing_store=$(virsh vol-path --pool default --vol alpine-base),backing_format=qcow2,format=qcow2 \
        --import \
        --graphics vnc \
        --network default,model=virtio \
        --noautoconsole


        kvm-install-vm remove alpine-playground

        VMDIR="/data/virt/vms"
        VMNAME="alpine-playground"
        IMG="$(curl -Ls https://api.github.com/repos/tuxpeople/libvirt-alpine-playground/releases/latest | jq '.assets[].browser_download_url' -r)"
        DISK_SIZE="20G"
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
