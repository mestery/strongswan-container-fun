# strongswan-container-fun

[![Build Status](https://travis-ci.org/mestery/strongswan-container-fun.svg?branch=master)](https://travis-ci.org/mestery/strongswan-container-fun)
[![GitHub license](https://img.shields.io/badge/license-Apache%20license%202.0-blue.svg)](https://github.com/mestery/strongswan-container-fun/blob/master/LICENSE)

StrongSwan for Docker containers
================================

This is used to test StrongSwan HA in Docker containers.

Building, running, testing
==========================

To build, run and test the allinone instance:

```
make docker-build
make run
make test
```

StrongSwan HA Scale VPN
=======================

See the [README.md](docker/ha-scale-vpn/README.md) for more information.

Redis-HA Setup
==============

To build this setup: `make docker-build-redis-ha`

To run the setup: `make run-redis-ha`

To remove this setup: `make remove-redis-ha`

See the [README.md](docker/redis-ha/README.md) for more information.
