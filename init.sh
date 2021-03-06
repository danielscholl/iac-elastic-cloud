#!/usr/bin/env bash
#
#  Purpose: Initialize the template load for testing purposes
#  Usage:
#    install.sh



###############################
## ARGUMENT INPUT            ##
###############################

usage() { echo "Usage: install.sh " 1>&2; exit 1; }

if [ -f ./.envrc ]; then source ./.envrc; fi

if [ -z $AZURE_LOCATION ]; then
  AZURE_LOCATION="eastus"
fi
if [ -z $UNIQUE ]; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    UNIQUE=$(jot -r 1  100 999)
  else
    UNIQUE=$(shuf -i 100-999 -n 1)
  fi
fi
if [ ! -z $1 ]; then ALLOCATORS=$1; fi
if [ -z $ALLOCATORS ]; then
  ALLOCATORS=3
fi
if [ ! -z $2 ]; then DIRECTORS=$2; fi
if [ -z $DIRECTORS ]; then
  DIRECTORS=2
fi
if [ ! -z $3 ]; then PRIMARIES=$3; fi
if [ -z $PRIMARIES ]; then
  PRIMARIES=1
fi

BASE=${PWD##*/}
PRINCIPAL_NAME=${BASE}-${UNIQUE}

###############################
## FUNCTIONS                 ##
###############################

function CreateSSHKeys() {
  # Required Argument $1 = SSH_USER
  if [ ! -d ~/.ssh ]
  then
    local _BASE_DIR = ${pwd}
    mkdir ~/.ssh && cd ~/.ssh
    ssh-keygen -t rsa -b 2048 -C $1 -f id_rsa && cd $_BASE_DIR
  fi

 _result=`cat ~/.ssh/id_rsa.pub |awk '{print $(NF-1), $NF}'`
 echo $_result
}



###############################
## Azure Intialize           ##
###############################

tput setaf 2; echo 'Creating SSH Keys...' ; tput sgr0
AZURE_USER=$(az account show --query user.name -otsv)
LINUX_USER=(${AZURE_USER//@/ })
SSH_KEY=$(CreateSSHKeys $AZURE_USER)

tput setaf 2; echo 'Deploying ARM Template...' ; tput sgr0
if [ -f ./params.json ]; then PARAMS="params.json"; else PARAMS="azuredeploy.parameters.json"; fi

echo $SSH_KEY
exit
az deployment create --template-file azuredeploy.json  \
  --location $AZURE_LOCATION \
  --parameters $PARAMS \
  --parameters random=$UNIQUE \
  --parameters adminUserName=$LINUX_USER \
  --parameters adminSshKey=$SSH_KEY

##############################
## Create Ansible Inventory ##
##############################
BASE=${PWD##*/}
RESOURCE_GROUP=${BASE}-${UNIQUE}
PRIMARY_PORT=4000
DIRECTOR_PORT=5000
ALLOCATOR_PORT=6000
INVENTORY="./ansible/inventories/azure/"
GLOBAL_VARS="./ansible/inventories/azure/group_vars"
mkdir -p ${INVENTORY};
mkdir -p ${GLOBAL_VARS}

tput setaf 2; echo "Retrieving Ansible Required Information ..." ; tput sgr0

TENANT=$(az account show \
  --query tenantId \
  -otsv)

LB_IP=$(az network public-ip show \
  --resource-group ${RESOURCE_GROUP} \
  --name ${UNIQUE}-lb-ip \
  --query ipAddress \
  -otsv)

# Ansible Inventory
tput setaf 2; echo 'Creating the ansible inventory files...' ; tput sgr0
cat > ${INVENTORY}/hosts << EOF
$(for (( c=0; c<$PRIMARIES; c++ )); do echo "primary-vm$c ansible_host=$LB_IP ansible_port=$(($PRIMARY_PORT + $c)) ansible_user=$LINUX_USER availability_zone=zone-$c"; done)
$(for (( c=0; c<$DIRECTORS; c++ )); do echo "director-vm$c ansible_host=$LB_IP ansible_port=$(($DIRECTOR_PORT + $c)) ansible_user=$LINUX_USER availability_zone=zone-$((1 + $c))"; done)
$(for (( c=0; c<$ALLOCATORS; c++ )); do echo "allocator-vm$c ansible_host=$LB_IP ansible_port=$(($ALLOCATOR_PORT + $c)) ansible_user=$LINUX_USER availability_zone=zone-$c"; done)

[primary]
$(for (( c=0; c<$PRIMARIES; c++ )); do echo "primary-vm$c"; done)

[director_coordinator]
$(for (( c=0; c<$DIRECTORS; c++ )); do echo "director-vm$c"; done)

[allocator]
$(for (( c=0; c<$ALLOCATORS; c++ )); do echo "allocator-vm$c"; done)

EOF
