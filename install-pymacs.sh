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

# Find the install command
# We'll look for dnf (Red Hat/Fedora), apt-get (Debian/Ubuntu), and brew (MacOS)
CHECK_CMD=$(which dnf 2> /dev/null)
if [[ -x "${CHECK_CMD}" ]]; then
    INSTALL_CMD="sudo ${CHECK_CMD} install -y"
fi
CHECK_CMD=$(which apt-get 2> /dev/null)
if [[ -x "${CHECK_CMD}" ]]; then
    INSTALL_CMD="sudo ${CHECK_CMD} install -y"
fi
CHECK_CMD=$(which brew 2> /dev/null)
if [[ -x "${CHECK_CMD}" ]]; then
    INSTALL_CMD="${CHECK_CMD} install"
fi

echo "Using ${INSTALL_CMD} to install."

if [[ `uname` == 'Linux' ]]; then
    echo "Apparently on Raspbian, Ubuntu, and Debian, pyopenssl needs python-dev and libffi"
    echo "in order to compile and install.  It mostly seems to work without"
    echo "them anyway, but if you want to sudo, here you go."
    echo " "
    echo "${INSTALL_CMD} python3-pip libssl-dev libffi-dev python-dev"
    ${INSTALL_CMD} python3-pip libssl-dev libffi-dev python-dev
    sudo pip install -U setuptools
fi

if [[ -d ~/.emacs.d/lisp ]]; then
    USER_LISP_DIR="$HOME/.emacs.d/lisp"
elif [[ -d ~/.emacs.d ]]; then
    USER_LISP_DIR="$HOME/.emacs.d"
else
    echo "Couldn't guess a good place to put pymacs.el."
    echo "You should manually copy it from $HOME/pymacs.el to your emacs init directory."
    USER_LISP_DIR="$HOME"
fi

python -m pip install $USERFLAG --upgrade pyopenssl
python -m pip install rope ropemacs $USERFLAG python

python -m pip install --editable "git+https://github.com/dgentry/Pymacs.git#egg=Pymacs"
pushd "$SRC"
cd pymacs/
make check
${SUDO} make install
echo " "
echo "Copying pymacs.el to $USER_LISP_DIR"
cp pymacs.el $USER_LISP_DIR
echo " "
popd
echo "Finished in:" $(pwd)
cd
echo "Final check:"
python -c 'import Pymacs'
