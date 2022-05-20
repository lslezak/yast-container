# This is file defines a Docker container based on openSUSE Leap
# and installs few YaST modules.

# the default base image
ARG image=opensuse/leap:15.4
FROM ${image}

# install some YaST modules with the default ncurses UI
RUN zypper --non-interactive install \
  "rubygem(yast-rake)" \
  patch \
  yast2-packager \
  yast2-registration \
  yast2-storage-ng \
  yast2-sysconfig

# redirect logging to the host
RUN mv /var/log /var/log.orig && ln -s /mnt/var/log /var/log


# patch sysconfig so it reads the files from /mnt/...
COPY mnt.diff .
RUN patch -i mnt.diff /usr/share/YaST2/modules/Sysconfig.rb && rm mnt.diff

# patch the Installation module to handle YAST_TARGET_DIR
COPY Installation.diff .
RUN patch -i Installation.diff /usr/share/YaST2/modules/Installation.rb && rm Installation.diff

# add Arch.is_management_container
COPY Arch.diff .
RUN patch -i Arch.diff /usr/share/YaST2/modules/Arch.rb && rm Arch.diff
