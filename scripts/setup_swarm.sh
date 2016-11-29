#!/bin/bash
#
# run_consul.sh
#
# Purpose: starts and configures swarm components

#supported prop keys
NODE_TYPE_PROP="swarm.node.type"
CONNECTION_TYPE_PROP="swarm.connection.type"
CONNECTION_PROP="swarm.connection.address"

# default values
_default_node_type="node"
_default_connection_type="role"
_default_connect_role="consul"
_default_swarm_port="4000"
_default_consul_port="8500"
_default_docker_port="2375"

dockerServiceDir=/etc/systemd/system/docker.service.d

function init_props() {
  if [ $(getProperty $NODE_TYPE_PROP) ]; then
    swarm_node_type=$(getProperty $NODE_TYPE_PROP)
    logMessage -l debug "Node $(getRole) will be configured as type $swarm_node_type"
  else
    swarm_node_type=$_default_node_type
    logMessage -l debug "Node $(getRole) will be configured as type $swarm_node_type"
  fi
  if [ $(getProperty $CONNECTION_TYPE_PROP) ]; then
    swarm_connection_type=$(getProperty $CONNECTION_TYPE_PROP)
    logMessage -l debug "Connecting to swarm via: $swarm_connection_type"
  else
    swarm_connection_type=$_default_connection_type
  fi
  if [ $(getProperty $CONNECTION_PROP) ]; then
    if [ "$swarm_connection_type" = "role" ]; then
      consul_connect_address=$(getIp $(getProperty $CONNECTION_PROP))
    else
      consul_connect_address=$(getProperty $CONNECTION_PROP)
    fi
    logMessage -l debug "Joining swarm at: $consul_connect_address"
  else
    consul_connect_address=$(getIp $_default_connect_role)
  fi
}

function start_consul() {
  logMessage "Starting Consul"
  docker run -d -p 8500:8500 --name=consul progrium/consul -server -bootstrap
}

function start_manager() {
  logMessage "starting swarm manager"
  docker run -d -p $_default_swarm_port:4000 swarm manage -H :4000 --replication --advertise $(hostname -i):4000 consul://$consul_connect_address:$_default_consul_port
}

function start_node() {
  logMessage "starting swarm agent"
  docker run -d swarm join --advertise $(hostname -i):$_default_docker_port consul://$consul_connect_address:$_default_consul_port
}

function run() {
  init_props
  case $swarm_node_type in
    "consul" )
      start_consul
      ;;
    "manager" )
      start_manager
      ;;
    "node" )
      start_node
      ;;
    * )
      logMessage -l error "node of type: $swarm_node_type not supported"
      exit 1
    esac
}

run
