# Пользователи и группы. Авторизация и аутентификация

## Выполнение лабораторной работы

1. Запускаем для тестов виртуалку, подключаемся и переходим в рута.  

### Создаем пользователей

1. Создаем пользователей user1 и user2.  
	```bash
	[root@otuslinux vagrant]# useradd -m -s /bin/bash user1
	[root@otuslinux vagrant]# useradd -m -s /bin/bash user2 
	```
2. Посмотрим по ним информацию: для user1 командой id, а затем общую из passwd. Видим, что пользователи получили uid 1002 и 1003 из области юзеров (>1000).  
	```bash
	[root@otuslinux vagrant]# id user1
	uid=1002(user1) gid=1003(user1) groups=1003(user1)
	[root@otuslinux vagrant]# cat /etc/passwd
	...
	vagrant:x:1000:1000:vagrant:/home/vagrant:/bin/bash
	test_user:x:1001:1001::/home/test_user:/bin/bash
	user1:x:1002:1003::/home/user1:/bin/bash
	user2:x:1003:1004::/home/user2:/bin/bash
	```
3. Опция -m сразу создает для пользователя домашнюю директорию, а опцией -s указываем, какая оболочка будет загружена для пользователя при входе.  

### Создаем группу и добавляем туда пользователей

1. Создаем группу admins и добавляем пользователей user1 и user2.  
	```bash
	[root@otuslinux vagrant]# groupadd admins
	[root@otuslinux vagrant]# gpasswd -a user1 admins
	Adding user user1 to group admins
	[root@otuslinux vagrant]# gpasswd -a user2 admins
	Adding user user2 to group admins
	```
2. Проверим, что пользователи кроме своей группы теперь включены и в группу admins.  
	```bash
	[root@otuslinux vagrant]# id user1
	uid=1002(user1) gid=1003(user1) groups=1003(user1),1005(admins)
	[root@otuslinux vagrant]# id user2
	uid=1003(user2) gid=1004(user2) groups=1004(user2),1005(admins)
	```
3. Cделаем группу admins основной для user1 и проверим результат  
	```bash
	[root@otuslinux vagrant]# usermod -g admins user1
	[root@otuslinux vagrant]# id user1
	uid=1002(user1) gid=1005(admins) groups=1005(admins)
	```

### Создать каталог от рута и дать права группе admins туда писать

1. Создаем каталог и посмотрим созданные для него права по умолчанию.  
	```bash
	[root@otuslinux vagrant]# mkdir /opt/upload
	[root@otuslinux vagrant]# ls -l /opt
	total 0
	drwxr-xr-x. 2 root root 6 Apr 16 17:41 upload
	```
2. Устанавливаем для каталога права на чтение, запись и выполнение для владельца каталога (7) и для группы (7), а также полностью запрещаем доступ к каталогу для всех остальных пользователей (0). Просматриваем и убеждаемся, что получили желаемый результат.  
	```bash
	[root@otuslinux vagrant]# chmod 770 /opt/upload
	[root@otuslinux vagrant]# ls -l /opt
	total 0
	drwxrwx---. 2 root root 6 Apr 16 17:41 upload
	```
3. Изменяем группу, которой даны права на данный каталог и проверяем результат - видим группу admins.  
	```bash
	[root@otuslinux vagrant]# chgrp admins /opt/upload
	[root@otuslinux vagrant]# ls -l /opt
	total 0
	drwxrwx---. 2 root admins 6 Apr 16 17:41 upload
	```
4. Создаем в каталоге /opt/upload/ файл file1 под пользователем user1
	```bash
	[root@otuslinux vagrant]# su - user1
	[user1@otuslinux ~]$ touch /opt/upload/file1
	[user1@otuslinux ~]$ exit
	logout
	```
5. Создаем в каталоге /opt/upload/ файл file2 под пользователем user2
	```bash
	[root@otuslinux vagrant]# su - user2
	[user2@otuslinux ~]$ touch /opt/upload/file2
	[user2@otuslinux ~]$ exit
	logout
	```
