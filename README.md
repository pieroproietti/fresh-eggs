![](./fresh-eggs.png)
# fresh-eggs

# [Donate](https://paypal.me/penguinseggs)
It took years of work to create the penguins-eggs, and I also incurred expenses for renting the site and subscribing to Google Gemini, for the artificial intelligence that is now indispensable.

Thanks you!

[![donate](https://img.shields.io/badge/Donate-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/penguinseggs)

**fresh-eggs**: install penguins-eggs and configure it on your AlmaLinux, AlpineLinux, Arch, Debian, Devuan, Fedora, Manjaro, Openmamba, openSuSE, RockyLinux, Ubuntu and most derivatives.

# Notes
## Native repositories
* on Debian/Devuan/Ubuntu and derivatives - after you installed penguins-eggs - it's possible to add  [pengins-eggs-repo](https://github.com/pieroproietti/penguins-eggs-repo) to get updates via apt. To enable it: `sudo eggs tools ppa --add`;

* on Arch - after you installed penguins-eggs - you can add [pengins-eggs-repo](https://github.com/pieroproietti/penguins-eggs-repo) to get fresh penguins-eggs packages. Just use: `sudo eggs tools ppa --add`. Penguins-eggs is on [Chaotic-AUR](https://aur.chaotic.cx/)

* on Manjaro penguins-eggs is already on the community repo, 

* on [AlmaLinux](https://github.com/pieroproietti/penguins-eggs/blob/master/DOCS/INSTALL-ENTERPRISE-LINUX.md), AlpineLinux, [Fedora](https://github.com/pieroproietti/penguins-eggs/blob/master/DOCS/INSTALL-FEDORA.md),  [openSuSE](https://github.com/pieroproietti/penguins-eggs/blob/master/DOCS/INSTALL-OPENSUSE.md), [RockyLinux](https://github.com/pieroproietti/penguins-eggs/blob/master/DOCS/INSTALL-ENTERPRISE-LINUX.md) follow the links to add native repo.

## nodejs > 18.x
* on some distributions, mainly Ubuntu bionic and derivatives, where nodejs >=18 is not available, you can still install penguins-eggs installing nodejs=16 from [nodesource repo](https://github.com/nodesource/distributions?tab=readme-ov-file#debian-and-ubuntu-based-distributions) and manually installing  the special package [penguins-eggs-25.x.x-1bionic.amd64.deb](https://penguins-eggs.net/basket/index.php/packages/?p=packages%2Fdebs) we continue to mantain.

# USAGE

* `git clone https://github.com/pieroproietti/fresh-eggs`
* `cd fresh-eggs`
* `sudo ./fresh-eggs`

And follow instructions.

# [SUPPORTED DISTROS](./SUPPORTED-DISTROS.md)

# Fork it!
This is a short and simple script, you are encouraged to fork it and adapt it to your needs. Of course PR will welcomed!