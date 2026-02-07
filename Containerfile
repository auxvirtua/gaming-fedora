# =============================================================================
# Gaming Fedora - Custom Immutable Gaming OS
# Based on Fedora Silverblue with NVIDIA (GNOME)
# =============================================================================
# Build:  podman build -t ghcr.io/YOURUSERNAME/gaming-fedora:latest .
# Push:   podman push ghcr.io/YOURUSERNAME/gaming-fedora:latest
# Rebase: rpm-ostree rebase ostree-unverified-registry:ghcr.io/YOURUSERNAME/gaming-fedora:latest
# =============================================================================

FROM ghcr.io/ublue-os/silverblue-nvidia:latest

# -----------------------------------------------------------------------------
# Gaming: Steam, Lutris, tools, and Proton helpers
# -----------------------------------------------------------------------------
RUN rpm-ostree install \
    steam \
    lutris \
    mangohud \
    gamemode \
    gamescope \
    vulkan-tools \
    wine \
    winetricks && \
    rpm-ostree cleanup -m

# -----------------------------------------------------------------------------
# Quality of life packages
# -----------------------------------------------------------------------------
RUN rpm-ostree install \
    htop \
    fastfetch \
    fish \
    distrobox && \
    rpm-ostree cleanup -m

# -----------------------------------------------------------------------------
# Kernel tuning for gaming performance
# -----------------------------------------------------------------------------
COPY etc/sysctl.d/99-gaming.conf /etc/sysctl.d/99-gaming.conf
COPY etc/security/limits.d/99-gaming.conf /etc/security/limits.d/99-gaming.conf

# -----------------------------------------------------------------------------
# Flatpak apps (pre-installed via Flathub, already configured in base image)
# -----------------------------------------------------------------------------
RUN flatpak install -y flathub com.discordapp.Discord

# -----------------------------------------------------------------------------
# Automatic updates: fetch + stage nightly, but NEVER auto-reboot
# Updates apply on your next manual reboot
# -----------------------------------------------------------------------------

# Disable the default fetch+apply+reboot timer
RUN systemctl disable bootc-fetch-apply-updates.timer

# Install custom fetch-only service and timer
COPY etc/systemd/system/bootc-fetch-updates.service /usr/lib/systemd/system/bootc-fetch-updates.service
COPY etc/systemd/system/bootc-fetch-updates.timer /usr/lib/systemd/system/bootc-fetch-updates.timer
RUN systemctl enable bootc-fetch-updates.timer

# -----------------------------------------------------------------------------
# Cleanup
# -----------------------------------------------------------------------------
RUN rpm-ostree cleanup -m && \
    ostree container commit
