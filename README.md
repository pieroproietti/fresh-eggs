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
```

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
sudo ./fresh-eggs.sh
```

This path requires `curl`, detects the distribution and architecture, downloads
the latest compatible non-legacy package from
[the basket](https://penguins-eggs.net/basket/packages/), and installs it with
the system package manager. No Go compiler or Node.js runtime is required.

For subsequent package updates, configure the native repository with:

```bash
sudo eggs tools ppa --add
```

## Legacy version

`sudo ./fresh-eggs-legacy.sh` is the separate installer for the old
Node.js implementation, `penguins-eggs-legacy`. Only that installer uses
`ensure-node.sh` and `prepare_pkgs.sh`, including the Node.js 22 setup.

# Package publishing

`basket.sh` and `sourceforge.sh` synchronize the latest local packages and
download the AppImages from the latest stable GitHub release of
`pieroproietti/penguins-gui` into `packages/appimage` (basket) and
`Packages/appimage` (SourceForge). This requires `curl` and `python3`, in addition
to `rsync` and SSH for SourceForge. Keep `stage-gui-appimage.sh` alongside both
scripts. If the AppImage download fails or the release has no matching asset,
the scripts stop before synchronizing destinations.

# [SUPPORTED DISTROS](./SUPPORTED-DISTROS.md)

# Fork it!
This is a short and simple script, you are encouraged to fork it and adapt it to your needs. Of course PR will welcomed!

Copyright (c) 2022 - 2026
[Piero Proietti](https://penguins-eggs.net/about-me.html), dual licensed under
the MIT or GPL Version 2 licenses.
