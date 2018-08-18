#!/bin/bash

# ===================================
# 用法: ./um.sh [服务商]
# 如果没有附带参数，将会自动判断服务商
# 可用的服务商:
#   ai    阿里云 国际版
#   tx    腾讯云 通用
#   jd    京东云 (待完成)
# ===================================
# 卸载后台监视程序，并优化系统设置。
# 
# 仅支持系统选择里可选的最新版 CentOS 7，
# 并在已取消勾选所有可选后台监控的情况下。
# 
# 阿里云云盾扫描 ip :
# 140.205.201.0/28,140.205.201.16/29,140.205.201.32/28,140.205.225.192/29,140.205.225.200/30,140.205.225.184/29,140.205.225.183/32,140.205.225.206/32,140.205.225.205/32,140.205.225.195/32,140.205.225.204/32
# 请在防火墙中阻止其访问。
# 云盾参考:
# 国内版: https://help.aliyun.com/knowledge_detail/37436.html
# 国际版: https://www.alibabacloud.com/help/zh/faq-detail/37436.htm
# 
# 脚本参考: 
# 阿里云官方卸载文档: https://help.aliyun.com/document_detail/31777.html
# 阿里云官方卸载脚本: http://update.aegis.aliyun.com/download/uninstall.sh
# 腾讯云官方卸载文档: https://www.qcloud.com/document/product/248/2259
# ===================================
# um.sh
# by DuanLian & pbstu
# https://www.pbstu.com/
# 2018.01.07
# ===================================

# 重置 DNS
dns () {
    # 判断 GFW
    if [ -z "`timeout 1s ping -c 1 google.com`" ]; then
        # 国内
        # 使用 114 DNS
        cat > /etc/resolv.conf << "EOF"
nameserver 114.114.114.114
EOF
    else
        # 国外
        # 使用 Google DNS
        cat > /etc/resolv.conf << "EOF"
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
    fi
}

