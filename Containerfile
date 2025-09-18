# Based on fedora-bootc image
FROM quay.io/fedora/fedora-bootc:latest

# Automatic Updates DNF
RUN echo "" \
 && sed -i 's|ExecStart=/usr/bin/bootc upgrade --apply --quiet|ExecStart=/usr/bin/bootc upgrade --quiet|' /usr/lib/systemd/system/bootc-fetch-apply-updates.service \
 && sed -i 's|OnBootSec=1h|OnCalendar=monthly|' /usr/lib/systemd/system/bootc-fetch-apply-updates.timer \
 && sed -i 's|OnUnitInactiveSec=8h|#OnUnitInactiveSec=8h|' /usr/lib/systemd/system/bootc-fetch-apply-updates.timer \
 && sed -i 's|RandomizedDelaySec=2h|#RandomizedDelaySec=2h|' /usr/lib/systemd/system/bootc-fetch-apply-updates.timer \
 && systemctl enable bootc-fetch-apply-updates.timer \
 && echo ""

# Tailscale
RUN echo "" \
 && dnf install -y dnf5-plugins \
 && dnf config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo \
 && dnf install -y tailscale \
 && systemctl enable tailscaled.service sshd.service \
 && dnf autoremove -y \
 && dnf clean all \
 && rm -rf /var/* /tmp/* \
 && echo ""

# Cockpit
RUN echo "" \
 && dnf install -y cockpit \
 && systemctl enable cockpit.socket \
 && dnf autoremove -y \
 && dnf clean all \
 && rm -rf /var/* /tmp/* \
 && echo ""

RUN echo "" \
 && systemctl enable podman-auto-update.timer \
 && systemctl disable systemd-remount-fs.service \
 && echo ""

# Finish
RUN echo "" \
 && rm -rf /var/* /tmp/* \
 && ostree container commit \
 && bootc container lint
