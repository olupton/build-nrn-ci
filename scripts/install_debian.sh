#!/bin/bash
# Avoid apt-get install hanging asking for user input to configure packages
export DEBIAN_FRONTEND=noninteractive

# Delegate to a Docker-image-specific install script.
# This is done first because it may enable repositories that make the generic
# commands below work.
CONTAINER_SCRIPT="scripts/install_debian_${OS_CONTAINER}.sh"
if [ -f "${CONTAINER_SCRIPT}" ]; then
  source "${CONTAINER_SCRIPT}"
fi

# Use sudo if its available (typically no inside Docker and yes outside)
SUDO=`command -v sudo || true`
${SUDO} apt-get update
${SUDO} apt-get install -y bison cmake doxygen flex git libncurses-dev \
  libopenmpi-dev libx11-dev libxcomposite-dev openmpi-bin python3-numpy \
  python3-pip python3-setuptools python3-wheel sudo
