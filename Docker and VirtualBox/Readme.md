# General info

Docker for Windows needs Windows to be booted in Hyper V Type 1. It will be started itself like a guest VM and access to hardware resource is different from then.
VirtualBox is a Hyper V Type 2, and uses the host to access hardware.
They are not compatibile.

# How to switch hyper V
```
# To run docker, enable hyper V and reboot
bcdedit /set hypervisorlaunchtype auto

# To run virtual box, disable hyper V and reboot
bcdedit /set hypervisorlaunchtype off
```

# docker images (not -a) shows many <none>:<none> entries
In contrast to `docker images -a` these entries are wasting space. Clean them with
  
`docker rmi $(docker images -f "dangling=true" -q)`

See this [link](https://www.projectatomic.io/blog/2015/07/what-are-docker-none-none-images/) for more information


# Virtual box Client has no GUI

**Important**: Do not start the gui via Task or `Register-Job` through powershell. Then you won't see any windows anymore.

In case of GUI not starting use this:
```
PS C:\Program Files\Oracle\VirtualBox> ./VBoxManage.exe startvm "VM Name" -type GUI
```

# X11 Forwarding to Windows from remote Ubuntu docker container

## On Windows
* Install vcxsrv (https://github.com/marchaesen/vcxsrv)
* If port 6000 is blocked on this machine, open reverse tunnel: `ssh -R 6000:localhost:6000 -N HOST_OR_IP`
* Launch XLauncher, configure it (disable AUTH if trusted network)
* Connect normally to Ubuntu (no -X or -Y required because of reverse tunnel). If no tunnel, then use `-X` or `-Y`
  
## On Ubuntu
* Test direct on host:
* ```
  export DISPLAY=localhost:0
  xeyes
  ```
* => Should display xeyes on X11 viewer

## Inside docker on this machine
* Docker file (X11Test.dockerfile):
* ```
  # Pick matching distro
  FROM ubuntu:22.04

  # Set proxy environment variables if needed
  #ENV http_proxy=...
  #ENV https_proxy=...
  
  # Install x11-apps (includes xeyes)
  RUN apt-get update && \
      apt-get install -y x11-apps && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/*
  
  # Set default command
  CMD ["/bin/bash"]
  ```
* Build container with `docker build -f X11Test.dockerfile -t x11-test .`
* Run container (Important: network host for simplicity) `docker run -it --rm --network=host -e DISPLAY=localhost:0 x11-test xeyes`
* => Should display xeyey from the docker container
* You might need call `docker kill x11-test`

# Clean up docker images

Check size
```
docker system df
docker system df -v
```

Clean up (from least destructive to very destructive)

```
# Build cache
docker builder prune
docker builder prune --filter until=168h    # older than 7 days

# dangling images, none:none layers
docker image prune

# stopped containers
docker container prune

# all unused images
docker image prune -a

# Very careful, deletes volumes
docker volume prune
```
