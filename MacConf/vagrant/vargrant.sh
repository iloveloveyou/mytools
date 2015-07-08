#!/bin/sh
#centos64是我们给这个 box 命的名字
vagrant box add centos64 /opt/vmware/precise64.box
cd /opt/htdocs
# 初始化
vagrant init centos64
# 启动环境
vagrant up
# SSH 登录
vagrant ssh
# 切换到开发目录，也就是宿主机上的 `/opt/htdocs`
cd /vagrant

test

#Vagrant 初始化成功后，会在初始化的目录里生成一个 Vagrantfile 的配置文件，可以修改配置文件进行个性化的定#制。
#Vagrant 默认是使用端口映射方式将虚拟机的端口映射本地从而实现类似 http://localhost:80 这种访问方式，这种方式比较麻烦，新开和修改端口的时候都得编辑。相比较而言，host-only 模式显得方便多了。打开 Vagrantfile，将下面这行的注释去掉（移除 #）并保存：
#config.vm.network :private_network, ip: "192.168.33.10"
#重启虚拟机，这样我们就能用 192.168.33.10 访问这台机器了，你可以把 IP 改成其他地址，只要不产生冲突就行。

#常用命令
#$ vagrant init  # 初始化
#$ vagrant up  # 启动虚拟机
#$ vagrant halt  # 关闭虚拟机
#$ vagrant reload  # 重启虚拟机
#$ vagrant ssh  # SSH 至虚拟机
#$ vagrant status  # 查看虚拟机运行状态
#$ vagrant destroy  # 销毁当前虚拟机
