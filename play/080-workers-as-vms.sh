#!/bin/bash

# prereqs
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/001-prereqs.sh


# vm as - workers - create if not exists
read -rd '' cmd <<.
   az vm availability-set create -g kubernetes -n worker-as -o table
.
exists=$(az vm availability-set list -g kubernetes --query="[?name==\`worker-as\`].name" -o tsv)
action=$([ "worker-as" = "$exists" ] && echo "update" || echo "create")
cmd=${cmd/availability-set create/availability-set $action}; printf "\n${cmd}\n\n"
if [ "$action" = "create" ]; then echo; eval $cmd ; echo; else echo "(skipped: exists)"; fi


# vm sku version find - see: https://github.com/Azure/azure-cli/issues/13320#issuecomment-649867249
LOCATION=$(az group show -g kubernetes --query="location" -o tsv)
UBUNTULTS=$(az vm image list --location $LOCATION --publisher Canonical --offer 0001-com-ubuntu-server-focal --sku 20_04-lts-gen2 --all --query '[].{publisher:publisher, offer:offer, sku:sku, version:version}' -o tsv | tail -1 | tr '\t' ':')
printf "\n${UBUNTULTS}\n\n"


# vms - workers - create if not exists
for i in 0 1; do
    printf "\n[Worker ${i}] Creating public IP ${i}...\n"
    read -rd '' cmd <<.
       az network public-ip create -g kubernetes -n worker-${i}-pip \
          --allocation-method static -o table
.
    exists=$(az network public-ip list -g kubernetes --query="[?name==\`worker-${i}-pip\`].name" -o tsv)
    action=$([ "worker-${i}-pip" = "$exists" ] && echo "update" || echo "create")
    cmd=${cmd/public-ip create/public-ip $action}; printf "\n${cmd}\n\n"
    if [ "$action" = "create" ]; then echo; eval $cmd ; echo; else echo "(skipped: exists)"; fi
    ip=$(az network public-ip show -g kubernetes -n worker-${i}-pip --query 'ipAddress' -o tsv) ; printf "\n$ip\n\n"
    
     
    printf "\n[Worker ${i}] Creating NIC ${i}...\n"
    read -rd '' cmd <<.
      az network nic create -g kubernetes -n worker-${i}-nic \
         --vnet kubernetes-vnet --subnet kubernetes-subnet \
         --private-ip-address 10.240.0.2${i} --public-ip-address worker-${i}-pip \
         --ip-forwarding -o table
.
    exists=$(az network nic list -g kubernetes --query="[?name==\`worker-${i}-nic\`].name" -o tsv)
    action=$([ "worker-${i}-nic" = "$exists" ] && echo "update" || echo "create")
    cmd=${cmd/nic create/nic $action}; printf "\n${cmd}\n\n"
    if [ "$action" = "create" ]; then echo; eval $cmd ; echo; else echo "(skipped: exists)"; fi
    
    
    printf "\n[Worker ${i}] Creating VM ${i}...\n"
    read -rd '' cmd <<.
       az vm create -g kubernetes -n worker-${i} --size Standard_B2s \
          --availability-set worker-as --image ${UBUNTULTS} \
          --nics worker-${i}-nic --nsg '' \
          --admin-username 'kuberoot' --generate-ssh-keys \
          --tags pod-cidr=10.200.${i}.0/24 -o table
.
    exists=$(az vm list -g kubernetes --query="[?name==\`worker-${i}\`].name" -o tsv)
    action=$([ "worker-${i}" = "$exists" ] && echo "update" || echo "create")
    cmd=${cmd/vm create/vm $action}; printf "\n${cmd}\n\n"
    if [ "$action" = "create" ]; then echo; eval $cmd ; echo; else echo "(skipped: exists)"; fi
done


