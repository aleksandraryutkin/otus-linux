# Домашнее задание - создание своего RPM пакета и репозитория

## Подготовительные действия
* Для корректной синхронизации директории хоста и директории /vagrant создана новая директория /src на виртуальной машине, куда помещен Vagrantfile. Также добавлена секция синхронизации директорий в него:
``` bash
    config.vm.synced_folder "/src/", "/vagrant"
```

* Создаем ВМ и подключаемся к ней
``` bash
root@[some-vm]: vagrant up && vagrant ssh
```
* На Centos 8 при создании ВМ из данного Vagrantfile ловил такую ошибку и shell с командами установки репы в зеркало не помог
``` bash
The following SSH command responded with a non-zero exit status.
Vagrant assumes that this means the command failed!

yum install -y centos-release

Stdout from the command:

CentOS Linux 8 - AppStream                      449  B/s |  38  B     00:00


Stderr from the command:

Error: Failed to download metadata for repo 'appstream': Cannot prepare internal mirrorlist: No URLs in mirrorlist
```

* Не было времени долго разбираться,  пожтому после того, как зашел на ВМ, ввел эти команды и дальше все установки пакетов проходили корректно
``` bash
[root@packages ~]# cd /etc/yum.repos.d/
[root@packages ~]# sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
[root@packages ~]# sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
```

## Основные работы

