#!/bin/bash
#
# setup_swarm.sh
#
# Purpose: starts and configures swarm components

#supported prop keys
NODE_TYPE_PROP="swarm.node.type"
CONNECTION_TYPE_PROP="swarm.connection.type"
CONNECTION_PROP="swarm.connection.address"

# default values
_default_node_type="worker"
_default_connection_type="role"
_default_connect_role="manager"

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
      manager_connect_address=$(getIp $(getProperty $CONNECTION_PROP))
    else
      manager_connect_address=$(getProperty $CONNECTION_PROP)
    fi
    logMessage -l debug "Joining swarm at: $manager_connect_address"
  else
    manager_connect_address=$(getIp $_default_connect_role)
  fi
}

function start_manager() {
  logMessage "starting swarm manager"
  docker swarm init --advertise-addr $(hostname -i)
}

function start_worker() {
  logMessage "starting swarm agent"
  docker_join_command=$(docker --host $manager_connect_address swarm join-token worker | sed 's/^.*docker/docker/')
  docker_join_command
}

function run() {
  init_props
  case $swarm_node_type in
    "manager" )
      start_manager
      ;;
    "worker" )
      start_node
      ;;
    * )
      logMessage -l error "node of type: $swarm_node_type not supported"
      exit 1
    esac
}

run
