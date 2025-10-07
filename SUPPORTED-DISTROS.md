# SUPPORTED DISTROS

I just take the list from [distrowatch](https://distrowatch.com/), to get an idea where we are.

Most of the information comes from direct experience, even from some time ago, and there may be errors. For example, some time ago Garuda could be remastered by removing the garuda-dracut package, but now it cannot.

If you have different results, or know more, you can report it in the [issues](https://github.com/pieroproietti/fresh-eggs/issues).

The order reflect Page Hit Ranking at 2025 luly, 28:

| Rank | Name   | Status | Note | Remastered |
|------|--------|--------|------|------------|
|   1|[CachyOS](https://cachyos.org/)      | OK|v25.10.6 |[SUPPORTED_ISOS](#supported_isos)
|  2|[Mint](https://linuxmint.com/)        | OK||[SUPPORTED_ISOS](#supported_isos)
|  3|[MX Linux](https://mxlinux.org/)      |OK| I suggest to remove mx-installer and mx-snapshot|)
|  4|[EndeavourOS](https://endeavouros.com/)|OK|[SUPPORTED_ISOS](#supported_isos)
|  5|[Debian](https://www.debian.org/)      |OK||[ISOS](#isos)
|  6|[Pop!_OS](https://system76.com/pop/)   |OK||
|  7|[Manjaro](https://manjaro.org/)        |OK||[ISOS](#isos)
|  8|[Ubuntu](https://manjaro.org/)         |OK||[ISOS](#isos)
|  9|[Fedora](https://fedoraproject.org/)   |OK||[ISOS](#isos)
| 10|[Zorin](https://zorin.com/os/)         |OK||
| 11|[openSUSE](https://www.opensuse.org/)  |OK| calamares on the repos is not complete, use krill to install|[download][ISOS](#isos)
| 10|[Zorin](https://zorin.com/os/)         |OK||
| 12|[Nobara](https://nobaraproject.org/)   |No| calamares on the repos is not complete, and installation with krill don't boot too|
| 13|[elementary](https://elementary.io)    |OK||
| 14|[NixOS](https://nixos.org/)            |No|Distro not supported|
| 15|[KDE neon](https://neon.kde.org/)      |OK||
| 16|[AnduinOS](https://www.anduinos.com/)  |OK||
| 17|[TUXEDO](https://www.tuxedocomputers.com/en/TUXEDO-OS_1.tuxedo)|OK||
| 18|[antiX](https://antixlinux.com/)       |OK||
| 19|[Bluestar](https://distrowatch.com/table.php?distribution=bluestar)|OK|Need to clean eggs.yaml|
| 20|[Garuda](https://garudalinux.org/)     |No|It use dracut to build initramfs and its package `garuda-dracut` conflict with `mkinitcpio`|
| 21|[AlmaLinux](https://almalinux.org/)    |OK|version 9.6|
| 22|[Kali](https://www.kali.org/)          |OK||
| 23|[FreeBSD](https://www.freebsd.org/)    |No|Not Linux, different OS|
| 24|[Solus](https://getsol.us/)            |No|Distro not supported|
| 25|[SparkyLinux](https://sparkylinux.org/)|OK||
| 26|[BigLinux](https://sparkylinux.org/)   |OK|
| 27|[Alpine](https://www.alpinelinux.org/)|OK||[ISOS](#isos)
| 28|[CentOS](https://www.centos.org/)      |||
| 29|[Q4OS](https://q4os.org/)              |OK||
| 30|[Lite](https://www.linuxliteos.com/)   |OK||
| 31|[Puppy](https://puppylinux-woof-ce.github.io/)|No|Distro not supported|
| 32|[EasyOS](https://easyos.org/)          |No|Distro not supported||
| 33|[Tails](https://tails.net/)            |OK|Distro not supported. it's mostly a live||
| 34|[Kubuntu](https://kubuntu.org/)        |OK||
| 35|[OpenMandriva](https://www.openmandriva.org/)  |No|Distro not supported, Mandrake based|
| 36|[deepin](https://www.deepin.org/index/en)  |Ko|Give `sudo deepin-immutable-writable enable` and install penguins-eggs package .deb manually|
| 37|[Linuxfx](https://distrowatch.com/table.php?distribution=linuxfx)  |OK||
| 38|[PCLinuxOS](https://pclinuxos.com/)    |No|Distro not supported! Mandrake based|
| 39|[Voyager](https://voyagerlive.org/)    |OK||
| 40|[Parrot](https://parrotsec.org/)       |OK|get problems to reinstall, must to check|
| 41|[Rocky](https://rockylinux.org/)       |OK||
| 42|[Lubuntu](https://lubuntu.me/)         |OK||
| 43|[Slackware](http://www.slackware.com/) |No|Distro not supported, Slackware based|
| 44|[PorteuX](https://www.porteus.org/)    |No|Distro not supported, Slackware based|
| 45|[Devuan](https://www.devuan.org/)      |OK||
| 46|[ALT](https://getalt.org/)             |No|Distro not supperted, Mandrake based|
| 47|[DragonOS](https://sourceforge.net/projects/dragonos-focal/)|OK||
| 48|[Red Hat](https://redhat.com)          |OK|To be tested|
| 49|[Ultimate](https://ultimateedition.info/)|OK|To be tested|
| 50|[ReactOS](https://reactos.org/)        |No|Not Linux, different OS|
| 51|[Xubuntu](https://xubuntu.org/)        |OK||
| 52|[KaOS](https://kaosx.us/)              |No|Distro not supported| 
| 53|[Chimera](https://chimera-linux.org/)  |No|Distro not supported| 
| 54|[Archcraft](https://archcraft.io/)     |OK|To be tested|
| 55|[Vanilla](https://vanillaos.org/)      |OK|To be tested|
| 56|[Gentoo](https://www.gentoo.org/)      |No|Distro not supported| 
| 57|[Calculate](https://www.calculate-linux.org/)  |No|Distro not supported| 
| 58|[Commodore](https://www.commodore.net/)|OK|To be tested|
| 59|[Arch](https://archlinux.org/)         |OK||[ISOS](#isos)
| 60|[Feren](https://ferenos.weebly.com/)   |OK||
| 61|[Peppermint](https://peppermintos.com/)|OK||
| 62|[RebornOS](https://rebornos.org/)      |OK|Tested from Ian Briggs|
| 63|[blendOS](https://blendos.co/)         |OK|To be tested|
| 64|[Mageia](https://www.mageia.org)       |No|Distro not supported|
| 65|[Rhino](https://rhinolinux.org/)       |OK|To be tested|
| 66|[Bodhi](https://www.bodhilinux.com/)   |OK||
| 67|[FunOS](https://funos.org/)            |OK||
| 68|[GhostBSD](https://www.ghostbsd.org/)  |No|Not Linux, different OS|
| 69|[Nitrux](https://nxos.org/)            |No|Distro not supported|
| 70|[wattOS](https://www.planetwatt.com/)  |OK||
| 71|[AV Linux](https://cinelerra-gg.org/it/avlinux/)   |OK||
| 72|[Kodachi](https://www.digi77.com/linux-kodachi/)   |OK||
| 73|[Mabox](https://maboxlinux.org/)       |OK|To be tested|
| 74|[SDesk](https://stevestudios.net/sdesk/)   |OK|To be tested|
| 75|[Artix](https://distrowatch.com/table.php?distribution=artix)|OK|To be tested|
| 76|[Qubes](https://www.qubes-os.org/)     |OK|To be tested|
| 77|[Regata](https://get.regataos.com.br/) |OK|OpenSuSE based, to be tested|
| 78|[ArchBang](https://archbang.org/)      |OK|Arch based. to be tested|
| 79|[Emmabuntüs](https://emmabuntus.org/)  |OK||
| 80|[Tiny Core](http://www.tinycorelinux.net/) |No|Indipendent, not supported|
| 81|[Oracle](https://www.oracle.com/it/linux/) |OK|To be tested|
| 82|[Murena](https://murena.com/)              |No|Distro not supported|
| 83|[4MLinux](https://4mlinux.com/index.php)   |No|Distro not supported|
| 84|[Bazzite](Bazzite)                         |OK|Fedora based To be tested|
| 85|[AUSTRUMI](http://cyti.latgola.lv/ruuni/)|No|Slackware based, not supported|
| 86|[Ultramarine](https://ultramarine-linux.org/)K|Fedora based To be tested|
| 87|[TrueNAS](https://www.truenas.com/blog/first-release-of-truenas-on-linux/)|No|Distro not supported|
| 88|[Ubuntu MATE](https://ubuntu-mate.org/)    |OK||
| 89|[MakuluLinux](https://webos.makululinux.com/)|OK||
| 90|[Ubuntu Studio](https://ubuntustudio.org/) |OK||
| 91|[Proxmox](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview)|OK|All you see born here!|
| 92|[Void](https://voidlinux.org/)             |No|Distro not supported|
| 93|[OpenBSD](https://www.openbsd.org/)        |No|Not Linux, different OS|
| 94|[PikaOS](https://wiki.pika-os.com/en/home) |OK||
| 95|[Dr.Parted](https://dr-parted-live.sourceforge.io/)    |OK|Debian based To be tested|
| 96|[Damn Small](https://www.damnsmalllinux.org/)          |OK|Debian based, to be tested|
| 97|[Haiku](https://www.haiku-os.org/)         |No|Distro not supported|
| 98|[BunsenLabs](https://www.bunsenlabs.org/)  |OK||
| 99|[Endless](https://www.endlessos.org/)      |OK|Debian based, to be tested|
|100|[Porteus](https://www.porteus.org/)        |OK|Slackware based, not supported|



# penguins-eggs repos
* [penguins-eggs Alpine Linux repo](https://github.com/pieroproietti/penguins-eggs/blob/master/DOCS/INSTALL-ALPINE.md)
* [penguins-eggs Arch Linux repo](https://github.com/pieroproietti/penguins-eggs/blob/master/DOCS/INSTALL-ARCHLINUX.md)
* [penguins-eggs Debian, Ubuntu repo](https://github.com/pieroproietti/penguins-eggs/blob/master/DOCS/INSTALL-DEBIAN-DEVUAN-UBUNTU.md)
* [penguins-eggs Enterprise Linux repo](https://github.com/pieroproietti/penguins-eggs/blob/master/DOCS/INSTALL-ENTERPRISE-LINUX.md)
* [penguins-eggs Fedora repo](https://github.com/pieroproietti/penguins-eggs/blob/master/DOCS/INSTALL-FEDORA.md)
* [penguins-eggs OpenSUSE repo](https://github.com/pieroproietti/penguins-eggs/blob/master/DOCS/INSTALL-OPENSUSE.md)

# Downloads

## [ISOS](https://drive.google.com/drive/folders/1Wc07Csh8kJvqENj3oL-VDBU3E6eA9CLU)
## [SUPPORTED-ISOS](https://drive.google.com/drive/folders/1E6MtIt6-GfgoMyqFoDNsg2j64liVi2JZ)
