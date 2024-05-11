# fedora-nautilus-typeahead-rpm

Automatically builds a **GNOME Files** (**[Nautilus](https://apps.gnome.org/en/Nautilus/)**) RPM with type-ahead functionality for [Fedora Linux](https://fedoraproject.org/).

The resulting RPM file is available for download on the [Releases](https://github.com/nelsonaloysio/fedora-nautilus-typeahead-rpm/releases) page.

> Last tested on **Workstation/Silverblue 40** with **Nautilus 46.1** (May 2024).

## Description

The default behavior on Nautilus nowadays is to type to search, i.e., to start a search when typing a character.
This package simply applies a pre-existing patch developed by the community to restore the type-ahead functionality,
i.e., browsing/navigating on key press instead - the default behavior on many file managers.

The new functionality may be toggled on the Preferences window (*Search on type ahead*):

![image](image/preferences.png)

## Install package

### On Fedora Workstation

To install the package on Fedora Workstation, use the following command:

```bash
dnf install ./nautilus-typeahead-*.rpm
```

Replace `*` with the appropriate version you downloaded or built.

### On Fedora Silverblue

To layer the package on Fedora (Atomic) Silverblue, use the following command:

```bash
rpm-ostree install --force-replacefiles ./nautilus-typeahead-*.rpm
```

The installed version will be replaced and type-ahead functionality will be enabled. Restart your machine in order to boot into the updated deployment.

___

## Build the RPM file

Simply run the script to install prerequesites with `dnf` and build Nautilus with the type-ahead patch:

```bash
bash build-nautilus-typeahead-rpm.sh
```

A new file `nautilus-typeahead-*.rpm` will be created by the end of the process.

**Note:** on **Silverblue**, the command above should be executed inside a `toolbox`, so to automatically obtain the required dependencies with `dnf` and avoid the need to layer the packages on your base system.

### Clean up dependencies

After building the RPM file, you may remove unneeded dependencies with:

```bash
dnf history undo $(dnf history list --reverse | tail -n1 | cut -f1 -d\|)
```

The command above will undo the changes made on the last `dnf` execution.

___

## Notes

* :question: For more information on the issue, please check the [corresponding ticket](https://gitlab.gnome.org/Teams/Design/whiteboards/-/issues/142) (one of many) on GitLab.

* :heart: Thanks to [@albertvaka](https://aur.archlinux.org/packages/nautilus-typeahead), [@lubomir-brindza](https://github.com/lubomir-brindza/nautilus-typeahead/), [@xclaesse](https://gitlab.gnome.org/xclaesse), and all others responsible for restoring the type-ahead functionality to Nautilus!
