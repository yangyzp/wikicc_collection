#!/bin/bash
#Check Root
docker version > /dev/null || curl -fsSL get.docker.com | bash
service docker restart
sudo systemctl enable docker
