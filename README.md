# Docker Swarm

Docker Swarm is native clustering for Docker. It turns a pool of Docker hosts into a single, virtual Docker host. Because Docker Swarm serves the standard Docker API, any tool that already communicates with a Docker daemon can use Swarm to transparently scale to multiple hosts.

# Usage
This asset supports configuration via custom deployment properties.
Supported Properties:

| key | values | default | description |
|:-----:|:--------:|:---------:|:-------------:|
|`swarm.node.type.<role>`|`consul`, `manager`, `node`|`node`|Determines type of swarm node
|`swarm.connection.type.<role>`|`role`,`host`|`role`|Join swarm via cons3rt role or by hostname/ip
|`swarm.connection.address.<role>`|any valid deployment `role` or `host`|role: `manager`, host: `manager.local` |Configure the role or host to use for consul connections |

# Requirements:
 * Linux Kernel 3.10+
 * Yum
 * [Cons3rt Utils](https://github.com/oconnormi/cons3rt-utils)
 * Docker
