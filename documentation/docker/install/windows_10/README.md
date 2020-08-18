# Install Docker on Windows 10

The deployer can be run with docker using Windows Subsystem for Linux, or WSL for short.

## Install WSL

The steps to install WSL are documented at https://docs.microsoft.com/en-us/windows/wsl/install-win10
The deployer can use either WSL 1 or 2. We recommend using WSL 2.
Once WSL is installed, install the Ubuntu linux version 18.04 LTS or later.

## Docker install

To install docker on windows, download it from the docker hub at https://hub.docker.com/editions/community/docker-ce-desktop-windows/
You'll want to select the `Stable` version.

## Verify install

Open a ubuntu linux window, and execute `docker version`.
You should see something looking like this:

```
jerard@NRB4PJW33 ~> docker version
Client: Docker Engine - Community
 Version:           19.03.8
 API version:       1.40
 Go version:        go1.12.17
 Git commit:        afacb8b7f0
 Built:             Wed Mar 11 01:25:46 2020
 OS/Arch:           linux/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          19.03.8
  API version:      1.40 (minimum version 1.12)
  Go version:       go1.12.17
  Git commit:       afacb8b
  Built:            Wed Mar 11 01:29:16 2020
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          v1.2.13
  GitCommit:        7ad184331fa3e55e52b890ea95e65ba581ae3429
 runc:
  Version:          1.0.0-rc10
  GitCommit:        dc9208a3303feef5b3839f4323d9beb36df0a9dd
 docker-init:
  Version:          0.18.0
  GitCommit:        fec3683
jerard@NRB4PJW33 ~>
```

Another way to test your docker install is successful and working, you could try to run a simple hello-world application by executing the command `docker run hello-world`.
You should see something looking like this:

```
jerard@NRB4PJW33 ~> docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

jerard@NRB4PJW33 ~>
```
