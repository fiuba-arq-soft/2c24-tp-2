#!/bin/bash
OLD_DIR="$(pwd)"
DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $DIR

./update_vmss_inventory.sh
ansible-playbook -i vmss_hosts --private-key ../key.pem -u azureuser ./vmss_setup.yml

cd $OLD_DIR