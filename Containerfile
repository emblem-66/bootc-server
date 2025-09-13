# Currently based on Silverblue image. In future, I am considering using fedora-bootc image.
FROM quay.io/fedora/fedora-silverblue:latest

# Automatic Updates DNF
RUN echo "starting" \
 && sed -i 's|ExecStart=/usr/bin/bootc upgrade --apply --quiet|ExecStart=/usr/bin/bootc upgrade --quiet|' /usr/lib/systemd/system/bootc-fetch-apply-updates.service \
 && sed -i 's|OnBootSec=1h|OnCalendar=monthly|' /usr/lib/systemd/system/bootc-fetch-apply-updates.timer \
 && sed -i 's|OnUnitInactiveSec=8h|#OnUnitInactiveSec=8h|' /usr/lib/systemd/system/bootc-fetch-apply-updates.timer \
 && sed -i 's|RandomizedDelaySec=2h|#RandomizedDelaySec=2h|' /usr/lib/systemd/system/bootc-fetch-apply-updates.timer \
 && systemctl enable bootc-fetch-apply-updates.timer \
 && echo "done" 

# Tailscale
RUN echo "starting" \
 && dnf config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo \
 && dnf install -y tailscale \
 && systemctl enable tailscaled.service sshd.service \
 && dnf autoremove -y \
 && dnf clean all \
 && rm -rf /var/cache/* /var/log/* /tmp/* \
 && echo "done" 

# Cockpit
RUN echo "starting" \
 && dnf install -y cockpit \
 && systemctl enable --now cockpit.socket \
 && echo "done" 

# Finish
RUN echo "starting" \
 && rm -rf /var/cache/* /var/log/* /tmp/* \
 && ostree container commit \
 && bootc container lint
