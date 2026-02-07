# Gaming Fedora

A custom immutable Fedora gaming image built on Silverblue (GNOME). Includes NVIDIA
open kernel modules, Steam, Lutris, MangoHud, Gamescope, Gamemode, multimedia codecs,
and kernel tuning for gaming performance.

Updates are fetched and staged automatically every night at 4am. They only apply on your
next manual reboot — no surprise reboots during a session.

## Quick Start

### 1. Install Fedora Silverblue

Download the standard [Fedora Silverblue](https://fedoraproject.org/silverblue/) ISO, flash
it to a USB drive, and install it normally.

### 2. Rebase to this image

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/YOURUSERNAME/gaming-fedora:latest
systemctl reboot
```

### 3. Post-reboot setup

Install your Flatpak apps:

```bash
flatpak install flathub com.discordapp.Discord
flatpak install flathub com.obsproject.Studio
flatpak install flathub net.davidotek.pupgui2  # ProtonUp-Qt
```

## Building Locally

```bash
podman build -t gaming-fedora .
```

## Pushing to GHCR

```bash
echo $GITHUB_TOKEN | podman login ghcr.io -u YOURUSERNAME --password-stdin
podman tag gaming-fedora ghcr.io/YOURUSERNAME/gaming-fedora:latest
podman push ghcr.io/YOURUSERNAME/gaming-fedora:latest
```

## Automated Builds

The included GitHub Actions workflow rebuilds the image:
- Every Monday at 6am UTC
- On every push to `main`
- Manually via the Actions tab ("Run workflow")

## Checking for Updates Manually

```bash
# See if an update is available
bootc upgrade --check

# Fetch and stage it now (applies on next reboot)
bootc upgrade

# Check what's staged
bootc status
```

## Rolling Back

If an update breaks something, select the previous deployment from the GRUB menu at
boot, or from a running system:

```bash
bootc rollback
systemctl reboot
```

## Project Structure

```
├── Containerfile                              # Image definition
├── etc/
│   ├── security/limits.d/99-gaming.conf       # Gamemode process priority
│   ├── sysctl.d/99-gaming.conf                # Kernel tuning for gaming
│   └── systemd/system/
│       ├── bootc-fetch-updates.service        # Fetch-only update service
│       └── bootc-fetch-updates.timer          # Nightly 4am check schedule
├── .github/workflows/build.yml                # Automated weekly builds
└── README.md
```
