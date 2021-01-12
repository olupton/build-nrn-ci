#!/bin/bash
if [ -z ${OS_FLAVOUR+x} ]
then
  echo "You must set the OS_FLAVOUR variable."
  exit 1
fi
# TODO factor out common code from different Linux flavours
source scripts/environment_${OS_FLAVOUR}.sh
# TODO remove some of these packages
python3 -m pip install --user --upgrade -r docs/docs_requirements.txt bokeh cython ipython matplotlib mpi4py \
  pytest scikit-build
echo "Jupyter paths:"
jupyter --paths --debug

# OS related
if [ "$RUNNER_OS" == "Linux" ]; then
  export CC=gcc
  export CXX=g++
  export SHELL="/bin/bash"
else
  export CXX=${CXX:-g++};
  export CC=${CC:-gcc};
fi
# TODO see if this can be removed
if [ "$RUNNER_OS" == "macOS" ]; then
  # TODO - this is a workaround that was implemented for Azure being reported as getting stuck.
  # However it does not get stuck: neuron module not found and script goes to interpreter, seeming stuck.
  # This needs to be addressed and SKIP_EMBEDED_PYTHON_TEST logic removed everywhere.
  export SKIP_EMBEDED_PYTHON_TEST="true"
fi
# Some logging
echo LANG=${LANG}, LC_ALL=${LC_ALL}
echo PATH=${PATH}
echo CC=${CC} \($(command -v ${CC})\) version $(${CC} -dumpversion)
echo CXX=${CXX} \($(command -v ${CXX})\), version $(${CXX} -dumpversion)
echo git \($(command -v git)\) version $(git --version | cut -d ' ' -f 3-)
echo CMake \($(command -v cmake)\)
cmake --version
python3 -c 'import os, sys; os.set_blocking(sys.stdout.fileno(), True)'

# Python setup
export PYTHON=$(which python3)
export PYTHONPATH=${PYTHONPATH}:${INSTALL_DIR}/lib/python
# TODO see if this is still needed
if [ "$RUNNER_OS" == "macOS" ]; then
  # Python is not installed as a framework, so we need to writ 'backend: TkAgg' to `matplotlibrc`.
  # Since we are in a virtual environment, we cannot use `$HOME/matplotlibrc`
  # The following solution is generic and relies on `matplotlib.__file__` to know where to append backend setup.
  $PYTHON -c "import os,matplotlib; f =open(os.path.join(os.path.dirname(matplotlib.__file__), 'mpl-data/matplotlibrc'),'a'); f.write('backend: TkAgg');f.close();"
fi;
export CMAKE_OPTION="-DNRN_ENABLE_BINARY_SPECIAL=ON -DNRN_ENABLE_MPI=ON -DNRN_ENABLE_INTERVIEWS=ON -DNRN_ENABLE_CORENEURON=ON -DPYTHON_EXECUTABLE=${PYTHON}"
mkdir build
pushd build
echo "Building with: ${CMAKE_OPTION}"
cmake $CMAKE_OPTION  -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX -DNRN_ENABLE_TESTS=ON -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR ..
cmake --build . -- -j
# TODO see if this is still needed
if [ "$RUNNER_OS" == "macOS" ]; then
  echo $'[install]\nprefix='>src/nrnpython/setup.cfg
fi
make install
export PATH=${INSTALL_DIR}/bin:${PATH}
echo "------- Run test suite -------"
ctest -VV
# We're still in the build/ directory here
echo "------- Build Doxygen Documentation -------"
make docs
echo ::set-output name=status::done
