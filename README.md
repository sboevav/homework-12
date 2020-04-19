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

1. Проверим права доступа к каталогу /opt/upload, затем изменим владельца на user3 и установим на каталог Sticky bit, означающий, что удалить файл из этого каталога может только владелец файла или владелец каталога или суперпользователь. Посмотрим на все сделанные изменения командой ```ls -l /opt``` - видим, что владельцем каталога стал пользователь user3 и установлен Sticky bit - T.  
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


```bash
```
```bash
```



