# wsl-setup (Winget Configurations)

# x64:
winget install Microsoft.VCRedist.2015+.x64

# ARM64:
winget install Microsoft.VCRedist.2015+.arm64



winget configure -f dev-config.winget --accept-configuration-agreements --disable-interactivity