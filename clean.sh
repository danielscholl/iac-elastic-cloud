#!/usr/bin/env bash
#
#  Purpose: Delete the Azure Resources
#  Usage:
#    clean.sh <unique>


###############################
## ARGUMENT INPUT            ##
###############################
usage() { echo "Usage: install.sh <unique>" 1>&2; exit 1; }

if [ -f ~/.azure/.env ]; then source ~/.azure/.env; fi
if [ -f ./.env ]; then source ./.env; fi

if [ -z $UNIQUE ]; then
  tput setaf 1; echo 'ERROR: UNIQUE not found' ; tput sgr0
  usage;
fi

#####################################
## Remove Temporary Resource Group ##
#####################################
BASE=${PWD##*/}
RESOURCE_GROUP=${BASE}-${UNIQUE}

tput setaf 2; echo "Removing the $RESOURCE_GROUP resource group..." ; tput sgr0
az group delete --name ${RESOURCE_GROUP} --no-wait --yes

if [ -d ansible/inventories ]; then rm -rf ansible/inventories; fi
if [ -f ansible/playbooks/main.retry ]; then rm ansible/playbooks/main.retry; fi
