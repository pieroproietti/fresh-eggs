# Package publishing

```bash
./publish/basket.sh
./publish/sourceforge.sh
```

Dependencies: Bash, curl, Python 3, rsync and standard system utilities.
SourceForge additionally requires SSH and access to the configured account.
Both scripts require access to the local package repositories configured inside them.

`basket.sh` synchronizes to `/home/artisan/basket/packages`.
`sourceforge.sh` synchronizes to the configured SourceForge `Packages` directory.
Both publish standard, legacy and GUI packages, and use
`../penguins-gui/stage-gui-appimage.sh` to download AppImages before syncing.
Their destination paths and package selection are preserved.

`common.sh` shares the repository map and package staging rules between publishers.
