# Домашнее задание - работа с LVM

## Подготовительные действия
* Для корректной синхронизации директории хоста и директории /vagrant создана новая директория /src на виртуальной машине, куда помещен Vagrantfile. Также добавлена секция синхронизации директорий в него:
``` bash
    config.vm.synced_folder "/src/", "/vagrant"
```
* Во время запуска возникла ошибка, которая решилась установкой соответствующего плагина
``` bash
Vagrant:
* Unknown configuration section 'vbguest'.

root@[some-vm]: vagrant plugin install vagrant-vbguest
```
* Создаем ВМ и подключаемся к ней
``` bash
root@[some-vm]: vagrant up && vagrant ssh
```

## Основные работы
* Уменьшить том под / до 8G - вывод команд представлен в файле [history_downgrade.txt](https://github.com/aleksandraryutkin/otus-linux/blob/homework_lvm/homework_lvm/history_downgrade.txt)
* Выделить том под /var в зеркало - вывод команд представлен в файле [history_var.txt](https://github.com/aleksandraryutkin/otus-linux/blob/homework_lvm/homework_lvm/history_var.txt)
* Выделить том под /home - вывод команд представлен в файле [history_home.txt](https://github.com/aleksandraryutkin/otus-linux/blob/homework_lvm/homework_lvm/history_home.txt)
* Работа со снапшотами - вывод команд представлен в файле [history_snapshot.txt](https://github.com/aleksandraryutkin/otus-linux/blob/homework_lvm/homework_lvm/history_snapshot.txt)
* Задание со звездочкой - вывод команд представлен в файле [history_opt.txt](https://github.com/aleksandraryutkin/otus-linux/blob/homework_lvm/homework_lvm/history_opt.txt)
