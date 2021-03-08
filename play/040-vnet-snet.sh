#!/bin/bash

# prereqs
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/001-prereqs.sh


# vnet - create if not exists (a re-create deletes snets OR fails if subnet in use)
read -rd '' cmd <<.
   az network vnet create -g kubernetes -n kubernetes-vnet \
      --address-prefix 10.240.0.0/20 -o table
.
exists=$(az network vnet list -g kubernetes --query="[?name==\`kubernetes-vnet\`].name" -o tsv)
action=$([ "kubernetes-vnet" = "$exists" ] && echo "update" || echo "create")
cmd=${cmd/vnet create/vnet $action}; printf "\n$cmd\n\n"
if [ "$action" = "create" ]; then echo; eval $cmd ; echo; else echo "(skipped: exists)"; fi


# snet - create if not exists (a re-create detaches nsg, routetable, etc. OR fails if subnet in use)
read -rd '' cmd <<.
   az network vnet subnet create -g kubernetes --vnet-name kubernetes-vnet -n kubernetes-subnet \
      --address-prefix 10.240.0.0/24 -o table
.
exists=$(az network vnet subnet list -g kubernetes --vnet-name kubernetes-vnet --query="[?name==\`kubernetes-subnet\`].name" -o tsv)
action=$([ "kubernetes-subnet" = "$exists" ] && echo "update" || echo "create")
cmd=${cmd/subnet create/subnet $action}; printf "\n$cmd\n\n"
if [ "$action" = "create" ]; then echo; eval $cmd ; echo; else echo "(skipped: exists)"; fi


