# Домашнее задание - Работа с PAM

## Подготовительные действия
* Создаем виртуальную машину на основе приложенного Vagrantfile с помощью команды:
``` bash
root@[some_vm]:/src# vagrant up
```

* Особенности созданного Vagrantfile:
  - Так как в данной лабораторной работе нам предстоит подключаться к нашей ВМ в неё добавлен дополнительный сетевой интерфейс: 
  ``` bash
  # Указываем IP-адрес для ВМ
  :ip => "192.168.57.10",
  ```
  
  - Для удобства, в параметрах SSH разрешена аутентификация пользователя по паролю: 
  ``` bash
   box.vm.provision "shell", inline: <<-SHELL
          #Разрешаем подключение пользователей по SSH с использованием пароля
          sed -i 's/^PasswordAuthentication.*$/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf
          #Перезапуск службы SSHD
          systemctl restart sshd.service
  	  SHELL
  ```
  Стоит обратить внимание, что изменение параметра происходит в другом файле, а не в том, в котором предложено в методичке, так как в указанном файле происходит определение возможности входа по паролю.  

  - Для возможности указывать время на созданной ВМ добавлен параметр отключения синхронизации времени между ВМ и хостом, иначе время тут же меняется обратно:
  ``` bash
        box.vm.provider "virtualbox" do |v|
        v.memory = boxconfig[:memory]
        v.cpus = boxconfig[:cpus]
        v.customize ["setextradata", :id, "VBoxInternal/Devices/VMMDev/0/Config/GetHostTimeDisabled", "1"]
  ```

## Основные работы

### Настройка запрета для всех пользователей (кроме группы Admin) логина в выходные дни (Праздники не учитываются)
* После подключение к ВМ переходим в root пользователя
``` bash
vagrant@pam:~$ sudo -i
root@pam:~#
```

* Создаём пользователя otusadm и otus:
``` bash
root@pam:~# useradd otusadm && sudo useradd otus
```

*  Создаём пользователям пароли (в методичке некорректный пример, у `passwd` нет флага `--stdin`, поэтому используется `chpasswd`):
``` bash
root@pam:~# echo "otusadm:Otus2022!" | chpasswd && echo "otus:Otus2022!" | chpasswd
```
Для примера мы указываем одинаковые пароли для пользователя otus и otusadm.  

* Создаём группу admin:
``` bash
root@pam:~# groupadd -f admin
```

* Добавляем пользователей vagrant,root и otusadm в группу admin:
``` bash
root@pam:~# usermod otusadm -a -G admin && usermod root -a -G admin && usermod vagrant -a -G admin  
```

* После создания пользователей, нужно проверить, что они могут подключаться по `SSH` к нашей ВМ с использованием заданного пароля. Для этого пытаемся подключиться с хостовой машины, сначала пользователь `otus`:  
``` bash
root@[some_vm]:/src# ssh otus@192.168.57.10
The authenticity of host '192.168.57.10 (192.168.57.10)' can't be established.
ED25519 key fingerprint is SHA256:r92nNNhxKBhAzwadEITe9n3PDCkq6QmwhSmktIGv4Hs.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.57.10' (ED25519) to the list of known hosts.
otus@192.168.57.10's password:
Welcome to Ubuntu 22.04.4 LTS (GNU/Linux 5.15.0-107-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Tue Jul 23 19:22:45 UTC 2024

  System load:  0.18              Processes:               104
  Usage of /:   5.3% of 38.70GB   Users logged in:         0
  Memory usage: 20%               IPv4 address for enp0s3: 10.0.2.15
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

37 updates can be applied immediately.
25 of these updates are standard security updates.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status



The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

Could not chdir to home directory /home/otus: No such file or directory
$ whoami
otus
$
Connection to 192.168.57.10 closed.
```

* Теперь подключаемся от пользователя `otusadm`:  
``` bash
root@[some_vm]:/src# ssh otusadm@192.168.57.10
otusadm@192.168.57.10's password:
Welcome to Ubuntu 22.04.4 LTS (GNU/Linux 5.15.0-107-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Tue Jul 23 19:23:54 UTC 2024

  System load:  0.13              Processes:               105
  Usage of /:   5.4% of 38.70GB   Users logged in:         0
  Memory usage: 20%               IPv4 address for enp0s3: 10.0.2.15
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

37 updates can be applied immediately.
25 of these updates are standard security updates.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status



The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

Could not chdir to home directory /home/otusadm: No such file or directory
$ whoami
otusadm
$
Connection to 192.168.57.10 closed.
```

