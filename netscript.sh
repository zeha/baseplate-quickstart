#!/bin/bash
# (Indirect) Dependencies:
# imvirt git ruby fai-setup-storage grml-debootstrap (>= 0.47) baseplate

# to be adjusted by the user
GITREPOS='git://github.com/zeha/baseplate-quickstart.git'
REPOSDIR="$(basename ${GITREPOS} .git)" # directory name (without .git)

die() {
  printf -- "$*\n" >&2
  exit 1
}

# FIXME - baseplate should be available ootb {{{
cd
if ! [ -d baseplate.git ] ; then
  git clone git://github.com/zeha/baseplate.git
else
  cd baseplate.git
  git pull --rebase
  cd
fi
BASEPLATE=$HOME/baseplate/bin/baseplate
# }}}

if ! [ -d "$REPOSDIR" ] ; then
  if ! git clone "${GITREPOS}" ; then
    die "Error cloning git repository ${GITREPOS}."
  fi
fi

if cd $REPOSDIR ; then
  git pull --rebase
else
  die "Error switching to git repository."
fi

if [ -e stage1.sh ] ; then
  . stage1.sh
else
  die "Could not find stage1.sh script to execute."
fi

if [ -z "$RECIPE" ] ; then
  die "Error: recipe (\$RECIPE) not set."
fi

if ! "$BASEPLATE" "${RECIPE}" ; then
  die "Error executing baseplate recipe ${RECIPE}"
fi

## END OF FILE #################################################################
# vim: ai expandtab foldmethod=marker shiftwidth=2
