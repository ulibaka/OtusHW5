Установка zfs в kABI-tracking kmod описана в setup_zfs.sh. Скрипт подключен в Vagrantfile. Работаем в:

$ cat /etc/redhat-release 
CentOS Linux release 7.8.2003 (Core)

## 1  создать 4 файловых системы на каждой применить свой алгоритм сжатия; 
```
[root@server ~]# zfs get compression  | grep -v default
NAME                   PROPERTY     VALUE           SOURCE
storage/gzip_compress  compression  gzip            local
storage/lz4_compress   compression  lz4             local
storage/lzjb_compress  compression  lzjb            local
storage/zle_compress   compression  zle             local
```

#### Скачиваем файл и раскладываем по директориям: 

```
[root@server ~]# wget -c http://www.gutenberg.org/ebooks/2600.txt.utf-8
[root@server ~]# for i in /storage/*compress; do cp 2600.txt.utf-8 $i; done
```

#### Получаем лучшее ratio (ответ - gzip в данном примере показал лучшее сжатие):
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

##  2  Определить настройки pool’a. 

#### Скачиваем и распаковываем архив
```
[root@server ~]# tar zxf zfs_task1.tar.gz
[root@server zpoolexport]# ls -l
итого 1024000
-rw-r--r--. 1 root root 524288000 май 15  2020 filea
-rw-r--r--. 1 root root 524288000 май 15  2020 fileb
```

#### Проверяем содержимое и восстанавливаем:
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
###  Определяем настройки пула
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

## 3 Найти сообщение от преподавателей. 

#### Восстанавливаем snapshot
```
# zfs receive otus/hometask2/file < otus_task2.file
```
Сообщение:
```
[root@server file]# cat `find ./ -name 'secret_message'`
https://github.com/sindresorhus/awesome
```