6. Проверим созданные файлы. Видим, что file1 создан от группы admins, т.к. это группа по умолчанию для пользователя user1, а file2 создан от группы user2, т.к. это  группа по умолчанию пользователя user2.  
	```bash
	[root@otuslinux vagrant]# ls -l /opt/upload/
	total 0
	-rw-r--r--. 1 user1 admins 0 Apr 16 17:56 file1
	-rw-rw-r--. 1 user2 user2  0 Apr 16 17:57 file2
	```
7. Теперь снова зайдем под пользователем user2 и выполним команду смены текущей группы для пользователя ```newgrp admins```. После этого создадим новый файл file3 и затем проверим результат - видим, что теперь файл file3 создан от группы admins.
	```bash
	[root@otuslinux vagrant]# su - user2
	Last login: Thu Apr 16 17:56:55 UTC 2020 on pts/0
	[user2@otuslinux ~]$ newgrp admins
	[user2@otuslinux ~]$ touch /opt/upload/file3
	[user2@otuslinux ~]$ exit
	exit
	[user2@otuslinux ~]$ exit
	logout
	[root@otuslinux vagrant]# ls -l /opt/upload/
	total 0
	-rw-r--r--. 1 user1 admins 0 Apr 16 17:56 file1
	-rw-rw-r--. 1 user2 user2  0 Apr 16 17:57 file2
	-rw-r--r--. 1 user2 admins 0 Apr 16 18:10 file3
	```

### Создать пользователя user3 и дать ему права писать в /opt/uploads

1. Создадим пользователя user3, посмотрим инфо о нем  
	```bash
	[root@otuslinux vagrant]# useradd -m -s /bin/bash user3
	[root@otuslinux vagrant]# id user3
	uid=1004(user3) gid=1006(user3) groups=1006(user3)
	```
2. Попробуем записать из под него файл file4 в /opt/uploads. Получили ошибку, т.к. он не входит в группу admins  
	```bash
	[user1@otuslinux ~]$ touch /opt/upload/file1
	[root@otuslinux vagrant]# su - user3
	[user3@otuslinux ~]$ touch /opt/upload/file4
	touch: cannot touch ‘/opt/upload/file4’: Permission denied
	```
3. Посмотрим с помощью getfacl права на каталог /opt/upload  
	```bash
	[root@otuslinux vagrant]# getfacl /opt/upload
	getfacl: Removing leading '/' from absolute path names
	# file: opt/upload
	# owner: root
	# group: admins
	user::rwx
	group::rwx
	other::---
	```
4. Добавим с момощью setfacl права на запись в каталог /opt/upload. Опция -m - изменение прав доступа к каталогу и опция -u - указание пользователя и его прав доступа.  После этого снова проверим права на католог. Видим, что добавились полные права (rwx) пользователю user3.  
	```bash
	[root@otuslinux vagrant]# setfacl -m u:user3:rwx /opt/upload
	[root@otuslinux vagrant]# getfacl /opt/upload
	getfacl: Removing leading '/' from absolute path names
	# file: opt/upload
	# owner: root
	# group: admins
	user::rwx
	user:user3:rwx
	group::rwx
	mask::rwx
	other::---
	```
5. Теперь снова зайдем под пользователем user3 и попробуем создать файл user3_file.  
	```bash
	[root@otuslinux vagrant]# su - user3
	Last login: Sun Apr 19 08:51:37 UTC 2020 on pts/0
	[user3@otuslinux ~]$ touch /opt/upload/user3_file
	[user3@otuslinux ~]$ ls -l /opt/upload/user3_file
	-rw-rw-r--. 1 user3 user3 0 Apr 19 09:17 /opt/upload/user3_file
	```

### Установить GUID флаг на директорию /opt/uploads

1. Перед внесением изменений проверим текущие права /opt/upload  
	```bash
	[root@otuslinux vagrant]# ls -l /opt/
	total 0
	drwxrwx---+ 2 root admins 63 Apr 19 09:17 upload
	```
2. Установим SGID на каталог /opt/upload. (Примечание - _текущие версии Linux игнорируют установку SUID на диреторию, также игнорируется выставление SUID на shell скрипт_)  
	```bash
	[root@otuslinux vagrant]# chmod g+s /opt/upload
	[root@otuslinux vagrant]# ls -l /opt/
	total 0
	drwxrws---+ 2 root admins 63 Apr 19 09:17 upload
	```
