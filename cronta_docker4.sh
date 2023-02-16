#!/bin/bash
#Check Root
echo "11 4 * * * /sbin/reboot" >> /var/spool/cron/root
/etc/init.d/cron restart