### Создание своего RPM пакета
* Устанавливаем необходимые пакеты:
``` bash
[root@packages ~]# yum install -y \
> redhat-lsb-core \wget \
> rpmdevtools \
> rpm-build \
> createrepo \
> yum-utils \
> gcc

...
Upgraded:
  cups-libs-1:2.2.6-40.el8.x86_64           dnf-plugins-core-4.0.21-3.el8.noarch              elfutils-libelf-0.185-1.el8.x86_64   elfutils-libs-0.185-1.el8.x86_64   glibc-2.28-164.el8.x86_64             glibc-common-2.28-164.el8.x86_64
  glibc-langpack-en-2.28-164.el8.x86_64     ima-evm-utils-1.3.2-12.el8.x86_64                 libblkid-2.32.1-28.el8.x86_64        libfdisk-2.32.1-28.el8.x86_64      libgcc-8.5.0-4.el8_5.x86_64           libgomp-8.5.0-4.el8_5.x86_64
  libmount-2.32.1-28.el8.x86_64             libsmartcols-2.32.1-28.el8.x86_64                 libuuid-2.32.1-28.el8.x86_64         libxcrypt-4.1.1-6.el8.x86_64       ncurses-6.1-9.20180224.el8.x86_64     ncurses-base-6.1-9.20180224.el8.noarch
  ncurses-libs-6.1-9.20180224.el8.x86_64    python3-dnf-plugins-core-4.0.21-3.el8.noarch      python3-rpm-4.14.3-19.el8.x86_64     rpm-4.14.3-19.el8.x86_64           rpm-build-libs-4.14.3-19.el8.x86_64   rpm-libs-4.14.3-19.el8.x86_64
  rpm-plugin-selinux-4.14.3-19.el8.x86_64   rpm-plugin-systemd-inhibit-4.14.3-19.el8.x86_64   util-linux-2.32.1-28.el8.x86_64      yum-utils-4.0.21-3.el8.noarch

Installed:
  annobin-9.72-1.el8_5.2.x86_64                     at-3.1.20-11.el8.x86_64                                           bc-1.07.1-5.el8.x86_64                                        binutils-2.30-108.el8_5.1.x86_64
  cpp-8.5.0-4.el8_5.x86_64                          createrepo_c-0.17.2-3.el8.x86_64                                  createrepo_c-libs-0.17.2-3.el8.x86_64                         cups-client-1:2.2.6-40.el8.x86_64
  drpm-0.4.1-3.el8.x86_64                           dwz-0.12-10.el8.x86_64                                            ed-1.14.2-4.el8.x86_64                                        efi-srpm-macros-3-3.el8.noarch
  elfutils-0.185-1.el8.x86_64                       emacs-filesystem-1:26.1-7.el8.noarch                              gc-7.6.4-3.el8.x86_64                                         gcc-8.5.0-4.el8_5.x86_64
  gdb-headless-8.2-16.el8.x86_64                    ghc-srpm-macros-1.4.2-7.el8.noarch                                glibc-devel-2.28-164.el8.x86_64                               glibc-headers-2.28-164.el8.x86_64
  go-srpm-macros-2-17.el8.noarch                    guile-5:2.0.14-7.el8.x86_64                                       isl-0.16.1-6.el8.x86_64                                       kernel-headers-4.18.0-348.7.1.el8_5.x86_64
  libatomic_ops-7.6.2-3.el8.x86_64                  libbabeltrace-1.5.4-3.el8.x86_64                                  libipt-1.6.1-8.el8.x86_64                                     libmpc-1.1.0-9.1.el8.x86_64
  libxcrypt-devel-4.1.1-6.el8.x86_64                m4-1.4.18-7.el8.x86_64                                            mailx-12.5-29.el8.x86_64                                      make-1:4.2.1-10.el8.x86_64
  ncurses-compat-libs-6.1-9.20180224.el8.x86_64     nspr-4.32.0-1.el8_4.x86_64                                        nss-3.67.0-7.el8_5.x86_64                                     nss-softokn-3.67.0-7.el8_5.x86_64
  nss-softokn-freebl-3.67.0-7.el8_5.x86_64          nss-sysinit-3.67.0-7.el8_5.x86_64                                 nss-util-3.67.0-7.el8_5.x86_64                                ocaml-srpm-macros-5-4.el8.noarch
  openblas-srpm-macros-2-2.el8.noarch               patch-2.7.6-11.el8.x86_64                                         perl-Carp-1.42-396.el8.noarch                                 perl-Data-Dumper-2.167-399.el8.x86_64
  perl-Digest-1.17-395.el8.noarch                   perl-Digest-MD5-2.55-396.el8.x86_64                               perl-Encode-4:2.97-3.el8.x86_64                               perl-Errno-1.28-420.el8.x86_64
  perl-Exporter-5.72-396.el8.noarch                 perl-File-Path-2.15-2.el8.noarch                                  perl-File-Temp-0.230.600-1.el8.noarch                         perl-Getopt-Long-1:2.50-4.el8.noarch
  perl-HTTP-Tiny-0.074-1.el8.noarch                 perl-IO-1.38-420.el8.x86_64                                       perl-IO-Socket-IP-0.39-5.el8.noarch                           perl-IO-Socket-SSL-2.066-4.module_el8.3.0+410+ff426aa3.noarch
  perl-MIME-Base64-3.15-396.el8.x86_64              perl-Mozilla-CA-20160104-7.module_el8.3.0+416+dee7bcef.noarch     perl-Net-SSLeay-1.88-1.module_el8.3.0+410+ff426aa3.x86_64     perl-PathTools-3.74-1.el8.x86_64
  perl-Pod-Escapes-1:1.07-395.el8.noarch            perl-Pod-Perldoc-3.28-396.el8.noarch                              perl-Pod-Simple-1:3.35-395.el8.noarch                         perl-Pod-Usage-4:1.69-395.el8.noarch
  perl-Scalar-List-Utils-3:1.49-2.el8.x86_64        perl-Socket-4:2.027-3.el8.x86_64                                  perl-Storable-1:3.11-3.el8.x86_64                             perl-Term-ANSIColor-4.06-396.el8.noarch
  perl-Term-Cap-1.17-395.el8.noarch                 perl-Text-ParseWords-3.30-395.el8.noarch                          perl-Text-Tabs+Wrap-2013.0523-395.el8.noarch                  perl-Time-Local-1:1.280-1.el8.noarch
  perl-URI-1.73-3.el8.noarch                        perl-Unicode-Normalize-1.25-396.el8.x86_64                        perl-constant-1.33-396.el8.noarch                             perl-interpreter-4:5.26.3-420.el8.x86_64
  perl-libnet-3.11-3.el8.noarch                     perl-libs-4:5.26.3-420.el8.x86_64                                 perl-macros-4:5.26.3-420.el8.x86_64                           perl-parent-1:0.237-1.el8.noarch
  perl-podlators-4.11-1.el8.noarch                  perl-srpm-macros-1-25.el8.noarch                                  perl-threads-1:2.21-2.el8.x86_64                              perl-threads-shared-1.58-2.el8.x86_64
  postfix-2:3.5.8-2.el8.x86_64                      psmisc-23.1-5.el8.x86_64                                          python-rpm-macros-3-41.el8.noarch                             python-srpm-macros-3-41.el8.noarch
  python3-rpm-macros-3-41.el8.noarch                qt5-srpm-macros-5.15.2-1.el8.noarch                               redhat-lsb-core-4.1-47.el8.x86_64                             redhat-lsb-submod-security-4.1-47.el8.x86_64
  redhat-rpm-config-125-1.el8.noarch                rpm-build-4.14.3-19.el8.x86_64                                    rpmdevtools-8.10-8.el8.noarch                                 rust-srpm-macros-5-2.el8.noarch
  spax-1.5.3-13.el8.x86_64                          time-1.9-3.el8.x86_64                                             tpm2-tss-2.3.2-4.el8.x86_64                                   unzip-6.0-45.el8_4.x86_64
  util-linux-user-2.32.1-28.el8.x86_64              wget-1.19.5-10.el8.x86_64                                         zip-3.0-23.el8.x86_64                                         zstd-1.4.4-1.el8.x86_64

Complete!
```