3. Теперь снова зайдем под пользователем user3 и попробуем создать файл user3_file2  
	```bash
	[root@otuslinux vagrant]# su - user3
	Last login: Sun Apr 19 09:14:03 UTC 2020 on pts/0
	[user3@otuslinux ~]$ touch /opt/upload/user3_file2
	[user3@otuslinux ~]$ ls -l /opt/upload/user3_file2
	-rw-rw-r--. 1 user3 admins 0 Apr 19 12:06 /opt/upload/user3_file2
	```
4. Сравним права на последние созданные файлы: user3_file и user3_file2. Видим, что последний файл user3_file2 создан от группы admins. На изменение группы при создании файла повлиял установленный SGID на каталог /opt/upload. После этого все создаваемые файлы в данном каталоге будут наследовать GID директории. А из следующей команды ```ls -l /opt/``` мы видим, что на каталог /opt/upload установлен GID admins.  
	```bash
	[user3@otuslinux ~]$ ls -l /opt/upload/
	total 0
	-rw-r--r--. 1 user1 admins 0 Apr 16 17:56 file1
	-rw-rw-r--. 1 user2 user2  0 Apr 16 17:57 file2
	-rw-r--r--. 1 user2 admins 0 Apr 16 18:10 file3
	-rw-rw-r--. 1 user3 user3  0 Apr 19 09:17 user3_file
	-rw-rw-r--. 1 user3 admins 0 Apr 19 12:06 user3_file2
	[user3@otuslinux ~]$ ls -l /opt/
	total 0
	drwxrws---+ 2 root admins 82 Apr 19 12:06 upload
	```

### Установить  SUID  флаг на выполняемый файл

1. Пытаемся вывести файл shadow под пользователем user3  
	```bash
	[user3@otuslinux ~]$ cat /etc/shadow
	cat: /etc/shadow: Permission denied
	```
2. Теперь установим suid на /bin/cat (Примечание - _текущие версии Linux игнорируют выставление SUID на shell скрипт (проверка на shebang)_)  
	```bash
	[root@otuslinux vagrant]# ls -l /bin/cat
	-rwxr-xr-x. 1 root root 54160 Oct 30  2018 /bin/cat
	[root@otuslinux vagrant]# chmod u+s /bin/cat
	[root@otuslinux vagrant]# ls -l /bin/cat
	-rwsr-xr-x. 1 root root 54160 Oct 30  2018 /bin/cat
	```
3. Теперь снова попытаемся вывести файл shadow под пользователем user3. Видим, что теперь исполняемый файл /bin/cat получил доступ к файлу /etc/shadow. Это связано с тем, что с установленным suid файл /bin/cat будет исполнятся с UID/GID владельца файла, а в пункте 2 видно, что владельцем файла является root.  
	```bash
	[root@otuslinux vagrant]# su - user3
	Last login: Sun Apr 19 12:05:51 UTC 2020 on pts/0
	[user3@otuslinux ~]$ cat /etc/shadow
	root:$1$QDyPlph/$oaAX/xNRf3aiW3l27NIUA/::0:99999:7:::
	...
	vagrant:$1$C93uBBDg$pqzqtS3a9llsERlv..YKs1::0:99999:7:::
	test_user:$1$l0NXv/Qs$MaqMaxYxojfeS7C26stOj.:18368:0:99999:7:::
	user1:!!:18368:0:99999:7:::
	user2:!!:18368:0:99999:7:::
	user3:!!:18371:0:99999:7:::
	```

###  Сменить владельца  /opt/uploads  на user3 и добавить sticky bit

