FROM opensuse/leap:15.3

# install some YaST modules with the default ncurses UI
RUN zypper --non-interactive install \
  patch \
  yast2-packager \
  yast2-storage-ng \
  yast2-sysconfig

# patch sysconfig so it reads the files from /mnt/...
COPY mnt.diff .
RUN patch -i mnt.diff /usr/share/YaST2/modules/Sysconfig.rb

# install the chroot wrapper client
COPY chroot_wrapper.rb /usr/share/YaST2/clients/
