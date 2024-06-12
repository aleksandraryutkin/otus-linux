#!/bin/bash

apt install -y nfs-common

echo "192.168.11.150:/srv/share/ /mnt nfs vers=3,noauto,x-systemd.automount 0 0" >> /etc/fstab

systemctl daemon-reload 
systemctl restart remote-fs.target
