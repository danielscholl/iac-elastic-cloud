#!/bin/bash
# cat setup.sh | gzip -9 | base64 -w0

#	Update package index
apt-get update

#	Install tools
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
