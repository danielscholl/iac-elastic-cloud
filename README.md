# iac-elastic-cloud

This is an Azure environment created using ARM templates to test Elastic Cloud Enterprise

__Requirements:__

- Cloud Shell

## Installation
### Clone the repo

```
git clone https://github.com/danielscholl/iac-elastic-cloud
cd iac-elastic-cloud
```


### Provision IaaS using ARM Template scripts

The first step is to deploy the custom ARM Templates using the install.sh script.  The script has two optional arguments.

- allocator count (The number of Allocator Nodes desired to be created  ie: 2)
- director count (The number of Director_Cordinator Nodes desired to be created  ie: 2)

```bash
./install.sh 2 2
```

### Configure the IaaS servers using Ansible Playbooks

Once the template is deployed properly a few Azure CLI commands are run to create the items not supported by ARM Templates.



#### Ansible Configuration File

This is the default ansible configuration file that is used by the provisioning process it identifies the location of the ssh keys and where the inventory file is located at.

```yaml
[defaults]
inventory = ./ansible/inventories/azure//hosts
private_key_file = ~/.ssh/id_rsa
host_key_checking = false
```

```bash
export ANSIBLE_CONFIG=./.ansible.cfg
```

### Validate Connectivity

Check and validate ansible connectivity once provisioning has been completed and begin to configure the node servers.

```bash
ansible all -m ping  #Check Connectivity
ansible-playbook ansible/playbooks/main.yml  # Provision the node Servers
```

### Upload Apps to File Share

```bash
./sync.sh
```

## Script Usage

- init.sh _unique_ _count_ (provision IaaS into azure)
- clean.sh _unique_ _count_ (delete IaaS from azure)
- connect.sh _unique_ _node_ (SSH Connect to the node instance)
- manage.sh _unique_ _command_ (deprovision/start/stop nodes in azure)
