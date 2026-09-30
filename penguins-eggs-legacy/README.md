# penguins-eggs-legacy

```bash
sudo ./penguins-eggs-legacy/install.sh
```

Installer dependencies: Bash, curl (also used for version discovery), grep with
PCRE support, standard system utilities and the native package manager.
The legacy application uses Node.js; `ensure-node.sh` handles the Node.js 22
setup on Debian-family systems, including the existing riscv64 fallback.
Other distributions rely on native package dependency resolution.

`prepare_pkgs.sh` contains distro-specific package selection.
