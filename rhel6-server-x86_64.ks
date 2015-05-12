install

# installation path, additional repositories
url --url http://linuxsoft.cern.ch/enterprise/rhel/server/6/6.6/x86_64/

repo --name="EPEL"             --baseurl http://linuxsoft.cern.ch/epel/6/x86_64
repo --name="RHEL - optional"  --baseurl http://linuxsoft.cern.ch/cdn.redhat.com/content/dist/rhel/server/6/6Server/x86_64/optional/os
#repo --name="RHEL - updates"   --baseurl http://linuxsoft.cern.ch/rhel/rhel6server-x86_64/RPMS.updates/
repo --name="RHEL - fastrack"  --baseurl http://linuxsoft.cern.ch/cdn.redhat.com/content/fastrack/rhel/server/6/x86_64/os

text
key --skip
keyboard us
lang en_US.UTF-8
skipx
network --bootproto dhcp
rootpw --iscrypted NOT-A-ROOT-PASSWORD

# Firewall rules
firewall --enabled --ssh

# authconfig
authconfig --useshadow --enablemd5 --enablekrb5 --disablenis

selinux --enforcing
timezone --utc Europe/Zurich

# logging
logging --level=debug

bootloader --location=mbr --append="console=ttyS0,115200 console=tty0"
zerombr
clearpart --all --initlabel

part /boot --size=400
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
-yum-autoupdate
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

%end
