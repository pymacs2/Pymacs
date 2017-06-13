#!/bin/bash -x

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

# Older rpi might be "armv6l"
if [[ `uname` == 'Linux' && `uname -m` == "armv7l" ]]; then
    echo "Apparently on Raspbian, pyopenssl needs python-dev and libffi"
    echo "in order to compile and install.  It mostly seems to work without"
    echo "them anyway, but if you want to sudo, here you go."
    echo " "
    sudo apt-get install python-dev libffi-dev
fi

python -m pip install $USERFLAG --upgrade pyopenssl
python -m pip install rope ropemacs $USERFLAG python

python -m pip install --editable "git+https://github.com/pinard/Pymacs.git#egg=Pymacs"
pushd "$SRC"
cd pymacs/
make check
${SUDO} make install
popd
echo "Finished in:" $(pwd)
cd
echo "Final check:"
python -c 'import Pymacs'
