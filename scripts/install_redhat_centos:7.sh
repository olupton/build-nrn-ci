#!/bin/bash
# EPEL is needed to get CMake 3 in CentOS7
# SCL is needed to get a modern toolchain in CentOS7
# The default CentOS7 git version is too old, which causes the checkout module
# (https://github.com/actions/checkout) to fall back to using a REST API and
# break subsequent initialisation of git submodules. This eventually makes the
# NEURON CI fail. Work around this by installing a newer git client from IUS.
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
  https://repo.ius.io/ius-release-el7.rpm \
  centos-release-scl

# Install a newer toolchain for CentOS7
yum install -y cmake3 ${SOFTWARE_COLLECTIONS_centos_7}

# Tell the install_redhat.sh which git package to install
GIT_PACKAGE=git224

# Make sure `cmake` and `ctest` see the 3.x versions, instead of the ancient
# CMake 2 included in CentOS7
alternatives --install /usr/local/bin/cmake cmake /usr/bin/cmake3 20 \
  --slave /usr/local/bin/ctest ctest /usr/bin/ctest3 \
  --slave /usr/local/bin/cpack cpack /usr/bin/cpack3 \
  --slave /usr/local/bin/ccmake ccmake /usr/bin/ccmake3
