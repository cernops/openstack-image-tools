install

# installation path, additional repositories
url --url http://linuxsoft.cern.ch/cern/slc511/i386/

repo --name="EPEL"             --baseurl http://linuxsoft.cern.ch/epel/5/i386
repo --name="SLC5 - updates"   --baseurl http://linuxsoft.cern.ch/cern/slc5X/i386/yum/updates/
repo --name="SLC5 - extras"    --baseurl http://linuxsoft.cern.ch/cern/slc5X/i386/yum/extras/

text

key --skip
keyboard us
lang en_US.UTF-8
langsupport --default en_US.UTF-8 en_US.UTF-8
mouse generic3ps/2 --device psaux
skipx
network --bootproto dhcp
rootpw --iscrypted NOT-A-ROOT-PASSWORD

# Firewall rules
# 7001 AFS
# 4241 ARC
firewall --enabled --ssh --port=7001:udp --port=4241:tcp

# authconfig
authconfig --enableshadow --enablemd5

selinux --enforcing
timezone --utc Europe/Zurich

bootloader --location=mbr --append="console=ttyS0,115200 console=tty0"
zerombr
clearpart --all

part /boot --size=400
part pv.1  --size=1   --grow

volgroup VolGroup00 --pesize=32768 pv.1

logvol swap --fstype swap --name=LogVol01 --vgname=VolGroup00 --size=768  --grow --maxsize=1536
logvol /                  --name=LogVol00 --vgname=VolGroup00 --size=1024 --grow

reboot

%packages
@core
@base
-yum-autoupdate
yum-protectbase
yum-priorities
yum-kernel-module
ntp
zsh

##############################################################################
#
# post installation part of the KickStart configuration file
#
##############################################################################
%post

/usr/bin/logger "Starting anaconda postinstall"

# redirect the output to the log file
exec >/root/anaconda-post.log 2>&1

# show the output on the seventh console
tail -f /root/anaconda-post.log >/dev/tty7 &

# changing to VT 7 that we can see what's going on....
/usr/bin/chvt 7

set -x 

#
# Update the machine
#
/usr/bin/yum update -y --skip-broken || :

#
# Misc fixes
#

exit 0
