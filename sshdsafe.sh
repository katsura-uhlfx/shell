#################################################
# sshdsafe.sh
# maintainer yamanouchi katsura <katsura@uhl.jp>
# 2020/05/20(Wed) 18:05:32
# all right reserved 2020 (c) uhlfx.trade
#################################################
#!/bin/bash
#variables--------------------------
USER="hoge"
PASSKEY="hage"
NEWPORT="foo"
#----------------------------------

#code------------------------------
dnf -y install expect

#step2------------------------------
mkdir /root/.ssh
chmod 600 /root/.ssh

cd /root/.ssh
expect -c "
set timeout 50
spawn ssh-keygen
expect \"Enter file in which to save the key (/root/.ssh/id_rsa):\"
send \"\n\"
expect \"Enter passphrase (empty for no passphrase):\"
send \"$PASSKEY\n\"
expect \"Enter same passphrase again:\"
send \"$PASSKEY\n\"
interact "

#Step3------------------------------
mkdir /home/$USER/.ssh
cp id_rsa.pub /home/$USER/.ssh/authorized_keys
cp id_rsa /home/$USER/.ssh/id_rsa
chown -R $USER:$USER /home/$USER/.ssh
chmod 660 /home/$USER/.ssh/id_rsa

echo -e "
#By SSHSCR Receive procedure
# Point:  File > SSH SCR
# [/home/<username>/.ssh/id_rsa]  to [proper directory local PC] e.g 'C:\Users\<username>\Documents'
# or, open another new connection with .ttl auto login method for TeraTerm
# If done above, hit any key and [return] "

read INPUT
echo "$INPUT huumm... by the way. we will go to step 4."

echo "Do you want to erase the private key from this server? [y | n]:"
read INPUT

if [$INPUT -eq "y"]
then
	rm -f /home/$USER/.ssh/id_rsa
	echo "erase the private key."
else
	chmod 100 /home/$USER/.ssh/id_rsa
	echo "change property. caution remaining the key."
fi
chmod 655 /home/$USER/.ssh/authorized_keys
chmod -R 600 /root/.ssh
chmod 100 /root/.ssh/id_rsa
chmod 660 /root/.ssh/id_rsa.pub

echo -e "
## REMAIN KEEPING THE CONNECTION ABOVE and proceed next ...
On Client>
TeraTermPro: login:<user>+id_rsa(key)
If you successfully made a connection with this key, you can safely close this session/window.
#If you failed something, erase directory and turn to Step 1."

#security tightening
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sed -i \
-e 's/^#Port 22$/Port $NEWPORT/g' \
-e 's/^.*LogLevel\(.*\)$/LogLevel  verbose/g' \
-e 's/^.*PermitRootLogin\(.*\)$/PermitRootLogin no/g' \
-e 's/^.*MaxAuthTries \(.*\)$/MaxAuthTries 2/g' \
-e 's/^.*\MaxSessions\(.*\)$/MaxSessions 5/g' \
-e 's/^.*PasswordAuthentification\(.*\)$/PasswordAuthentification no/g' \
-e 's/^.*AllowAgentForwarding\(.*\)$/AllowAgentForwarding no/g' \
-e 's/^.*AllowTcpForwarding\(.*\)$/AllowTcpForwarding no/g' \
-e 's/^.*TCPKeepAlive\(.*\)$/TCPKeepAlive no/g' \
-e 's/^.*Compression\(.*\)$/Compression no/g' \
-e 's/^.*ClientAliveCountMax\(.*\)$/ClientAliveCountMax 2/g' \
/etc/ssh/sshd_config

chmod -R 600 /etc/ssh
semanage port -a -t ssh_port_t -p tcp $NEWPORT
cp /usr/lib/firewalld/services/ssh.xml /etc/firewalld/services/ssh.xml
sed -i -e 's/port protocol="tcp" port="22"$/port protocol="tcp" port=$NEWPORT/g' /etc/firewalld/services/ssh.xml
firewall-cmd --reload
systemctl restart sshd
#EOF

