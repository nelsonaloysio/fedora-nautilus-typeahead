# fedora-nautilus-typeahead

[![Copr build status](https://copr.fedorainfracloud.org/coprs/nelsonaloysio/nautilus-typeahead/package/nautilus-typeahead/status_image/last_build.png)](https://copr.fedorainfracloud.org/coprs/nelsonaloysio/nautilus-typeahead/package/nautilus-typeahead/)

Automatically builds a **GNOME Files** (**[Nautilus](https://apps.gnome.org/en/Nautilus/)**) RPM with type-ahead functionality for [Fedora Linux](https://fedoraproject.org/).

:sparkles: A [Copr](https://copr.fedorainfracloud.org/coprs/nelsonaloysio/nautilus-typeahead/) is available to automate installing and updating the package.

> Updated on **2025-02-20** to support layering on more recent Fedora Silverblue base images.

:package: The resulting RPMs are also listed for download in the [Releases](https://github.com/nelsonaloysio/fedora-nautilus-typeahead-rpm/releases) page.

> - Supported Fedora versions: **41, 40, 39** (Workstation/Silverblue).
> - Supported Nautilus versions: **47.1, 47.0, 46.2, 46.1, 45.2.1**.

## Description

The default behavior on Nautilus nowadays is to type to search, i.e., to start a search when typing a character.
This package simply applies a pre-existing patch developed by the community to restore the type-ahead functionality,
i.e., browsing/navigating on key press, the default behavior on many file managers.

The new functionality may be toggled on the Preferences window (*Search on type ahead*):

![image](image/preferences.png)

___

## Install package

To install this package via Copr, first [enable the repository](https://docs.pagure.org/copr.copr/how_to_enable_repo.html) on your system with:

```bash
dnf copr enable nelsonaloysio/nautilus-typeahead
```

> Alternatively, [download](https://github.com/nelsonaloysio/fedora-nautilus-typeahead/releases) or [build the package from source](#build-from-source) before following the next steps.

### On Fedora Workstation

To install the package on [Fedora Workstation](https://fedoraproject.org/en/workstation), use the following command:

```bash
dnf install nautilus-typeahead
```

> Note: if installing from a local package, replace `nautilus-typeahead` with `./nautilus-typeahead-*.rpm`.

### On Fedora Silverblue

To layer the package on [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/), use the following command:

```bash
rpm-ostree override remove nautilus nautilus-extensions --install nautilus-typeahead
```

> Note: if installing from a local package, replace `nautilus-typeahead` with `./nautilus-typeahead-*.rpm`.

Restart your machine in order to boot into the updated deployment.

___

## Build from source

Simply run the script to install prerequisites with `dnf`, patch Nautilus, and build the RPM with:

```bash
bash build-nautilus-typeahead-rpm.sh
```

A new file `nautilus-typeahead-*.rpm` will be created by the end of the process.

> **Note:** on Silverblue, it is required to run the command above inside a `toolbox` to obtain the
> required dependencies using `dnf`, avoiding the need to layer them on your base system.

### Clean up dependencies

After building the RPM file, any installed dependencies may be removed with:

```bash
dnf history undo $(dnf history list --reverse | tail -n1 | cut -f1 -d\|)
```

The command above will simply undo the changes made by the last `dnf` execution.

___

## Notes

- :question: For more information on the issue, please check the [corresponding ticket](https://gitlab.gnome.org/Teams/Design/whiteboards/-/issues/142) (one of many) on GitLab.

- :memo: Patch file sources:
[47.0](https://raw.githubusercontent.com/lubomir-brindza/nautilus-typeahead/91b529ea78fbc7bcb3cdb84c3474f6fde47aa81e/nautilus-restore-typeahead.patch),
[46.2](https://github.com/lubomir-brindza/nautilus-typeahead/archive/refs/tags/46.0-0ubuntu2ppa1.zip),
[46.1](https://github.com/lubomir-brindza/nautilus-typeahead/archive/refs/tags/46-beta-0ubuntu3ppa2.tar.gz),
[45.2.1](https://aur.archlinux.org/cgit/aur.git/snapshot/aur-524d92c42ea768e5e4ab965511287152ed885d22.tar.gz).

- :heart: Thanks to all contributors responsible for developing and maintaining the type-ahead patch to restore this functionality to Nautilus!

### Contributors

> Last updated on August, 2024.

- Contributor (original patch code): Jan de Groot <jgc@archlinux.org>
- Contributor (original package maintainer): Ian Hernández <badwolfie@archlinux.info>
- Contributor (updated Xavier's patch for 43.2): Bryan Lai <bryanlais@gmail.com>
- Contributor (updated Xavier's patch for 44.1): DragoonAethis <dragoon@dragonic.eu>
- Contributor (fix for backspace going to parent folder): Jeremy Bicha <jbicha@debian.org>
- Contributor (current patch code): Xavier Claessens <xavier.claessens@collabora.com>
- [AUR](https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=nautilus-typeahead) maintainer: Albert Vaca Cintora <albertvaka@gmail.com>
- [PPA](https://github.com/lubomir-brindza/nautilus-typeahead) maintainer: Lubomir Brindza <lubomir@brindza.sk>
