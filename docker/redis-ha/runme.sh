#!/bin/bash
#
# The order of what happens here is as follows:
#
# 1. First, we check for the base Docker network the containers will share (defined
#    as DOCKER_NETWORK) and create it if it is not found.
# 2. We then start the HA StrongSwan IKE/ESP containers.
# 3. We next start the StrongSwan client container.
# 4. We now check for the VPN network (defined as VPN_NETWORK) and create it if it
#    is not found.
# 5. We then connect this network up to the HA StrongSwan containers.
# 6. We now run the start scripts on the HA StrongSwan containers and the client
#    StrongSwan container.
# 7. Finally, we start a farend client on the VPN_NETWORK.

# shellcheck disable=SC1091
source env.list

SERVERIMAGE1=$1
SERVERIMAGE2=$2
CLIENTIMAGE=$3

# Create the redis network
echo "Looking for ${REDIS_NETWORK}"
EXISTS="$(docker network ls | grep "${REDIS_NETWORK}")"
echo "Found this value: ${EXISTS}"
# Check if the docker network exists
if [ "x${EXISTS}" == "x" ] ; then
	docker network create "${REDIS_NETWORK}" --subnet="${REDIS_NETWORK_RANGE}"
fi

# Create the StrongSwan Network
echo "Looking for ${SSWAN_NETWORK}"
EXISTS="$(docker network ls | grep "${SSWAN_NETWORK}")"
echo "Found this value: ${EXISTS}"
# Check if the docker network exists
if [ "x${EXISTS}" == "x" ] ; then
	docker network create "${SSWAN_NETWORK}" --subnet="${SSWAN_NETWORK_RANGE}"
fi

# Create the Quagga/Client Network
echo "Looking for ${QUAGGA_NETWORK}"
EXISTS="$(docker network ls | grep "${QUAGGA_NETWORK}")"
echo "Found this value: ${EXISTS}"
# Check if the docker network exists
if [ "x${EXISTS}" == "x" ] ; then
	docker network create "${QUAGGA_NETWORK}" --subnet="${QUAGGA_NETWORK_RANGE}"
fi

# Start the redis container
docker run --name "${REDIS_NAME}" --net "${REDIS_NETWORK}" --ip "${REDIS_SERVER_IP}" -id redis

# Start the quagga container
docker run --privileged -id --name "${QUAGGA_NAME}" --net="${SSWAN_NETWORK}" --ip="${SSWAN_QUAGGA_IP}" -v `pwd`/quagga:/etc/quagga:rw pierky/quagga
docker exec -it quagga apt-get update
docker exec -it quagga apt-get install -y net-tools
docker exec -it quagga route add -host 10.15.15.15/32 dev eth0

# Attach Quagga to Quagga network
docker network connect --ip "${QUAGGA_Q_IP}" "${QUAGGA_NETWORK}" "${QUAGGA_NAME}"

# Start the StrongSwan Server containers
docker run --privileged --mac-address "${SERVER1_MAC}" --net "${SSWAN_NETWORK}" --ip "${SSWAN_HA1_MASTER_IP}" --cap-add IPC_LOCK --cap-add NET_ADMIN --env-file ./env.list -id --name "${SERVER1_NAME}" "${SERVERIMAGE1}"
docker run --privileged --mac-address "${SERVER2_MAC}" --net "${SSWAN_NETWORK}" --ip "${SSWAN_HA1_SLAVE_IP}" --cap-add IPC_LOCK --cap-add NET_ADMIN --env-file ./env.list -id --name "${SERVER2_NAME}" "${SERVERIMAGE2}"

# Connect the redis network
docker network connect --ip "${REDIS_HA1_MASTER_IP}" "${REDIS_NETWORK}" "${SERVER1_NAME}"
docker network connect --ip "${REDIS_HA1_SLAVE_IP}" "${REDIS_NETWORK}" "${SERVER2_NAME}"

# Run the client container
docker run --privileged --mac-address "${CLIENT_MAC}" --net "${QUAGGA_NETWORK}" --ip "${QUAGGA_C_IP}" --cap-add IPC_LOCK --cap-add NET_ADMIN --env-file ./env.list -id --name "${CLIENT_NAME}" "${CLIENTIMAGE}"

# Now run the up scripts
docker exec -it "${SERVER1_NAME}" /startstrongswan1.sh
docker exec -it "${SERVER2_NAME}" /startstrongswan2.sh
docker exec -it "${CLIENT_NAME}" /startvpnclient.sh

echo "Finished"
