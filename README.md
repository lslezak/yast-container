# Experimental YaST Docker Container

This is a proof of concept (PoC) project for testing how to run YaST from
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

```

If you want to use Docker as a non-root user add yourselves into the `docker`
user group.

### Running a Container

### Tested Modules

## Problems

### Accessing the Host System

### Package Management

### Logging

### Summary
