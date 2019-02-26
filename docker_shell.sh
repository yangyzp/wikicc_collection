#!/bin/bash
#Check Root
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager \
    --add-repo \
     https://download.docker.com/linux/centos/docker-ce.repo
sudo yum makecache fast
sudo yum install docker-ce  -y
sudo systemctl start docker
sudo systemctl enable docker
