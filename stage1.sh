#!/bin/bash

# defaults {{{
BRANCH='production'
RECIPE='examples/recipe.bp'
LOGO='true'
# }}}

# helper functions {{{
CMD_LINE=$(cat /proc/cmdline)
stringInString() {
  local to_test_="$1"   # matching pattern
  local source_="$2"    # string to search in
  case "$source_" in *$to_test_*) return 0;; esac
  return 1
}

checkBootParam() {
  stringInString " $1" "$CMD_LINE"
  return "$?"
}

getBootParam() {
  local param_to_search="$1"
  local result=''

  stringInString " $param_to_search=" "$CMD_LINE" || return 1
  result="${CMD_LINE##*$param_to_search=}"
  result="${result%%[   ]*}"
  echo "$result"
  return 0
}

logo() {
  cat <<-EOF
+++ baseplate deployment +++

$(cat /etc/grml_version)

$CHASSIS
$(ip-screen)
$(lscpu | awk '/^CPU\(s\)/ {print $2}') CPUs | $(/usr/bin/gawk '/MemTotal/{print $2}' /proc/meminfo)kB RAM
Started deployment at $(date)
--------------------------------------------------------------------------------
EOF
}

display_logo() {
  if "$LOGO" ; then
    echo -ne "\ec\e[1;32m"
    logo
    echo -ne "\e[9;0r"
    echo -ne "\e[9B\e[1;m"
  fi
}

check_grml_cd() {
  if ! [ -r /etc/grml_cd ] ; then
    echo "Not running inside Grml, better safe than sorry. Sorry." >&2
    return 1
  fi
}

check_virtual() {
  if [[ $(imvirt 2>/dev/null) != "KVM" ]] ; then # FIXME
    echo "Physical installation found, refusing to do anything." >&2
    return 1
  fi
}
# }}}

# main execution {{{
check_grml_cd || exit 1
check_virtual || exit 1

display_logo

cd ~/baseplate-quickstart

if checkBootParam "deploybranch" ; then
  BRANCH=$(getBootParam deploybranch)
  if [ -n "$BRANCH" ] ; then
    echo "Using branch $BRANCH for deployment."
  else
    die "No branch name given for deploybranch."
  fi
fi

if git tag | grep -q "$BRANCH" ; then
  git pull --rebase
  git checkout master # make sure we're not on a branch we delete in next step
  git branch -D deployment/$BRANCH # delete possibly already existing branch
  git checkout -b deployment/$BRANCH $BRANCH
fi
# }}}

## END OF FILE #################################################################
# vim: ai expandtab foldmethod=marker shiftwidth=2
