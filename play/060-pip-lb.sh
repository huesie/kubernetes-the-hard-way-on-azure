#!/bin/bash

# prereqs
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/001-prereqs.sh


# pip - create if not exists
read -rd '' cmd <<.
   az network public-ip create -g kubernetes -n kubernetes-pip \
      --allocation-method static -o table
.
exists=$(az network public-ip list -g kubernetes --query="[?name==\`kubernetes-pip\`].name" -o tsv)
action=$([ "kubernetes-pip" = "$exists" ] && echo "update" || echo "create")
cmd=${cmd/public-ip create/public-ip $action}; printf "\n${cmd}\n\n"
if [ "$action" = "create" ]; then echo; eval $cmd ; echo; else echo "(skipped: exists)"; fi
ip=$(az network public-ip show -g kubernetes -n kubernetes-pip --query 'ipAddress' -o tsv) ; printf "\n${ip} <- Kubernetes API Server\n"


# lb - apply
read -rd '' cmd <<.
   az network lb create -g kubernetes -n kubernetes-lb \
      --public-ip-address kubernetes-pip \
      --backend-pool-name kubernetes-lb-pool -o table
.
exists=$(az network lb list -g kubernetes --query="[?name==\`kubernetes-lb\`].name" -o tsv)
action=$([ "kubernetes-lb" = "$exists" ] && echo "update" || echo "create")
cmd=${cmd/lb create/lb $action}; printf "\n${cmd}\n\n"
if [ "$action" = "create" ]; then echo; eval $cmd ; echo; else echo "(skipped: exists)"; fi


