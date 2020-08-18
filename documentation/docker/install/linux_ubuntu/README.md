# Install Docker on Ubuntu
The deployer can be run using Docker on Ubuntu. It should work on any other Linux distribution, but these instructions will focus on Ubuntu.   
We are assuming you are using Ubuntu 18.04 LTS or later.

# Open the terminal
**Note**: If you are running Ubuntu without a GUI, skip this step.   
There are two ways to find your terminal in Ubuntu. You can use whichever is more comfortable.
1. Click the "Ubuntu" logo in the upper left of the screen and type "terminal". Then press the "enter" key.
or
2. Press CTRL + ALT + T.


# Docker install
Run the following commands to install Docker.

1. Update your apt repositories.
```bash
sudo apt update -y
```

2. Install Docker.
```bash
sudo apt install -y docker.io
```
You should see something like this:
```
After this operation, 334 MB of additional disk space will be used.
Get:1 http://us.archive.ubuntu.com/ubuntu focal/main amd64 runc amd64 1.0.0~rc10-0ubuntu1 [2,549 kB]
Get:2 http://us.archive.ubuntu.com/ubuntu focal/main amd64 containerd amd64 1.3.3-0ubuntu2 [27.8 MB]
Get:3 http://us.archive.ubuntu.com/ubuntu focal/main amd64 dns-root-data all 2019052802 [5,300 B]
Get:4 http://us.archive.ubuntu.com/ubuntu focal/main amd64 libidn11 amd64 1.33-2.2ubuntu2 [46.2 kB]
Get:5 http://us.archive.ubuntu.com/ubuntu focal/main amd64 dnsmasq-base amd64 2.80-1.1ubuntu1 [314 kB]
Get:6 http://us.archive.ubuntu.com/ubuntu focal-updates/universe amd64 docker.io amd64 19.03.8-0ubuntu1.20.04 [38.9 MB]
Get:7 http://us.archive.ubuntu.com/ubuntu focal/main amd64 ubuntu-fan all 0.12.13 [34.5 kB]
Fetched 67.4 MB in 5s (12.5 MB/s)
Preconfiguring packages ...
Selecting previously unselected package pigz.
(Reading database ... 70787 files and directories currently installed.)
Preparing to unpack .../0-pigz_2.4-1_amd64.deb ...
Unpacking pigz (2.4-1) ...
Selecting previously unselected package bridge-utils.
Preparing to unpack .../1-bridge-utils_1.6-2ubuntu1_amd64.deb ...
Unpacking bridge-utils (1.6-2ubuntu1) ...
Selecting previously unselected package cgroupfs-mount.
Preparing to unpack .../2-cgroupfs-mount_1.4_all.deb ...
Unpacking cgroupfs-mount (1.4) ...
Selecting previously unselected package runc.
Preparing to unpack .../3-runc_1.0.0~rc10-0ubuntu1_amd64.deb ...
Unpacking runc (1.0.0~rc10-0ubuntu1) ...
Selecting previously unselected package containerd.
Preparing to unpack .../4-containerd_1.3.3-0ubuntu2_amd64.deb ...
Unpacking containerd (1.3.3-0ubuntu2) ...
Selecting previously unselected package dns-root-data.
Preparing to unpack .../5-dns-root-data_2019052802_all.deb ...
Unpacking dns-root-data (2019052802) ...
Selecting previously unselected package libidn11:amd64.
Preparing to unpack .../6-libidn11_1.33-2.2ubuntu2_amd64.deb ...
Unpacking libidn11:amd64 (1.33-2.2ubuntu2) ...
Selecting previously unselected package dnsmasq-base.
Preparing to unpack .../7-dnsmasq-base_2.80-1.1ubuntu1_amd64.deb ...
Unpacking dnsmasq-base (2.80-1.1ubuntu1) ...
Selecting previously unselected package docker.io.
Preparing to unpack .../8-docker.io_19.03.8-0ubuntu1.20.04_amd64.deb ...
Unpacking docker.io (19.03.8-0ubuntu1.20.04) ...
Selecting previously unselected package ubuntu-fan.
Preparing to unpack .../9-ubuntu-fan_0.12.13_all.deb ...
Unpacking ubuntu-fan (0.12.13) ...
Setting up runc (1.0.0~rc10-0ubuntu1) ...
Setting up dns-root-data (2019052802) ...
Setting up libidn11:amd64 (1.33-2.2ubuntu2) ...
Setting up bridge-utils (1.6-2ubuntu1) ...
Setting up pigz (2.4-1) ...
Setting up cgroupfs-mount (1.4) ...
Setting up containerd (1.3.3-0ubuntu2) ...
Created symlink /etc/systemd/system/multi-user.target.wants/containerd.service → /lib/systemd/system/containerd.service.
Setting up docker.io (19.03.8-0ubuntu1.20.04) ...
Adding group `docker' (GID 117) ...
Done.
Created symlink /etc/systemd/system/sockets.target.wants/docker.socket → /lib/systemd/system/docker.socket.
docker.service is a disabled or a static unit, not starting it.
Setting up dnsmasq-base (2.80-1.1ubuntu1) ...
Setting up ubuntu-fan (0.12.13) ...
Created symlink /etc/systemd/system/multi-user.target.wants/ubuntu-fan.service → /lib/systemd/system/ubuntu-fan.service.
Processing triggers for systemd (245.4-4ubuntu3) ...
Processing triggers for man-db (2.9.1-1) ...
Processing triggers for dbus (1.12.16-2ubuntu2.1) ...
Processing triggers for libc-bin (2.31-0ubuntu9) ...
```


# Configure security groups
Docker added a new security group during installation. To use it without adding `sudo` to every command, you will need to add your user to the group.

1. Add your user to the docker security group.
```bash
sudo usermod -aG docker ${USER}
```

2. Log out and back in for the changes to take place.

# Verify install
Test out your installation by running a simple docker command.
```bash
docker version
```

The output should be similar to this:
```
alec@alectest:~$ docker version
Client:
 Version:           19.03.8
 API version:       1.40
 Go version:        go1.13.8
 Git commit:        afacb8b7f0
 Built:             Tue Jun 23 22:26:12 2020
 OS/Arch:           linux/amd64
 Experimental:      false

Server:
 Engine:
  Version:          19.03.8
  API version:      1.40 (minimum version 1.12)
  Go version:       go1.13.8
  Git commit:       afacb8b7f0
  Built:            Thu Jun 18 08:26:54 2020
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.3.3-0ubuntu2
  GitCommit:
 runc:
  Version:          spec: 1.0.1-dev
  GitCommit:
 docker-init:
  Version:          0.18.0
  GitCommit:
alec@alectest:~$
```

# All done!
Woohoo! You can now use Docker on your machine.