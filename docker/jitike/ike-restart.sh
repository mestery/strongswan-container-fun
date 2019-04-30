#!/bin/bash
#
# shellcheck disable=SC1091
source env.list

IKE_TO_START=$1
JITIKE_IKE1_IMAGE=$2
JITIKE_IKE2_IMAGE=$3
JITIKE_IKE3_IMAGE=$4

if [ "${IKE_TO_START}" == "1" ] ; then
    # Start the StrongSwan Server containers
    docker run --privileged --mac-address "${SERVER1_MAC}" --net "${SSWAN_NETWORK}" --ip "${JITIKE_IKE1_IP}" --cap-add IPC_LOCK --cap-add NET_ADMIN --env-file ./env.list -id --name "${JITIKE_IKE1_NAME}" "${JITIKE_IKE1_IMAGE}"
    # Connect the redis network
    docker network connect --ip "${REDIS_HA1_MASTER_IP}" "${REDIS_NETWORK}" "${JITIKE_IKE1_NAME}"
    # Now run the up scripts
    docker exec -it "${JITIKE_IKE1_NAME}" /start-ike1.sh
else
    # Start the StrongSwan Server containers
    docker run --privileged --mac-address "${SERVER2_MAC}" --net "${SSWAN_NETWORK}" --ip "${JITIKE_IKE2_IP}" --cap-add IPC_LOCK --cap-add NET_ADMIN --env-file ./env.list -id --name "${JITIKE_IKE2_NAME}" "${JITIKE_IKE2_IMAGE}"
    # Connect the redis network
    docker network connect --ip "${REDIS_HA2_MASTER_IP}" "${REDIS_NETWORK}" "${JITIKE_IKE2_NAME}"
    # Now run the up scripts
    docker exec -it "${JITIKE_IKE2_NAME}" /start-ike2.sh
else
    # Start the StrongSwan Server containers
    docker run --privileged --mac-address "${SERVER3_MAC}" --net "${SSWAN_NETWORK}" --ip "${JITIKE_IKE3_IP}" --cap-add IPC_LOCK --cap-add NET_ADMIN --env-file ./env.list -id --name "${JITIKE_IKE3_NAME}" "${JITIKE_IKE3_IMAGE}"
    # Connect the redis network
    docker network connect --ip "${REDIS_HA2_MASTER_IP}" "${REDIS_NETWORK}" "${JITIKE_IKE3_NAME}"
    # Now run the up scripts
    docker exec -it "${JITIKE_IKE2_NAME}" /start-ike3.sh
fi

echo "Finished"
