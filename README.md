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

How to deploy it in my lab:

`curl -sfL https://github.com/tuxpeople/libvirt-alpine-playground/raw/master/labdeploy.sh | bash -`
