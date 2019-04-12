#!/bin/bash

ANYCAST_NETWORK=anycast
ANYCAST_SUBNET=10.199.199.0/24
ANYCASTCLIENT1IP=10.199.199.21
ANYCASTCLIENT2IP=10.199.199.22
ANYCASTSERVERIP=10.199.199.40

REMOTE_NETWORK=clientnetwork
REMOTE_SUBNET=10.50.50.0/24
REMOTECLIENTIP=10.50.50.10
REMOTESERVERIP=10.50.50.40

echo "Looking for ${ANYCAST_NETWORK}"
EXISTS="$(docker network ls | grep "${ANYCAST_NETWORK}")"
echo "Found this value: ${EXISTS}"
# Check if the docker network exists
if [ "x${EXISTS}" == "x" ] ; then
        docker network create "${ANYCAST_NETWORK}" --subnet="${ANYCAST_SUBNET}"
fi

docker run -d --name client1 --cap-add=NET_ADMIN --privileged --net="${ANYCAST_NETWORK}" --ip="${ANYCASTCLIENT1IP}" any/client1
docker run -d --name client2 --cap-add=NET_ADMIN --privileged --net="${ANYCAST_NETWORK}" --ip="${ANYCASTCLIENT2IP}" any/client2
docker run -d --name server --net="${ANYCAST_NETWORK}" --ip="${ANYCASTSERVERIP}" -v "$(pwd)"/quagga:/etc/quagga:rw pierky/quagga

echo "Looking for ${REMOTE_NETWORK}"
EXISTS="$(docker network ls | grep "${REMOTE_NETWORK}")"
echo "Found this value: ${EXISTS}"
# Check if the docker network exists
if [ "x${EXISTS}" == "x" ] ; then
        docker network create "${REMOTE_NETWORK}" --subnet="${REMOTE_SUBNET}"
fi

# Connect the remote network
docker network connect --ip "${REMOTESERVERIP}" "${REMOTE_NETWORK}" server

# Start the remote container
docker run -d --name remote --cap-add=NET_ADMIN --privileged --net="${REMOTE_NETWORK}" --ip="${REMOTECLIENTIP}" any/remote

# Set the quagga route
