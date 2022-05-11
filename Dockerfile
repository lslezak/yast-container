FROM opensuse/leap:15.3

# install some YaST modules with the default ncurses UI
RUN zypper --non-interactive install \
  yast2-packager \
  yast2-storage-ng \
  yast2-sysconfig

# install the chroot wrapper client
COPY chroot_wrapper.rb /usr/share/YaST2/clients/
