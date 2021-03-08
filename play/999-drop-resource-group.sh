#!/bin/bash

# prereqs
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/001-prereqs.sh


# rg
read -rd '' cmd <<.
   az group create -n kubernetes -o table
.
exists=$(az group list --query "[?name==\`kubernetes\`].name" -o tsv)
action=$([ "kubernetes" = "$exists" ] && echo "delete" || echo "create")
cmd=${cmd/group create/group $action}; printf "\n$cmd\n\n"
if [ "$action" = "delete" ]; then echo; eval $cmd ; echo; else echo "(skipped: not exists)"; fi


