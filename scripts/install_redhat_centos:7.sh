#!/bin/bash
# EPEL is needed to get CMake 3 in CentOS7
# SCL is needed to get a modern toolchain in CentOS7
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
  centos-release-scl

# Install a newer toolchain for CentOS7
yum install -y cmake3 ${SOFTWARE_COLLECTIONS_centos_7}

# Make sure `cmake` and `ctest` see the 3.x versions, instead of the ancient
# CMake 2 included in CentOS7
alternatives --install /usr/local/bin/cmake cmake /usr/bin/cmake3 20 \
  --slave /usr/local/bin/ctest ctest /usr/bin/ctest3 \
  --slave /usr/local/bin/cpack cpack /usr/bin/cpack3 \
  --slave /usr/local/bin/ccmake ccmake /usr/bin/ccmake3
