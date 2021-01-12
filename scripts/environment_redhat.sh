# This is working around GitHub Actions running commands in non-login shells
# that would otherwise not have the `module` command available.
source /etc/profile.d/modules.sh
# Assume we only installed one version; otherwise you would have to specify an
# implementation/version of MPI.
module load mpi
export PATH=${HOME}/.local/bin:/usr/local/sbin:/usr/local/bin:${PATH}
