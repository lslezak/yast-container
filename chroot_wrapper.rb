# ------------------------------------------------------------------------------
# Copyright (c) 2017 SUSE LLC
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of version 2 of the GNU General Public License as published by the
# Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# ------------------------------------------------------------------------------
#

require "yast"

client = Yast::WFM.Args.first
abort "Missing client name" if client.to_s.empty?

puts "Changing system target to /mnt..."
Yast.import "Installation"
Yast::Installation.destdir = "/mnt"

old_handle = Yast::WFM.SCRGetDefault
handle = Yast::WFM.SCROpen("chroot=#{Yast::Installation.destdir}:scr", false)
Yast::WFM.SCRSetDefault(handle)

# initialize the package manager in the /mnt chroot
# (This is not strictly required by all clients, but as we do not know whether
# the client will or will not use the package management so we do it always
# just to be safe.)
Yast.import "Pkg"
Yast::Pkg.TargetInitialize(Yast::Installation.destdir)
Yast::Pkg.TargetLoad
Yast::Pkg.SourceRestore
Yast::Pkg.SourceLoad

puts "Running client #{client}"
ret = Yast::WFM.call(client)
puts "Return value: #{ret}"

Yast::WFM.SCRSetDefault(old_handle)
Yast::WFM.SCRClose(handle)
