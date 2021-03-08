#!/bin/bash

# script folder
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# load params and vars
source $DIR/000-values.sh

# validation
if [ -n "$SUBS_GUID" ] && [[ ! "$SUBS_GUID" =~ ^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$ ]]; then printf "\n**ERROR** SUBS_GUID is set to an invalid guid in file 000-values.sh\n\nTo Fix - List subscriptions with: az account list -o table\nand edit 000-values.sh and set any missing or invalid values.\n\n"; exit 1; fi
CURR_SUBS_GUID=$(az account show --query="id" -o tsv) ; printf "\n${CURR_SUBS_GUID} <- Selected Subscription ID\n\n"
if [ -n "$SUBS_GUID" ]; then
  if [ "$CURR_SUBS_GUID" != "$SUBS_GUID" ]; then printf "Expected subscription id $SUBS_GUID but found $CURR_SUBS_GUID - aborting.\n\n"; exit 1; fi
else
  printf "NB: Not validating correct subscription selected - to enable: set SUBS_GUID in 000-values.sh\n\n"
fi

# common functions

prompt_abort() { read -t 30 -rp "$1(30s) Abort? y/n " ; [[ $REPLY =~ [Yy] ]] && printf "(aborted)\n\n" && exit 1 || return 0; }

prompt_skip() { read -t 10 -rp "(10s) Skip? y/n " ; [[ $REPLY =~ [Yy] ]] && printf "(skipped)\n\n" && return 1 || return 0; }


