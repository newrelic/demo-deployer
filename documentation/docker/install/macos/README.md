# Install Docker on Mac OS

# Docker install
To run Docker on Mac OS, we will use Docker Desktop for Mac. Follow the link below and complete steps up to the "Uninstall Docker Desktop" section.
* [Docker Desktop installation Mac](https://docs.docker.com/docker-for-mac/install/)

# Verify install
After completing the installation, verify it by opening the Terminal application (located at Applications/Utilities/Terminal.app) and running `docker version`.
The output should be similar to this:
```
❯ docker version
Client: Docker Engine - Community
 Version:           19.03.8
 API version:       1.40
 Go version:        go1.12.17
 Git commit:        afacb8b
 Built:             Wed Mar 11 01:21:11 2020
 OS/Arch:           darwin/amd64
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
~
❯
```

# All done!
Woohoo! You can now use Docker on your machine.