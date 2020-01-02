#!/bin/bash
# cat setup.sh | gzip -9 | base64 -w0

#	Update package index
apt-get update

apt-get install -y \
  libxss1 \
  aptitude
