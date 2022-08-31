#!/bin/sh

WD="$( dirname "$0"; printf a )"; WD="${WD%?a}"
cd "${WD}" || { printf "Could not cd to directory of '%s'" "$0" >&2; exit 1; }
WD="$( pwd -P; printf a )"; WD="${WD%?a}"


TETRACLI="${1-"${WD}/tetra/target/debug/tetra-cli"}"
NL='
'
foreach_relative_paths() (
  cd "$1" || die 1 "FATAL: \`list_relative_paths\` - \"$1\" does not exist"
  list="${NL}././"  # Prefix all the files with ././ (last hh)
  while [ "${list}" != "" ]; do  # Add limit to dodge infinite loop?
    dir="${list#${NL}}"
    dir="${dir%%${NL}././*}"
    list="${list#"${NL}${dir}"}"

    for f in "${dir}"* "${dir}".[!.]* "${dir}"..?*; do
      [ ! -e "${f}" ] && continue
      [ ! -L "${f}" ] && [ -d "${f}" ] && list="${list}${NL}${f}/"
      [ -f "${f}" ] && "${2}" "${f}"
    done
  done
)



action() {
  [ "${1}" != "${1#*/.git/}" ] && return 0
  if [ "${1}" != "${1%.md}" ]; then
    #tetra/target/debug/tetra-cli parse 
    out="${WD}/docs/${1}"
    mkdir -p "${out%/*}"
    "${TETRACLI}" parse "${1}" "${out}"
  fi
}

[ -d "docs" ] && rm -r "docs"
mkdir -p docs
foreach_relative_paths . action
