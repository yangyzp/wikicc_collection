#!/bin/sh

apt -v && apt update -y

bash -c "firewalld -h && yum remove firewalld -y ; setenforce 0 && sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config">/dev/null
bash -c "ufw -v && systemctl stop ufw && systemctl disable ufw && apt remove ufw -y">/dev/null
echo "已卸载防火墙"
#stop some service
systemctl stop waagent && systemctl disable waagent && echo "已停止waagent"
systemctl stop walinuxagent && systemctl disable walinuxagent && echo "已停止waagent"
systemctl stop hypervkvpd && systemctl disable hypervkvpd && echo "已停止hypervkvpd"
tuned -v > /dev/null && systemctl stop tuned && systemctl disable tuned && echo "已停止tuned"
systemctl stop smartd && systemctl disable smartd && echo "已停止smartd"

/usr/local/qcloud/YunJing/uninst.sh
/usr/local/qcloud/stargate/admin/uninstall.sh
/usr/local/qcloud/monitor/barad/admin/uninstall.sh
/usr/local/sa/agent/uninstall.sh
rm -rf /usr/local/qcloud
sed -i "/qcloud/d" /etc/rc.local
echo "已卸载腾讯云"

# ulimit & open files
echo "1000000" > /proc/sys/fs/file-max
ulimit -SHn 1000000 && ulimit -c unlimited
echo "root     soft   nofile    1000000
root     hard   nofile    1000000
root     soft   nproc     1000000
root     hard   nproc     1000000
root     soft   core      1000000
root     hard   core      1000000
root     hard   memlock   unlimited
root     soft   memlock   unlimited

*     soft   nofile    1000000
*     hard   nofile    1000000
*     soft   nproc     1000000
*     hard   nproc     1000000
*     soft   core      1000000
*     hard   core      1000000
*     hard   memlock   unlimited
*     soft   memlock   unlimited
">/etc/security/limits.conf
if grep -q "ulimit" /etc/profile; then
  :
else
  sed -i '/ulimit -SHn/d' /etc/profile
  echo "ulimit -SHn 1000000" >>/etc/profile
fi
if grep -q "pam_limits.so" /etc/pam.d/common-session; then
  :
else
  sed -i '/required pam_limits.so/d' /etc/pam.d/common-session
  echo "session required pam_limits.so" >>/etc/pam.d/common-session
fi
echo "ulimit已调优"

#bbr
if uname -r|grep -q "^5."
then
    echo "kernel 5.x OK"
else
    echo "updating kernel..."
    rm /root/bbr.sh -f;wget neko.nnr.moe:1314/bbr.sh -O /root/bbr.sh > /dev/null; bash /root/bbr.sh > /dev/null
fi
echo "BBR内核安装完成"

# sysctl.conf
rm -f /etc/sysctl.d/*.conf
cat > '/etc/sysctl.conf' << EOF
fs.file-max=1000000
fs.inotify.max_user_instances=65536

net.ipv4.conf.all.route_localnet=1
net.ipv4.ip_forward=1
net.ipv4.conf.all.forwarding=1
net.ipv4.conf.default.forwarding=1

net.ipv6.conf.all.forwarding = 1
net.ipv6.conf.default.forwarding = 1
net.ipv6.conf.lo.forwarding = 1
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0

net.ipv4.tcp_syncookies=1
net.ipv4.tcp_retries1=3
net.ipv4.tcp_retries2=5
net.ipv4.tcp_orphan_retries=3
net.ipv4.tcp_syn_retries=3
net.ipv4.tcp_synack_retries=3
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_fin_timeout=15
net.ipv4.tcp_max_tw_buckets=32768
net.ipv4.tcp_max_syn_backlog=131072
net.core.netdev_max_backlog=131072
net.core.somaxconn=32768
net.ipv4.tcp_notsent_lowat=16384
net.ipv4.tcp_keepalive_time=300
net.ipv4.tcp_keepalive_probes=3
net.ipv4.tcp_keepalive_intvl=30
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_autocorking=0
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_ecn=0
net.ipv4.tcp_frto=0
net.ipv4.tcp_mtu_probing=0
net.ipv4.tcp_rfc1337=0
net.ipv4.tcp_sack=1
net.ipv4.tcp_fack=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_adv_win_scale=1
net.ipv4.tcp_moderate_rcvbuf=1
net.core.rmem_max=33554432
net.core.wmem_max=33554432
net.ipv4.tcp_rmem=4096 87380 33554432
net.ipv4.tcp_wmem=4096 16384 33554432
net.ipv4.udp_rmem_min=8192
net.ipv4.udp_wmem_min=8192
net.ipv4.tcp_mem=262144 1048576 4194304
net.ipv4.udp_mem=262144 1048576 4194304
net.ipv4.tcp_congestion_control=bbr
net.core.default_qdisc=fq
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.ping_group_range=0 2147483647
net.netfilter.nf_conntrack_max=4194304
EOF
sysctl -p /etc/sysctl.conf > /dev/null
sed -i "/sysctl -p/d" /etc/rc.local
echo "sysctl -p /etc/sysctl.conf" >> /etc/rc.local

echo bbr >/proc/sys/net/ipv4/tcp_congestion_control
cat /proc/sys/net/ipv4/tcp_congestion_control
echo fq >/proc/sys/net/core/default_qdisc
cat /proc/sys/net/core/default_qdisc

echo "内核参数已优化"

# rm -f /etc/localtime && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
# command -v rdate || { echo "正在安装rdate" && (apt install rdate -y || yum install rdate -y) && rdate -s -u time.nist.gov && echo "时间同步成功"; }
# echo "当前时间: " && date -R
# sed -i "/rdate/d" /etc/rc.local
# echo "rdate -s -u time.nist.gov" >> /etc/rc.local

sed -i '/#!\/bin/d' /etc/rc.local
sed -i '1i\#!/bin/sh' /etc/rc.local

sed -i '/exit 0/d' /etc/rc.local
echo "exit 0" >> /etc/rc.local
chmod +x /etc/rc.local

echo "正在安装常用命令 (iperf3 mtr traceroute nload curl lsof htop iftop  telnet nano)"

iperf3 -v >/dev/null || (yum install epel-release -y > /dev/null && yum install iperf3 mtr traceroute nload htop lsof net-tools ca-certificates wget nano telnet -y > /dev/null)
iperf3 -v >/dev/null || (apt install iperf3 mtr traceroute nload curl lsof htop iftop ca-certificates telnet -y > /dev/null)

echo "已安装常用命令"