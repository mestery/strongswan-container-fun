#!/bin/bash

set -xe

cat >/tmp/ipsec.conf << EOL
config setup
        strictcrlpolicy=no

conn %default
        #ike=aes256-sha1-modp2048!
        esp=aes128gcm8
        mobike=no
        keyexchange=ikev2
        ikelifetime=24h
        lifetime=24h

conn net-net
        type=tunnel
        right=${SSWAN_ANYCAST_IP}
        rightsubnet=0.0.0.0/0
        rightauth=psk
        left=${QUAGGA_C_IP}
        leftauth=psk
        auto=add
EOL
sudo mv /tmp/ipsec.conf /etc/ipsec.conf

cat >/tmp/ipsec.secrets << EOL
: PSK "Vpp123"
EOL
sudo mv /tmp/ipsec.secrets /etc/ipsec.secrets

# Modify the default route
route delete default
route add default gw 10.124.223.251

mkdir -p /etc/ipsec.d/run
ipsec start && sleep 5
ipsec up net-net

# If this script is run via the Dockerfile, we'd want the below at the end. But
# in the case of the ha-scale-vpn containers, we run this script via a "docker
# exec" command after the container is started, so we'll comment this out for
# this use case and leave it here as a note in case someone copies this script.
#tail -f /dev/null
