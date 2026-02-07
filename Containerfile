# =============================================================================
# Gaming Fedora - Custom Immutable Gaming OS
# Based on Fedora Silverblue (GNOME)
# =============================================================================
# Build:  podman build -t ghcr.io/YOURUSERNAME/gaming-fedora:latest .
# Push:   podman push ghcr.io/YOURUSERNAME/gaming-fedora:latest
# Rebase: rpm-ostree rebase ostree-unverified-registry:ghcr.io/YOURUSERNAME/gaming-fedora:latest
# =============================================================================

FROM ghcr.io/ublue-os/silverblue-main:latest

# -----------------------------------------------------------------------------
# RPM Fusion repos (needed for NVIDIA drivers, codecs, Steam, etc.)
# -----------------------------------------------------------------------------
RUN rpm-ostree install \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
    rpm-ostree cleanup -m

# -----------------------------------------------------------------------------
# NVIDIA open kernel modules + proprietary userspace
# (Open kernel modules are the default/only option for Blackwell GPUs)
# -----------------------------------------------------------------------------
RUN rpm-ostree install \
    akmod-nvidia \
    xorg-x11-drv-nvidia \
    xorg-x11-drv-nvidia-cuda \
    nvidia-vaapi-driver && \
    rpm-ostree cleanup -m

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
    mesa-vulkan-drivers \
    wine \
    winetricks && \
    rpm-ostree cleanup -m

# -----------------------------------------------------------------------------
# Multimedia codecs
# -----------------------------------------------------------------------------
RUN rpm-ostree install \
    ffmpeg \
    gstreamer1-plugins-bad-free \
    gstreamer1-plugins-ugly \
    gstreamer1-plugin-libav && \
    rpm-ostree cleanup -m

# -----------------------------------------------------------------------------
# Quality of life packages
# -----------------------------------------------------------------------------
RUN rpm-ostree install \
    htop \
    fastfetch \
    fish \
    distrobox \
    flatpak && \
    rpm-ostree cleanup -m

# -----------------------------------------------------------------------------
# Kernel tuning for gaming performance
# -----------------------------------------------------------------------------
COPY etc/sysctl.d/99-gaming.conf /etc/sysctl.d/99-gaming.conf
COPY etc/security/limits.d/99-gaming.conf /etc/security/limits.d/99-gaming.conf

# -----------------------------------------------------------------------------
# Flathub remote for Flatpak apps (Discord, OBS, ProtonUp-Qt, browsers, etc.)
# -----------------------------------------------------------------------------
RUN flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

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
