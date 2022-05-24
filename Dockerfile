# This is file defines a Docker container based on openSUSE Leap
# and installs few YaST modules.

# the default base image
ARG image=opensuse/leap:15.4
FROM ${image}

# install some YaST modules with the default ncurses UI
RUN zypper --non-interactive install \
  "rubygem(yast-rake)" \
  patch \
  yast2-registration

# redirect logging to the host
RUN mv /var/log /var/log.orig && mkdir -p /mnt/var/log/ && ln -s /mnt/var/log /var/log

# patch the Installation module
COPY Installation.diff .
RUN patch -i Installation.diff /usr/share/YaST2/modules/Installation.rb && rm Installation.diff

# patch the YaST starting scripts
COPY y2start.diff .
RUN patch -i y2start.diff /usr/lib/YaST2/bin/y2start && rm y2start.diff
COPY y2start_helpers.diff .
RUN patch -i y2start_helpers.diff /usr/lib64/ruby/vendor_ruby/*/yast/y2start_helpers.rb && rm y2start_helpers.diff
