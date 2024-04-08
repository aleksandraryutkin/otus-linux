# Домашнее задание - написать роль ansible для установки веб-сервера nginx

* После копирования репозитория запускать ansible и vagrant нужно из папки `homework-ansible` в одноименной ветке
* Сам я запускал playbook для виртуальной машины из VKcloud, в моем случае файл inventory выглядел так 
``` bash
[web]
nginx ansible_host=[external_IP] ansible_ssh_private_key_file=~/.ssh/id_rsa
```
И `remote_user` в `ansible.cfg` был `ubuntu`

* Запуск осуществляется такой командой
``` bash
ansible-playbook main.yml
```

* Вывод команды
``` bash
PLAY [NGINX install] *******************************************************************

TASK [Gathering Facts] *****************************************************************
ok: [nginx]

TASK [Include the homework-ansible role] ***********************************************

TASK [homework-ansible : update] *******************************************************
changed: [nginx]

TASK [homework-ansible : NGINX | Install NGINX] ****************************************
changed: [nginx]

TASK [homework-ansible : NGINX | Create NGINX config file from template] ***************
changed: [nginx]

RUNNING HANDLER [homework-ansible : restart nginx] *************************************
changed: [nginx]

RUNNING HANDLER [homework-ansible : reload nginx] **************************************
changed: [nginx]

PLAY RECAP *****************************************************************************
nginx                      : ok=6    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

* Копирование конфига nginx сделал в папку `/etc/nginx`, потому что туда по умолчанию копируются конфигурационные файлы nginx при установке
* После установки проверил curl'ом
``` bash
curl http://[external_IP]:8080

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

* По vagrant машину nginx тоже разворачивал для проверки Vagrantfile. Сначала пробовал запустить вместе с предыдущей машиной kernel-update, но не получилось из-за настроек подключения к ВМ. В итоге сделал `halt` и потом поднял ВМ nginx. Несколько сумбурно получилось, но с ходу не разобрался, как обе ВМ одним конфигом проверить по запуску
``` bash
root@[some-vm]:~# vagrant status
Current machine states:

kernel-update             running (virtualbox)

The VM is running. To stop this VM, you can run `vagrant halt` to
shut it down forcefully, or you can run `vagrant suspend` to simply
suspend the virtual machine. In either case, to restart it again,
simply run `vagrant up`.

root@[some-vm]:~# nano Vagrantfile # прописал конфигурацию ВМ nginx, удалив конфигурацию kernel-update

root@[some-vm]:~# vagrant up # запустил, но не прошла проверка коннекта к ВМ
Bringing machine 'nginx' up with 'virtualbox' provider...
==> nginx: Box 'generic/ubuntu2204' could not be found. Attempting to find and install...
    nginx: Box Provider: virtualbox
    nginx: Box Version: >= 0
==> nginx: Loading metadata for box 'generic/ubuntu2204'
    nginx: URL: https://vagrantcloud.com/api/v2/vagrant/generic/ubuntu2204
==> nginx: Adding box 'generic/ubuntu2204' (v4.3.12) for provider: virtualbox (amd64)
    nginx: Downloading: https://vagrantcloud.com/generic/boxes/ubuntu2204/versions/4.3.12/providers/virtualbox/amd64/vagrant.box
    nginx: Calculating and comparing box checksum...
==> nginx: Successfully added box 'generic/ubuntu2204' (v4.3.12) for 'virtualbox (amd64)'!
==> nginx: Importing base box 'generic/ubuntu2204'...
==> nginx: Matching MAC address for NAT networking...
==> nginx: Checking if box 'generic/ubuntu2204' version '4.3.12' is up to date...
==> nginx: Setting the name of the VM: root_nginx_1711877255239_48140
==> nginx: Fixed port collision for 22 => 2222. Now on port 2200.
==> nginx: Clearing any previously set network interfaces...
==> nginx: Preparing network interfaces based on configuration...
    nginx: Adapter 1: nat
    nginx: Adapter 2: intnet
==> nginx: Forwarding ports...
    nginx: 22 (guest) => 2200 (host) (adapter 1)
==> nginx: Running 'pre-boot' VM customizations...
==> nginx: Booting VM...
==> nginx: Waiting for machine to boot. This may take a few minutes...
    nginx: SSH address: 127.0.0.1:2200
    nginx: SSH username: vagrant
    nginx: SSH auth method: private key
    nginx: Warning: Connection reset. Retrying...
    nginx: Warning: Remote connection disconnect. Retrying...
    nginx: Warning: Connection reset. Retrying...
    nginx: Warning: Remote connection disconnect. Retrying...
    nginx: Warning: Connection reset. Retrying...
    nginx: Warning: Remote connection disconnect. Retrying...
    nginx: Warning: Connection reset. Retrying...
    nginx: Warning: Remote connection disconnect. Retrying...
    nginx: Warning: Connection reset. Retrying...
    nginx: Warning: Remote connection disconnect. Retrying...
    nginx: Warning: Connection reset. Retrying...
    nginx: Warning: Remote connection disconnect. Retrying...
    nginx: Warning: Connection reset. Retrying...
    nginx: Warning: Remote connection disconnect. Retrying...
    nginx: Warning: Connection reset. Retrying...
    nginx: Warning: Connection reset. Retrying...
    nginx: Warning: Remote connection disconnect. Retrying...
    nginx: Warning: Connection reset. Retrying...
    nginx: Warning: Remote connection disconnect. Retrying...
^C==> nginx: Waiting for cleanup before exiting...
    nginx: Warning: Authentication failure. Retrying...
Vagrant exited after cleanup due to external interrupt.

root@[some-vm]:~# nano Vagrantfile # вернул конфигурацию kernel-update

root@[some-vm]:~# vagrant halt

root@[some-vm]:~# vagrant status
Current machine states:

kernel-update             aborted (virtualbox)

The VM is in an aborted state. This means that it was abruptly
stopped without properly closing the session. Run `vagrant up`
to resume this virtual machine. If any problems persist, you may
have to destroy and restart the virtual machine.

root@[some-vm]:~# nano Vagrantfile # вернул конфигурацию nginx

root@[some-vm]:~# vagrant up
Bringing machine 'nginx' up with 'virtualbox' provider...
==> nginx: Checking if box 'generic/ubuntu2204' version '4.3.12' is up to date...
==> nginx: Running provisioner: shell...
    nginx: Running: inline script

root@[some-vm]:~# vagrant status
Current machine states:

nginx                     running (virtualbox)

The VM is running. To stop this VM, you can run `vagrant halt` to
shut it down forcefully, or you can run `vagrant suspend` to simply
suspend the virtual machine. In either case, to restart it again,
simply run `vagrant up`.

root@[some-vm]:~# vagrant ssh
vagrant@ubuntu2204:~$
vagrant@ubuntu2204:~$
vagrant@ubuntu2204:~$ exit
logout

root@[some-vm]:~# vagrant ssh-config
Host nginx
  HostName 127.0.0.1
  User vagrant
  Port 2200
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile /root/.vagrant.d/insecure_private_keys/vagrant.key.ed25519
  IdentityFile /root/.vagrant.d/insecure_private_keys/vagrant.key.rsa
  IdentitiesOnly yes
  LogLevel FATAL
  PubkeyAcceptedKeyTypes +ssh-rsa
  HostKeyAlgorithms +ssh-rsa
```
