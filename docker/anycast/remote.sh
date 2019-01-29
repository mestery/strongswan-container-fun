#!/bin/bash

# Modify the default route
route delete default
route add default gw 10.50.50.40

# Run forever
tail -f /dev/null
