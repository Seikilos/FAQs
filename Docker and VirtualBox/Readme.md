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
