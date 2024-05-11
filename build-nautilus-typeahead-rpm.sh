#!/usr/bin/env bash

# build-nautilus-typeahead-rpm

# Automatically builds GNOME Files with type-ahead
# functionality for Fedora Workstation/Silverblue.

URL="https://github.com/nelsonaloysio/build-nautilus-typeahead-rpm"
URL_NAUTILUS="https://github.com/GNOME/nautilus/archive/refs/tags/46.1.tar.gz"
URL_PATCH="https://github.com/lubomir-brindza/nautilus-typeahead/archive/refs/tags/46-beta-0ubuntu3ppa2.tar.gz"

NAME="nautilus"
VERSION="46.1"
FEDORA="$(rpm -E %fedora)"
RELEASE="1"
ARCH="x86_64"

# Create RPM build directories
echo -e "Create RPM build directories..."
for directory in {BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
do
    [ ! -d ${HOME}/rpmbuild/$directory ] &&
    [ ! -L ${HOME}/rpmbuild/$directory ] &&
    mkdir -p ${HOME}/rpmbuild/$directory
done

# Install requirements.
echo -e "\nInstall requirements..."
sudo dnf install \
    git \
    gnome-autoar-devel \
    gstreamer1-plugins-base-devel \
    libgexiv2-devel \
    libportal-gtk3-devel \
    libportal-gtk4-devel \
    meson \
    rpmrebuild \
    tracker-devel

# Create new folder and change directory.
echo -e "\nCreate new folder and change directory..."
rm -rf build-nautilus-typeahead-rpm &&
mkdir build-nautilus-typeahead-rpm &&
cd build-nautilus-typeahead-rpm

# Download and extract nautilus.
echo -e "\nDownload and extract nautilus..."
wget "$URL_NAUTILUS" -O nautilus.tar.gz
tar -xzvf nautilus.tar.gz

# Download and extract nautilus-typeahead patch.
echo -e "\nDownload and extract nautilus-typeahead patch..."
wget "$URL_PATCH" -O nautilus-restore-typeahead.tar.gz
tar -xzvf \
    nautilus-restore-typeahead.tar.gz \
    --strip 1 \
    '*nautilus-restore-typeahead.patch'

# Patch source code.
echo -e "\nPatch source code..."
patch \
    --directory="${NAME}-${VERSION}" \
    --strip=1 < \
    nautilus-restore-typeahead.patch

# Change directory.
echo -e "\nChange directory..."
mkdir -p ${NAME}-${VERSION}/build &&
cd ${NAME}-${VERSION}/build

# Setup and build patched nautilus.
echo -e "\nSetup and build patched nautilus..."
meson setup \
    --prefix=/usr \
    --buildtype=release \
    -Dpackagekit=false \
    # -Dselinux=false

ninja

# Download RPM and extract files.
echo -e "\nDownload RPM and extract files..."
cd ../..

dnf download ${NAME}-${VERSION}-${RELEASE}.fc${FEDORA}.${ARCH}

rpm2cpio ${NAME}-${VERSION}-${RELEASE}.fc${FEDORA}.${ARCH}.rpm |
cpio -idmv

# Rebuild and edit spec file.
echo -e "\nRebuild and edit spec file..."

rpmrebuild -s \
    ${HOME}/rpmbuild/SPECS/${NAME}-typeahead-${VERSION}-${RELEASE}.fc${FEDORA}.${ARCH}.spec \
    ${NAME}-${VERSION}-${RELEASE}.fc${FEDORA}.${ARCH}.rpm

sed -i 's/Name: .* nautilus/Name: nautilus-typeahead/' \
    ${HOME}/rpmbuild/SPECS/${NAME}-typeahead-${VERSION}-${RELEASE}.fc${FEDORA}.${ARCH}.spec

# sed -i "s/Provides: .* nautilus =/Obsoletes: .* nautilus =/" \
#     ${HOME}/rpmbuild/SPECS/${NAME}-typeahead-${VERSION}-${RELEASE}.fc${FEDORA}.${ARCH}.spec

# Copy and replace modified files.
echo -e "\nCopy and replace modified files..."
cp -f \
    ${NAME}-${VERSION}/build/src/nautilus \
    usr/bin/nautilus

cp -f \
    ${NAME}-${VERSION}/data/org.gnome.nautilus.gschema.xml \
    usr/share/glib-2.0/schemas/org.gnome.nautilus.gschema.xml

# Create new folder and store build files.
mkdir -p ${HOME}/rpmbuild/BUILDROOT/${NAME}-typeahead-${VERSION}-${RELEASE}.fc${FEDORA}.${ARCH}
cp -r usr ${HOME}/rpmbuild/BUILDROOT/${NAME}-typeahead-${VERSION}-${RELEASE}.fc${FEDORA}.${ARCH}

# Build RPM file.
echo -e "\nBuild RPM file..."
rpmbuild -ba ${HOME}/rpmbuild/SPECS/${NAME}-typeahead-${VERSION}-${RELEASE}.fc${FEDORA}.${ARCH}.spec

# Move RPM file.
cd ..
echo -e "\nMove RPM file..."
mv ${HOME}/rpmbuild/RPMS/x86_64/${NAME}-typeahead-${VERSION}-${RELEASE}.fc${FEDORA}.${ARCH}.rpm .

# Remove generated files.
echo -e "\nRemove generated files..."
rm -rf build-nautilus-typeahead-rpm

# Check if file was built.
[ -f "${NAME}-typeahead-${VERSION}-${RELEASE}.fc${FEDORA}.${ARCH}.rpm" ] &&
echo -e "\nSuccessfully built '${NAME}-typeahead-${VERSION}-${RELEASE}.fc${FEDORA}.${ARCH}.rpm'." ||
echo -e """
Failed to build '${NAME}-typeahead-${VERSION}-${RELEASE}.fc${FEDORA}.${ARCH}.rpm'.\n
Please submit an issue with the log of execution to:
${URL}/issues"""