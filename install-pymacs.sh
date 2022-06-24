#!/bin/bash

# Install pymacs stuff that emacs needs (outside emacs), into the current
# virtual environment, if there is one.

# Variables for colors/contrast
txtbld=$(tput bold)             # Bold
bldblu=${txtbld}$(tput setaf 4) #  blue
txtrst=$(tput sgr0)             # Reset

myname='install-pymacs'
# Provide our messages with our name, and contrast to the other
# install messages that will be going by
msg() {
    echo "$bldblu${myname}: $*${txtrst}"
}


if [[ -e "$VIRTUAL_ENV" ]]; then
    msg "Installing (rope, ropemacs, and) pymacs into virtual environment $VIRTUAL_ENV"
    SRC="$VIRTUAL_ENV/src"
    USERFLAG=
    SUDO=
else
    SRC=src
    USERFLAG=--user
    SUDO=sudo
    msg "Doing a user install of rope and ropemacs."
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

msg "Using ${INSTALL_CMD} to install."

if [[ `uname` == 'Linux' ]]; then
    msg "Apparently on Raspbian, Ubuntu, and Debian, pyopenssl needs python-dev and libffi"
    msg "in order to compile and install.  It mostly seems to work without"
    msg "them anyway, but if you want to sudo, here you go."
    msg " "
    PKGS='python3-pip python3-dev'
    msg "${INSTALL_CMD}  ${PKGS}"
    ${INSTALL_CMD} ${PKGS}
    sudo pip install -U setuptools
    PKGS='libssl-dev libffi-dev'
    msg "${INSTALL_CMD} ${PKGS}"
fi

if [[ -d ~/.emacs.d/lisp ]]; then
    USER_LISP_DIR="$HOME/.emacs.d/lisp"
elif [[ -d ~/.emacs.d ]]; then
    USER_LISP_DIR="$HOME/.emacs.d"
else
    msg "Couldn't guess a good place to put pymacs.el."
    msg "You should manually copy it from $HOME/pymacs.el to your emacs init directory."
    USER_LISP_DIR="$HOME"
fi

python -m pip install $USERFLAG --upgrade pyopenssl
python -m pip install rope ropemacs

python -m pip install --editable "git+https://github.com/dgentry/Pymacs.git#egg=Pymacs"
pushd "$SRC"
cd pymacs/
msg "Running tests"
make check
msg "Installing"
${SUDO} make install
msg " "
msg "Copying pymacs.el to $USER_LISP_DIR"
cp pymacs.el $USER_LISP_DIR
msg " "
cd ..
msg "Final check:"
python -c 'import Pymacs'
if [ $? ]; then
    msg "Success."
else
    msg "Some kind of error: Status was $?"
fi
