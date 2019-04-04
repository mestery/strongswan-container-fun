JITIKE Container Testing
========================

This directory contains Dockerfiles and scripts to build, run and test
the following containers:
* Two StrongSwan containers with the JITIKE plugin enabled.
* Two StrongSwan client containers.
* A redis container.
* A Quagga container for routing between clients and servers.

Note that in the client container, we use network namespaces to run a
per-client ipsec. That configuration is handled roughly by the instructions
found [here](https://wiki.strongswan.org/projects/strongswan/wiki/Netns#Running-strongSwan-Inside-a-Network-Namespace).
The HA configuration for StrongSwan is based on the examples found on
[this page](https://wiki.strongswan.org/projects/strongswan/wiki/HighAvailability).

The configuration of the container is handled by the `env.list` file found
in this directory. To change this configuration, you can modify this file or
pass these individually on the command line when launching this container.

Before Building
---------------

Make sure to set the environment variables `GH_USERNAME` and `GH_API_TOKEN` to relevant
values.

Network Layout
--------------

The built containers are networked as follows:

![Site Map](./docs/diagrams/anycast_vpn.png)

Accessing the nodes
-------------------

To access the Quagga node:

```
docker exec -it quagga telnet 127.0.0.1 2605
```

From there, you can examine the BGP session and routes:

```
show bgp summary
show ip bgp
```

Logging into a StrongSwan node (ike1 or ike2) and accessing redis using the CLI
requires you to pass `-h 10.5.5.10` to redis-cli since redis is not running
locally.

On client1 or client2, there is a script located at /scale.sh which allows you
to build out clients. Modify `MAXCOUNT` at the top of the script to change the
number of clients you create.
