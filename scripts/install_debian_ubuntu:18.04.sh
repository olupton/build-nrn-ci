#!/bin/bash
# As with CentOS7, the default Git is too old for the GitHub Actions checkout
# module. Install a newer one.
apt-get install -y software-properties-common
add-apt-repository -y ppa:git-core/ppa
