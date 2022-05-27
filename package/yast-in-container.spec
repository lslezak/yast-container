#
# spec file for package yast2
#
# Copyright (c) 2022 SUSE LINUX GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via https://bugs.opensuse.org/
#


Name:           yast-in-container
Version:        4.5.0

Release:        0
Summary:        YaST2 Main Package
License:        GPL-2.0-only
Group:          System/YaST
URL:            https://github.com/yast/yast-yast2
Source0:        %{name}-%{version}.tar.bz2

# recommend Podman for running the containers, optionally Docker might be used
Recommends:     podman

%description
This package contains scripts and data needed for SUSE Linux
installation with YaST2

%prep
%setup -q

%build

%install

%if !0%{?usrmerged}
mkdir -p %{buildroot}/sbin
ln -s ../%{_sbindir}/yast_container  %{buildroot}/sbin
ln -s ../%{_sbindir}/yast2_container %{buildroot}/sbin
%endif



# documentation (not included in devel subpackage)
%doc %dir %{yast_docdir}
%license %{yast_docdir}/COPYING
%doc %{yast_docdir}/README.md


%if !0%{?usrmerged}
/sbin/yast*_container
%endif

%{_sbindir}/yast*


%changelog
