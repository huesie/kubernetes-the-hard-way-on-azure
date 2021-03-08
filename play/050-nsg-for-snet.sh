#!/bin/bash

# prereqs
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/001-prereqs.sh


# nsg - create if not exists
read -rd '' cmd <<.
   az network nsg create -g kubernetes -n kubernetes-nsg -o table
.
exists=$(az network nsg list -g kubernetes --query="[?name==\`kubernetes-nsg\`].name" -o tsv)
action=$([ "kubernetes-nsg" = "$exists" ] && echo "update" || echo "create")
cmd=${cmd/nsg create/nsg $action}; printf "\n${cmd}\n\n"
if [ "$action" = "create" ]; then echo; eval $cmd ; echo; else echo "(skipped: exists)"; fi


# snet assign nsg - update if not set
read -rd '' cmd <<.
   az network vnet subnet update -g kubernetes -n kubernetes-subnet --vnet-name kubernetes-vnet \
      --network-security-group kubernetes-nsg -o table
.
snet_nsg_rid=$(az network vnet subnet show -g kubernetes -n kubernetes-subnet --vnet-name kubernetes-vnet --query="networkSecurityGroup.id" -o tsv)
curr_nsg=$((IFS='/'; for elem in $snet_nsg_rid; do echo "$elem"; done) | tac | head -1) # last elem of rid
action=$([ "$curr_nsg" = "kubernetes-nsg" ] && echo "exists" || echo "update")
printf "\n${cmd}\n\n"
if [ "$action" = "update" ]; then echo; eval $cmd ; echo; else echo "(skipped: exists)"; fi


# nsg rule 1 ssh - create if not exists
read -rd '' cmd <<.
   az network nsg rule create -g kubernetes --nsg-name kubernetes-nsg -n kubernetes-allow-ssh \
      --access allow --direction inbound --protocol tcp --priority 1000 \
      --destination-address-prefix '*' --destination-port-range 22 \
      --source-address-prefix '*' --source-port-range '*' -o table
.
exists=$(az network nsg rule list -g kubernetes --nsg-name kubernetes-nsg --query="[?name==\`kubernetes-allow-ssh\`].name" -o tsv)
action=$([ "kubernetes-allow-ssh" = "$exists" ] && echo "update" || echo "create")
cmd=${cmd/rule create/rule $action}; printf "\n${cmd}\n\n"
if [ "$action" = "create" ]; then echo; eval $cmd ; echo; else echo "(skipped: exists)"; fi


# nsg rule 2 api server - create if not exists
read -rd '' cmd <<.
   az network nsg rule create -g kubernetes --nsg-name kubernetes-nsg -n kubernetes-allow-api-server \
      --access allow --direction inbound --protocol tcp --priority 1001 \
      --destination-address-prefix '*' --destination-port-range 6443 \
      --source-address-prefix '*' --source-port-range '*' -o table
.
exists=$(az network nsg rule list -g kubernetes --nsg-name kubernetes-nsg --query="[?name==\`kubernetes-allow-api-server\`].name" -o tsv)
action=$([ "kubernetes-allow-api-server" = "$exists" ] && echo "update" || echo "create")
cmd=${cmd/rule create/rule $action}; printf "\n${cmd}\n\n"
if [ "$action" = "create" ]; then echo; eval $cmd ; echo; else echo "(skipped: exists)"; fi


