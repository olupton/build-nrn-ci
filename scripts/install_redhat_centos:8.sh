#!/bin/bash
# This repository is needed to get Doxygen in CentOS8
dnf install -y 'dnf-command(config-manager)'
dnf config-manager --set-enabled powertools
