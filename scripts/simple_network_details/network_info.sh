#!/bin/bash

# Get name of network interface
interface=$(ip route get 8.8.8.8 | awk -- '{printf $5}')

# Get MAC addresses for all interfaces
mac_addresses=$(ifconfig -a | grep -oE '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')

# Get IP addresses for interface
ip_addresses=$(ifconfig $interface | grep -oE 'inet addr:[^ ]+' | sed 's/inet addr://')

# Get IP of gateway
gateway_ip=$(ip route | grep -oE 'via [^ ]+' | awk '{print $2}')

# Print information
echo "Network Interface: $interface"
echo "MAC Addresses: $mac_addresses"
echo "IP Addresses: $ip_addresses"
echo "Gateway IP: $gateway_ip"
