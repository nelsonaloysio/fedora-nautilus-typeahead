#! /bin/sh -x

NAME="nautilus"
ARCH="$(rpm -E %_arch)"
VERSION="45.2.1"
FEDORA="39"
RELEASE="1"
URL="https://github.com/nelsonaloysio/fedora-nautilus-typeahead"

if [ -z "$VERSION" ]; then
  VERSION="$(dnf list $NAME.$ARCH --showduplicates | tail -1 | awk '{print $2}')"
  [ -z "$FEDORA" ] && FEDORA="$(echo $VERSION | cut -d- -f2 | cut -d. -f2  | tr -d 'fc')"
  [ -z "$RELEASE" ] && RELEASE="$(echo $VERSION | cut -d- -f2 | cut -d. -f1)"
  VERSION="$(echo $VERSION | cut -f1 -d-)"
  echo "Auto-selected Nautilus package release version ${VERSION}-${RELEASE}.fc${FEDORA}."
fi

[ -z "$COPR_RESULTDIR" ] && COPR_RESULTDIR="."

wget \
  "${URL}/releases/download/${VERSION}/${NAME}-typeahead-${VERSION}-${RELEASE}.fc${FEDORA}.${ARCH}.spec"\
  -qO "${COPR_RESULTDIR}/$NAME-typeahead.spec"