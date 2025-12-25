#!/bin/bash
admin_user=openvpn
admin_pw=Openvpn@123
reroute_gw=1     # If 1, clients route internet traffic through the VPN.
reroute_dns=1   # If 1, clients route DNS queries through the VPN. Note: If the VPC CIDR block is defined, it is made accessible to VPN clients via NAT.