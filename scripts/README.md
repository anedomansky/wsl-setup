# wsl-setup (scripts)

## Usage

Run the following command from an PowerShell with administrative rights:

`.\scripts\wsl_deploy.ps1  -userdefined_distribution ubuntu -localusername anedomansky -gitname anedomansky -gitmail 'anedomansky@gmail.com'`

## TODOs

✔︎ Bottle docker (29.5.3)                                                                     Downloaded    9.0MB/  9.0MB
==> Pouring docker--29.5.3.arm64_linux.bottle.tar.gz
==> Caveats
The daemon component is provided in a separate formula:
  brew install docker-engine
==> Summary
🍺  /home/linuxbrew/.linuxbrew/Cellar/docker/29.5.3: 17 files, 27.6MB
==> Running `brew cleanup docker`...
Disable this behaviour by setting `HOMEBREW_NO_INSTALL_CLEANUP=1`.
Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).
==> Caveats
Bash completion has been installed to:
  /home/linuxbrew/.linuxbrew/etc/bash_completion.d
Configuring Docker permissions...
[sudo: authenticate] Password:
Changing default shell to Zsh...
chsh: Warning: /home/linuxbrew/.linuxbrew/bin/zsh is an invalid shell
Setting ubuntu as default distribution

The operation completed successfully.
     80       6     1424       7660       0,02  11868   2 wsl
zsh:1: permission denied: config
ubuntu has been deployed

Please restart your PC as a final completion step