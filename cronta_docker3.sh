#!/bin/bash
#Check Root
echo "11 4 * * * /sbin/reboot" >> /var/spool/cron/root
service crond restart
chkconfig crond on
systemctl stop firewalld.service
systemctl disable firewalld.service

