# Домашнее задание - работа с mdadm
* В результате разворачивания ВМ из Vagrantfile создается дополнительно 5 дисков и RAID6 массив (через скрипт). Запускаем ВМ через `vagrant up`
``` bash
root@[some-vm]:~# vagrant up
Bringing machine 'otuslinux' up with 'virtualbox' provider...
==> otuslinux: Importing base box 'centos/7'...
==> otuslinux: Matching MAC address for NAT networking...
==> otuslinux: Checking if box 'centos/7' version '2004.01' is up to date...
==> otuslinux: Setting the name of the VM: root_otuslinux_1712378857508_14625
==> otuslinux: Clearing any previously set network interfaces...
==> otuslinux: Preparing network interfaces based on configuration...
    otuslinux: Adapter 1: nat
    otuslinux: Adapter 2: hostonly
==> otuslinux: Forwarding ports...
    otuslinux: 22 (guest) => 2222 (host) (adapter 1)
==> otuslinux: Running 'pre-boot' VM customizations...
==> otuslinux: Booting VM...
==> otuslinux: Waiting for machine to boot. This may take a few minutes...
    otuslinux: SSH address: 127.0.0.1:2222
    otuslinux: SSH username: vagrant
    otuslinux: SSH auth method: private key
    otuslinux:
    otuslinux: Vagrant insecure key detected. Vagrant will automatically replace
    otuslinux: this with a newly generated keypair for better security.
    otuslinux:
    otuslinux: Inserting generated public key within guest...
    otuslinux: Removing insecure key from the guest if it's present...
    otuslinux: Key inserted! Disconnecting and reconnecting using new SSH key...
==> otuslinux: Machine booted and ready!
==> otuslinux: Checking for guest additions in VM...
    otuslinux: No guest additions were detected on the base box for this VM! Guest
    otuslinux: additions are required for forwarded ports, shared folders, host only
    otuslinux: networking, and more. If SSH fails on this machine, please install
    otuslinux: the guest additions and repackage the box to continue.
    otuslinux:
    otuslinux: This is not an error message; everything may continue to work properly,
    otuslinux: in which case you may ignore this message.
==> otuslinux: Setting hostname...
==> otuslinux: Configuring and enabling network interfaces...
==> otuslinux: Rsyncing folder: /root/ => /vagrant
==> otuslinux: Running provisioner: shell...
    otuslinux: Running: inline script
    otuslinux: Loaded plugins: fastestmirror
    otuslinux: Determining fastest mirrors
    otuslinux:  * base: de.mirrors.clouvider.net
    otuslinux:  * extras: de.mirrors.clouvider.net
    otuslinux:  * updates: de.mirrors.clouvider.net
    otuslinux: Resolving Dependencies
    otuslinux: --> Running transaction check
    otuslinux: ---> Package gdisk.x86_64 0:0.8.10-3.el7 will be installed
    otuslinux: ---> Package hdparm.x86_64 0:9.43-5.el7 will be installed
    otuslinux: ---> Package mdadm.x86_64 0:4.1-9.el7_9 will be installed
    otuslinux: --> Processing Dependency: libreport-filesystem for package: mdadm-4.1-9.el7_9.x86_64
    otuslinux: ---> Package smartmontools.x86_64 1:7.0-2.el7 will be installed
    otuslinux: --> Processing Dependency: mailx for package: 1:smartmontools-7.0-2.el7.x86_64
    otuslinux: --> Running transaction check
    otuslinux: ---> Package libreport-filesystem.x86_64 0:2.1.11-53.el7.centos will be installed
    otuslinux: ---> Package mailx.x86_64 0:12.5-19.el7 will be installed
    otuslinux: --> Finished Dependency Resolution
    otuslinux:
    otuslinux: Dependencies Resolved
    otuslinux:
    otuslinux: ================================================================================
    otuslinux:  Package                  Arch       Version                  Repository   Size
    otuslinux: ================================================================================
    otuslinux: Installing:
    otuslinux:  gdisk                    x86_64     0.8.10-3.el7             base        190 k
    otuslinux:  hdparm                   x86_64     9.43-5.el7               base         83 k
    otuslinux:  mdadm                    x86_64     4.1-9.el7_9              updates     439 k
    otuslinux:  smartmontools            x86_64     1:7.0-2.el7              base        546 k
    otuslinux: Installing for dependencies:
    otuslinux:  libreport-filesystem     x86_64     2.1.11-53.el7.centos     base         41 k
    otuslinux:  mailx                    x86_64     12.5-19.el7              base        245 k
    otuslinux:
    otuslinux: Transaction Summary
    otuslinux: ================================================================================
    otuslinux: Install  4 Packages (+2 Dependent packages)
    otuslinux:
    otuslinux: Total download size: 1.5 M
    otuslinux: Installed size: 4.3 M
    otuslinux: Downloading packages:
    otuslinux: Public key for libreport-filesystem-2.1.11-53.el7.centos.x86_64.rpm is not installed
    otuslinux: warning: /var/cache/yum/x86_64/7/base/packages/libreport-filesystem-2.1.11-53.el7.centos.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
    otuslinux: Public key for mdadm-4.1-9.el7_9.x86_64.rpm is not installed
    otuslinux: --------------------------------------------------------------------------------
    otuslinux: Total                                              1.9 MB/s | 1.5 MB  00:00
    otuslinux: Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
    otuslinux: Importing GPG key 0xF4A80EB5:
    otuslinux:  Userid     : "CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>"
    otuslinux:  Fingerprint: 6341 ab27 53d7 8a78 a7c2 7bb1 24c6 a8a7 f4a8 0eb5
    otuslinux:  Package    : centos-release-7-8.2003.0.el7.centos.x86_64 (@anaconda)
    otuslinux:  From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
    otuslinux: Running transaction check
    otuslinux: Running transaction test
    otuslinux: Transaction test succeeded
    otuslinux: Running transaction
    otuslinux:   Installing : libreport-filesystem-2.1.11-53.el7.centos.x86_64             1/6
    otuslinux:   Installing : mailx-12.5-19.el7.x86_64                                     2/6
    otuslinux:   Installing : 1:smartmontools-7.0-2.el7.x86_64                             3/6
    otuslinux:   Installing : mdadm-4.1-9.el7_9.x86_64                                     4/6
    otuslinux:   Installing : hdparm-9.43-5.el7.x86_64                                     5/6
    otuslinux:   Installing : gdisk-0.8.10-3.el7.x86_64                                    6/6
    otuslinux:   Verifying  : mdadm-4.1-9.el7_9.x86_64                                     1/6
    otuslinux:   Verifying  : 1:smartmontools-7.0-2.el7.x86_64                             2/6
    otuslinux:   Verifying  : gdisk-0.8.10-3.el7.x86_64                                    3/6
    otuslinux:   Verifying  : mailx-12.5-19.el7.x86_64                                     4/6
    otuslinux:   Verifying  : hdparm-9.43-5.el7.x86_64                                     5/6
    otuslinux:   Verifying  : libreport-filesystem-2.1.11-53.el7.centos.x86_64             6/6
    otuslinux:
    otuslinux: Installed:
    otuslinux:   gdisk.x86_64 0:0.8.10-3.el7          hdparm.x86_64 0:9.43-5.el7
    otuslinux:   mdadm.x86_64 0:4.1-9.el7_9           smartmontools.x86_64 1:7.0-2.el7
    otuslinux:
    otuslinux: Dependency Installed:
    otuslinux:   libreport-filesystem.x86_64 0:2.1.11-53.el7.centos mailx.x86_64 0:12.5-19.el7
    otuslinux:
    otuslinux: Complete!
    otuslinux: mdadm: Unrecognised md component device - /dev/sdb
    otuslinux: mdadm: Unrecognised md component device - /dev/sdc
    otuslinux: mdadm: Unrecognised md component device - /dev/sdd
    otuslinux: mdadm: Unrecognised md component device - /dev/sde
    otuslinux: mdadm: Unrecognised md component device - /dev/sdf
    otuslinux: mdadm: layout defaults to left-symmetric
    otuslinux: mdadm: layout defaults to left-symmetric
    otuslinux: mdadm: chunk size defaults to 512K
    otuslinux: mdadm: size set to 253952K
    otuslinux: mdadm: Defaulting to version 1.2 metadata
    otuslinux: mdadm: array /dev/md0 started.
```

* Проверяем RAID, заходя на ВМ
``` bash
root@[some-vm]:~# vagrant ssh
[vagrant@otuslinux ~]$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Sat Apr  6 05:02:46 2024
        Raid Level : raid6
        Array Size : 761856 (744.00 MiB 780.14 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Sat Apr  6 05:02:56 2024
             State : clean
    Active Devices : 5
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : otuslinux:0  (local to host otuslinux)
              UUID : 30dc788f:375bba8b:79ee8a23:bd57ffa1
            Events : 17

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       3       8       64        3      active sync   /dev/sde
       4       8       80        4      active sync   /dev/sdf
```