1. Проверим права доступа к каталогу /opt/upload, затем изменим владельца на user3 и установим на каталог sticky bit, означающий, что удалить файл из этого каталога может только владелец файла или владелец каталога или суперпользователь. Посмотрим на все сделанные изменения командой ```ls -l /opt``` - видим, что владельцем каталога стал пользователь user3 и установлен sticky bit - T.  
	```bash
	[root@otuslinux vagrant]# ls -l /opt
	total 0
	drwxrws---+ 2 root admins 82 Apr 19 12:06 upload
	[root@otuslinux vagrant]# chown user3 /opt/upload
	[root@otuslinux vagrant]# chmod +t /opt/upload
	[root@otuslinux vagrant]# ls -l /opt
	total 0
	drwxrws--T+ 2 user3 admins 82 Apr 19 12:06 upload
	```
2. Создадим файл user1_file_test под пользователем user1 и выведем информацию о правах доступа  
	```bash
	[root@otuslinux vagrant]# su - user1
	Last login: Thu Apr 16 17:56:03 UTC 2020 on pts/0
	[user1@otuslinux ~]$ touch /opt/upload/user1_file_test
	[user1@otuslinux ~]$ ls -l /opt/upload/user1_file_test
	-rw-r--r--. 1 user1 admins 0 Apr 19 14:13 /opt/upload/user1_file_test
	```
3. Зайдем пользователем user3 и попытаемся удалить файл user1_file_test, созданный пользователем user1. Удаление прошло успешно, т.к. пользователь user3 у нас стал владельцем каталога /opt/upload (п.1), а установленный на каталог Sticky bit, позволяет удалить файл из этого каталога владелецу файла, владелецу каталога или суперпользователю.  
	```bash
	[root@otuslinux vagrant]# su - user3
	Last login: Sun Apr 19 14:17:45 UTC 2020 on pts/0
	[user3@otuslinux ~]$ rm -f  /opt/upload/user1_file_test
	[user3@otuslinux ~]$ ls -l /opt/upload/
	total 0
	-rw-r--r--. 1 user1 admins 0 Apr 16 17:56 file1
	-rw-rw-r--. 1 user2 user2  0 Apr 16 17:57 file2
	-rw-r--r--. 1 user2 admins 0 Apr 16 18:10 file3
	-rw-rw-r--. 1 user3 user3  0 Apr 19 09:17 user3_file
	-rw-rw-r--. 1 user3 admins 0 Apr 19 12:06 user3_file2
	```
4. Теперь снова зайдем пользователем user1, создадим файл user1_file_test и попытаемся удалить файл этим же пользователем user1. В результате выполнения всех операций видим, что все прошло успешно.  
	```bash
	[root@otuslinux vagrant]# su - user1
	Last login: Sun Apr 19 14:13:20 UTC 2020 on pts/0
	[user1@otuslinux ~]$ touch /opt/upload/user1_file_test
	[user1@otuslinux ~]$ ls -l /opt/upload/
	total 0
	-rw-r--r--. 1 user1 admins 0 Apr 16 17:56 file1
	-rw-rw-r--. 1 user2 user2  0 Apr 16 17:57 file2
	-rw-r--r--. 1 user2 admins 0 Apr 16 18:10 file3
	-rw-r--r--. 1 user1 admins 0 Apr 19 14:27 user1_file_test
	-rw-rw-r--. 1 user3 user3  0 Apr 19 09:17 user3_file
	-rw-rw-r--. 1 user3 admins 0 Apr 19 12:06 user3_file2
	[user1@otuslinux ~]$ rm -f  /opt/upload/user1_file_test
	[user1@otuslinux ~]$ ls -l /opt/upload/
	total 0
	-rw-r--r--. 1 user1 admins 0 Apr 16 17:56 file1
	-rw-rw-r--. 1 user2 user2  0 Apr 16 17:57 file2
	-rw-r--r--. 1 user2 admins 0 Apr 16 18:10 file3
	-rw-rw-r--. 1 user3 user3  0 Apr 19 09:17 user3_file
	-rw-rw-r--. 1 user3 admins 0 Apr 19 12:06 user3_file2
	```

### Записи в sudoers

1. Попробуем из под user3 выполнить ```sudo ls -l /root```. Выполнение не получилось-требует пароль  
	```bash
	[user3@otuslinux ~]$ sudo ls -l /root

	We trust you have received the usual lecture from the local System
	Administrator. It usually boils down to these three things:

	    #1) Respect the privacy of others.
	    #2) Think before you type.
	    #3) With great power comes great responsibility.

	[sudo] password for user3: 
	```
