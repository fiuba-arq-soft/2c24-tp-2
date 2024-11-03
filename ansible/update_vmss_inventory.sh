#!/bin/bash

# Get the Jumpbox DNS name
JUMPBOX_DNS=$(cat ./jumpbox_dns)

# Setup how Ansible is going to use the Jumpbox to communicate with the VMSS instances
echo "[vmss:vars]" > ./vmss_hosts
echo "ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand=\"ssh -o StrictHostKeyChecking=no -i ../key.pem -W %h:%p -q azureuser@$JUMPBOX_DNS\"'" >> ./vmss_hosts

# List all instances, obtain their private IP and add those to the inventory
echo "[vmss]" >> ./vmss_hosts
az vmss nic list --resource-group tp2_resource_group --vmss-name tp2vmss --query [].ipConfigurations[].privateIPAddress -o tsv | tr "\t" "\n" >> ./vmss_hosts