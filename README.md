# Experimental YaST Docker Container

This is a proof of concept (PoC) project for testing how to run YaST in
a container to manage the host system.

## :warning: Warning :warning:

**This is an experimental project, do not use it in production systems! It is
recommended to use a virtual machine for testing! There is a high risk of
breaking the system or data loss!**

## Purpose

The goal is to decrease the size of the system and avoid unnecessary dependencies.

Using a separate container would also allow upgrading the tools, libraries
and languages without affecting the users. I.e. we could use newer Ruby in
YaST and still keep the old one in SLE/Leap.

## Proof of Concept

This repository contains some scripts and container definition

*Note: The containers use the openSUSE Leap 15.3 system and should be used for
managing an openSUSE Leap 15.3 system. If you use a different version adapt
the `Dockerfile` accordingly.*

### Pre-requisites

The testing scripts use [Docker](https://www.docker.com/) for managing and running
containers.

```shell
# install the packages
zypper in docker git
# enable and start the Docker service
systemctl enable docker
systemctl start docker
# download the scripts
git clone https://github.com/lslezak/yast-container.git
cd yast-container
```

If you want to use Docker as a non-root user add yourselves into the `docker`
user group.

### Running a Container



### Tested Modules

- `yast2 chroot_wrapper repositories`
- `yast2 chroot_wrapper sw_single`
- `yast2 sysconfig`
- `yast2 chroot_wrapper disk`
  
## Implementation Details

The [chroot_wrapper.rb](./chroot_wrapper.rb) helper script just redirects SCR
and initializes the package manager in the `/mnt` subdirectory. Then it runs
the specified YaST client as usually. But that does not guarantee that the
module will work properly in the client, see the problems mentioned below.

## Problems

### Accessing the Host System

The host system is mounted to `/mnt` directory in the container. YaST must use
this subdirectory instead of the root directory for reading/writing files.

But that's usually not the case, esp. for modules designed to run only in
installed system.

### Package Management

Libzyp supports installing into a chroot directory, that's used during standard
installation. That means the package management should work fine.

But the problem is that YaST needs to distinguish between the packages needed
in the management container and the packages needed in the host system.

For example the partitioner suggests installing `btrfstools` package for handling
BtrFs operations. But it should be enough to have that package in the container,
it's not needed in the host.

On the other hand, configuring NetworkManager requires it in the host system
so it can set the network after reboot.

Unfortunately this distinction is missing in YaST...

### Executing commands

Similarly to the package management, it is important to know where the executed
command is available and where it needs run.

- Run the command in the container (e.g. `fdisk` can be used from a container
  and does not need access to the host files)
- Run it in the container and pass it `/mnt` option if that is possible
- Run it in the container but copy the result into the target system
- Run it in the host system using `chroot` (but that requires the command to be
  available in the host system)

*Note: The YaST SCR component allow chrooting (see the [chroot_wrapper.rb](
./chroot_wrapper.rb) file), but that uses the parser and YaST libraries from the
host system, that means it would require some YaST packages there. That's against
the goal which we want to achieve with containers...*


### Logging

The log is written into `/var/log/YaST2/y2log` in the container, after finishing
the container the log is lost. That's not good for debugging purposes.

YaST should redirect the logging into `/mnt`, either by setting the log file or
indirectly via a symlink in `/var/log`.

### Summary