2. Создадим файл /etc/sudoers.d/user3, в котором пропишем ```user3	ALL=NOPASSWD:/bin/ls```, означающее, что пользователям группы user3 везде разрешено выполнение команды /bin/ls без ввода пароля  
	```bash
	[root@otuslinux vagrant]# vi /etc/sudoers.d/user3
	[root@otuslinux vagrant]# cat /etc/sudoers.d/user3
	user3	ALL=NOPASSWD:/bin/ls
	```
3. Снова попробуем из под user3 выполнить ```sudo ls -l /root```. Выполнено успешно без запроса пароля  
	```bash
	[user3@otuslinux ~]$ sudo ls -l /root
	total 16
	-rw-------. 1 root root 5570 Jun  1  2019 anaconda-ks.cfg
	-rw-------. 1 root root 5300 Jun  1  2019 original-ks.cfg
	```
4. Добавим запись в /etc/sudoers.d/admins разрешающий пользователям группы admins любые команды под sudo только с вводом пароля  
	```bash
	[root@otuslinux vagrant]# vi /etc/sudoers.d/admins
	[root@otuslinux vagrant]# cat /etc/sudoers.d/admins
	admins	ALL = PASSWD: ALL
	```
5. Теперь попробуем из под user1, находящегося в группе admins, вывести содержимое каталога /opt/upload/   
	```bash
	[root@otuslinux vagrant]# su - user1
	Last login: Sun Apr 19 14:27:16 UTC 2020 on pts/0
	[user1@otuslinux ~]$ ls -l /opt/upload/
	total 0
	-rw-r--r--. 1 user1 admins 0 Apr 16 17:56 file1
	-rw-rw-r--. 1 user2 user2  0 Apr 16 17:57 file2
	-rw-r--r--. 1 user2 admins 0 Apr 16 18:10 file3
	-rw-rw-r--. 1 user3 user3  0 Apr 19 09:17 user3_file
	-rw-rw-r--. 1 user3 admins 0 Apr 19 12:06 user3_file2
	```
6. Предыдущая операция успешно выполнена, но если эту же операцию выполнить под sudo, то мы увидим запрос пароля, т.к. установили правило запроса пароля под sudo на все команды от пользователей группы admins.  
	```bash
	[user1@otuslinux ~]$ sudo ls -l /opt/upload/

	We trust you have received the usual lecture from the local System
	Administrator. It usually boils down to these three things:

	    #1) Respect the privacy of others.
	    #2) Think before you type.
	    #3) With great power comes great responsibility.

	[sudo] password for user1: 
	```

## Выполнение ДЗ

### Запретить всем пользователям, кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников

1. Создадим скрипт pam_date_check.sh, проверяющий группу пользователя и день недели для определения возможности входа данного пользователя. Скрипт будет вызываться для осуществления проверки PAM-модулем pam_script.so. Скрипт использует переменную PAM_USER для определения группы, к которой принадлежит пользователь:  
	```bash
	user@linux1:~/linux/homework-12$ cat scripts/pam_date_check.sh
	#!/bin/bash

	# Проверка пользователя, выход если админ
	if [[ `grep $PAM_USER /etc/group | grep 'admin'` ]]
	then
	  exit 0
	fi

	# Проверка дня недели
	if [[ `date +%u` > 5 ]]
	then
	  exit 1
	fi

	exit 0
	```

2. Для выполнения задания создадим виртуалку и пропишем в провижин выполнение следующих операций  
	- создадим пользователя test_user, которому будет разрешен вход в выходные
	- создадим группу admin
	- добавим пользователя test_user в группу admin
	- назначим пользователю test_user пароль "123456"

	- создадим пользователя test_user2, которому будет запрещено входить в выходные
	- назначим пользователю test_user2 пароль "123456"

	- включим аутентификацию PAM, для этого заменим в файле /etc/ssh/sshd_config  'PasswordAuthentication no' на 'PasswordAuthentication yes'
	- добавим в файл конфигурации /etc/pam.d/sshd строку 'auth  required  pam_script.so' для проверки группы пользователя во время входа скриптом /etc/pam_script
	- скопируем скрипт pam_date_check.sh, проверяющий группу пользователя и день недели, в файл /etc/pam_script

