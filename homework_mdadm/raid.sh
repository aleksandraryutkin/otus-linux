#!/bin/bash

# Зануляем блоки
mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}

# Создаем RAID 6
yes | mdadm --create --verbose /dev/md0 -l 6 -n 5 /dev/sd{b,c,d,e,f}

# Создаем папку для конфига mdadm.conf
mkdir /etc/mdadm/

# Создаем конфигурацию RAID массива
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