* Для примера возьмем пакет NGINX и соберем его с поддержкой openssl
* Загрузим SRPM пакет NGINX для дальнейшей работы над ним:
``` bash
[root@packages ~]# wget https://nginx.org/packages/centos/8/SRPMS/nginx-1.20.2-1.el8.ngx.src.rpm
--2024-04-11 02:52:13--  https://nginx.org/packages/centos/8/SRPMS/nginx-1.20.2-1.el8.ngx.src.rpm
Resolving nginx.org (nginx.org)... 52.58.199.22, 3.125.197.172, 2a05:d014:5c0:2601::6, ...
Connecting to nginx.org (nginx.org)|52.58.199.22|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 1086865 (1.0M) [application/x-redhat-package-manager]
Saving to: ‘nginx-1.20.2-1.el8.ngx.src.rpm’

100%[===========================================================================================================================================================================================================>] 1,086,865   --.-K/s   in 0.08s

2024-04-11 02:52:13 (13.5 MB/s) - ‘nginx-1.20.2-1.el8.ngx.src.rpm’ saved [1086865/1086865]
```

* При установке такого пакета в домашней директории создается древо каталогов для сборки:
``` bash
[root@packages ~]# rpm -i nginx-1.*
warning: nginx-1.20.2-1.el8.ngx.src.rpm: Header V4 RSA/SHA1 Signature, key ID 7bd9bf62: NOKEY
warning: user builder does not exist - using root
warning: group builder does not exist - using root
warning: user builder does not exist - using root
warning: group builder does not exist - using root
warning: user builder does not exist - using root
warning: group builder does not exist - using root
warning: user builder does not exist - using root
warning: group builder does not exist - using root
warning: user builder does not exist - using root
warning: group builder does not exist - using root
warning: user builder does not exist - using root
warning: group builder does not exist - using root
warning: user builder does not exist - using root
warning: group builder does not exist - using root
warning: user builder does not exist - using root
warning: group builder does not exist - using root
warning: user builder does not exist - using root
warning: group builder does not exist - using root
warning: user builder does not exist - using root
warning: group builder does not exist - using root
warning: user builder does not exist - using root
warning: group builder does not exist - using root
[root@packages ~]# ll
total 1080
-rw-------. 1 root root    5763 May 12  2018 anaconda-ks.cfg
-rw-r--r--. 1 root root 1086865 Nov 16  2021 nginx-1.20.2-1.el8.ngx.src.rpm
-rw-------. 1 root root    5432 May 12  2018 original-ks.cfg
drwxr-xr-x. 4 root root      34 Apr 11 02:53 rpmbuild
[root@packages ~]# ll rpmbuild/
total 0
drwxr-xr-x. 2 root root 246 Apr 11 03:08 SOURCES
drwxr-xr-x. 2 root root  24 Apr 11 03:08 SPECS
```

