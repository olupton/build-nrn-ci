#!/bin/bash
if [ -n "${OS_CONTAINER}" ]
then
  # We are running under Docker
  if [ -z ${UNPRIVILEGED_USER+x} ]
  then
    echo "You must set the UNPRIVILEGED_USER variable."
    exit 1
  fi
  CMD_PREFIX="sudo -u ${UNPRIVILEGED_USER} --set-home"
  # Construct a variable name listing RedHat Software Collections that must be
  # enabled. This is something like SOFTWARE_COLLECTIONS_centos_7, where the
  # : separator from Docker and any . have been replaced with _
  SOFTWARE_COLLECTIONS_NAME="SOFTWARE_COLLECTIONS_${OS_CONTAINER//[:.]/_}"
  # Get the list of software collections for this image
  SOFTWARE_COLLECTIONS="${!SOFTWARE_COLLECTIONS_NAME}"
  # If there are any, inject an `scl enable` layer into the commandline
  if [ -n "${SOFTWARE_COLLECTIONS}" ]
  then
    CMD_PREFIX="${CMD_PREFIX} scl enable ${SOFTWARE_COLLECTIONS} --"
  fi
fi
echo "Wrapper script generated command prefix: ${CMD_PREFIX}"
${CMD_PREFIX} sh -c "INSTALL_DIR=${INSTALL_DIR} OS_FLAVOUR=${OS_FLAVOUR} bash --noprofile --norc -eo pipefail $@"
