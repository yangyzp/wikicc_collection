#!/bin/bash
#Check Root
echo "11 4 * * * sudo service docker restart" >> /var/spool/cron/root
echo "38 4 * * * /sbin/reboot" >> /var/spool/cron/root
service crond restart
chkconfig crond on
systemctl stop firewalld.service
systemctl disable firewalld.service

