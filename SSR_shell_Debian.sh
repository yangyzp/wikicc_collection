#!/bin/bash
#Check Root
apt update -y
apt install python-pip git libssl-dev python-dev libffi-dev vim -y
apt update -y
apt-get install git
git clone https://github.com/yangyzp/SSR-manyuser_glzjin_shell.git SSR
cd SSR
chmod +x shadowsocks_new.sh
./shadowsocks_new.sh install | tee ss.log