* Также нужно скачать и разархивировать последний исходник для openssl - он потребуется при сборке:
``` bash
[root@packages ~]# wget https://github.com/openssl/openssl/archive/refs/heads/OpenSSL_1_1_1-stable.zip
--2024-04-11 03:12:41--  https://github.com/openssl/openssl/archive/refs/heads/OpenSSL_1_1_1-stable.zip
Resolving github.com (github.com)... 140.82.121.4
Connecting to github.com (github.com)|140.82.121.4|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://codeload.github.com/openssl/openssl/zip/refs/heads/OpenSSL_1_1_1-stable [following]
--2024-04-11 03:12:41--  https://codeload.github.com/openssl/openssl/zip/refs/heads/OpenSSL_1_1_1-stable
Resolving codeload.github.com (codeload.github.com)... 140.82.121.9
Connecting to codeload.github.com (codeload.github.com)|140.82.121.9|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: unspecified [application/zip]
Saving to: ‘OpenSSL_1_1_1-stable.zip’

    [      <=>                                                                                                                                                                                                   ] 11,924,330  7.80MB/s   in 1.5s

2024-04-11 03:12:43 (7.80 MB/s) - ‘OpenSSL_1_1_1-stable.zip’ saved [11924330]

[root@packages ~]# unzip OpenSSL_1_1_1-stable.zip
```

* Заранее поставим все зависимости, чтобы в процессе сборки не было ошибок:
``` bash
[root@packages ~]# yum-builddep rpmbuild/SPECS/nginx.spec
...
Upgraded:
  e2fsprogs-1.45.6-2.el8.x86_64     e2fsprogs-libs-1.45.6-2.el8.x86_64 keyutils-1.5.10-9.el8.x86_64      keyutils-libs-1.5.10-9.el8.x86_64  krb5-libs-1.18.2-14.el8.x86_64       libcom_err-1.45.6-2.el8.x86_64 libselinux-2.9-5.el8.x86_64
  libselinux-utils-2.9-5.el8.x86_64 libsepol-2.9-3.el8.x86_64          libss-1.45.6-2.el8.x86_64         openssl-1:1.1.1k-5.el8_5.x86_64    openssl-libs-1:1.1.1k-5.el8_5.x86_64 pcre-8.42-6.el8.x86_64         python3-libselinux-2.9-5.el8.x86_64
  systemd-239-51.el8_5.2.x86_64     systemd-libs-239-51.el8_5.2.x86_64 systemd-pam-239-51.el8_5.2.x86_64 systemd-udev-239-51.el8_5.2.x86_64 zlib-1.2.11-17.el8.x86_64

Installed:
  keyutils-libs-devel-1.5.10-9.el8.x86_64 krb5-devel-1.18.2-14.el8.x86_64 libcom_err-devel-1.45.6-2.el8.x86_64 libkadm5-1.18.2-14.el8.x86_64 libselinux-devel-2.9-5.el8.x86_64 libsepol-devel-2.9-3.el8.x86_64 libverto-devel-0.3.0-5.el8.x86_64
  openssl-devel-1:1.1.1k-5.el8_5.x86_64   pcre-cpp-8.42-6.el8.x86_64      pcre-devel-8.42-6.el8.x86_64         pcre-utf16-8.42-6.el8.x86_64  pcre-utf32-8.42-6.el8.x86_64      pcre2-devel-10.32-2.el8.x86_64  pcre2-utf16-10.32-2.el8.x86_64
  pcre2-utf32-10.32-2.el8.x86_64          zlib-devel-1.2.11-17.el8.x86_64

Complete!
```

