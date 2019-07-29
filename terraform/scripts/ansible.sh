#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y

#update openssl for prompt during non-interactive issue for ansible installation
sudo apt-get upgrade openssl -y
sudo apt-get install python3-pip -y
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update -y

#Interactive prompt during non-interactive install
#Due to bug in this ubuntu release --https://bugs.launchpad.net/ubuntu/+source/ansible/+bug/1833013
sudo UCF_FORCE_CONFOLD=1 DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -qq -y install ansible

