# Based on fedora-bootc image
FROM quay.io/fedora/fedora-bootc:latest

# Automatic Updates DNF
RUN echo "" \
 && sed -i 's|ExecStart=/usr/bin/bootc upgrade --apply --quiet|ExecStart=/usr/bin/bootc upgrade --quiet|' /usr/lib/systemd/system/bootc-fetch-apply-updates.service \
 && sed -i 's|OnBootSec=1h|OnCalendar=monthly|' /usr/lib/systemd/system/bootc-fetch-apply-updates.timer \
 && sed -i 's|OnUnitInactiveSec=8h|#OnUnitInactiveSec=8h|' /usr/lib/systemd/system/bootc-fetch-apply-updates.timer \
 && sed -i 's|RandomizedDelaySec=2h|#RandomizedDelaySec=2h|' /usr/lib/systemd/system/bootc-fetch-apply-updates.timer \
 && systemctl enable bootc-fetch-apply-updates.timer \
 && dnf install -y dnf5-plugins \
# RPM fusion
 && dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
# Tailscale
 && dnf config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo \
 && dnf install -y tailscale \
 && systemctl enable tailscaled.service sshd.service \
# Cockpit
 && dnf install -y cockpit \
 && systemctl enable cockpit.socket \
# Caddy
 && dnf copr enable -y @caddy/caddy \
 && dnf install -y caddy \
# Freeworld
 && dnf install -y ffmpeg libavcodec-freeworld --allowerasing \
# Jellyfin
 && dnf install -y jellyfin \
 && dnf autoremove -y \
 && dnf clean all \
 && rm -rf /var/* /tmp/* \
# && systemctl enable podman-auto-update.timer \
# && systemctl disable systemd-remount-fs.service \
# Finish
 && rm -rf /var/* /tmp/* \
 && ostree container commit \
 && bootc container lint