### ДЗ* Дать конкретному пользователю права работать с докером и возможность рестартить докер сервис

1. Дополним провижин нашей виртуалки следующими командами для установки докера:  
	```bash
	yum check-update
	curl -fsSL https://get.docker.com/ | sh
	```
2. Чтобы пользователь мог выполнять команды с докером необходимо добавить его в группу docker.  
	```bash
	usermod -aG docker test_user
	```
3. Чтобы пользователь мог рестартить докер сервис, включим его в группу wheel. Пользователи данной группы могут повысить свои права с помощью sudo.  
	```bash
	usermod -aG wheel test_user
	```
4. В итоге наш конечный vagrantfile выглядит следующим образом:  
	```bash
	user@linux1:~/linux/homework-12$ cat vagrantfile
	# -*- mode: ruby -*-
	# vim: set ft=ruby :

	MACHINES = {
	  :otuslinux => {
		:box_name => "centos/7",
		:ip_addr => '192.168.11.101',
	  },
	}

	Vagrant.configure("2") do |config|

	 # config.vm.provision "shell", path: "install.sh"

	  MACHINES.each do |boxname, boxconfig|

	      config.vm.define boxname do |box|

		  box.vm.box = boxconfig[:box_name]
		  box.vm.host_name = boxname.to_s

		  #box.vm.network "forwarded_port", guest: 80, host: 80

		  box.vm.network "private_network", ip: boxconfig[:ip_addr]

		  box.vm.provider :virtualbox do |vb|
		    	  vb.customize ["modifyvm", :id, "--memory", "256"]
		  end

	      box.vm.provision "shell", inline: <<-SHELL
		mkdir -p ~root/.ssh
		cp ~vagrant/.ssh/auth* ~root/.ssh

		for pkg in epel-release pam_script; do yum install -y $pkg; done	    

		# Добавление пользователя test_user размещение его в группу admins
		useradd test_user
		groupadd admin
		usermod -a -G admin test_user
		echo "test_user:123456" | chpasswd

		# Добавление пользователя test_user2, имеющего обычные права
		useradd test_user2
		echo "test_user2:123456" | chpasswd

		# Изменение файлов конфигураций
		sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
		sed -i '2i auth  required  pam_script.so'  /etc/pam.d/sshd

		cp /vagrant/scripts/pam_date_check.sh /etc/pam_script

		# Установка докера
		yum check-update
		curl -fsSL https://get.docker.com/ | sh
		
		# Назначение test_user повышенных прав - для команд с докером и возможности рестарта сервиса
		usermod -aG docker test_user
		usermod -aG wheel test_user

		systemctl restart sshd

	  	SHELL

	      end
	  end
	end
	```

### Проверка задания

1. Поднимаем виртуалку и подключаемся.  
	```bash
	user@linux1:~/linux/homework-12$ vagrant ssh
	[vagrant@otuslinux ~]$
	```bash
2. Проверим созданных пользователей и их группы:  
	```bash
	[vagrant@otuslinux ~]$ id test_user
	uid=1001(test_user) gid=1001(test_user) groups=1001(test_user),10(wheel),1002(admin),993(docker)
	[vagrant@otuslinux ~]$ id test_user2
	uid=1002(test_user2) gid=1003(test_user2) groups=1003(test_user2)
	```
3. Проверим дату и убедимся, что в понедельник оба пользователя заходят в систему нормально:   
	```bash
	[vagrant@otuslinux ~]$ date
	Mon Apr 27 16:35:18 UTC 2020
	[vagrant@otuslinux ~]$ ssh test_user@192.168.11.101
	The authenticity of host '192.168.11.101 (192.168.11.101)' can't be established.
	ECDSA key fingerprint is SHA256:s9RQXXyxoyg6pOeMpLrspOK2+GmqkMl4QNL4cfsqs98.
	ECDSA key fingerprint is MD5:a1:f8:f2:a8:88:e4:49:2d:e0:b3:87:a9:d1:e0:c9:55.
	Are you sure you want to continue connecting (yes/no)? y
	Please type 'yes' or 'no': yes
	Warning: Permanently added '192.168.11.101' (ECDSA) to the list of known hosts.
	test_user@192.168.11.101's password: 
	[test_user@otuslinux ~]$ exit
	logout
	Connection to 192.168.11.101 closed.
	[vagrant@otuslinux ~]$ ssh test_user2@192.168.11.101
	test_user2@192.168.11.101's password: 
	[test_user2@otuslinux ~]$ exit
	logout
	Connection to 192.168.11.101 closed.
	```
