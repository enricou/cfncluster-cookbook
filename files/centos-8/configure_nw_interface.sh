#!/bin/sh
# Configure a specific Network Interface according to the OS
# The configuration involves 3 aspects:
# - Main configuration (IP address, protocol and gateway)
# - A specific routing table, so that all traffic coming to a network interface leaves the instance using the same
#   interface
# - A routing rule to make the OS use the specific routing table for this network interface

set -e

if
  [ -z "${DEVICE_NAME}" ] ||          # name of the device
  [ -z "${DEVICE_NUMBER}" ] ||        # number of the device
  [ -z "${GW_IP_ADDRESS}" ] ||        # gateway ip address
  [ -z "${DEVICE_IP_ADDRESS}" ] ||    # ip address to assign to the interface
  [ -z "${CIDR_PREFIX_LENGTH}" ]      # the prefix length of the device IP cidr block
then
  echo 'One or more environment variables missing'
  exit 1
fi

con_name="System ${DEVICE_NAME}"
route_table="100${DEVICE_NUMBER}"
priority="100${DEVICE_NUMBER}"
metric="100${DEVICE_NUMBER}"

# Rename connection
original_con_name=`nmcli -t -f GENERAL.CONNECTION device show ${DEVICE_NAME} | cut -f2 -d':'`
nmcli connection modify "${original_con_name}" con-name "${con_name}" ifname ${DEVICE_NAME}

# Setup connection method to "manual", configure ip address and gateway
nmcli connection modify "${con_name}" ipv4.method manual ipv4.addresses ${DEVICE_IP_ADDRESS}/${CIDR_PREFIX_LENGTH} ipv4.gateway ${GW_IP_ADDRESS}

# Setup routes
nmcli connection modify "${con_name}" ipv4.routes "0.0.0.0/0 ${GW_IP_ADDRESS} table=${route_table}"

# Setup routing rules
nmcli connection modify "${con_name}" ipv4.routing-rules "priority ${priority} from ${DEVICE_IP_ADDRESS} table ${route_table}"

# Assign route table and metric to the device
nmcli dev modify ${DEVICE_NAME} ipv4.route-table ${route_table} ipv4.route-metric ${metric}
