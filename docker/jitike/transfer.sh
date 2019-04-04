#!/bin/bash

STARTER=$(ps -ef | grep /usr/lib/ipsec/starter | grep -v grep | awk '{ print $2 }')
CHARON=$(ps -ef | grep /usr/lib/ipsec/charon | grep -v grep | awk '{ print $2 }')

kill -9 "${STARTER}" "${CHARON}"

ipsec stop
ipsec stop
#ipsec start
