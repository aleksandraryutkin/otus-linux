# Домашнее задание - обновление ядра Linux
* После подготовки окружения и установки утилит создаем [Vagrantfile](https://github.com/aleksandraryutkin/otus-linux/blob/homework_kernel_update/homework_kernel_update/Vagrantfile) и запускаем виртуальную машину
``` bash
root@[some_vm]:~# vagrant up
Bringing machine 'kernel-update' up with 'virtualbox' provider...
==> kernel-update: Box 'generic/centos8s' could not be found. Attempting to find and install...
    kernel-update: Box Provider: virtualbox
    kernel-update: Box Version: 4.3.4
==> kernel-update: Loading metadata for box 'generic/centos8s'
    kernel-update: URL: https://vagrantcloud.com/api/v2/vagrant/generic/centos8s
==> kernel-update: Adding box 'generic/centos8s' (v4.3.4) for provider: virtualbox (amd64)
    kernel-update: Downloading: https://vagrantcloud.com/generic/boxes/centos8s/versions/4.3.4/providers/virtualbox/amd64/vagrant.box
    kernel-update: Calculating and comparing box checksum...
==> kernel-update: Successfully added box 'generic/centos8s' (v4.3.4) for 'virtualbox (amd64)'!
==> kernel-update: Importing base box 'generic/centos8s'...
==> kernel-update: Matching MAC address for NAT networking...
==> kernel-update: Checking if box 'generic/centos8s' version '4.3.4' is up to date...
==> kernel-update: Setting the name of the VM: root_kernel-update_1710692080828_83057
==> kernel-update: Clearing any previously set network interfaces...
==> kernel-update: Preparing network interfaces based on configuration...
    kernel-update: Adapter 1: nat
==> kernel-update: Forwarding ports...
    kernel-update: 22 (guest) => 2222 (host) (adapter 1)
==> kernel-update: Running 'pre-boot' VM customizations...
==> kernel-update: Booting VM...
==> kernel-update: Waiting for machine to boot. This may take a few minutes...
    kernel-update: SSH address: 127.0.0.1:2222
    kernel-update: SSH username: vagrant
    kernel-update: SSH auth method: private key
    kernel-update:
    kernel-update: Vagrant insecure key detected. Vagrant will automatically replace
    kernel-update: this with a newly generated keypair for better security.
    kernel-update:
    kernel-update: Inserting generated public key within guest...
    kernel-update: Removing insecure key from the guest if it's present...
    kernel-update: Key inserted! Disconnecting and reconnecting using new SSH key...
==> kernel-update: Machine booted and ready!
==> kernel-update: Checking for guest additions in VM...
==> kernel-update: Setting hostname...
```

* Проверям запущенную машину, видим статус running
``` bash
root@[some_vm]:~# vagrant status
Current machine states:

kernel-update             running (virtualbox)

The VM is running. To stop this VM, you can run `vagrant halt` to
shut it down forcefully, or you can run `vagrant suspend` to simply
suspend the virtual machine. In either case, to restart it again,
simply run `vagrant up`.
```

* Подключаемся к созданной ВМ
``` bash
root@[some_vm]:~# vagrant ssh
```

* Проверяем версию ядра, видим устаревшую
``` bash
[vagrant@kernel-update ~]$ uname -r
4.18.0-516.el8.x86_64
```

* Подключаем репозиторий, откуда возьмем нужную версию ядра
``` bash
[vagrant@kernel-update ~]$ sudo yum install -y https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm
CentOS Stream 8 - AppStream                                                                                                                                                                                          9.2 MB/s |  28 MB     00:03
CentOS Stream 8 - BaseOS                                                                                                                                                                                             9.4 MB/s |  10 MB     00:01
CentOS Stream 8 - Extras                                                                                                                                                                                              51 kB/s |  18 kB     00:00
CentOS Stream 8 - Extras common packages                                                                                                                                                                              45 kB/s | 7.5 kB     00:00
Extra Packages for Enterprise Linux 8 - x86_64                                                                                                                                                                       6.3 MB/s |  16 MB     00:02
Extra Packages for Enterprise Linux 8 - Next - x86_64                                                                                                                                                                253 kB/s | 368 kB     00:01
elrepo-release-8.el8.elrepo.noarch.rpm                                                                                                                                                                               2.2 kB/s |  13 kB     00:05
Dependencies resolved.
=====================================================================================================================================================================================================================================================
 Package                                                      Architecture                                         Version                                                          Repository                                                  Size
=====================================================================================================================================================================================================================================================
Installing:
 elrepo-release                                               noarch                                               8.3-1.el8.elrepo                                                 @commandline                                                13 k

Transaction Summary
=====================================================================================================================================================================================================================================================
Install  1 Package

Total size: 13 k
Installed size: 5.0 k
Downloading Packages:
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                                                                                                                             1/1
  Installing       : elrepo-release-8.3-1.el8.elrepo.noarch                                                                                                                                                                                      1/1
  Verifying        : elrepo-release-8.3-1.el8.elrepo.noarch                                                                                                                                                                                      1/1

Installed:
  elrepo-release-8.3-1.el8.elrepo.noarch

Complete!
```

* Устанавливаем последнее ядро из репозитория elrepo-kernel
``` bash
[vagrant@kernel-update ~]$ sudo yum --enablerepo elrepo-kernel install kernel-ml -y
ELRepo.org Community Enterprise Linux Repository - el8                                                                                                                                                               404 kB/s | 203 kB     00:00
ELRepo.org Community Enterprise Linux Kernel Repository - el8                                                                                                                                                        3.5 MB/s | 2.2 MB     00:00
Dependencies resolved.
=====================================================================================================================================================================================================================================================
 Package                                                        Architecture                                        Version                                                         Repository                                                  Size
=====================================================================================================================================================================================================================================================
Installing:
 kernel-ml                                                      x86_64                                              6.8.1-1.el8.elrepo                                              elrepo-kernel                                              123 k
Installing dependencies:
 kernel-ml-core                                                 x86_64                                              6.8.1-1.el8.elrepo                                              elrepo-kernel                                               39 M
 kernel-ml-modules                                              x86_64                                              6.8.1-1.el8.elrepo                                              elrepo-kernel                                               34 M

Transaction Summary
=====================================================================================================================================================================================================================================================
Install  3 Packages

Total download size: 73 M
Installed size: 115 M
Downloading Packages:
(1/3): kernel-ml-6.8.1-1.el8.elrepo.x86_64.rpm                                                                                                                                                                       700 kB/s | 123 kB     00:00
(2/3): kernel-ml-modules-6.8.1-1.el8.elrepo.x86_64.rpm                                                                                                                                                               6.6 MB/s |  34 MB     00:05
(3/3): kernel-ml-core-6.8.1-1.el8.elrepo.x86_64.rpm                                                                                                                                                                  6.8 MB/s |  39 MB     00:05
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                                                                                                                                 12 MB/s |  73 MB     00:05
ELRepo.org Community Enterprise Linux Kernel Repository - el8                                                                                                                                                        1.6 MB/s | 1.7 kB     00:00
Importing GPG key 0xBAADAE52:
 Userid     : "elrepo.org (RPM Signing Key for elrepo.org) <secure@elrepo.org>"
 Fingerprint: 96C0 104F 6315 4731 1E0B B1AE 309B C305 BAAD AE52
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org
Key imported successfully
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                                                                                                                             1/1
  Installing       : kernel-ml-core-6.8.1-1.el8.elrepo.x86_64                                                                                                                                                                                    1/3
  Running scriptlet: kernel-ml-core-6.8.1-1.el8.elrepo.x86_64                                                                                                                                                                                    1/3
  Installing       : kernel-ml-modules-6.8.1-1.el8.elrepo.x86_64                                                                                                                                                                                 2/3
  Running scriptlet: kernel-ml-modules-6.8.1-1.el8.elrepo.x86_64                                                                                                                                                                                 2/3
  Installing       : kernel-ml-6.8.1-1.el8.elrepo.x86_64                                                                                                                                                                                         3/3
  Running scriptlet: kernel-ml-core-6.8.1-1.el8.elrepo.x86_64                                                                                                                                                                                    3/3
dracut: Disabling early microcode, because kernel does not support it. CONFIG_MICROCODE_[AMD|INTEL]!=y
dracut: Disabling early microcode, because kernel does not support it. CONFIG_MICROCODE_[AMD|INTEL]!=y

  Running scriptlet: kernel-ml-6.8.1-1.el8.elrepo.x86_64                                                                                                                                                                                         3/3
  Verifying        : kernel-ml-6.8.1-1.el8.elrepo.x86_64                                                                                                                                                                                         1/3
  Verifying        : kernel-ml-core-6.8.1-1.el8.elrepo.x86_64                                                                                                                                                                                    2/3
  Verifying        : kernel-ml-modules-6.8.1-1.el8.elrepo.x86_64                                                                                                                                                                                 3/3

Installed:
  kernel-ml-6.8.1-1.el8.elrepo.x86_64                                          kernel-ml-core-6.8.1-1.el8.elrepo.x86_64                                          kernel-ml-modules-6.8.1-1.el8.elrepo.x86_64

Complete!
```

* Назначаем новое ядро по умолчанию. Сначала обновляем конфигурацию загрузчика
``` bash
[vagrant@kernel-update ~]$ sudo grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
done
```

* Выбираем загрузку нового ядра по-умолчанию и перезагружаем ВМ
``` bash
[vagrant@kernel-update ~]$ sudo grub2-set-default 0
[vagrant@kernel-update ~]$ sudo reboot
Connection to 127.0.0.1 closed by remote host.
```

* Снова заходим и проверяем версию ядра. Видим, что установилась нужная
``` bash
root@[some_vm]:~# vagrant ssh
Last login: Sun Mar 17 16:17:49 2024 from 10.0.2.2
[vagrant@kernel-update ~]$ uname -r
6.8.1-1.el8.elrepo.x86_64
```

# Домашнее задание со * - сборка ядра из исходников
* Пересоздаем виртуальную машину и заходим в нее (делал через `vagrant destroy`). Копируем архив с исходником
``` bash
[vagrant@kernel-update ~] wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.8.1.tar.xz

--2024-03-26 16:15:39--  https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.8.1.tar.xz
Resolving cdn.kernel.org (cdn.kernel.org)... 146.75.117.176, 2a04:4e42:8d::432
Connecting to cdn.kernel.org (cdn.kernel.org)|146.75.117.176|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 142525520 (136M) [application/x-xz]
Saving to: ‘linux-6.8.1.tar.xz’

linux-6.8.1.tar.xz                                            100%[==============================================================================================================================================>] 135.92M  25.3MB/s    in 5.1s

2024-03-26 16:15:44 (26.6 MB/s) - ‘linux-6.8.1.tar.xz’ saved [142525520/142525520]
```

* Разархивируем архив и переходим в папку
``` bash
[vagrant@kernel-update ~]$ tar -xf linux-6.8.1.tar.xz

[vagrant@kernel-update ~]$ cd linux-6.8.1
```

* Далее необходим ряд действий, которые приведут к корректному завершению команды make install. Сначала нужно поменять конфигурацию ядра и убрать ссылку на предварительную загрузку сертификатов
``` bash
[vagrant@kernel-update linux-6.8.1]$ make menuconfig

Navigate to: 
Cryptographic API
    > Certificates for signature checking
       > X.509 certificates to be preloaded into the system blacklist keyring
 Change the 'certs/rhel.pem' string to '' and save .config
```

* Устанавливаем утилиту bc (binary calculator), без которой часть команд при сборке ядра не отработает
``` bash
[vagrant@kernel-update linux-6.8.1]$ sudo yum install bc

CentOS Stream 8 - AppStream                                                                                                                                                                                           18 kB/s | 4.4 kB     00:00
CentOS Stream 8 - BaseOS                                                                                                                                                                                              15 kB/s | 3.9 kB     00:00
CentOS Stream 8 - Extras                                                                                                                                                                                             5.6 kB/s | 2.9 kB     00:00
CentOS Stream 8 - Extras common packages                                                                                                                                                                             8.7 kB/s | 3.0 kB     00:00
Extra Packages for Enterprise Linux 8 - x86_64                                                                                                                                                                        47 kB/s |  33 kB     00:00
Extra Packages for Enterprise Linux 8 - Next - x86_64                                                                                                                                                                 71 kB/s |  35 kB     00:00
Dependencies resolved.
=====================================================================================================================================================================================================================================================
 Package                                                Architecture                                               Version                                                          Repository                                                  Size
=====================================================================================================================================================================================================================================================
Installing:
 bc                                                     x86_64                                                     1.07.1-5.el8                                                     baseos                                                     129 k

Transaction Summary
=====================================================================================================================================================================================================================================================
Install  1 Package

Total download size: 129 k
Installed size: 236 k
Is this ok [y/N]: y
Downloading Packages:
bc-1.07.1-5.el8.x86_64.rpm                                                                                                                                                                                           937 kB/s | 129 kB     00:00
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                                                                                                                                359 kB/s | 129 kB     00:00
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                                                                                                                             1/1
  Installing       : bc-1.07.1-5.el8.x86_64                                                                                                                                                                                                      1/1
  Running scriptlet: bc-1.07.1-5.el8.x86_64                                                                                                                                                                                                      1/1
  Verifying        : bc-1.07.1-5.el8.x86_64                                                                                                                                                                                                      1/1

Installed:
  bc-1.07.1-5.el8.x86_64

Complete!
```

* Устанавливаем инструмент pahole, который используется для генерации BTF (если, конечно, не планируется использовать BTF, то можно отключить опцию конфигурации ядра CONFIG_DEBUG_INFO_BTF, чтобы избежать ошибки). Он идет в составе пакета dwarves, для которого необходимо установить репозиторий PowerTools
* Создаем конфигурацию для репозитория со следующим содержимым
``` bash
[vagrant@kernel-update linux-6.8.1]$ sudo touch /etc/yum.repos.d/CentOS-PowerTools.repo
[vagrant@kernel-update linux-6.8.1]$ sudo vim /etc/yum.repos.d/CentOS-PowerTools.repo

[powertools]
name=CentOS-$releasever - PowerTools
baseurl=http://mirror.centos.org/centos/8-stream/PowerTools/x86_64/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
``` 

* Обновляем пакеты в системе
``` bash
[vagrant@kernel-update ~]$ sudo yum makecache
Repository powertools is listed more than once in the configuration
CentOS-8 - PowerTools                                                                                                                                                                                                7.7 MB/s | 4.9 MB     00:00
CentOS Stream 8 - AppStream                                                                                                                                                                                           22 kB/s | 4.4 kB     00:00
CentOS Stream 8 - BaseOS                                                                                                                                                                                              13 kB/s | 3.9 kB     00:00
CentOS Stream 8 - Extras                                                                                                                                                                                              40 kB/s | 2.9 kB     00:00
CentOS Stream 8 - Extras common packages                                                                                                                                                                              47 kB/s | 3.0 kB     00:00
Extra Packages for Enterprise Linux 8 - x86_64                                                                                                                                                                        46 kB/s |  22 kB     00:00
Extra Packages for Enterprise Linux 8 - Next - x86_64                                                                                                                                                                 72 kB/s |  35 kB     00:00
Metadata cache created.
``` 

* Устанавливаем dwarves
``` bash
[vagrant@kernel-update ~]$ sudo yum install dwarves
Repository powertools is listed more than once in the configuration
Last metadata expiration check: 0:00:31 ago on Wed Mar 27 09:20:27 2024.
Dependencies resolved.
=====================================================================================================================================================================================================================================================
 Package                                                      Architecture                                            Version                                                      Repository                                                   Size
=====================================================================================================================================================================================================================================================
Installing:
 dwarves                                                      x86_64                                                  1.22-1.el8                                                   powertools                                                  130 k
Installing dependencies:
 libdwarves1                                                  x86_64                                                  1.22-1.el8                                                   powertools                                                  176 k

Transaction Summary
=====================================================================================================================================================================================================================================================
Install  2 Packages

Total download size: 305 k
Installed size: 768 k
Is this ok [y/N]: y
Downloading Packages:
(1/2): dwarves-1.22-1.el8.x86_64.rpm                                                                                                                                                                                 518 kB/s | 130 kB     00:00
(2/2): libdwarves1-1.22-1.el8.x86_64.rpm                                                                                                                                                                             656 kB/s | 176 kB     00:00
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                                                                                                                                1.1 MB/s | 305 kB     00:00
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                                                                                                                             1/1
  Installing       : libdwarves1-1.22-1.el8.x86_64                                                                                                                                                                                               1/2
  Installing       : dwarves-1.22-1.el8.x86_64                                                                                                                                                                                                   2/2
  Running scriptlet: dwarves-1.22-1.el8.x86_64                                                                                                                                                                                                   2/2
  Verifying        : dwarves-1.22-1.el8.x86_64                                                                                                                                                                                                   1/2
  Verifying        : libdwarves1-1.22-1.el8.x86_64                                                                                                                                                                                               2/2

Installed:
  dwarves-1.22-1.el8.x86_64                                                                                               libdwarves1-1.22-1.el8.x86_64

Complete!
```

* Собираем ядро (использовал nohup для сборки в фоновом режиме, потому что очень долго собиралось)
``` bash
[vagrant@kernel-update linux-6.8.1]$ sudo nohup make -j$(nproc) &
[1] 4096
[vagrant@kernel-update linux-6.8.1]$ nohup: ignoring input and appending output to 'nohup.out'
```

* Необходимые файлы сгенерировались и были отправлены в каталог /boot. Однако в процессе сборки по непонятной причине один из файлов (`initramfs-0-rescue-d2be5e27c7a64f178cf54856141426cd.img`) не захотел копироваться, хотя места в каталоге было достаточно (удалил старое ядро). Предполагаю это может быть связано с нехваткой ресурсов, потому что они использовались на пределе. Но больше ресурсов выделить не мог внутри другой ВМ. Без этого файла система загрузилась, насколько понимаю он отвечает за восстановление системы после сбоев
``` bash
[vagrant@kernel-update linux-6.8.1]$ cat linux-6.8.1/nohup.out
  INSTALL /boot
cp: error writing '/boot/initramfs-0-rescue-d2be5e27c7a64f178cf54856141426cd.img': No space left on device
dracut: dracut: creation of /boot/initramfs-0-rescue-d2be5e27c7a64f178cf54856141426cd.img failed
make[1]: *** [arch/x86/Makefile:295: install] Error 1
make: *** [Makefile:240: __sub-make] Error 2

[vagrant@kernel-update linux-6.8.1]$]$ df -h
Filesystem                    Size  Used Avail Use% Mounted on
devtmpfs                      865M     0  865M   0% /dev
tmpfs                         884M     0  884M   0% /dev/shm
tmpfs                         884M   39M  845M   5% /run
tmpfs                         884M     0  884M   0% /sys/fs/cgroup
/dev/mapper/cs_centos8s-root  125G   30G   96G  24% /
/dev/sda1                    1014M  178M  837M  18% /boot
tmpfs                         177M     0  177M   0% /run/user/1000

[vagrant@kernel-update linux-6.8.1]$ ls -l /boot
total 135492
lrwxrwxrwx. 1 root root        22 Mar 27 14:10 System.map -> /boot/System.map-6.8.1
-rw-r--r--. 1 root root   6849738 Mar 27 14:10 System.map-6.8.1
drwxr-xr-x. 3 root root        17 Oct 17 04:12 efi
drwx------. 4 root root        83 Mar 27 15:00 grub2
-rw-------. 1 root root 104837213 Mar 27 14:13 initramfs-6.8.1.img
drwxr-xr-x. 3 root root        21 Oct 17 04:12 loader
lrwxrwxrwx. 1 root root        19 Mar 27 14:10 vmlinuz -> /boot/vmlinuz-6.8.1
-rw-r--r--. 1 root root  13521408 Mar 27 14:13 vmlinuz-0-rescue-d2be5e27c7a64f178cf54856141426cd
-rw-r--r--. 1 root root  13521408 Mar 27 14:10 vmlinuz-6.8.1
```
* Устанавливаем модули
``` bash
[vagrant@kernel-update linux-6.8.1]$ sudo make modules_install
  ...
  INSTALL /lib/modules/6.8.1/kernel/virt/lib/irqbypass.ko
  SIGN    /lib/modules/6.8.1/kernel/virt/lib/irqbypass.ko
  DEPMOD  /lib/modules/6.8.1
[vagrant@kernel-update linux-6.8.1]$
```

* Назначаем новое ядро по умолчанию. Сначала обновляем конфигурацию загрузчика
``` bash
[vagrant@kernel-update linux-6.8.1]$ cd ../
[vagrant@kernel-update ~]$ sudo grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
done
```

* Выбираем загрузку нового ядра по-умолчанию и перезагружаем ВМ
``` bash
[vagrant@kernel-update ~]$ sudo grub2-set-default 0
[vagrant@kernel-update ~]$ sudo reboot
Connection to 127.0.0.1 closed by remote host.
```

* Снова заходим и проверяем версию ядра. Видим, что установилась нужная
``` bash
root@n[some_vm]:~# vagrant ssh
Last login: Sun Mar 17 16:17:49 2024 from 10.0.2.2
[vagrant@kernel-update ~]$ uname -r
6.8.1
```
