![](./fresh-eggs.png)
# fresh-eggs

# [Donate](https://paypal.me/penguinseggs)
It took years of work to create the penguins-eggs, and I also incurred expenses for renting the site and subscribing to Google Gemini, for the artificial intelligence that is now indispensable.

Thanks you!

[![donate](https://img.shields.io/badge/Donate-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/penguinseggs)

**fresh-eggs** bootstraps Penguins' Eggs, now written in Go. Node.js and
NodeSource are not needed for the current version.

# Usage

```bash
git clone https://github.com/pieroproietti/fresh-eggs
cd fresh-eggs
./fresh-eggs.sh
```


Without arguments, the script displays usage and exits without downloading or
installing anything. Run it as a normal user; `--cli` and `--legacy` request
sudo authorization when needed.

## Desktop: penguins-gui AppImage

```bash
./fresh-eggs.sh --gui
./penguins-gui.AppImage
```

The script downloads the AppImage matching your architecture from the latest
stable [penguins-gui release](https://github.com/pieroproietti/penguins-gui/releases/latest)
and saves it as `penguins-gui.AppImage` in the current directory. It requires
`curl` and `python3`; no root privileges are needed. If the release has no
matching AppImage, it stops with an error.

Run the GUI as a normal user. Choose **Edit → Install penguins-egg CLI** to
configure the native repository and install Penguins' Eggs. The GUI requests
administrative authorization when needed. See the
[penguins-gui documentation](https://github.com/pieroproietti/penguins-gui#repository-and-calamares-setup)
for supported distributions and runtime requirements (`curl`, Debian `gpg`,
and sudo/polkit for administrative actions).

On systems without FUSE, run:

```bash
APPIMAGE_EXTRACT_AND_RUN=1 ./penguins-gui.AppImage
```

## Terminal: install Penguins' Eggs directly

```bash
./fresh-eggs.sh --cli
```

This path requires `curl`, detects the distribution and architecture, downloads
the latest compatible non-legacy package from
[the basket](https://penguins-eggs.net/basket/packages/), and installs it with
the system package manager. No Go compiler or Node.js runtime is required.

For subsequent package updates, configure the native repository with:

```bash
sudo eggs tools repo add
```

## Legacy version

`./fresh-eggs.sh --legacy` selects the separate installer for the old
Node.js implementation, `penguins-eggs-legacy`. Only that installer uses
`penguins-eggs-legacy/ensure-node.sh` and `penguins-eggs-legacy/prepare_pkgs.sh`, including the Node.js 22 setup.

For subsequent package updates, configure the native repository with:

```bash
sudo eggs tools repo --add
```


# Repository layout

```text
fresh-eggs.sh                  # dispatcher: --gui, --cli, --legacy
penguins-gui/                  # AppImage installer and download helper
penguins-eggs/                 # Go CLI installer
penguins-eggs-legacy/          # legacy installer and Node.js helpers
publish/                      # basket.sh and sourceforge.sh
```

Each component documents its dependencies in its own README. Installers resolve
helpers relative to their script location, so they can be called from any directory.
Without arguments, the command only displays usage; `--gui` downloads the
AppImage without launching it.

```bash
./fresh-eggs.sh --gui
./fresh-eggs.sh --cli
./fresh-eggs.sh --legacy
```

You can also invoke `install.sh` directly in each component directory.


# DOWNLOADS
All materials is under my googledrive [penguins-eggs](https://drive.google.com/drive/folders/19fwjvsZiW0Dspu2Iq-fQN0J-PDbKBlYY), You can visit and browse.
### [SUPPORTED-ISOS](https://drive.google.com/drive/folders/1E6MtIt6-GfgoMyqFoDNsg2j64liVi2JZ)
### [penguins-eggs.net packages](https://penguins-eggs.net/basket/packages/)
### [google drive isos](https://drive.google.com/drive/folders/1Wc07Csh8kJvqENj3oL-VDBU3E6eA9CLU)
### [sourceforge packages](https://sourceforge.net/projects/penguins-eggs/files/Packages/)
### [sourceforge isos](https://sourceforge.net/projects/penguins-eggs/files/Isos/)

# Just for the author: package publishing

`publish/basket.sh` and `publish/sourceforge.sh` synchronize the latest local packages and
download the AppImages from the latest stable GitHub release of
`pieroproietti/penguins-gui` into `packages/appimage` (basket) and
`Packages/appimage` (SourceForge). This requires `curl` and `python3`, in addition
to `rsync` and SSH for SourceForge. Both scripts use `penguins-gui/stage-gui-appimage.sh`; keep the repository
layout intact. If the AppImage download fails or the release has no matching asset,
the scripts stop before synchronizing destinations.

Copyright (c) 2022 - 2026
[Piero Proietti](https://penguins-eggs.net/about-me.html), dual licensed under
the MIT or GPL Version 2 licenses.
