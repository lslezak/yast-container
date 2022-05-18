# Experimental YaST Docker Container

This is a proof of concept (PoC) project for testing how to run YaST in
a container to manage the host system.

## :warning: Warning :warning:

**This is an experimental project, do not use it in production systems! It is
recommended to use a virtual machine for testing! There is a high risk of
breaking the system or data loss!**

## Purpose

The goal is to decrease the size of the system and avoid unnecessary dependencies.

Using a separate container would also make upgrading the tools, libraries
and languages easier, without affecting the users. We could use newer Ruby in
the YaST container and keep the old one in SLE/Leap for backward compatibility.

## Proof of Concept

This repository contains some scripts and container definitions.

*Note: The containers use the openSUSE Leap 15.3 base system and should be used for
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
user group. *(Security note: Be careful, such users become equivalent to `root`!)*

### Running a Container

There are two helper scripts, `yast_container` and `yast2_container`. The first
runs the specified YaST module in ncurses UI, the second one uses Qt UI.

The scripts build the container image at start if it is not built yet and then
run the specified YaST module in the container.

The container is automatically deleted after finishing YaST, if you want to
inspect the container you have to start it manually.

### Tested Modules

This is a list of YaST modules which you can try with the testing image:

- `yast2_container chroot_wrapper repositories` - shows the repositories from
  the host system, unfortunately it tries to save the changes to the container...
- `yast2_container chroot_wrapper sw_single` - package installation works fine,
  tha packages are correctly installed in the host system (though there is a
  problem with the libzypp lock, see below...)
- `yast2_container chroot_wrapper key_manager` - displays the imported GPG keys
  known by the package management - again, saving changes does not work
- `yast2_container sysconfig` - the patched modules can edit the files in the
  host system properly
- `yast2_container chroot_wrapper disk` - it displays the devices, but it does not
  display the mount points (probably because `/etc/fstab` is read from the container)

Feel free to experiment with other YaST modules... :wink:
  
## Implementation Details

The [chroot_wrapper.rb](./chroot_wrapper.rb) helper script just redirects SCR
and initializes the package manager in the `/mnt` subdirectory. Then it runs
the specified YaST client as usually. But that does not guarantee that the
module will work properly in the client, see the problems mentioned below.

## Problems

Unfortunately that helper does not solve all problems, in general you cannot
expect that you can just wrap existing modules by this wrapper and everything
will work fine. No, that's not the case... :worried:

### Accessing the Host System

The host system is mounted to `/mnt` directory in the container. YaST must use
this subdirectory instead of the root directory for reading/writing files.

But that's usually not supported, esp. for modules designed to run only in
an installed system.

### Package Management

Libzypp supports installing into a chroot directory, that's used during standard
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
command is available and where it needs to run.

- Run the command in the container (e.g. `fdisk` can be used from a container
  and does not need access to the host files)
- Run it in the container and pass it `/mnt` option if that is possible so
  it modifies the host system
- Run it in the container but copy the result into the target system
- Run it in the host system using `chroot` (but that requires the command to be
  available in the host system)
- Run the command using `ssh`, this would ensure it is fully executed in the host
  system context

*Note: The YaST SCR component allow chrooting (see the [chroot_wrapper.rb](
./chroot_wrapper.rb) file), but that uses the parser and YaST libraries from the
host system, that means it would require some YaST packages there. That's against
the goal which we want to achieve with containers...*

### Other Interactions with the System

It is a question which other interactions with the host system are possible
or not. It turned out that even loading kernel modules works with
`chroot /mnt modprobe <module>`...

### Logging and Locking

The YaST log is written into `/var/log/YaST2/y2log` in the container, after finishing
the container the log is lost. That's not good for debugging problems.

YaST should redirect the logging into `/mnt`, either by setting the logging
target or indirectly via a symlink in `/var/log` in the container.

A similar problem is with locking. E.g libzypp creates `/var/run/zypp.pid` lock
file to avoid running multiple instances of the package management at once.
But that file is currently created inside the container...

### Sending Signals

Normally the processes in a container start with PID 1 and the processes in
the host or in other containers are not visible.

That's a problem if you need to send a signal to a processes running
in the host or you need to check whether some process is running.

Fortunately Docker provides the `--pid=host` option which disables the process
name space and allows to see all processes in the host. See more details in the
[documentation](https://docs.docker.com/engine/reference/run/#pid-settings---pid).

### Summary

It seems that it should be possible to fully manage the host system from
a container.

However, the current YaST is not prepared for that. The adjustments seem to
be small but a lot of places would need to be updated. It should be similar
to moving some configuration steps from the second installation stage
(running in `/`) to the first stage (running in `/mnt`) as we did some time ago.

Also some YaST modules do not make sense in a containerized world,
for example the module for HTTP server. It is supposed that the HTTP server
would run in a separate container, managed by other tools.
