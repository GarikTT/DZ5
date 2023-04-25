#!/bin/bash

sudo -i

yum install -y nfs-utils // Устанавливаем пакеты для организации NFS-сервера
systemctl enable firewalld --now
firewall-cmd --add-service="nfs3" --add-service="rpc-bind" --add-service="mountd" --permanent
firewall-cmd --reload
systemctl enable nfs --now
ss -tnplu
mkdir -p /srv/share/upload
chown -R nfsnobody:nfsnobody /srv/share
chmod 0777 /srv/share/upload
cat << EOF > /etc/exports 
/srv/share 192.168.56.11/24(rw,sync,no_root_squash,no_all_squash)
EOF
exportfs -r
exportfs -s

exit 0