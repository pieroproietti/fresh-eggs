# penguins-gui

```bash
./penguins-gui/install.sh
./penguins-gui.AppImage
```

Dependencies: Bash, curl, Python 3 and standard system utilities.
The installer downloads the latest stable matching AppImage into the current
working directory. No root privileges are needed; run the GUI as a normal user.
Without FUSE, use `APPIMAGE_EXTRACT_AND_RUN=1 ./penguins-gui.AppImage`.

CLI installation is initiated from the GUI, as described in the root README.
`stage-gui-appimage.sh` is the download helper also used by `publish/`.
