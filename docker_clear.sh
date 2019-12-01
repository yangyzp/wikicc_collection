#!/bin/bash
#Check Root
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker image rm $(docker image ls -a -q)
docker volume rm $(docker volume ls -q)
