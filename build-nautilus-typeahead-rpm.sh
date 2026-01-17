#!/usr/bin/env bash

# build-nautilus-typeahead-rpm

# Automatically builds GNOME Files with type-ahead
# functionality for Fedora Workstation/Silverblue.

URL="https://github.com/nelsonaloysio/fedora-nautilus-typeahead"

NAME="nautilus"
ARCH="$(rpm -E %_arch)"
FLAGS="--prefix=/usr --buildtype=release -Ddocs=false -Dpackagekit=false"

USAGE="""Usage:
    $(basename $0) [-h] [-n NAUTILUS_VERSION] [-p PATCH_FILE] [-a ARCH_TYPE]
                   [--flags FLAGS] [--noclean] [-y|--assumeyes]

Arguments:
    -h, --help
        Show this help message and exit.
    -n, --nautilus NAUTILUS_VERSION
        Specify Nautilus package version (X-Y.fcZZ). Default: latest available.
    -p, --patch-file PATCH_FILE
        Specify patch file. Must match Nautilus version.
    -a, --arch ARCH_TYPE
        Specify architecture type. Default: same as running system.
    --flags FLAGS
        Specify Nautilus build flags. Replaces default flags.
        Default: '$FLAGS'.
    --noclean
        Do not clean build files and folders after building package.
    -y, --assumeyes
        Automatically answer yes to dnf install requirements."""

# Parse arguments.
while [[ $# -gt 0 ]]; do
    ARGS+=("$1")
    case $1 in
        -h|--help)
            echo "$USAGE"
            exit 0
            ;;
        -n|--nautilus)
            VERSION="$2"
            ARGS+=("$2")
            shift 2
            ;;
        -p|--patch-file)
            PATCH_FILE="$2"
            ARGS+=("$2")
            shift 2
            ;;
        -a|--arch)
            ARCH="$2"
            ARGS+=("$2")
            shift 2
            ;;
        --flags)
            FLAGS="$2"
            ARGS+=("$2")
            shift 2
            ;;
        --noclean)
            NOCLEAN=1
            shift
            ;;
        -y|--assumeyes)
            YES=1
            shift
            ;;
        *)
            shift
            ;;
    esac
done
set -- "${ARGS[@]}"

# Check system architecture.
if [ "$ARCH" != i686 -a "$ARCH" != x86_64 ]; then
    echo -e "[!] Unsupported architecture type: $ARCH, must be 'x86_64' or 'i686'."
    exit 1
fi

# Check if dnf is installed.
if [ -z "$(command -v dnf)" ]; then
    echo "[!] dnf package manager is required to build nautilus-typeahead with this script."
    exit 1
fi

# Select nautilus version.
if [ -z "$VERSION" ]; then
    VERSION="$(dnf list $NAME.$ARCH --showduplicates | tail -1 | awk '{print $2}')" &&
    echo -e "Auto-selected Nautilus package version: ${VERSION}..."
fi
RELEASE="$(echo $VERSION | cut -d- -f2 | cut -d. -f1)" &&
FEDORA="$(echo $VERSION | cut -d- -f2 | cut -d. -f2  | tr -d 'fc')" &&
VERSION="$(echo $VERSION | cut -f1 -d-)"

# Auto-select patch file.
if [ -z "$PATCH_FILE" ]; then
    PATCH_FILE="$(dirname "$(realpath "$0")")/patch/$VERSION/nautilus-restore-typeahead.patch"
fi

# Verify patch file exists.
if [ -f "$PATCH_FILE" ]; then
    echo "Using patch: '$PATCH_FILE'..."
else
    echo -e "[!] Unable to auto-select patch for this Nautilus version."
    exit 1
fi

# Set package full name.
PACKAGE="${NAME}-typeahead-${VERSION}-${RELEASE}.fc${FEDORA}.${ARCH}"
echo -e "\nBuild package: ${PACKAGE}..."

