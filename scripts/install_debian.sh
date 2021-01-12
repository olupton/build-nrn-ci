#!/bin/bash
# Avoid apt-get install hanging asking for user input to configure packages
export DEBIAN_FRONTEND=noninteractive

# Use sudo if its available (typically no inside Docker and yes outside)
SUDO=`which sudo || true`
${SUDO} apt-get update
${SUDO} apt-get upgrade -y
${SUDO} apt-get install -y bison cmake doxygen flex libncurses-dev \
  libopenmpi-dev libx11-dev libxcomposite-dev openmpi-bin python3-numpy \
  python3-pip python3-setuptools python3-wheel sudo
