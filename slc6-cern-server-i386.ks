install

# installation path, additional repositories
url --url http://linuxsoft.cern.ch/cern/slc63/i386/

repo --name="EPEL"             --baseurl http://linuxsoft.cern.ch/epel/6/i386
repo --name="SLC6 - updates"   --baseurl http://linuxsoft.cern.ch/cern/slc6X/i386/yum/updates/
repo --name="SLC6 - extras"    --baseurl http://linuxsoft.cern.ch/cern/slc6X/i386/yum/extras/
repo --name="SLC6 - cernonly"  --baseurl http://linuxsoft.cern.ch/onlycern/slc6X/i386/yum/cernonly/

text
key --skip
keyboard us
lang en_US.UTF-8
skipx
network --bootproto dhcp
rootpw --iscrypted NOT-A-ROOT-PASSWORD

# Firewall rules
# 7001 AFS
# 4241 ARC
firewall --enabled --ssh --port=7001:udp --port=4241:tcp

# authconfig
authconfig --useshadow --enablemd5 --enablekrb5 --disablenis

selinux --enforcing
timezone --utc Europe/Zurich

# logging
logging --level=debug

bootloader --location=mbr --append="console=ttyS0,115200 console=tty0"
zerombr yes
clearpart --all --initlabel

part /boot --size=200
part pv.1  --size=1   --grow

volgroup VolGroup00 --pesize=32768 pv.1

logvol swap --fstype swap --name=LogVol01 --vgname=VolGroup00 --size=768  --grow --maxsize=1536
logvol /                  --name=LogVol00 --vgname=VolGroup00 --size=1024 --grow

reboot

##############################################################################
#
# Packages
#
##############################################################################
%packages
@ Server Platform
pam_krb5
yum-plugin-priorities
-fprintd
%end

##############################################################################
#
# post installation part of the KickStart configuration file
#
##############################################################################
%post --log=/root/anaconda-post.log

/usr/bin/logger "Starting anaconda postinstall"

## redirect the output to the log file
#exec >/root/anaconda-post.log 2>&1
#
## show the output on the seventh console
#tail -f /root/anaconda-post.log >/dev/tty7 &
#
## changing to VT 7 that we can see what's going on....
#/usr/bin/chvt 7

set -x 

#
# Update the machine
#
/usr/bin/yum update -y --skip-broken || :

#
# Misc fixes
#

# The net.bridge.* entries in /etc/sysctl.conf make "sysctl -p" fail if "bridge" module is not loaded...
/usr/bin/perl -ni -e '$_ = "### Commented out by CERN... $_" if /^net\.bridge/;print' /etc/sysctl.conf || :

# create ec2-user
#/usr/sbin/useradd ec2-user
#/bin/echo -e 'ec2-user\tALL=(ALL)\tNOPASSWD: ALL' >> /etc/sudoers

%end
