#!/bin/bash
# Delegate to a Docker-image-specific install script.
# This is done first because it may enable repositories that make the generic
# commands below work.
CONTAINER_SCRIPT="scripts/install_redhat_${OS_CONTAINER}.sh"
if [ -f "${CONTAINER_SCRIPT}" ]
then
  source "${CONTAINER_SCRIPT}"
fi

# Use DNF if available (not CentOS7), otherwise YUM
CMD=$(command -v dnf || command -v yum)
${CMD} upgrade -y
${CMD} install -y bison cmake dnf doxygen flex gcc gcc-c++ ${GIT_PACKAGE-git} \
  openmpi-devel libXcomposite-devel libXext-devel make ncurses-devel \
  python3-devel python3-pip python3-wheel sudo
