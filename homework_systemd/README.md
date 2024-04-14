# Домашнее задание - работа с systemd

## Подготовительные действия
Использовал настроенную конфигурацию Centos 8 через Vagrant из [homework_rpm](https://github.com/aleksandraryutkin/otus-linux/blob/main/homework_rpm/)

## Написать сервис, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова. Файл и слово должны задаваться в /etc/sysconfig
* Для начала создаём файл с конфигурацией для сервиса в директории /etc/sysconfig - из неё сервис будет брать необходимые переменные:
``` bash
[root@localhost ~]# echo '# Configuration file for my watchlog service
# Place it to /etc/sysconfig

# File and word in that file that we will be monit
WORD="ALERT"
LOG=/var/log/watchlog.log' > /etc/sysconfig/watchlogd
```

* Затем создаем /var/log/watchlog.log и пишем туда рандомные строки и ключевое слово ‘ALERT’
``` bash
[root@localhost ~]# echo 'Some string ALERT' > /var/log/watchlog.log
```

* Создадим скрипт:
``` bash
[root@localhost ~]# echo '#!/bin/bash

WORD=$1
LOG=$2
DATE=`date`

if grep $WORD $LOG &> /dev/null
then
logger "$DATE: I found word, Master!"
else
exit 0
fi' > /opt/watchlog.sh
```

* Добавим права на запуск файла:
``` bash
[root@localhost ~]# chmod +x /opt/watchlog.sh
```

* Создадим юнит для сервиса:
``` bash
[root@localhost ~]# echo '[Unit]
Description=My watchlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh $WORD $LOG' > /etc/systemd/system/watchlog.service
```

* Создадим юнит для таймера:
``` bash
[root@localhost ~]# echo '[Unit]
Description=Run watchlog script every 30 second

[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/watchlog.timer
```

* Затем достаточно только стартануть timer:
``` bash
[root@localhost ~]# systemctl start watchlog.timer
```

* Однако в моем случае этого оказалось недостаточно. После старта timer не запускал сервис. 
``` bash
[root@localhost ~]# systemctl start watchlog.timer
[root@localhost ~]# tail -f /var/log/messages
Apr 14 04:57:33 localhost NetworkManager[703]: <info>  [1713070653.2629] dhcp4 (eth1): option requested_time_offset => '1'
Apr 14 04:57:33 localhost NetworkManager[703]: <info>  [1713070653.2629] dhcp4 (eth1): option requested_wpad       => '1'
Apr 14 04:57:33 localhost NetworkManager[703]: <info>  [1713070653.2629] dhcp4 (eth1): option subnet_mask          => '255.255.255.0'
Apr 14 04:57:33 localhost NetworkManager[703]: <info>  [1713070653.2629] dhcp4 (eth1): state changed extended -> extended
Apr 14 04:57:33 localhost dbus-daemon[701]: [system] Activating via systemd: service name='org.freedesktop.nm_dispatcher' unit='dbus-org.freedesktop.nm-dispatcher.service' requested by ':1.5' (uid=0 pid=703 comm="/usr/sbin/NetworkManager --no-daemon " label="system_u:system_r:NetworkManager_t:s0")
Apr 14 04:57:33 localhost systemd[1]: Starting Network Manager Script Dispatcher Service...
Apr 14 04:57:33 localhost dbus-daemon[701]: [system] Successfully activated service 'org.freedesktop.nm_dispatcher'

Apr 14 04:57:33 localhost systemd[1]: Started Network Manager Script Dispatcher Service.
Apr 14 04:57:43 localhost systemd[1]: NetworkManager-dispatcher.service: Succeeded.
Apr 14 04:58:39 localhost systemd[1]: Started Run watchlog script every 30 second.
^C
```

* После запуска сервиса вручную timer заработал, однако не совсем, как ожидалось. Интервал запуска колебался от 50 до 90 секунд:
``` bash
[root@localhost ~]# systemctl start watchlog.service
[root@localhost ~]#  tail -f /var/log/messages
Apr 14 05:32:33 localhost NetworkManager[703]: <info>  [1713072753.2746] dhcp4 (eth1): state changed extended -> extended
Apr 14 05:32:33 localhost dbus-daemon[701]: [system] Activating via systemd: service name='org.freedesktop.nm_dispatcher' unit='dbus-org.freedesktop.nm-dispatcher.service' requested by ':1.5' (uid=0 pid=703 comm="/usr/sbin/NetworkManager --no-daemon " label="system_u:system_r:NetworkManager_t:s0")
Apr 14 05:32:33 localhost systemd[1]: Starting Network Manager Script Dispatcher Service...
Apr 14 05:32:33 localhost dbus-daemon[701]: [system] Successfully activated service 'org.freedesktop.nm_dispatcher'

Apr 14 05:32:33 localhost systemd[1]: Started Network Manager Script Dispatcher Service.
Apr 14 05:32:43 localhost systemd[1]: Starting My watchlog service...
Apr 14 05:32:43 localhost systemd[1]: NetworkManager-dispatcher.service: Succeeded.
Apr 14 05:32:43 localhost root[21328]: Sun Apr 14 05:32:43 UTC 2024: I found word, Master!
Apr 14 05:32:43 localhost systemd[1]: watchlog.service: Succeeded.
Apr 14 05:32:43 localhost systemd[1]: Started My watchlog service.
Apr 14 05:33:59 localhost systemd[1]: Starting My watchlog service...
Apr 14 05:33:59 localhost root[21335]: Sun Apr 14 05:33:59 UTC 2024: I found word, Master!
Apr 14 05:33:59 localhost systemd[1]: watchlog.service: Succeeded.
Apr 14 05:33:59 localhost systemd[1]: Started My watchlog service.
```

* Поставил явное указание подсчета в секундах в конифгурацию timer (настройка `AccuracySec=1s`):
``` bash
[root@localhost ~]# cat /etc/systemd/system/watchlog.timer
[Unit]
Description=Run watchlog script every 30 second

[Timer]
# Run every 30 second
OnUnitActiveSec=30
AccuracySec=1s
Unit=watchlog.service

[Install]
WantedBy=multi-user.target
```

* После перечитывания конфигурации и рестарта сервиса timer получилось получить нужный результат:
``` bash
[root@localhost ~]# systemctl daemon-reload
[root@localhost ~]# systemctl restart watchlog.timer
[root@localhost ~]#  tail -f /var/log/messages
Apr 14 05:33:59 localhost systemd[1]: Started My watchlog service.
Apr 14 05:35:01 localhost systemd[1]: Starting My watchlog service...
Apr 14 05:35:01 localhost systemd[1]: Reloading.
Apr 14 05:35:01 localhost root[21360]: Sun Apr 14 05:35:01 UTC 2024: I found word, Master!
Apr 14 05:35:01 localhost systemd[1]: watchlog.service: Succeeded.
Apr 14 05:35:01 localhost systemd[1]: Started My watchlog service.
Apr 14 05:35:07 localhost systemd[1]: watchlog.timer: Succeeded.
Apr 14 05:35:07 localhost systemd[1]: Stopped Run watchlog script every 30 second.
Apr 14 05:35:07 localhost systemd[1]: Stopping Run watchlog script every 30 second.
Apr 14 05:35:07 localhost systemd[1]: Started Run watchlog script every 30 second.
Apr 14 05:35:32 localhost systemd[1]: Starting My watchlog service...
Apr 14 05:35:32 localhost root[21369]: Sun Apr 14 05:35:32 UTC 2024: I found word, Master!
Apr 14 05:35:32 localhost systemd[1]: watchlog.service: Succeeded.
Apr 14 05:35:32 localhost systemd[1]: Started My watchlog service.
Apr 14 05:36:03 localhost systemd[1]: Starting My watchlog service...
Apr 14 05:36:03 localhost root[21374]: Sun Apr 14 05:36:03 UTC 2024: I found word, Master!
Apr 14 05:36:03 localhost systemd[1]: watchlog.service: Succeeded.
Apr 14 05:36:03 localhost systemd[1]: Started My watchlog service.
Apr 14 05:36:34 localhost systemd[1]: Starting My watchlog service...
Apr 14 05:36:34 localhost root[21379]: Sun Apr 14 05:36:34 UTC 2024: I found word, Master!
Apr 14 05:36:34 localhost systemd[1]: watchlog.service: Succeeded.
Apr 14 05:36:34 localhost systemd[1]: Started My watchlog service.
Apr 14 05:37:05 localhost systemd[1]: Starting My watchlog service...
Apr 14 05:37:05 localhost root[21384]: Sun Apr 14 05:37:05 UTC 2024: I found word, Master!
Apr 14 05:37:05 localhost systemd[1]: watchlog.service: Succeeded.
Apr 14 05:37:05 localhost systemd[1]: Started My watchlog service.
Apr 14 05:37:29 localhost systemd[1]: Starting dnf makecache...
Apr 14 05:37:30 localhost dnf[21386]: Metadata cache refreshed recently.
Apr 14 05:37:30 localhost systemd[1]: dnf-makecache.service: Succeeded.
Apr 14 05:37:30 localhost systemd[1]: Started dnf makecache.
```

## Из epel установить spawn-fcgi и переписать init-скрипт на unit-файл. Имя сервиса должно также называться
* Устанавливаем spawn-fcgi и необходимые для него пакеты:
``` bash
[root@localhost ~]# yum install epel-release -y && yum install spawn-fcgi php php-cli
...
Installed:
  epel-release-8-11.el8.noarch

Complete!
...
Installed:
  apr-1.6.3-12.el8.x86_64                                 apr-util-1.6.1-6.el8.x86_64                                apr-util-bdb-1.6.1-6.el8.x86_64                                    apr-util-openssl-1.6.1-6.el8.x86_64
  centos-logos-httpd-85.8-2.el8.noarch                    httpd-2.4.37-43.module_el8.5.0+1022+b541f3b1.x86_64        httpd-filesystem-2.4.37-43.module_el8.5.0+1022+b541f3b1.noarch     httpd-tools-2.4.37-43.module_el8.5.0+1022+b541f3b1.x86_64
  mailcap-2.1.48-3.el8.noarch                             mod_http2-1.15.7-3.module_el8.4.0+778+c970deab.x86_64      nginx-filesystem-1:1.14.1-9.module_el8.0.0+184+e34fea82.noarch     php-7.2.24-1.module_el8.2.0+313+b04d0a66.x86_64
  php-cli-7.2.24-1.module_el8.2.0+313+b04d0a66.x86_64     php-common-7.2.24-1.module_el8.2.0+313+b04d0a66.x86_64     php-fpm-7.2.24-1.module_el8.2.0+313+b04d0a66.x86_64                spawn-fcgi-1.6.3-17.el8.x86_64

Complete!
```
/etc/rc.d/init.d/spawn-fcgi - cам Init скрипт, который будем переписывать

* Раскомментируем строки с переменными файла /etc/sysconfig/spawn-fcgi, чтобы конфиг выглядел следующим образом:
``` bash
[root@localhost ~]# cat /etc/sysconfig/spawn-fcgi
# You must set some working options before the "spawn-fcgi" service will work.
# If SOCKET points to a file, then this file is cleaned up by the init script.
#
# See spawn-fcgi(1) for all possible options.
#
# Example :
SOCKET=/var/run/php-fcgi.sock
OPTIONS="-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi"
```

* Прописываем unit файл для spawn-fcgi
``` bash
echo '[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/spawn-fcgi.service
```

* Убеждаемся, что все успешно работает:
``` bash
[root@localhost ~]# systemctl start spawn-fcgi
[root@localhost ~]# systemctl status spawn-fcgi
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
   Active: active (running) since Sun 2024-04-14 06:28:51 UTC; 5s ago
 Main PID: 22654 (php-cgi)
    Tasks: 33 (limit: 2746)
   Memory: 27.9M
   CGroup: /system.slice/spawn-fcgi.service
           ├─22654 /usr/bin/php-cgi
           ├─22655 /usr/bin/php-cgi
           ├─22656 /usr/bin/php-cgi
           ├─22657 /usr/bin/php-cgi
           ├─22658 /usr/bin/php-cgi
           ├─22659 /usr/bin/php-cgi
           ├─22660 /usr/bin/php-cgi
           ├─22661 /usr/bin/php-cgi
           ├─22662 /usr/bin/php-cgi
           ├─22663 /usr/bin/php-cgi
           ├─22664 /usr/bin/php-cgi
           ├─22665 /usr/bin/php-cgi
           ├─22666 /usr/bin/php-cgi
           ├─22667 /usr/bin/php-cgi
           ├─22668 /usr/bin/php-cgi
           ├─22669 /usr/bin/php-cgi
           ├─22670 /usr/bin/php-cgi
           ├─22671 /usr/bin/php-cgi
           ├─22672 /usr/bin/php-cgi
           ├─22673 /usr/bin/php-cgi
           ├─22674 /usr/bin/php-cgi
           ├─22675 /usr/bin/php-cgi
           ├─22676 /usr/bin/php-cgi
           ├─22677 /usr/bin/php-cgi
           ├─22678 /usr/bin/php-cgi
           ├─22679 /usr/bin/php-cgi
           ├─22680 /usr/bin/php-cgi
           ├─22681 /usr/bin/php-cgi
           ├─22682 /usr/bin/php-cgi
           ├─22683 /usr/bin/php-cgi
           ├─22684 /usr/bin/php-cgi
           ├─22685 /usr/bin/php-cgi
           └─22686 /usr/bin/php-cgi

Apr 14 06:28:51 localhost.localdomain systemd[1]: Started Spawn-fcgi startup service by Otus.
```

## Дополнить юнит-файл apache httpd возможностью запустить несколько инстансов сервера с разными конфигами
* Для запуска нескольких экземпляров сервиса будем использовать шаблон в конфигурации файла окружения (/usr/lib/systemd/system/httpd.service ):
``` bash
[root@localhost ~]# cat /usr/lib/systemd/system/httpd.service
# See httpd.service(8) for more information on using the httpd service.

# Modifying this file in-place is not recommended, because changes
# will be overwritten during package upgrades.  To customize the
# behaviour, run "systemctl edit httpd" to create an override unit.

# For example, to pass additional options (such as -D definitions) to
# the httpd binary at startup, create an override unit (as is done by
# systemctl edit) and enter the following:

#	[Service]
#	Environment=OPTIONS=-DMY_DEFINE

[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-init.service
Documentation=man:httpd.service(8)

[Service]
Type=notify
Environment=LANG=C

ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

* В самом файле окружения (которых будет два) задается опция для запуска веб-сервера с необходимым конфигурационным файлом:
``` bash
[root@localhost ~]# echo 'OPTIONS=-f conf/first.conf' > /etc/sysconfig/httpd-first
[root@localhost ~]# echo 'OPTIONS=-f conf/second.conf' > /etc/sysconfig/httpd-second
```

* Соответственно в директории с конфигами httpd (/etc/httpd/conf) должны лежать два конфига, в нашем случае это будут first.conf и second.conf:
``` bash
[root@localhost ~]# cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/first.conf
[root@localhost ~]# cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/second.conf
```

* Для удачного запуска, в конфигурационных файлах должны быть указаны уникальные для каждого экземпляра опции Listen и PidFile. После копирования для второго конфига меняем параметры и указываем эти опции:
``` bash
PidFile /var/run/httpd-second.pid
Listen 8080
```

* Запускаем:
``` bash
[root@localhost ~]# systemctl start httpd@first
[root@localhost ~]# systemctl start httpd@second
```

* Проверяем - смотрим, какие порты слушаются, видим 2 нужных экземпляра:
``` bash
[root@localhost ~]# ss -tnulp | grep httpd
tcp     LISTEN   0        128                    *:8080                *:*       users:(("httpd",pid=23018,fd=4),("httpd",pid=23017,fd=4),("httpd",pid=23016,fd=4),("httpd",pid=23013,fd=4))
tcp     LISTEN   0        128                    *:80                  *:*       users:(("httpd",pid=22796,fd=4),("httpd",pid=22795,fd=4),("httpd",pid=22794,fd=4),("httpd",pid=22790,fd=4))
```
