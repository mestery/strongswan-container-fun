#!/usr/bin/env bash

if [ "$1" == 'exabgp' ]; then

  # Create pipes
  if [ ! -p /run/exabgp.in ]; then mkfifo /run/exabgp.in; chmod 600 /run/exabgp.in; fi
  if [ ! -p /run/exabgp.out ]; then mkfifo /run/exabgp.out; chmod 600 /run/exabgp.out; fi

  # Create env file
  if [ ! -f /usr/local/etc/exabgp/exabgp.env ]; then
    exabgp --fi > /usr/local/etc/exabgp/exabgp.env
    # bind to all interfaces
    sed -i "s/^bind = .*/bind = '0.0.0.0'/" /usr/local/etc/exabgp/exabgp.env 
    # run as root (otherwise ip add commands wont work)
    sed -i "s/^user = 'nobody'/user = 'root'/" /usr/local/etc/exabgp/exabgp.env 
  fi

  if [ -f /usr/local/etc/exabgp/exabgp.conf.server ] ; then
    cp /usr/local/etc/exabgp/exabgp.conf.server /usr/local/etc/exabgp/exabgp.conf
  fi
  if [ -f /usr/local/etc/exabgp/exabgp.conf.ha1-master ] ; then
    cp /usr/local/etc/exabgp/exabgp.conf.ha1-master /usr/local/etc/exabgp/exabgp.conf
  fi
  if [ -f /usr/local/etc/exabgp/exabgp.conf.ha1-slave ] ; then
    cp /usr/local/etc/exabgp/exabgp.conf.ha1-slave /usr/local/etc/exabgp/exabgp.conf
  fi
  if [ -f /usr/local/etc/exabgp/exabgp.conf.ha2-master ] ; then
    cp /usr/local/etc/exabgp/exabgp.conf.ha2-master /usr/local/etc/exabgp/exabgp.conf
  fi
  if [ -f /usr/local/etc/exabgp/exabgp.conf.ha2-slave ] ; then
    cp /usr/local/etc/exabgp/exabgp.conf.ha2-slave /usr/local/etc/exabgp/exabgp.conf
  fi
  if [ -f /usr/local/etc/exabgp/exabgp.conf.ha3-master ] ; then
    cp /usr/local/etc/exabgp/exabgp.conf.ha3-master /usr/local/etc/exabgp/exabgp.conf
  fi
  if [ -f /usr/local/etc/exabgp/exabgp.conf.ha3-slave ] ; then
    cp /usr/local/etc/exabgp/exabgp.conf.ha3-slave /usr/local/etc/exabgp/exabgp.conf
  fi

  # Modify the default route
  route delete default
  route add default gw 10.35.35.40

  # run 
  #env exabgp.daemon.user=root exabgp.log.destination=/tmp/exabgp.log exabgp.log.all=true /usr/bin/exabgp /usr/local/etc/exabgp/exabgp.conf
  env exabgp.daemon.user=root exabgp.daemon.daemonize=true exabgp.daemon.pid=/var/run/exabgp.pid exabgp.log.destination=/var/log/exabgp.log /usr/local/bin/exabgp /usr/local/etc/exabgp/exabgp.conf
else 
  exec "$@"
fi