* Правим результирующий spec файл (нужно установить корректный путь до ssl, в моем случае это --with-openssl=/root/openssl-OpenSSL_1_1_1-stable)
* Теперь можно приступить к сборке RPM пакета:
``` bash
[root@packages ~]# rpmbuild -bb rpmbuild/SPECS/nginx.spec
...
Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.ZCtupi
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cd nginx-1.20.2
+ /usr/bin/rm -rf /root/rpmbuild/BUILDROOT/nginx-1.20.2-1.el8.ngx.x86_64.rp
+ exit 0
```

* Убедимся, что пакеты создались:
``` bash
[root@localhost ~]# ll rpmbuild/RPMS/x86_64/
total 4676
-rw-r--r--. 1 root root 2250116 Apr 12 06:34 nginx-1.20.2-1.el8.ngx.x86_64.rpm
-rw-r--r--. 1 root root 2533124 Apr 12 06:34 nginx-debuginfo-1.20.2-1.el8.ngx.x86_64.rpm
```

* Теперь можно установить наш пакет и убедиться, что nginx работает:
``` bash
[root@packages ~]# yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el8.ngx.x86_64.rpm
...
Installed:
  nginx-1:1.20.2-1.el8.ngx.x86_64

Complete!
[root@packages ~]# systemctl start nginx
[root@packages ~]# systemctl status nginx
● nginx.service - nginx - high performance web server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Fri 2024-04-12 06:39:18 UTC; 4s ago
     Docs: http://nginx.org/en/docs/
  Process: 46663 ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf (code=exited, status=0/SUCCESS)
 Main PID: 46664 (nginx)
    Tasks: 2 (limit: 2746)
   Memory: 2.1M
   CGroup: /system.slice/nginx.service
           ├─46664 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.conf
           └─46665 nginx: worker process

Apr 12 06:39:18 localhost.localdomain systemd[1]: Starting nginx - high performance web server...
Apr 12 06:39:18 localhost.localdomain systemd[1]: nginx.service: Can't open PID file /var/run/nginx.pid (yet?) after start: No such file or directory
Apr 12 06:39:18 localhost.localdomain systemd[1]: Started nginx - high performance web server.
```

* Далее мы будем использовать его для доступа к своему репозиторию

### Создание своего репозитория и размещение там ранее собранного RPM
* Теперь приступим к созданию своего репозитория. Директория для статики у NGINX по умолчанию /usr/share/nginx/html. Создадим там каталог repo:
``` bash
[root@packages ~]# mkdir /usr/share/nginx/html/repo
```

* Копируем туда наш собранный RPM и, например, RPM для установки репозитория Percona-Server:
``` bash
[root@packages ~]# cp rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el8.ngx.x86_64.rpm /usr/share/nginx/html/repo/
[root@packages ~]# wget https://downloads.percona.com/downloads/percona-distribution-mysql-ps/percona-distribution-mysql-ps-8.0.28/binary/redhat/8/x86_64/percona-orchestrator-3.2.6-2.el8.x86_64.rpm -O /usr/share/nginx/html/repo/percona-orchestrator-3.2.6-2.el8.x86_64.rpm

--2024-04-12 06:40:25--  https://downloads.percona.com/downloads/percona-distribution-mysql-ps/percona-distribution-mysql-ps-8.0.28/binary/redhat/8/x86_64/percona-orchestrator-3.2.6-2.el8.x86_64.rpm
Resolving downloads.percona.com (downloads.percona.com)... 49.12.125.205, 2a01:4f8:242:5792::2
Connecting to downloads.percona.com (downloads.percona.com)|49.12.125.205|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 5222976 (5.0M) [application/x-redhat-package-manager]
Saving to: ‘/usr/share/nginx/html/repo/percona-orchestrator-3.2.6-2.el8.x86_64.rpm’

/usr/share/nginx/html/repo/percona-orchestrator-3.2.6-2.el8.x 100%[==============================================================================================================================================>]   4.98M  15.3MB/s    in 0.3s

2024-04-12 06:40:26 (15.3 MB/s) - ‘/usr/share/nginx/html/repo/percona-orchestrator-3.2.6-2.el8.x86_64.rpm’ saved [5222976/5222976]
```

