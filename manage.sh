#!/usr/bin/env bash
#
#  Purpose: Start and Stop the Azure VM's
#  Usage:
#    manage.sh  <command>

###############################
## ARGUMENT INPUT            ##
###############################
usage() { echo "Usage: manage.sh <command>" 1>&2; exit 1; }

if [ -f ~/.azure/.env ]; then source ~/.azure/.env; fi
if [ -f ./.env ]; then source ./.env; fi

if [ -z $UNIQUE ]; then
  tput setaf 1; echo 'ERROR: UNIQUE not found' ; tput sgr0
  usage;
fi
if [ -z ${AZURE_LOCATION} ]; then
  tput setaf 1; echo 'ERROR: Global Variable AZURE_LOCATION not set'; tput sgr0
  exit 1;
fi

#////////////////////////////////
BASE=${PWD##*/}
RESOURCE_GROUP=${BASE}-${UNIQUE}

VMS_IDS=$(az vm list -g ${RESOURCE_GROUP} --query "[].id" -o tsv)

case $1 in
start)
  echo "Starting all Virtual Machines in " ${RESOURCE_GROUP}
  az vm start --ids ${VMS_IDS}
  ;;
stop)
  echo "Stopping all Virtual Machines in " ${RESOURCE_GROUP}
  az vm stop --ids ${VMS_IDS}
  ;;
*)
  echo "Deallocating all Virtual Machines in " ${RESOURCE_GROUP}
  az vm deallocate --ids ${VMS_IDS}
  ;;
esac
