#!/bin/bash
set -e

USAGE="Usage: vm.sh <vmdisk> <iso>"
HELP="\
vm.sh <vmdisk> <iso>
Params:
    vmdisk            virtual machine disk file
    iso               iso disk image (optional)
"

TAP=tap0
NIC=$(route | grep '^default' | grep -o '[^ ]*$')
NET=10.10.10
UVR=uefi_vars.bin

function trace { echo " -  $@"; }
function info { echo "[+] $@"; }

function elevate {
    if (($EUID != 0)); then
        info "Elevating..."
        if [[ -t 1 ]]; then
            sudo "$0" "$@"
        else
            gksu "$0 $@"
        fi
        exit
    fi
}

function net_setup {
    trace "Enabling packet forwarding for TAP device"
    sysctl -q -w net.ipv4.ip_forward=1
    iptables -F
    iptables -F -t nat
    iptables -A FORWARD -i $TAP -o $NIC -j ACCEPT
    iptables -A FORWARD -i $NIC -o $TAP -j ACCEPT
    iptables -t nat -A POSTROUTING -o $NIC -j MASQUERADE

    trace "Creating TAP interface"
    ip tuntap add dev $TAP mode tap group netdev
    ip addr flush dev $TAP
    ip addr add $NET.1/24 dev $TAP
    ip link set $TAP up

    trace "Firing up DHCP server"
    dnsmasq -d --interface=$TAP \
               --strict-order \
               --listen-address=$NET.1 \
               --bind-interfaces \
               --dhcp-range=$NET.2,$NET.100 \
               >/dev/null 2>&1 &
    dhcpd_pid=$!
}

function net_remove {
    trace "Removing TAP interface"
    ip tuntap del $TAP mode tap
    if [ ! -z "$dhcpd_pid" ]; then
        trace "Killing DHCP server"
        pkill dnsmasq
        wait $dhcpd_pid
    fi
}

function uefi_setup {
    local vars_file=/usr/share/ovmf/x64/OVMF_VARS.fd
    if [ -f $vars_file ]; then
        trace "Found OVMF!"
        [ ! -f $UVR ] && cp $vars_file $UVR
        trace "Enabling UEFI support"
        uefi_params="-drive if=pflash,format=raw,readonly,file=/usr/share/ovmf/x64/OVMF_CODE.fd -drive if=pflash,format=raw,file=$UVR"
    else
        trace "OVMF not found"
    fi
}

function cleanup {
    info "Cleaning up..."
    net_remove
}

case "$#" in
    0)
        echo >&2 "$USAGE"; exit 1 ;;
    *)
        cmd="$1"
        case "$cmd" in
            -h|--help)
                echo "$HELP"; exit 0 ;;
            *)
                VMDISK=$1; ISOIMG=$2 ;;
        esac
esac

elevate $@
trap cleanup EXIT

info "Setting up network..."
net_setup

info "Setting up UEFI..."
uefi_setup

info "Firing up VM..."
[ -n "$VMDISK" ] && disk_params="-drive file=$VMDISK,if=virtio"
[ -n "$ISOIMG" ] && drive_params="-boot d -cdrom $ISOIMG"
qemu-system-x86_64 \
  $uefi_params $disk_params $drive_params -usb -device usb-tablet -show-cursor \
  -m 4096 -enable-kvm -M q35 -cpu host -smp 4,sockets=1,cores=4,threads=1 \
  -vga virtio -display gtk,gl=off \
  -netdev tap,id=net0,ifname=$TAP,script=no,downscript=no -device e1000,netdev=net0,mac=DE:AD:BE:EF:E0:01
