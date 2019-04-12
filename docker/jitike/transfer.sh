#!/bin/bash

# shellcheck disable=SC2009
STARTER=$(ps -ef | grep /usr/lib/ipsec/starter | grep -v grep | awk '{ print $2 }')
# shellcheck disable=SC2009
CHARON=$(ps -ef | grep /usr/lib/ipsec/charon | grep -v grep | awk '{ print $2 }')

kill -9 "${STARTER}" "${CHARON}"

ipsec stop
ipsec stop
#ipsec start
