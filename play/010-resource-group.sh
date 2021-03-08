#!/bin/bash

# prereqs
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/001-prereqs.sh


# rg
read -rd '' cmd <<.
   az group create -n kubernetes -l \$LOCATION -o table
.
exists=$(az group list --query "[?name==\`kubernetes\`].name" -o tsv)
action=$([ "kubernetes" = "$exists" ] && echo "update" || echo "create")
cmd=${cmd/group create/group $action}
if [ "$action" = "create" ]; then
  cat <<.
**ERROR**  Resource group not found: kubernetes
Create this group manually now to set location:

       ${cmd}

  e.g. az group create -n kubernetes -l uksouth -o table
       az group create -n kubernetes -l eastus2 -o table
       az group create -n kubernetes -l westeurope -o table

To get a list of valid locations: az account list-locations --query='[].name' -o table
.
else
  echo "(skipped: exists)"
fi


