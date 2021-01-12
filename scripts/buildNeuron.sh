#!/bin/bash
if [ -z ${OS_FLAVOUR+x} ]
then
  echo "You must set the OS_FLAVOUR variable."
  exit 1
fi
# Do things like `module load mpi` that need to modify the current environment
source ../scripts/environment_${OS_FLAVOUR}.sh

# Choose which Python version to use
export PYTHON=$(command -v python3)

# TODO remove some of these packages
${PYTHON} -m pip install --user --upgrade -r docs/docs_requirements.txt bokeh cython ipython matplotlib mpi4py \
  pytest scikit-build

# Set default compilers, but don't override preset values
export CC=${CC:-gcc}
export CXX=${CXX:-g++}

# Some logging
echo LANG=${LANG}, LC_ALL=${LC_ALL}
echo PATH=${PATH}
echo CC=${CC} \($(command -v ${CC})\) version $(${CC} -dumpversion)
echo CXX=${CXX} \($(command -v ${CXX})\), version $(${CXX} -dumpversion)
echo git \($(command -v git)\) version $(git --version | cut -d ' ' -f 3-)
echo python \(${PYTHON}\) version $(${PYTHON} --version | cut -d ' ' -f 2-)
echo CMake \($(command -v cmake)\)
cmake --version
${PYTHON} -c 'import os, sys; os.set_blocking(sys.stdout.fileno(), True)'

# TODO see if this is still needed
#if [ "$RUNNER_OS" == "macOS" ]; then
  # Python is not installed as a framework, so we need to writ 'backend: TkAgg' to `matplotlibrc`.
  # Since we are in a virtual environment, we cannot use `$HOME/matplotlibrc`
  # The following solution is generic and relies on `matplotlib.__file__` to know where to append backend setup.
  #$PYTHON -c "import os,matplotlib; f =open(os.path.join(os.path.dirname(matplotlib.__file__), 'mpl-data/matplotlibrc'),'a'); f.write('backend: TkAgg');f.close();"
#fi;
export CMAKE_OPTION="-DNRN_ENABLE_BINARY_SPECIAL=ON -DNRN_ENABLE_MPI=ON -DNRN_ENABLE_INTERVIEWS=ON -DNRN_ENABLE_CORENEURON=ON -DPYTHON_EXECUTABLE=${PYTHON}"
mkdir build
pushd build
echo "Building with: ${CMAKE_OPTION}"
cmake ${CMAKE_OPTION}  -DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CXX} -DNRN_ENABLE_TESTS=ON -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} ..
cmake --build . -- -j
# TODO see if this is still needed
if [ "$RUNNER_OS" == "macOS" ]; then
  echo $'[install]\nprefix='>src/nrnpython/setup.cfg
fi
make install
# Make sure the installed files can be found
export PATH=${INSTALL_DIR}/bin:${PATH}
export PYTHONPATH=${INSTALL_DIR}/lib/python:${PYTHONPATH}
echo "------- Run test suite -------"
ctest -VV
# We're still in the build/ directory here
echo "------- Build Doxygen Documentation -------"
make docs
echo ::set-output name=status::done
