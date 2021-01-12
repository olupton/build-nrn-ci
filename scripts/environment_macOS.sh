#!/bin/bash
PYTHON_USER_BASE=$(python3 -c "import site; print(site.USER_BASE)")
export PATH=${PYTHON_USER_BASE}/bin:${PATH}
export JUPYTER_PATH=${PYTHON_USER_BASE}/share/jupyter
echo "macOS: PATH=${PATH}"
