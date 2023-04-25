1. Цель домашнего задания - Научиться самостоятельно развернуть сервис NFS и подключить к нему клиента
1.1 Задача - `vagrant up` должен поднимать 2 настроенных виртуальных машины (сервер NFS и клиента) без дополнительных ручных действий;
	- на сервере NFS должна быть подготовлена и экспортирована директория; 
	- в экспортированной директории должна быть поддиректория с именем "upload" с правами на запись в неё; 
	- экспортированная директория должна автоматически монтироваться на клиенте при старте виртуальной машины (systemd, autofs или fstab -  любым способом); 
	- монтирование и работа NFS на клиенте должна быть организована с использованием NFSv3 по протоколу UDP; 
	- firewall должен быть включен и настроен как на клиенте, так и на сервере.
1.2. Описание каталогов и файлов в репозитории - 
	1. README.md - описание выполнения урока.
	2. Vagrantfile - файл для ручного ввода команд.
	3. Vagrantfile.script - файл для запуска скриптов.
	4. nfsc_script.sh и nfsc_script.sh - скрипты для сервера и клиента.
	5. homework.log и time_homework_log - результат работы.
1.3. Особенности проектирования и реализации решения, в т.ч.  существенные отличия от того, что написано выше.

2. Настраиваем сервер NFS
2.1 script --timing=time_homework_log homework.log
2.2. vagrant up
2.3. vagrant ssh nfss
2.4. sudo -i
2.5. yum install -y nfs-utils // Устанавливаем пакеты для организации NFS-сервера
2.6. systemctl enable firewalld --now
2.7. firewall-cmd --add-service="nfs3" --add-service="rpc-bind" --add-service="mountd" --permanent
2.8. firewall-cmd --reload
2.9. systemctl enable nfs --now
2.10. ss -tnplu
2.11. mkdir -p /srv/share/upload
	  chown -R nfsnobody:nfsnobody /srv/share
	  chmod 0777 /srv/share/upload
2.12. cat << EOF > /etc/exports 
	/srv/share 192.168.56.11/24(rw,sync,no_root_squash,no_all_squash)
	EOF
2.13. exportfs -r
2.14. exportfs -s

3. Настраиваем клиент NFS
3.1. vagrant ssh nfsc
3.2. sudo -i
3.3. yum install -y nfs-utils
3.4. echo "192.168.56.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab
3.5. systemctl daemon-reload
3.6. systemctl restart remote-fs.target
3.7. cd /mnt
3.8. mount | grep mnt

4. Проверка работоспособности:
4.1. Заходим на сервер.
4.2. Заходим в каталог `/srv/share/upload` - cd /srv/share/upload
4.3. Создаём тестовый файл - touch check_file
4.4. Заходим на клиент.
4.5. Заходим в каталог `/mnt/upload` - cd /mnt/upload
4.6. Создаём тестовый файл - touch client_file
4.7. Проверяем, что файл успешно создан - ls -la /mnt/upload
4.8. Проверяем сервер: 
	1. shutdown -r now
	2. vagrant ssh nfss
	3. ls -la /srv/share/upload/
	4. Проверяем статус сервера NFS - systemctl status nfs
	5. Проверяем статус firewall - systemctl status firewalld
	6. Проверяем экспорты - exportfs -s
	7. Проверяем работу RPC - showmount -a 192.168.56.10
4.9. Проверяем клиент:
	1. shutdown -r now
	2. vagrant ssh nfss
	3. Проверяем работу RPC - showmount -a 192.168.56.10
	4. Заходим в каталог - cd /mnt/upload
	5. Проверяем статус монтирования - mount | grep mnt
	6. Проверяем наличие ранее созданных файлов - ls -la
	7. Создаём тестовый файл - touch final_check
	8. Проверяем, что файл успешно создан - ls -la

5. Выходим из записи команд и проверяем успешность - scriptreplay --timing=time_homework_log homework.log -d 20
6. Заменяем файл Vagrantfile на Vagrantfile.script, удаляем созданные машины и запускаем создание виртуальных машин в автоматическом режиме.
7. Все