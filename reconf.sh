#!/bin/bash
BR_BOUFFALO_OVERLAY_PATH=$(pwd)
BR_ROOTFS=$(pwd)/board/pine64/ox64/rootfs-overlay/

# .env variables:
#
# - remote logging: SYSLOGD_ARGS="-R 192.168.0.123:514 -s 30 -b 3 -L"
# - wifi: AP_NAME=".."; AP_PASSWORD=".." [; AP_NAME2=".."; AP_PASSWORD2=".." ]
# - opkg: OPKG_REPO="src/gz repo_name http://192.168.0.123/"
# - ssh: SSH_AUTH_KEY=".."
#
reconf() {
    SYSLOGD_ARGS="-s 50 -b 3"
    if [ -e .env ]; then . .env; fi

    mkdir -p $BR_ROOTFS/etc/default

    # syslogd config
    echo "SYSLOGD_ARGS=\"$SYSLOGD_ARGS\"" >$BR_ROOTFS/etc/default/syslogd

    # wifi config
    for i in "" 2 3; do
        AP_NAME=$(eval echo \$AP_NAME$i)
        AP_PASSWORD=$(eval echo \$AP_PASSWORD$i)
        if [ "$AP_NAME" != "" ]; then
           echo "AP_NAME$i=\"$AP_NAME\""
           echo "AP_PASSWORD$i=\"$AP_PASSWORD\""
        fi
    done >$BR_ROOTFS/etc/default/wifi

    # opkg config
    mkdir -p $BR_ROOTFS/etc/opkg
    echo $OPKG_REPO >$BR_ROOTFS/etc/opkg/customfeeds.conf

    # Persistent SSH server key (TODO: move to .env?)
    mkdir -p $BR_ROOTFS/etc/dropbear
    echo "AAAAC3NzaC1lZDI1NTE5AAAAQOa1oM8pz0F9uEE0KmNyCBHpQVf9gLLw5EZvcUySFPv1eOjMaRN5/b/pzFVVQs7AAX28IoUr7t2tB4jl01dimVA=" | base64 -d > $BR_ROOTFS/etc/dropbear/dropbear_ed25519_host_key

    # SSH Authorized Key
    echo "SSH_AUTH_KEY=\"$SSH_AUTH_KEY\"" > $BR_ROOTFS/etc/default/rootssh
}
     
# --- main ---
reconf
cd buildroot
make BR2_EXTERNAL=$BR_BOUFFALO_OVERLAY_PATH bl808_nor_flash_defconfig
