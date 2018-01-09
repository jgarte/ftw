# gerbil-nix-env.sh -*- Shell -*-
# Copyright 2017 Francois-Rene Rideau <fare@tunes.org>
# This file is published under both LGPLv2.1 and Apache 2.0 licenses.
#
# Source this file into your shell environment to define important variables
# that let you compile with gerbil from within your interactive Nix environment.
#   source .../gerbil-nix-env.sh

if [ -n "${BASH_VERSION-}" ] ; then
    this=${BASH_SOURCE[0]}
elif [ -n "${ZSH_VERSION-}" ] ; then
    this=$0
elif [ -n "$this" ] ; then
    # For this file to work on shells other than bash and zsh, e.g. dash,
    # the caller must define the variable $this the location of a file
    # in the same directory as gerbil-nix-env.sh.
    # for instance my-gxi in this same directory uses:
    #    this=$0
    :
else
    echo "Unknown shell and \$this not defined" ; unset this ; set -u ; return 1
fi


###### USER-EDITABLE SETTINGS #####

# This setting assumes that this file is copied to or symlinked from the
# top directory for your Gerbil source.
# If that is not the case, adjust this variable accordingly
export MY_GERBIL_SRC=$(realpath "$(dirname "$this")")

# If you want other library directories in your loadpath, adjust this, too:
export GERBIL_LOADPATH=$MY_GERBIL_SRC

###### END OF USER-EDITABLE SETTINGS #####

# Enable more debugging, plus all I/O and source UTF-8 by default
export GAMBOPT=t8,f8,-8,dRr

export GERBIL_HOME=$(dirname "$(dirname "$(realpath "$(which gxc)")")")

# Get the flags for compiling and linking against openssl and other libraries.
eval "$(nix-shell '<nixpkgs>' --pure --attr gerbil --command \
  'echo "export \
     NIX_SHELL_PATH=\"$PATH\" \
     NIX_LDFLAGS=\"$NIX_LDFLAGS\" \
     NIX_BINTOOLS=\"$NIX_BINTOOLS\" \
     NIX_CC=\"$NIX_CC\" \
     NIX_CFLAGS_COMPILE=\"$NIX_CFLAGS_COMPILE\""')"

: ${ORIG_PATH:=$PATH}
export ORIG_PATH
export PATH="$NIX_SHELL_PATH:$ORIG_PATH"

# This enables the NIX wrapper
target=$("${NIX_CC}/bin/cc" -v 2>&1 | sed '/^Target: /!d ; s/^Target: // ; s/[^a-zA-Z0-9_]/_/g')
eval "export NIX_CC_WRAPPER_${target}_TARGET_HOST=1"
eval "export NIX_BINTOOLS_WRAPPER_${target}_TARGET_HOST=1"
