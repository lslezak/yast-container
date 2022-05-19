# This is file defines a Docker container based on openSUSE Leap
# and installs few YaST modules.

# the default base image
ARG image=opensuse/leap:15.3
FROM ${image}

# install some YaST modules with the default ncurses UI
RUN zypper --non-interactive install \
  patch \
  yast2-packager \
  yast2-registration \
  yast2-storage-ng \
  yast2-sysconfig

# read/write the libzypp lock to /mnt/...
ENV ZYPP_LOCKFILE_ROOT=/mnt
# set YaST target
ENV YAST_TARGET_DIR=/mnt

# redirect logging to the host
RUN mv /var/log /var/log.orig && ln -s /mnt/var/log /var/log


# patch sysconfig so it reads the files from /mnt/...
COPY mnt.diff .
RUN patch -i mnt.diff /usr/share/YaST2/modules/Sysconfig.rb && rm mnt.diff

COPY y2start.diff .
RUN patch -i y2start.diff /usr/lib/YaST2/bin/y2start && rm y2start.diff