* Инициализируем репозиторий командой:
``` bash
[root@packages ~]# createrepo /usr/share/nginx/html/repo/
Directory walk started
Directory walk done - 2 packages
Temporary output repo path: /usr/share/nginx/html/repo/.repodata/
Preparing sqlite DBs
Pool started (with 5 workers)
Pool finished
```

* Для прозрачности настроим в NGINX доступ к листингу каталога: добавим директиву autoindex on в конфигурацию. Проверим и перезапустим nginx
``` bash
[root@packages ~]# nano /etc/nginx/conf.d/default.conf
    location / {
        root   /usr/share/nginx/html;
       	index  index.html index.htm;
       	autoindex on;
    }

[root@packages ~]# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
[root@packages ~]# nginx -s reload
```

* Проверим доступность через curl:
``` bash
[root@packages ~]#  curl -a http://localhost/repo/
<html>
<head><title>Index of /repo/</title></head>
<body>
<h1>Index of /repo/</h1><hr><pre><a href="../">../</a>
<a href="repodata/">repodata/</a>                                          12-Apr-2024 06:40                   -
<a href="nginx-1.20.2-1.el8.ngx.x86_64.rpm">nginx-1.20.2-1.el8.ngx.x86_64.rpm</a>                  12-Apr-2024 06:40             2250116
<a href="percona-orchestrator-3.2.6-2.el8.x86_64.rpm">percona-orchestrator-3.2.6-2.el8.x86_64.rpm</a>        16-Feb-2022 15:57             5222976
</pre><hr></body>
</html>
```

* Все готово для того, чтобы протестировать репозиторий.
* Добавим его в /etc/yum.repos.d:
``` bash
[root@packages ~]# cat >> /etc/yum.repos.d/otus.repo << EOF
> [otus]
> name=otus-linux
> baseurl=http://localhost/repo
> gpgcheck=0
> enabled=1
> EOF
```

* Убедимся, что репозиторий подключился и посмотрим, что в нем есть:
``` bash
[root@packages ~]# yum repolist enabled | grep otus
otus                                otus-linux

[root@packages ~]# yum list | grep otus
otus-linux                                       68 kB/s | 2.8 kB     00:00
percona-orchestrator.x86_64                            2:3.2.6-2.el8
```
Тут стоит отметить, что в списке `yum list` мы видим только одну percona, без nginx, так как тот уже установлен
* Так как NGINX у нас уже стоит, установим репозиторий percona-release
``` bash
[root@packages ~]# yum install percona-orchestrator.x86_64 -y
...
Installed:
  jq-1.5-12.el8.x86_64                                                   oniguruma-6.8.2-2.el8.x86_64                                                   percona-orchestrator-2:3.2.6-2.el8.x86_64

Complete!
```
Если тут проверить `yum list`, то пакетов уже не увидим
``` bash
[root@packages ~]# yum repolist enabled | grep otus
otus                            otus-linux
```

* Задание со звездойчкой представляю как делать, надо оформить `Dockerfile` с установкой nginx, собрать через `docker build`, протегировать образ `docker tag` и можно пушнуть в свой `docker hub`. Но времени нет это сделать(

