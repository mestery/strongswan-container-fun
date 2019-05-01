#!/bin/bash

# First arg indicates whether or not we want to tail the log at the end
RUNFROMCOMPOSE=$1

set -xe

mv /etc/strongswan.d/charon-logging.conf /etc/strongswan.d/charon-logging.conf.old
cat > /etc/strongswan.d/charon-logging.conf << EOL
charon {
    # two defined file loggers
    filelog {
        charon {
            # path to the log file, specify this as section name in versions prior to 5.7.0
            path = /var/log/charon.log
            # add a timestamp prefix
            time_format = %b %e %T
            # prepend connection name, simplifies grepping
            ike_name = yes
            # overwrite existing files
            append = no
            # increase default loglevel for all daemon subsystems
            default = 1
            # flush each line to disk
            flush_line = yes
        }
        stderr {
            # more detailed loglevel for a specific subsystem, overriding the
            # default loglevel.
            ike = 2
            knl = 3
        }
    }
}
EOL

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
        left=${QUAGGA_C2_IP}
        leftauth=psk
        auto=add
        dpdaction=restart
        dpddelay=10s
EOL
sudo mv /tmp/ipsec.conf /etc/ipsec.conf

cat >/tmp/ipsec.secrets << EOL
: PSK "Vpp123"
EOL
sudo mv /tmp/ipsec.secrets /etc/ipsec.secrets

# Modify the default route
route delete default
route add default gw "${QUAGGA_Q_IP}"

mkdir -p /etc/ipsec.d/run
ipsec start && sleep 5
ipsec up net-net

# If this script is run via the Dockerfile, we'd want the below at the end. But
# in the case of the ha-scale-vpn containers, we run this script via a "docker
# exec" command after the container is started, so we'll comment this out for
# this use case and leave it here as a note in case someone copies this script.
if [ "${RUNFROMCOMPOSE}" == "compose" ] ; then
  tail -f /dev/null
fi
