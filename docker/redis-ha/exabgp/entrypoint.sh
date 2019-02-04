#!/usr/bin/env bash

if [ "$1" == 'exabgp' ]; then

  # Create pipes
  if [ ! -p /run/exabgp.in ]; then mkfifo /run/exabgp.in; chmod 600 /run/exabgp.in; fi
  if [ ! -p /run/exabgp.out ]; then mkfifo /run/exabgp.out; chmod 600 /run/exabgp.out; fi

  # Create env file
  if [ ! -f /usr/etc/exabgp/exabgp.env ]; then
    exabgp --fi > /usr/etc/exabgp/exabgp.env
    # bind to all interfaces
    sed -i "s/^bind = .*/bind = '0.0.0.0'/" /usr/etc/exabgp/exabgp.env 
    # run as root (otherwise ip add commands wont work)
    sed -i "s/^user = 'nobody'/user = 'root'/" /usr/etc/exabgp/exabgp.env 
  fi

  if [ -f /usr/etc/exabgp/exabgp.conf.server ] ; then
    cp /usr/etc/exabgp/exabgp.conf.server /usr/etc/exabgp/exabgp.conf
  fi
  if [ -f /usr/etc/exabgp/exabgp.conf.ha1 ] ; then
    cp /usr/etc/exabgp/exabgp.conf.ha1 /usr/etc/exabgp/exabgp.conf
  fi
  if [ -f /usr/etc/exabgp/exabgp.conf.ha2 ] ; then
    cp /usr/etc/exabgp/exabgp.conf.ha2 /usr/etc/exabgp/exabgp.conf
  fi

  # Modify the default route
  route delete default
  route add default gw 10.35.35.40

  # run 
  #env exabgp.daemon.user=root exabgp.log.destination=/tmp/exabgp.log exabgp.log.all=true /usr/bin/exabgp /usr/etc/exabgp/exabgp.conf
  env exabgp.daemon.user=root exabgp.daemon.daemonize=true exabgp.daemon.pid=/var/run/exabgp.pid exabgp.log.destination=/var/log/exabgp.log /usr/bin/exabgp /usr/etc/exabgp/exabgp.conf
else 
  exec "$@"
fi

