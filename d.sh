#!/bin/bash

set -ex

sudo id

sudo apt-get remove -y --purge java* libreof* mysql* parole *falso* atril modemmanager* sane xsaned* avahi* bluez lm-sensors rsyslog xfce4-screen* xfce4-notes* hv3 firefox* system-config-print* vim* virtualbox-guest* chromium* network-manager*
sudo apt -y autoremove

sudo apt -y update
sudo apt -y full-upgrade
sudo apt -y autoremove

echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf
echo 'net.ipv6.conf.enp0s3.disable_ipv6 = 1' >> /etc/sysctl.conf
sysctl -p

systemctl disable networking.service || true

cat > /etc/network/interfaces <<-END
auto lo
iface lo inet loopback

allow-hotplug enp0s3
auto enp0s3
iface enp0s3 inet static
address 10.152.152.12
netmask 255.255.192.0
network 192.168.0.0
broadcast 192.168.0.255
gateway 10.152.152.10
END

ifdown enp0s3 || true
sleep 1
ifup enp0s3 || true

sudo apt -y install wget curl lsb-release apt-transport-https htop net-tools git wget unzip ca-certificates build-essential tcl gcc make perl

echo "deb https://packages.sury.org/php/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/php.list
echo "deb https://deb.torproject.org/torproject.org $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/tor.list
echo "deb-src https://deb.torproject.org/torproject.org $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list.d/tor.list
curl https://packages.sury.org/php/apt.gpg | sudo apt-key add -
curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | sudo gpg --import
sudo gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
wget https://repo.mysql.com//mysql-apt-config_0.8.22-1_all.deb -O /tmp/mysinstal.deb
sudo dpkg -i /tmp/mysinstal.deb

sudo apt -y update
sudo apt -y full-upgrade
sudo apt -y autoremove

sudo apt -y install tor curl jq git sshpass deb.torproject.org-keyring xfce4-xkb-plugin openjdk-17-source keepassx htop gobuster python3-pip mysql-community-server filezilla libzen-dev libmediainfo-dev debhelper qtbase5-dev qt5-qmake libqt5x11extras5-dev libqt5dbus5 libqt5svg5-dev libcrypto++-dev libraw-dev libc-ares-dev libssl-dev libsqlite3-dev zlib1g-dev  dh-autoreconf cdbs libtool-bin pkg-config qttools5-dev-tools libavcodec-dev libavutil-dev libavformat-dev libswscale-dev libmediainfo-dev  python3-pip firefox-esr php8.1 php8.1-{bcmath,cli,common,curl,fpm,gd,mbstring,mysql,opcache,zip,ssh2,xml,sqlite3} dnsutils rsync nginx john hashid hashcat psi-plus sqlitebrowser whois proxychains-ng iptables alsa-utils chromium

sudo systemctl enable mysql
sudo systemctl enable tor
sudo systemctl enable php8.1-fpm
sudo systemctl enable nginx

#sudo pip install mysql-to-sqlite3
#sudo pip install wfuzz

sudo rm -rf /home/x/*
mkdir /home/x/down
mkdir /home/x/apps

sudo iptables -F
sudo iptables -X

sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT

sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

sudo iptables -A OUTPUT -m owner --uid-owner www-data -j DROP
sudo iptables -A OUTPUT -m owner --uid-owner mysql -j DROP

sudo ip6tables -F
sudo ip6tables -X

sudo ip6tables -P INPUT DROP
sudo ip6tables -P FORWARD DROP
sudo ip6tables -P OUTPUT ACCEPT

sudo ip6tables -A INPUT -i lo -j ACCEPT
sudo ip6tables -A OUTPUT -o lo -j ACCEPT

sudo ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

sudo ip6tables -A OUTPUT -m owner --uid-owner www-data -j DROP
sudo ip6tables -A OUTPUT -m owner --uid-owner mysql -j DROP

sudo apt install iptables-persistent -y

sudo apt remove --purge avahi* -y
sudo apt autoremove -y

echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet ipv6.disable=1"' >> /etc/default/grub
echo 'GRUB_CMDLINE_LINUX="ipv6.disable=1"' >> /etc/default/grub
sudo update-grub

echo 'Section "Monitor"' > /etc/X11/xorg.conf.d/10-monitor.conf
echo '    Identifier "Virtual1"' >> /etc/X11/xorg.conf.d/10-monitor.conf
echo '    Modeline "p1920x1080"  173.00  1920 2048 2248 2576  1080 1083 1088 1120 +hsync +vsync' >> /etc/X11/xorg.conf.d/10-monitor.conf
echo '    Option "PreferredMode" "p1920x1080"' >> /etc/X11/xorg.conf.d/10-monitor.conf
echo 'EndSection' >> /etc/X11/xorg.conf.d/10-monitor.conf

sudo chmod -R og-rwx /home/x/
sudo chown x:www-data -R /var/www
sudo chmod +s /var/www
sudo chown x:x -R /etc/mysql
sudo chown x:x -R /etc/nginx
sudo chown x:x -R /etc/php
sudo chown x:x -R /home/x/

sudo apt-get remove -y --purge modemmanager* sane xsaned* avahi* lm-sensors rsyslog virtualbox-guest* network-manager* geoclue* xfce4-terminal hv3 vim* bluez libreof*

sudo apt -y autoremove

sudo userdel -fr geoclue || true
sudo userdel -fr saned || true
sudo userdel -fr avahi-autoipd || true
sudo userdel -fr avahi || true
sudo userdel -fr games || true
sudo userdel -fr news || true

sudo apt -y install qterminal

mysqladmin -uroot -proot password ''

cd /tmp

#psi icons
wget https://codeload.github.com/psi-im/resources/zip/refs/heads/master -O psi-icon.zip
unzip -o psi-icon.zip
sudo cp -a resources-master/iconsets/* /usr/share/psi-plus/iconsets/.
sudo chown -R root:root /usr/share/psi-plus/iconsets/
sudo find /usr/share/psi-plus/iconsets/ -type f -exec chmod go+r {} \;
sudo find /usr/share/psi-plus/iconsets/ -type d -exec chmod go+rx {} \;

echo "OK"

