#!/bin/bash
#
# Copyright (c) 2019 Cisco and/or its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at:
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# This script will (in parallel) load new StrongSwan onto some hosts
#
# We do things in this order:
#
# 1. Copy the diff file over
# 2. Stop ipsec on the host
# 3. Apply the diff
# 4. Build StrongSwan
# 5. Install StrongSwan
# 6. Restart StrongSwan

set -xe

HOSTFILE=newswan.txt
DIFF="$1"

perform_reload() {
    BDIFF=$(basename ${DIFF})

    # Copy the diff file over
    docker cp "${DIFF}" "${1}":/tmp

    # Run the script on the container
    docker exec -i "${1}" /reload.sh
}

#while IFS= read -r dhost
#do
#    perform_reload "${dhost}" &
#done < "${HOSTFILE}"

# Do the slaves first
perform_reload ha1s &
perform_reload ha2s &
wait

# Now do the masters
perform_reload ha1m &
perform_reload ha2m &
wait

echo "All host upgraded"
