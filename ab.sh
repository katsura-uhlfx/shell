#################################################
# AfterBoot.sh > ab.sh
# maintainer yamanouchi katsura <katsura@uhl.jp>
# 2020/05/19(Sun) 23:39:58 JST
# all right reserved 2020 (c) uhlfx.trade
#################################################

### update system ###
### variables change to your data...
username="hoge"
hostname="hage"
homeip="foo"
officeip="bar"
#####################################

dnf -y update && dnf clean all

### Note Result ###
cd /home/$username
mkdir .doc
cd .doc
cat /etc/passwd > .p.txt
dnf list installed > .y.txt
journalctl > .f.txt
chmod 100 *.txt

### Basic security ###
# set hostname
nmcli g h $hostname	#cat /etc/hostname

#add new a network, and delete permission to ssh from public
#uhl_net enabling
firewall-cmd --new-zone=$hostname_net --permanent
firewall-cmd --zone=$hostname_net --set-target=ACCEPT --permanent
firewall-cmd --zone=$hostname_net --add-service=ssh --permanent
firewall-cmd --zone=$hostname_net --add-source=$homeip --permanent
firewall-cmd --zone=$hostname_net --add-source=$officeip --permanent
firewall-cmd  --zone=public --remove-service=ssh --permanent
firewall-cmd --reload

#Other processes
systemctl disable smartd mdmonitor

#umask change
sed -i -e 's/umask[\s\d]+$/umask 022/g' -e 's/umask[\s\d]+$/umask 027/g' /etc/profile

#db renew for 'locate' files
updatedb -e /tmp

#Some another fixation
#blacklisted unuse modules
echo -e "blacklist firewire-core
blacklist soundcore
blacklist dvb_usb
blacklist dvb_usb_v2
blacklist usb-storage
" > /etc/modprobe.d/blacklist-devices.conf

#EOF-----------------------------------------------