# Create RPM build directories.
echo -e "\nCreate RPM build directories..."
for directory in {BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
do
    [ ! -d ${HOME}/rpmbuild/$directory ] &&
    [ ! -L ${HOME}/rpmbuild/$directory ] &&
    mkdir -p ${HOME}/rpmbuild/$directory
done

# Install requirements.
echo -e "\nInstall requirements..."
sudo dnf install $([ "$YES" = 1 ] && echo '-y') \
    appstream-devel \
    desktop-file-utils \
    'dnf-command(download)' \
    gcc \
    gi-docgen \
    git \
    gnome-autoar-devel \
    gnome-desktop4-devel \
    gstreamer1-plugins-base-devel \
    libadwaita-devel \
    libappstream-glib \
    libgexiv2-devel \
    libportal-gtk3-devel \
    libportal-gtk4-devel \
    meson \
    pkgconfig \
    rpm-build \
    rpmrebuild \
    wget \
    $( [ "$FEDORA" -lt 43 ] && echo "tracker-devel" ) \
    $( [ "$FEDORA" -ge 43 ] && echo "localsearch" ) \
    $( [ "$FEDORA" -ge 43 ] && echo "pkgconfig(tracker-sparql-3.0)" )

# Prepare build directory.
mkdir -p build/${PACKAGE}
cd build/${PACKAGE}

# Download and extract RPM source files.
mkdir -p ${NAME}-${VERSION}
cd ${NAME}-${VERSION}
# if [ ! -f ${NAME}-${VERSION}-${RELEASE}.fc${FEDORA}.src.rpm ]; then
echo -e "\nDownload RPM source..."
dnf download --source ${NAME}-${VERSION}-${RELEASE}.fc${FEDORA}.${ARCH}
# fi
echo -e "\nExtract RPM files..."
rpm2cpio ${NAME}-${VERSION}-${RELEASE}.fc${FEDORA}.src.rpm |
cpio --extract -dvm

# Copy patch file to build directory.
cp "$PATCH_FILE" .

# Enable type-ahead functionality by default.
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=nautilus-typeahead
awk -i inplace \
    '/type-ahead-search/{c++;} c==1 && /true/{sub("true", "false"); c++;} 1' \
    nautilus-restore-typeahead.patch

# Edit package spec file.
sed -i 's/Name: .* nautilus/Name: nautilus-typeahead/' nautilus.spec
sed -i 's/%{name}/nautilus/g' nautilus.spec
sed -i 's/Source0/Patch: nautilus-restore-typeahead.patch\nSource0/' nautilus.spec
sed -i "s/Source0/Provides: nautilus = %{version}\nSource0/" nautilus.spec
sed -i "s/Source0/Obsoletes: nautilus\nSource0/" nautilus.spec
sed -i 's/Requires: .*nautilus/Requires: nautilus-typeahead/' nautilus.spec
# sed -i 's/nautilus-typeahead-extensions/nautilus-extensions/' nautilus.spec
# sed -i 's/%package extensions/%package extensions\nProvides: nautilus-extensions = %{version}/' nautilus.spec
# sed -i 's/%package extensions/%package extensions\nObsoletes: nautilus-extensions/' nautilus.spec
sed -i 's/%package devel/%package devel\nProvides: nautilus-devel = %{version}/' nautilus.spec
mv -f nautilus.spec ${HOME}/rpmbuild/SPECS/nautilus-typeahead.spec

# Copy source files to RPM build directory.
ls -1 | xargs -I {} cp -f {} ${HOME}/rpmbuild/SOURCES/
cd ../../..

# Build RPM files.
echo -e "\nBuild RPM file..."
rpmbuild -bs ${HOME}/rpmbuild/SPECS/nautilus-typeahead.spec
rpmbuild -ba $([ -n "$NOCLEAN"] && echo --noclean) \
    ${HOME}/rpmbuild/SPECS/nautilus-typeahead.spec

# Clean up leftover build files.
if [ -z "$NOCLEAN" ]; then
    rm -rf build/${NAME}-typeahead-${VERSION}-${RELEASE}.fc${FEDORA}.${ARCH}
fi

# Check if file was built.
if [ ! -f "${HOME}/rpmbuild/RPMS/${ARCH}/${PACKAGE}.rpm" ]; then
    echo -e "Failed to build '${PACKAGE}.rpm'.\n
    Please submit an issue with the log of execution if desired to:
    > ${URL}/issues"
    exit 1
fi

# Copy RPM file to current directory.
cp ${HOME}/rpmbuild/RPMS/${ARCH}/${NAME}-typeahead*-${VERSION}-${RELEASE}.fc${FEDORA}.${ARCH}.rpm build/
cp ${HOME}/rpmbuild/SRPMS/${NAME}-typeahead-${VERSION}-${RELEASE}.fc${FEDORA}.src.rpm build/

# Print success message and suggest cleaning dependencies.
echo -e "\nSuccessfully built '${PACKAGE}'."
echo "Build files may be removed from $HOME/rpmbuild."

echo -e "\nInstalled dependencies may be removed with:"
echo "$ dnf history undo \$(dnf history list --reverse | tail -n1 | cut -f1 -d\|)"
