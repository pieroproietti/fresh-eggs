![](./fresh-eggs.png)
# fresh-eggs

# [Donate](https://paypal.me/penguinseggs)
It took years of work to create the penguins-eggs, and I also incurred expenses for renting the site and subscribing to Google Gemini, for the artificial intelligence that is now indispensable.

Thanks you!

[![donate](https://img.shields.io/badge/Donate-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/penguinseggs)

**fresh-eggs**: install penguins-eggs and configure it on your AlmaLinux, AlpineLinux, Arch, Debian, Devuan, Fedora, Manjaro, Openmamba, openSuSE, RockyLinux, Ubuntu and most derivatives.

# Notes
## Native repositories
* on Almalinux, Arch, Debian, Devuan, Fedora, ManjaroopenSuse, RockyLinux and Ubuntu - after you installed penguins-eggs - you can add [pengins-eggs-repo](https://github.com/pieroproietti/penguins-eggs-repo) to get fresh penguins-eggs packages. Just use: `sudo eggs tools ppa --add`. 

* On Arch Linux penguins-eggs is on [Chaotic-AUR](https://aur.chaotic.cx/) too. Tis is the actual [PKGBUILD](https://aur.archlinux.org/packages/penguins-eggs).

* On Debian/Devuan/Ubuntu and derivatives - you can use [penguins-eggs-ppa](https://github.com/pieroproietti/penguins-eggs-ppa) to get fresh penguins-eggs packages. Read the [README](https://github.com/pieroproietti/penguins-eggs-ppa/blob/master/README.md) for more info.

* on Manjaro penguins-eggs is already on the community repo. [pengins-eggs-repo](https://github.com/pieroproietti/penguins-eggs/blob/master/DOCS/INSTALL-ALPINE.md)) can be added too.

* Other documentation is on [AlmaLinux](https://github.com/pieroproietti/penguins-eggs/blob/master/DOCS/INSTALL-ENTERPRISE-LINUX.md), [AlpineLinux](https://github.com/pieroproietti/penguins-eggs/blob/master/DOCS/INSTALL-ALPINE.md), [Fedora](https://github.com/pieroproietti/penguins-eggs/blob/master/DOCS/INSTALL-FEDORA.md),  [openSuSE](https://github.com/pieroproietti/penguins-eggs/blob/master/DOCS/INSTALL-OPENSUSE.md), [RockyLinux](https://github.com/pieroproietti/penguins-eggs/blob/master/DOCS/INSTALL-ENTERPRISE-LINUX.md).

## nodejs >= 22.x
* The script ensures that nodejs >= 22.x is available. If not found in the official repositories, it will attempt to configure the [nodesource repo](https://github.com/nodesource/distributions) to install it.

# USAGE

* `git clone https://github.com/pieroproietti/fresh-eggs`
* `cd fresh-eggs`
* `sudo ./fresh-eggs`

And follow instructions.

# [SUPPORTED DISTROS](./SUPPORTED-DISTROS.md)

# Fork it!
This is a short and simple script, you are encouraged to fork it and adapt it to your needs. Of course PR will welcomed!

Copyright (c) 2022 - 2026
[Piero Proietti](https://penguins-eggs.net/about-me.html), dual licensed under
the MIT or GPL Version 2 licenses.
