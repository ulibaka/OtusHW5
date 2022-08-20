#!/bin/bash

sudo yum update 
sudo yum install -y yum-utils
sudo yum install -y https://zfsonlinux.org/epel/zfs-release-2-2$(rpm --eval "%{dist}").noarch.rpm
#sudo rpm --import  --nosignature /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
sudo yum-config-manager --disable zfs
sudo yum-config-manager --enable zfs-kmod
sudo yum install zfs -y

sudo modprobe zfs

