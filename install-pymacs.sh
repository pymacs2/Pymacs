#!/bin/bash

# Install pymacs stuff that emacs needs (outside emacs), into the current
# virtual environment, if there is one.

if [[ -e "$VIRTUAL_ENV" ]]; then
    echo "Installing (rope, ropemacs, and) pymacs into virtual environment $VIRTUAL_ENV"
    SRC="$VIRTUAL_ENV/src"
    USERFLAG=
    SUDO=
else
    SRC=src
    USERFLAG=--user
    SUDO=sudo
    echo "Doing a user install of rope and ropemacs."
fi

pip install rope ropemacs $USERFLAG python

pip install --editable "git+https://github.com/pinard/Pymacs.git#egg=Pymacs"
pushd "$SRC"
cd pymacs/
make check
${SUDO} make install
popd
echo "Finished in:" $(pwd)
cd
echo "Final check:"
python -c 'import Pymacs'
