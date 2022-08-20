# *** Описание/Пошаговая инструкция выполнения домашнего задания: ***

    Определить алгоритм с наилучшим сжатием.
    Зачем: отрабатываем навыки работы с созданием томов и установкой параметров. Находим наилучшее сжатие.
    Шаги:

    определить какие алгоритмы сжатия поддерживает zfs (gzip gzip-N, zle lzjb, lz4);
    создать 4 файловых системы на каждой применить свой алгоритм сжатия;
    Для сжатия использовать либо текстовый файл либо группу файлов:
    скачать файл “Война и мир” и расположить на файловой системе wget -O War_and_Peace.txt http://www.gutenberg.org/ebooks/2600.txt.utf-8, либо скачать файл ядра распаковать и расположить на файловой системе.
    Результат:
    список команд которыми получен результат с их выводами;
    вывод команды из которой видно какой из алгоритмов лучше.

    Определить настройки pool’a.
    Зачем: для переноса дисков между системами используется функция export/import. Отрабатываем навыки работы с файловой системой ZFS.
    Шаги:

    загрузить архив с файлами локально.
    https://drive.google.com/open?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg
    Распаковать.
    с помощью команды zfs import собрать pool ZFS;
    командами zfs определить настройки:
    размер хранилища;
    тип pool;
    значение recordsize;
    какое сжатие используется;
    какая контрольная сумма используется.
    Результат:
    список команд которыми восстановили pool . Желательно с Output команд;
    файл с описанием настроек settings.

    Найти сообщение от преподавателей.
    Зачем: для бэкапа используются технологии snapshot. Snapshot можно передавать между хостами и восстанавливать с помощью send/receive. Отрабатываем навыки восстановления snapshot и переноса файла.
    Шаги:

    скопировать файл из удаленной директории. https://drive.google.com/file/d/1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG/view?usp=sharing
    Файл был получен командой zfs send otus/storage@task2 > otus_task2.file
    восстановить файл локально. zfs receive
    найти зашифрованное сообщение в файле secret_message
    Результат:
    список шагов которыми восстанавливали;
    зашифрованное сообщение.

---

Установка zfs в kABI-tracking kmod описана в setup_zfs.sh. Скрипт подключен в Vagrantfile. Работаем в:

$ cat /etc/redhat-release 
CentOS Linux release 7.8.2003 (Core)

### *** 1  создать 4 файловых системы на каждой применить свой алгоритм сжатия; ***
```
[root@server ~]# zfs get compression  | grep -v default
NAME                   PROPERTY     VALUE           SOURCE
storage/gzip_compress  compression  gzip            local
storage/lz4_compress   compression  lz4             local
storage/lzjb_compress  compression  lzjb            local
storage/zle_compress   compression  zle             local
```

#### ***  Скачиваем файл и расклыдываем по директориям: ***

```
[root@server ~]# wget -c http://www.gutenberg.org/ebooks/2600.txt.utf-8
[root@server ~]# for i in /storage/*compress; do cp 2600.txt.utf-8 $i; done
```

Получаем лучшее ratio (ответ gzip в данном примере показал лучшее сжатие):
```
[root@server ~]# for i in storage/lz4_compress storage/lzjb_compress storage/zle_compress storage/gzip_compress; do zfs get compression,compressratio $i; done
NAME                  PROPERTY       VALUE           SOURCE
storage/lz4_compress  compression    lz4             local
storage/lz4_compress  compressratio  1.63x           -
NAME                   PROPERTY       VALUE           SOURCE
storage/lzjb_compress  compression    lzjb            local
storage/lzjb_compress  compressratio  1.36x           -
NAME                  PROPERTY       VALUE           SOURCE
storage/zle_compress  compression    zle             local
storage/zle_compress  compressratio  1.01x           -
NAME                   PROPERTY       VALUE           SOURCE
storage/gzip_compress  compression    gzip            local
storage/gzip_compress  compressratio  2.67x           -
```

## *** 2  Определить настройки pool’a. ***

Скачиваем и распаковываем архив
```
[root@server ~]# tar zxf zfs_task1.tar.gz
[root@server zpoolexport]# ls -l
итого 1024000
-rw-r--r--. 1 root root 524288000 май 15  2020 filea
-rw-r--r--. 1 root root 524288000 май 15  2020 fileb
```

Проверяем содержимое и восстанавливаем:
```
[root@server zpoolexport]# zpool import -d $PWD/ 
   pool: otus
     id: 6554193320433390805
  state: ONLINE
status: Some supported features are not enabled on the pool.
 action: The pool can be imported using its name or numeric identifier, though
	some features will not be available without an explicit 'zpool upgrade'.
 config:

	otus                         ONLINE
	  mirror-0                   ONLINE
	    /root/zpoolexport/filea  ONLINE
	    /root/zpoolexport/fileb  ONLINE

[root@server zpoolexport]# zpool import -d $PWD/ otus
```
### *** Определяем настройки пула
```
# zpool list
NAME      SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
otus      480M  2.18M   478M        -         -     0%     0%  1.00x    ONLINE  -

# zfs list otus
NAME   USED  AVAIL     REFER  MOUNTPOINT
otus  2.04M   350M       24K  /otus

# zfs get recordsize,compression,checksum
NAME                   PROPERTY     VALUE           SOURCE
otus                   recordsize   128K            local
otus                   compression  zle             local
otus                   checksum     sha256          local
otus/hometask2         recordsize   128K            inherited from otus
otus/hometask2         compression  zle             inherited from otus
otus/hometask2         checksum     sha256          inherited from otus

# zfs get recordsize,compression,checksum otus
NAME  PROPERTY     VALUE           SOURCE
otus  recordsize   128K            local
otus  compression  zle             local
otus  checksum     sha256          local
```

## *** 3 Найти сообщение от преподавателей. ***

Восстанавливаем snapshot
```
# zfs receive otus/hometask2/file < otus_task2.file
```
Сообщение:
```
[root@server file]# cat `find ./ -name 'secret_message'`
https://github.com/sindresorhus/awesome
```
