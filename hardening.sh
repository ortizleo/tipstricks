echo "Hardening básico padrão"
#Referências
#https://highon.coffee/blog/security-harden-centos-7/
#https://wiki.centos.org/HowTos/OS_Protection

#Root não pode logar em nenhum local (obrigando su)
#Securança no dir root (so o root tem acesso)
echo > /etc/securetty
chmod 700 /root

#UMASK 077
#Cuidar com o server q for aplicar, entender bem o serviço
perl -npe 's/umask\s+0\d2/umask 077/g' -i /etc/bashrc
perl -npe 's/umask\s+0\d2/umask 077/g' -i /etc/csh.cshrc

#Remover idle users
echo "Idle users will be removed after 15 minutes"
echo "readonly TMOUT=900" >> /etc/profile.d/os-security.sh
echo "readonly HISTFILE" >> /etc/profile.d/os-security.sh
chmod +x /etc/profile.d/os-security.sh


MODULOS(){
echo "Desabilitando modulos de wireless, pendrive"
#desabilitar wireless
for i in $(find /lib/modules/`uname -r`/kernel/drivers/net/wireless -name "*.ko" -type f) ; do echo blacklist $i >> /etc/modprobe.d/blacklist-wireless ; done

#desabilitar usb-storage
echo "blacklist usb-storage" > /etc/modprobe.d/blacklist-usbstorage

}

SYSCTL(){
echo "Verificar e ADD no sysctl.config"
echo "
If you want to know more about any of these options, install the kernel-doc package, and look in Documentation/networking/ip-sysctl.txt

net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.tcp_max_syn_backlog = 1280
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_timestamps = 0
net.ipv4.conf.all.forwarding=0
net.ipv4.conf.all.mc_forwarding=0
"
}
SSH(){
#tcp wrappers com envio de e-mail
#necessario pacote mailx
echo "sshd : CONFIGURAR IP.*" >> /etc/hosts.allow
echo "sshd : ALL : spawn /bin/echo "$(hostname) - SSH - Acesso DENY - Client %h" |mailx -s "$(hostname) - SSH - Acesso DENY - Client %h" leonardo.ortiz@marisolsa.com" >> /etc/hosts.deny

}

#Desabilitar ctrl+alt+del
systemctl mask ctrl-alt-del.target

#desabilitar serviços
echo "
#######################################
#Verifique esses serviços carregados###
#######################################"
systemctl list-units -t service


echo 'HISTTIMEFORMAT="%d/%m/%y  %T  "' >> .bashrc'



#Desabilitar protocolos não usados
echo "install dccp /bin/false" > /etc/modprobe.d/dccp.conf
echo "install sctp /bin/false" > /etc/modprobe.d/sctp.conf
echo "install rds /bin/false" > /etc/modprobe.d/rds.conf
echo "install tipc /bin/false" > /etc/modprobe.d/tipc.conf

#Ativar audit
systemctl enable auditd.service
systemctl start auditd.service

#Desabilitar serviços
systemctl disable xinetd
systemctl disable rexec
systemctl disable rsh
systemctl disable rlogin
systemctl disable ypbind
systemctl disable tftp
systemctl disable certmonger
systemctl disable cgconfig
systemctl disable cgred
systemctl disable cpuspeed
systemctl enable irqbalance
systemctl disable kdump
systemctl disable mdmonitor
systemctl disable messagebus
systemctl disable netconsole
systemctl disable ntpdate
systemctl disable oddjobd
systemctl disable portreserve
systemctl enable psacct
systemctl disable qpidd
systemctl disable quota_nld
systemctl disable rdisc
systemctl disable rhnsd
systemctl disable rhsmcertd
systemctl disable saslauthd
systemctl disable smartd
systemctl disable sysstat
systemctl enable crond
systemctl disable atd
systemctl disable nfslock
systemctl disable named
systemctl disable httpd
systemctl disable dovecot
systemctl disable squid
systemctl disable snmpd
systemctl disable cups
systemctl disable avahi-daemon

yum erase dhcp


#