# 重置源
repo () {
    # 删除所有自带源及自带公钥
    rpm -e --allmatches gpg-pubkey
    rm -rf /etc/yum.repos.d/*
    rm -rf /etc/pki/rpm-gpg/*
# 导入 CentOS 源公钥, 为防止在传输中被篡改所以写死在脚本中, 原址为: https://www.centos.org/keys/RPM-GPG-KEY-CentOS-7
cat > /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 << "EOF"
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.5 (GNU/Linux)

mQINBFOn/0sBEADLDyZ+DQHkcTHDQSE0a0B2iYAEXwpPvs67cJ4tmhe/iMOyVMh9
Yw/vBIF8scm6T/vPN5fopsKiW9UsAhGKg0epC6y5ed+NAUHTEa6pSOdo7CyFDwtn
4HF61Esyb4gzPT6QiSr0zvdTtgYBRZjAEPFVu3Dio0oZ5UQZ7fzdZfeixMQ8VMTQ
4y4x5vik9B+cqmGiq9AW71ixlDYVWasgR093fXiD9NLT4DTtK+KLGYNjJ8eMRqfZ
Ws7g7C+9aEGHfsGZ/SxLOumx/GfiTloal0dnq8TC7XQ/JuNdB9qjoXzRF+faDUsj
WuvNSQEqUXW1dzJjBvroEvgTdfCJfRpIgOrc256qvDMp1SxchMFltPlo5mbSMKu1
x1p4UkAzx543meMlRXOgx2/hnBm6H6L0FsSyDS6P224yF+30eeODD4Ju4BCyQ0jO
IpUxmUnApo/m0eRelI6TRl7jK6aGqSYUNhFBuFxSPKgKYBpFhVzRM63Jsvib82rY
438q3sIOUdxZY6pvMOWRkdUVoz7WBExTdx5NtGX4kdW5QtcQHM+2kht6sBnJsvcB
JYcYIwAUeA5vdRfwLKuZn6SgAUKdgeOtuf+cPR3/E68LZr784SlokiHLtQkfk98j
NXm6fJjXwJvwiM2IiFyg8aUwEEDX5U+QOCA0wYrgUQ/h8iathvBJKSc9jQARAQAB
tEJDZW50T1MtNyBLZXkgKENlbnRPUyA3IE9mZmljaWFsIFNpZ25pbmcgS2V5KSA8
c2VjdXJpdHlAY2VudG9zLm9yZz6JAjUEEwECAB8FAlOn/0sCGwMGCwkIBwMCBBUC
CAMDFgIBAh4BAheAAAoJECTGqKf0qA61TN0P/2730Th8cM+d1pEON7n0F1YiyxqG
QzwpC2Fhr2UIsXpi/lWTXIG6AlRvrajjFhw9HktYjlF4oMG032SnI0XPdmrN29lL
F+ee1ANdyvtkw4mMu2yQweVxU7Ku4oATPBvWRv+6pCQPTOMe5xPG0ZPjPGNiJ0xw
4Ns+f5Q6Gqm927oHXpylUQEmuHKsCp3dK/kZaxJOXsmq6syY1gbrLj2Anq0iWWP4
Tq8WMktUrTcc+zQ2pFR7ovEihK0Rvhmk6/N4+4JwAGijfhejxwNX8T6PCuYs5Jiv
hQvsI9FdIIlTP4XhFZ4N9ndnEwA4AH7tNBsmB3HEbLqUSmu2Rr8hGiT2Plc4Y9AO
aliW1kOMsZFYrX39krfRk2n2NXvieQJ/lw318gSGR67uckkz2ZekbCEpj/0mnHWD
3R6V7m95R6UYqjcw++Q5CtZ2tzmxomZTf42IGIKBbSVmIS75WY+cBULUx3PcZYHD
ZqAbB0Dl4MbdEH61kOI8EbN/TLl1i077r+9LXR1mOnlC3GLD03+XfY8eEBQf7137
YSMiW5r/5xwQk7xEcKlbZdmUJp3ZDTQBXT06vavvp3jlkqqH9QOE8ViZZ6aKQLqv
pL+4bs52jzuGwTMT7gOR5MzD+vT0fVS7Xm8MjOxvZgbHsAgzyFGlI1ggUQmU7lu3
uPNL0eRx4S1G4Jn5
=OGYX
-----END PGP PUBLIC KEY BLOCK-----
EOF
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
# 导入 CentOS 源
cat > /etc/yum.repos.d/CentOS-Base.repo << "EOF"
# CentOS-Base.repo
#
# The mirror system uses the connecting IP address of the client and the
# update status of each mirror to pick mirrors that are updated to and
# geographically close to the client.  You should use this for CentOS updates
# unless you are manually picking other mirrors.
#
# If the mirrorlist= does not work for you, as a fall back you can try the 
# remarked out baseurl= line instead.
#
#

[base]
name=CentOS-$releasever - Base
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os&infra=$infra
#baseurl=http://mirror.centos.org/centos/$releasever/os/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#released updates 
[updates]
name=CentOS-$releasever - Updates
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates&infra=$infra
#baseurl=http://mirror.centos.org/centos/$releasever/updates/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras&infra=$infra
#baseurl=http://mirror.centos.org/centos/$releasever/extras/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus&infra=$infra
#baseurl=http://mirror.centos.org/centos/$releasever/centosplus/$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF
    # 清理缓存
    yum clean all
    rm -rf /var/cache/yum

    # 安装 epel 源
    yum -y install epel-release
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
}

# 重置 ntpd
ntpd () {
    systemctl stop ntpd
    yum -y remove ntp
    rm -f /etc/ntp.conf*
    rm -rf /etc/ntp
    yum -y install ntp
    systemctl start ntpd
}

# 阿里云国际版
ai () {
    # 卸载后台监视程序
    killall -9 AliYunDunUpdate
    killall -9 AliYunDun
    killall -9 AliHids

    systemctl stop aliyun
    systemctl stop agentwatch
    systemctl stop aegis
    systemctl disable aliyun
    systemctl disable agentwatch
    systemctl disable aegis
    chkconfig --del agentwatch
    chkconfig --del aegis

    for i in {0..6}; do
        rm -rf /etc/rc.d/rc${i}.d/*aegis
        rm -rf /etc/rc.d/rc${i}.d/*agentwatch
    done

    rm -rf /etc/systemd/system/aliyun.service
    rm -rf /etc/rc.d/init.d/aegis
    rm -rf /etc/rc.d/init.d/agentwatch
    rm -rf /usr/local/aegis
    rm -rf /usr/sbin/aliyun-service
    rm -rf /usr/sbin/gshelld
    rm -rf /usr/sbin/virt-what-cpuid-helper

    systemctl daemon-reload

    dns
    repo
    ntpd

    # 还原 Python 设置
    rm -f /root/.pydistutils.cfg
    rm -rf /root/.pip
    rm -rf /root/.cache

    # 清空 motd 消息
    > /etc/motd

    exit
}

# 腾讯云通用
tx () {
    # 清理后台监视程序
    rm -rf /usr/local/qcloud

    # 清空定时任务
    > /var/spool/cron/root
    sed -i 20,22d /etc/rc.local

    # 关闭 postfix 服务
    systemctl stop postfix
    systemctl disable postfix

    dns
    repo
    ntpd

    exit
}

# 判断服务商
if [ -z $1 ]; then
    if   [ -f /etc/systemd/system/aliyun.service ]; then ai
    elif [ -f /usr/local/qcloud ];                  then tx
    else echo "No IDC match. 没有服务商匹配。"; exit
    fi
else
    case $1 in
        ai) ai ;;
        tx) tx ;;
         *) echo "No IDC match. 没有服务商匹配。" ; exit ;;
    esac
fi
