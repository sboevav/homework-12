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