* Настроим правило, по которому все пользователи кроме тех, что указаны в группе admin не смогут подключаться в выходные дни. Проверим, что пользователи root, vagrant и otusadm есть в группе admin:
``` bash
root@pam:~#  cat /etc/group | grep admin
admin:x:118:otusadm,root,vagrant
```
Информация о группах и пользователях в них хранится в файле /etc/group, пользователи указываются через запятую.  

* Выберем метод PAM-аутентификации на основе небольшого скрипта контроля и использования модуля pam_exec. Создадим файл-скрипт `/usr/local/bin/login.sh`:
``` bash
root@pam:~# nano /usr/local/bin/login.sh

#!/bin/bash
#Первое условие: если день недели суббота или воскресенье
if [ $(date +%a) = "Sat" ] || [ $(date +%a) = "Sun" ]; then
 #Второе условие: входит ли пользователь в группу admin
 if getent group admin | grep -qw "$PAM_USER"; then
        #Если пользователь входит в группу admin, то он может подключиться
        exit 0
      else
        #Иначе ошибка (не сможет подключиться)
        exit 1
    fi
  #Если день не выходной, то подключиться может любой пользователь
  else
    exit 0
fi
```
В скрипте подписаны все условия. Скрипт работает по принципу: если сегодня суббота или воскресенье, то нужно проверить, входит ли пользователь в группу admin, если не входит — то подключение запрещено. При любых других вариантах подключение разрешено. 

* Добавим права на исполнение файла:  
``` bash
root@pam:~# chmod +x /usr/local/bin/login.sh
```

* Укажем в файле `/etc/pam.d/sshd` модуль `pam_exec` и наш скрипт:
``` bash

```

* Установим дату в выходной день:
``` bash
root@pam:~# date 082712302022.00
Sat Aug 27 12:30:00 UTC 2022
```

* Попробуем подключиться пользовтаелем `otus` (которого нет в группе `admin`)
``` bash
root@[some_vm]:/src# ssh otus@192.168.57.10
otus@192.168.57.10's password:
Permission denied, please try again.
```
Видим, что возвращается ошибка. Значит настройки работают корректно на ограничение входа пользователей

* Попробуем подключиться пользователем `otusadm`:
``` bash
root@[some_vm]:/src# ssh otusadm@192.168.57.10
otusadm@192.168.57.10's password:
Welcome to Ubuntu 22.04.4 LTS (GNU/Linux 5.15.0-116-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Tue Jul 23 19:50:50 UTC 2024

  System load:  0.65              Processes:               105
  Usage of /:   6.3% of 38.70GB   Users logged in:         0
  Memory usage: 20%               IPv4 address for enp0s3: 10.0.2.15
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

12 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status



The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

Last login: Tue Jul 23 19:23:55 2024 from 192.168.57.1
Could not chdir to home directory /home/otusadm: No such file or directory
$
```
Подключение прошло успешно, пользователи группы admin могут подключаться в любое время.

* Зададим дату в будний день:
``` bash
root@pam:~# date -s "2024-07-17 14:30:00"
Wed Jul 17 14:30:00 UTC 2024
```

* Попробуем снова подключиться пользователем `otus`
``` bash
root@[some_vm]:/src# ssh otus@192.168.57.10
otus@192.168.57.10's password:
Welcome to Ubuntu 22.04.4 LTS (GNU/Linux 5.15.0-116-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Tue Jul 23 19:50:50 UTC 2024

  System load:  0.65              Processes:               105
  Usage of /:   6.3% of 38.70GB   Users logged in:         0
  Memory usage: 20%               IPv4 address for enp0s3: 10.0.2.15
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

12 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status



The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

Last login: Tue Jul 23 19:30:17 2024 from 192.168.57.1
Could not chdir to home directory /home/otus: No such file or directory
$
```  
Подключение прошло, из чего можно сделать вывод, что пользователь otus может подключаться к ВМ только в будние дни.
