#!/bin/bash

# prereqs
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/001-prereqs.sh


# vm as - controllers - create if not exists
read -rd '' cmd <<.
   az vm availability-set create -g kubernetes -n controller-as -o table
.
exists=$(az vm availability-set list -g kubernetes --query="[?name==\`controller-as\`].name" -o tsv)
action=$([ "controller-as" = "$exists" ] && echo "update" || echo "create")
cmd=${cmd/availability-set create/availability-set $action}; printf "\n${cmd}\n\n"
if [ "$action" = "create" ]; then echo; eval $cmd ; echo; else echo "(skipped: exists)"; fi


# vm sku version find - see: https://github.com/Azure/azure-cli/issues/13320#issuecomment-649867249
LOCATION=$(az group show -g kubernetes --query="location" -o tsv)
UBUNTULTS=$(az vm image list --location $LOCATION --publisher Canonical --offer 0001-com-ubuntu-server-focal --sku 20_04-lts-gen2 --all --query '[].{publisher:publisher, offer:offer, sku:sku, version:version}' -o tsv | tail -1 | tr '\t' ':')
printf "\n${UBUNTULTS}\n\n"


# vms - controllers - create if not exists
for i in 0 1 2; do
    printf "\n[Controller ${i}] Creating public IP ${i}...\n"
    read -rd '' cmd <<.
       az network public-ip create -g kubernetes -n controller-${i}-pip \
          --allocation-method static -o table
.
    exists=$(az network public-ip list -g kubernetes --query="[?name==\`controller-${i}-pip\`].name" -o tsv)
    action=$([ "controller-${i}-pip" = "$exists" ] && echo "update" || echo "create")
    cmd=${cmd/public-ip create/public-ip $action}; printf "\n${cmd}\n\n"
    if [ "$action" = "create" ]; then echo; eval $cmd ; echo; else echo "(skipped: exists)"; fi
    ip=$(az network public-ip show -g kubernetes -n controller-${i}-pip --query 'ipAddress' -o tsv) ; printf "\n$ip\n\n"
    
     
    printf "\n[Controller ${i}] Creating NIC ${i}...\n"
    read -rd '' cmd <<.
      az network nic create -g kubernetes -n controller-${i}-nic \
         --vnet kubernetes-vnet --subnet kubernetes-subnet \
         --private-ip-address 10.240.0.1${i} --public-ip-address controller-${i}-pip \
         --ip-forwarding --lb-name kubernetes-lb --lb-address-pools kubernetes-lb-pool -o table
.
    exists=$(az network nic list -g kubernetes --query="[?name==\`controller-${i}-nic\`].name" -o tsv)
    action=$([ "controller-${i}-nic" = "$exists" ] && echo "update" || echo "create")
    cmd=${cmd/nic create/nic $action}; printf "\n${cmd}\n\n"
    if [ "$action" = "create" ]; then echo; eval $cmd ; echo; else echo "(skipped: exists)"; fi
    
    
    printf "\n[Controller ${i}] Creating VM ${i}...\n"
    read -rd '' cmd <<.
       az vm create -g kubernetes -n controller-${i} --size Standard_B2s \
          --availability-set controller-as --image ${UBUNTULTS} \
          --nics controller-${i}-nic --nsg '' \
          --admin-username 'kuberoot' --generate-ssh-keys -o table
.
    exists=$(az vm list -g kubernetes --query="[?name==\`controller-${i}\`].name" -o tsv)
    action=$([ "controller-${i}" = "$exists" ] && echo "update" || echo "create")
    cmd=${cmd/vm create/vm $action}; printf "\n${cmd}\n\n"
    if [ "$action" = "create" ]; then echo; eval $cmd ; echo; else echo "(skipped: exists)"; fi
done