4. Переведем дату на выходной и затем убедимся, что пользователь test_user группы admin может подключиться, а пользователь test_user2 нет. Выведем последние логи /var/log/secure:  
	```bash
	Sun Apr 26 00:00:00 UTC 2020
	[vagrant@otuslinux ~]$ ssh test_user@192.168.11.101
	test_user@192.168.11.101's password: 
	Last login: Mon Apr 27 16:35:59 2020 from 192.168.11.101
	[test_user@otuslinux ~]$ exit
	logout
	Connection to 192.168.11.101 closed.
	[vagrant@otuslinux ~]$ ssh test_user2@192.168.11.101
	test_user2@192.168.11.101's password: 
	Permission denied, please try again.
	test_user2@192.168.11.101's password: 

	[vagrant@otuslinux ~]$ tail -n 10 /var/log/secure
	tail: cannot open '/var/log/secure' for reading: Permission denied
	[vagrant@otuslinux ~]$ sudo tail -n 10 /var/log/secure
	Apr 26 00:00:00 localhost sudo: pam_unix(sudo:session): session opened for user root by vagrant(uid=0)
	Apr 26 00:00:00 localhost sudo: pam_unix(sudo:session): session closed for user root
	Apr 26 00:00:23 localhost sshd[26149]: Accepted password for test_user from 192.168.11.101 port 43908 ssh2
	Apr 26 00:00:23 localhost sshd[26149]: pam_unix(sshd:session): session opened for user test_user by (uid=0)
	Apr 26 00:00:29 localhost sshd[26157]: Received disconnect from 192.168.11.101 port 43908:11: disconnected by user
	Apr 26 00:00:29 localhost sshd[26157]: Disconnected from 192.168.11.101 port 43908
	Apr 26 00:00:29 localhost sshd[26149]: pam_unix(sshd:session): session closed for user test_user
	Apr 26 00:00:40 localhost sshd[26182]: Failed password for test_user2 from 192.168.11.101 port 43910 ssh2
	Apr 26 00:00:51 localhost sshd[26182]: Connection closed by 192.168.11.101 port 43910 [preauth]
	Apr 26 00:01:24 localhost sudo: vagrant : TTY=pts/0 ; PWD=/home/vagrant ; USER=root ; COMMAND=/bin/tail -n 10 /var/log/secure
	```
