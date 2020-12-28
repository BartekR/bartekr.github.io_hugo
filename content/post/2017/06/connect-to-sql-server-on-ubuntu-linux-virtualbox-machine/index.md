---
title: "Connect to SQL Server on Ubuntu Linux VirtualBox machine"
date: "2017-06-28"
draft: false
images:
  - src: "2017/06/28/connect-to-sql-server-on-ubuntu-linux-virtualbox-machine/images/PortForwarding01.png"
    alt: ""
    stretch: ""
tags: ['Linux', 'Ubuntu', 'VirtualBox', 'VM']
categories: ['SQL Server']
---

For my everyday tests with SQL Server I use VirtualBox. SQL Server 2017 is/will be a huge thing - mostly because it will be available on Linux. If so - I should get comfortable with using it on Linux.

I start with Ubuntu Server (because of the name - I used Ubuntu Desktop in the past), Installation of VM on VirtualBox comes down to adding ISO image as the CD-ROM (DVD-ROM?) and selecting almost only the default options. I don't want to build a cluster or do sophisticated things - I just want the Linux Server to be up and running.

It takes just few minutes to install Ubuntu Linux Server (16.04) . The next step is to install SQL Server. Following [the official](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-ubuntu) documentation I run just 5 commands to set up and one to verify if the service works well:

```shell
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/16.04/mssql-server.list | sudo tee /etc/apt/sources.list.d/mssql-server.list
sudo apt-get update
sudo apt-get install -y mssql-server
sudo /opt/mssql/bin/mssql-conf setup

systemctl status mssql-server
```

OK, looks easy (and it is!). It really takes few minutes to have SQL Server on Linux experience. Now: I want to connect to SQL Server on VM from my Host machine (Windows). I have my SSMS there, with SQLPrompt (so you understand why I want to use it) - I want to connect to the VM.

But.

My internal network is 192.168.x.x and Ubuntu Linux creates 10.0.2.15 IP address for the machine. I don't use Linux that often (also not that often on VirtualBox) and I don't want to try allthis things with iptables, ifconfig setup and so on. Is there some magic switch I could use?

The internet says: yes, there is - Port Forwarding.

Open the settings for the virtual machine, switch to _Network_ tab and expand _Advanced_ part. There is a _Port Forwarding_ button. Don't be shy, just click it.

[![Port forwarding option](images/PortForwarding01.png#center)](images/PortForwarding01.png)

On the Port Forwarding Rules setup window set things as on the picture: Host IP == 127.0.0.1, Host port - one of your choice - this is the port you will connect from Host VM. Guest IP means virtual machine IP and Guest Port is the port of service on VM. SQL Server runs on port 1433 on the Ubuntu Linux with address 10.0.2.15 and I forward it to my local machine to port 14333 (because I want to). The rule name is MSSQL to be clear what is it about, you can give any name you want.

[![Port forwarding setup](images/PortForwarding02.png#center)](images/PortForwarding02.png)

Best with VM turned off as I've read to restart the machine after the change (and didn't check it too much, just followed the instructions).

And that's it! Now I use port 14333 (remember to use a comma!) in SSMS and I'm connected to VM with SQL Server on Linux.

[![SSMS connect dialog](images/PortForwarding03.png#center)](images/PortForwarding03.png)
