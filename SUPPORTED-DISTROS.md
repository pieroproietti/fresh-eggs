# SUPPORTED DISTROS

I just take the list from [distrowatch](https://distrowatch.com/), to get an idea where we are.

Most of the information comes from direct experience, even from some time ago, and there may be errors. For example, some time ago Garuda could be remastered by removing the garuda-dracut package, but now it cannot.

If you have different results, or know more, you can report it in the [issues](https://github.com/pieroproietti/get-eggs/issues).


The order reflect Page Hit Ranking at 2025 luly, 28:

| Rank | Name   | Status | Note | Remastered |
|------|--------|--------|------|------------|
|   1 |[CachyOS](https://cachyos.org/)      | OK| You need to: edit `/etc/os-release` and insert the line: `ID_LIKE=arch`, then create a symlink: `ln -s /boot/initramfs-initramfs.img /boot/initramfs-$(uname -r).img`|[download](https://drive.google.com/drive/folders/1fJwjObseZAz5uvk00cQXJH_pjkAAAL3r)
|  2|[Mint](https://linuxmint.com/)        | OK||[download](https://drive.google.com/drive/folders/1oK_NiS-RSylS-ynf5ILh8xCkhAUl2HJs)
|  3|[MX Linux](https://mxlinux.org/)      |OK| I suggest to remove mx-installer and mx-snapshot|[download](https://drive.google.com/drive/folders/1-Xq4XfWkzlN14UEBr6ituSQ_A0zRT8Z5)
|  4|[EndeavourOS](https://endeavouros.com/)|OK||[download](https://drive.google.com/drive/folders/1ai5HSsNnQ65QWnTgtXI4kMRDpF9XqyQE)
|  5|[Debian](https://www.debian.org/)      |OK||[download](https://drive.google.com/drive/folders/116YqAq55PBfbzXM9wLvyT2OXKuQPpKZr)
|  6|[Pop!_OS](https://system76.com/pop/)   |OK||[Download](https://drive.google.com/drive/folders/1PpBhbE3XYJRCgE1gWmVgyHCkFgfxcIRt)
|  7|[Manjaro](https://manjaro.org/)        |OK||[Download](https://drive.google.com/drive/folders/18C14m9nZIlYLA7zayRzDcqpZUWMoixyU)
|  8|[Ubuntu](https://manjaro.org/)         |OK||[Download](https://drive.google.com/drive/folders/1zd-5istKS9eVHBcbXD7CL9T_UxjaKotQ)
|  9|[Fedora](https://fedoraproject.org/)   |OK||[Download](https://drive.google.com/drive/folders/1B8am7G3FSxCD8rCLcyysDGTJD0GVUMhY)
| 10|[Zorin](https://zorin.com/os/)         |OK||[Download](https://drive.google.com/drive/folders/1MOz7BZIpsVwZmMI_OersLQlLmzTn9Ib9)
| 11|[openSUSE](https://www.opensuse.org/)  |OK| calamares on the repos is not complete, use krill to install|[Download](https://drive.google.com/drive/folders/1MOz7BZIpsVwZmMI_OersLQlLmzTn9Ib9)
| 12|[Nobara](https://nobaraproject.org/)   |No| calamares on the repos is not complete, and installation with krill don't boot too|[Download](https://drive.google.com/drive/folders/1iiw1Itfo3-zGwn4jeM-LvWZbcbYKTd3Q)
| 13|[elementary](https://elementary.io)    |OK||[Download](https://drive.google.com/drive/folders/1ojMO3m4jv7fMPtBkN-xsGz7gu16hmta4)
| 14|[NixOS](https://nixos.org/)            |No|Distro not supported|
| 15|[KDE neon](https://neon.kde.org/)      |OK||[Download](https://drive.google.com/drive/folders/1bRyl0tc6c-a_J2Y5PFvdI2hyMGZ20OKn)
| 16|[AnduinOS](https://www.anduinos.com/)  |OK||[Download](https://drive.google.com/drive/folders/1gPhOxkuFn8i5X1cQO9v5Hr3NFo20JBOV)
| 17|[TUXEDO](https://www.tuxedocomputers.com/en/TUXEDO-OS_1.tuxedo)|OK||[Download](https://drive.google.com/drive/folders/1bl3cXKI6sSrvpFNezRNRhLsP6d2biupW)
| 18|[antiX](https://antixlinux.com/)       |OK||
| 19|[Bluestar](https://distrowatch.com/table.php?distribution=bluestar)|OK|Need to clean eggs.yaml|[Download](https://drive.google.com/drive/folders/1hRyW0KDq0lyW7BxveoL1tKo-y__WCaf1)
| 20|[Garuda](https://garudalinux.org/)     |No|It use dracut to build initramfs and its package `garuda-dracut` conflict with `mkinitcpio`|
| 21|[AlmaLinux](https://almalinux.org/)    |OK|version 9.6|[Download](https://drive.google.com/drive/folders/1KVd6uRlX5bwICCCuWcX42uxHj3vJRK3T)
| 22|[Kali](https://www.kali.org/)          |OK||[Download](https://drive.google.com/drive/folders/1Yikb1fLiK10u03AD6QBqzpDZXPkJdjEF)
| 23|[FreeBSD](https://www.freebsd.org/)    |No|Not Linux, different OS|
| 24|[Solus](https://getsol.us/)            |No|Distro not supported|
| 25|[SparkyLinux](https://sparkylinux.org/)|OK||[Download](https://drive.google.com/drive/folders/1IX07xKfCJQH2KJ1Ab5FW5Ch3ddkaj-Zv)
| 26|[BigLinux](https://sparkylinux.org/)   |OK||[Download](https://drive.google.com/drive/folders/1hWq1-B6nNU09AxddXmPm4GXRsXCECp99)
| 27|[Alpine](https://www.alpinelinux.org/)|OK||[Download](https://drive.google.com/drive/folders/1xLSkmYDqwe01MEkDdYWG__gCNrqatLmr)
| 28|[CentOS](https://www.centos.org/)      |||
| 29|[Q4OS](https://q4os.org/)              |OK||[Download](https://drive.google.com/drive/folders/1-hTsVytCoajSl0zdGbA988voWk_DdjO4)
| 30|[Lite](https://www.linuxliteos.com/)   |OK||[Download](https://drive.google.com/drive/folders/1ARW-39JPyFgjAwBcAK6O9-jnDdgu1SV5)
| 31|[Puppy](https://puppylinux-woof-ce.github.io/)|No|Distro not supported|
| 32|[EasyOS](https://easyos.org/)          |No|Distro not supported||
| 33|[Tails](https://tails.net/)            |OK||
| 34|[Kubuntu](https://kubuntu.org/)        |OK||[Download](https://drive.google.com/drive/folders/1-nmLVxbvzOjLXPMYXdV4cCnbUCoipnMr)
| 35|[OpenMandriva](https://www.openmandriva.org/)  |No|Distro not supported|
| 36|[deepin](https://www.deepin.org/index/en)  |OK||
| 37|[Linuxfx](https://distrowatch.com/table.php?distribution=linuxfx)  |OK||
| 38|[PCLinuxOS](https://pclinuxos.com/)    |No|PCLinuxOS started from Mandrake and have a great history, but is not supported|
| 39|[Voyager](https://voyagerlive.org/)    |OK||
| 40|[Parrot](https://parrotsec.org/)       |OK||
| 41|[Rocky](https://rockylinux.org/)       |OK||[Download](https://drive.google.com/drive/folders/1perjMEKAo5F-ezb2TXbae5dACstJ5VAl)
| 42|[Lubuntu](https://lubuntu.me/)         |OK||[Download](https://drive.google.com/drive/folders/16M3nUtqa-38RkHea6RPUhY9PSe63ODmK)
| 43|[Slackware](http://www.slackware.com/) |No|Sorry Patrick, the great Slackware is not supported|
| 44|[PorteuX](https://www.porteus.org/)    |No|Slackware based, not supported|
| 45|[Devuan](https://www.devuan.org/)      |OK||
| 46|[ALT](https://getalt.org/)             |No| This distro was a fork of Mandrake, not supported|
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
| 59|[Arch](https://archlinux.org/)         |OK||[Download](https://drive.google.com/drive/folders/1qWh-hWjldQpb6TWSDY9h8tKdD4VadkOr)
| 60|[Feren](https://ferenos.weebly.com/)   |OK||
| 61|[Peppermint](https://peppermintos.com/)|OK||
| 62|[RebornOS](https://rebornos.org/)      |OK|To be tested|
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