5. Теперь снова подключимся пользователем test_user и убедимся, что он имеет возможность запустить докер-сервис:  
	```bash
	[vagrant@otuslinux ~]$ ssh test_user@192.168.11.101
	test_user@192.168.11.101's password: 
	Last login: Mon Apr 27 17:45:02 2020 from 192.168.11.101
	[test_user@otuslinux ~]$ systemctl status docker
	● docker.service - Docker Application Container Engine
	   Loaded: loaded (/usr/lib/systemd/system/docker.service; disabled; vendor preset: disabled)
	   Active: inactive (dead) since Mon 2020-04-27 17:46:12 UTC; 3min 49s ago
	     Docs: https://docs.docker.com
	  Process: 6287 ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock (code=exited, status=0/SUCCESS)
	 Main PID: 6287 (code=exited, status=0/SUCCESS)

	Apr 27 17:45:31 otuslinux dockerd[6287]: time="2020-04-27T17:45:31.538377336..."
	Apr 27 17:45:31 otuslinux dockerd[6287]: time="2020-04-27T17:45:31.658655731..."
	Apr 27 17:45:31 otuslinux dockerd[6287]: time="2020-04-27T17:45:31.762218040...8
	Apr 27 17:45:31 otuslinux dockerd[6287]: time="2020-04-27T17:45:31.772697060..."
	Apr 27 17:45:31 otuslinux systemd[1]: Started Docker Application Container ...e.
	Apr 27 17:45:31 otuslinux dockerd[6287]: time="2020-04-27T17:45:31.882480593..."
	Apr 27 17:46:12 otuslinux systemd[1]: Stopping Docker Application Container.....
	Apr 27 17:46:12 otuslinux dockerd[6287]: time="2020-04-27T17:46:12.131030999..."
	Apr 27 17:46:12 otuslinux dockerd[6287]: time="2020-04-27T17:46:12.134251744..."
	Apr 27 17:46:12 otuslinux systemd[1]: Stopped Docker Application Container ...e.
	Hint: Some lines were ellipsized, use -l to show in full.
	[test_user@otuslinux ~]$ sudo systemctl start docker

	We trust you have received the usual lecture from the local System
	Administrator. It usually boils down to these three things:

	    #1) Respect the privacy of others.
	    #2) Think before you type.
	    #3) With great power comes great responsibility.

	[sudo] password for test_user: 
	[test_user@otuslinux ~]$ systemctl status docker
	● docker.service - Docker Application Container Engine
	   Loaded: loaded (/usr/lib/systemd/system/docker.service; disabled; vendor preset: disabled)
	   Active: active (running) since Mon 2020-04-27 17:50:39 UTC; 7s ago
	     Docs: https://docs.docker.com
	 Main PID: 6596 (dockerd)
	    Tasks: 8
	   Memory: 81.9M
	   CGroup: /system.slice/docker.service
		   └─6596 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/cont...

	Apr 27 17:50:38 otuslinux dockerd[6596]: time="2020-04-27T17:50:38.949333121...c
	Apr 27 17:50:38 otuslinux dockerd[6596]: time="2020-04-27T17:50:38.949340836...c
	Apr 27 17:50:38 otuslinux dockerd[6596]: time="2020-04-27T17:50:38.954733245..."
	Apr 27 17:50:38 otuslinux dockerd[6596]: time="2020-04-27T17:50:38.964646765..."
	Apr 27 17:50:39 otuslinux dockerd[6596]: time="2020-04-27T17:50:39.108820211..."
	Apr 27 17:50:39 otuslinux dockerd[6596]: time="2020-04-27T17:50:39.141151625..."
	Apr 27 17:50:39 otuslinux dockerd[6596]: time="2020-04-27T17:50:39.174592305...8
	Apr 27 17:50:39 otuslinux dockerd[6596]: time="2020-04-27T17:50:39.180436355..."
	Apr 27 17:50:39 otuslinux dockerd[6596]: time="2020-04-27T17:50:39.221303186..."
	Apr 27 17:50:39 otuslinux systemd[1]: Started Docker Application Container ...e.
	Hint: Some lines were ellipsized, use -l to show in full.
	[test_user@otuslinux ~]$ exit
	logout
	Connection to 192.168.11.101 closed.
	```
6. Теперь снова подключимся пользователем test_user2 и убедимся, что он не имеет права управлять докер-сервисом:  
	```bash
	[vagrant@otuslinux ~]$ ssh test_user2@192.168.11.101
	test_user2@192.168.11.101's password: 
	Last login: Mon Apr 27 17:45:48 2020 from 192.168.11.101
	[test_user2@otuslinux ~]$  systemctl status docker
	● docker.service - Docker Application Container Engine
	   Loaded: loaded (/usr/lib/systemd/system/docker.service; disabled; vendor preset: disabled)
	   Active: active (running) since Mon 2020-04-27 17:50:39 UTC; 2min 25s ago
	     Docs: https://docs.docker.com
	 Main PID: 6596 (dockerd)
	    Tasks: 8
	   Memory: 79.0M
	   CGroup: /system.slice/docker.service
		   └─6596 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/cont...
	[test_user2@otuslinux ~]$ sudo  systemctl stop docker
	[sudo] password for test_user2: 
	test_user2 is not in the sudoers file.  This incident will be reported.
	```
