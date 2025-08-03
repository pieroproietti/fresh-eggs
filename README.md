# get-eggs

# [Donate](https://www.paypal.com/pool/9h2CmPBaPG?sr=wccr)
It took years of work to create the penguins-eggs, and I also incurred expenses for renting the site and subscribing to Google Gemini, for the artificial intelligence that is now indispensable.

Thanks you!

[![Donate](./assets/donate.png)](https://www.paypal.com/pool/9h2CmPBaPG?sr=wccr)

[![donate](https://img.shields.io/badge/penguinseggs-donate-cyan)](https://www.paypal.com/pool/9h2CmPBaPG?sr=wccr)

**get-eggs**: install penguins-eggs and configure it on your AlmaLinux, AlpineLinux, Arch, Debian, Devuan, Fedora, Manjaro, Openmamba, openSuSE, RockyLinu, Ubuntu and most derivatives.

# Notes
* on Debian/Devuan/Ubuntu and derivatives - after you installed eggs - it's possible to add  [pengins-eggs-ppa](https://github.com/pieroproietti/penguins-eggs-ppa) to get updates via apt. To enable it: `sudo eggs tools ppa --add`;

* on Arch, you can add Automated building repo for AUR packages [Chaotic-AUR](https://aur.chaotic.cx/) to get fresh penguins-eggs packages. Just use: `sudo ./add-aur-chaotic.sh` from this repository.

* on some distributions, mainly Ubuntu bionic and derivatives, where nodejs >=18 is not available, you can still install penguins-eggs installing nodejs=16 from [nodesource repo](https://github.com/nodesource/distributions?tab=readme-ov-file#debian-and-ubuntu-based-distributions) and manually installing  the special package [penguins-eggs-25.x.x-1bionic.amd64.deb](https://penguins-eggs.net/basket/index.php/packages/?p=packages%2Fdebs) we continue to mantain.

# USAGE

* `git clone https://github.com/pieroproietti/get-eggs`
* `cd get-eggs`
* `sudo ./get-eggs`

And follow instructions.

# [SUPPORTED DISTROS](./SUPPORTED-DISTROS.md)

# Fork it!
This is a short and simple script, you are encouraged to fork it and adapt it to your needs. Of course PR will welcomed!