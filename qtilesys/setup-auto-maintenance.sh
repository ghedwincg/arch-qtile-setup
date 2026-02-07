#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# SETUP AUTOMATED MAINTENANCE
# Configures systemd timer for weekly automated maintenance
###############################################################################

banner() {
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║       AUTOMATED MAINTENANCE SETUP                             ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
}

banner

# Ensure script exists
if [[ ! -f "auto-maintenance.sh" ]]; then
    echo "Error: auto-maintenance.sh not found in current directory"
    exit 1
fi

# Make script executable
chmod +x auto-maintenance.sh

# Install script
echo "[1/4] Installing maintenance script..."
sudo install -m 755 auto-maintenance.sh /usr/local/bin/auto-maintenance
echo "✓ Script installed to /usr/local/bin/auto-maintenance"
echo ""

# Create systemd service
SERVICE_FILE=/etc/systemd/system/auto-maintenance.service
if [[ -f "$SERVICE_FILE" ]]; then
    echo "Service file already exists at $SERVICE_FILE"
else
    echo "[2/4] Creating systemd service..."
    sudo tee "$SERVICE_FILE" > /dev/null <<EOSERVICE
[Unit]
Description=Automated system maintenance
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/auto-maintenance
StandardOutput=journal
StandardError=journal
SyslogIdentifier=auto-maintenance

[Install]
WantedBy=multi-user.target
EOSERVICE
    echo "✓ Service file created"
fi
echo ""

# Create systemd timer
TIMER_FILE=/etc/systemd/system/auto-maintenance.timer
if [[ -f "$TIMER_FILE" ]]; then
    echo "Timer file already exists at $TIMER_FILE"
else
    echo "[3/4] Creating systemd timer..."
    sudo tee "$TIMER_FILE" > /dev/null <<EOTIMER
[Unit]
Description=Weekly automated maintenance timer
Requires=auto-maintenance.service

[Timer]
OnCalendar=Sun 02:00
Persistent=true
RandomizedDelaySec=30min

[Install]
WantedBy=timers.target
EOTIMER
    echo "✓ Timer file created"
fi
echo ""

# Reload systemd and enable timer
echo "[4/4] Enabling automated maintenance..."
sudo systemctl daemon-reload
sudo systemctl enable --now auto-maintenance.timer
echo "✓ Automated maintenance enabled"
echo ""

# Show timer status
echo "═══════════════════════════════════════════════════════════════"
echo "INSTALLATION COMPLETE!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Automated maintenance is now scheduled to run:"
echo "  • Every Sunday at 2:00 AM"
echo "  • Logs stored in: journalctl (and optionally ~/.local/share/maintenance-logs/)"
echo ""
echo "Timer status:"
systemctl status auto-maintenance.timer --no-pager || true
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "USEFUL COMMANDS:"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Check timer status:"
echo "  systemctl status auto-maintenance.timer"
echo ""
echo "View next run time:"
echo "  systemctl list-timers auto-maintenance.timer"
echo ""
echo "Run maintenance now:"
echo "  sudo systemctl start auto-maintenance.service"
echo ""
echo "View maintenance logs:"
echo "  journalctl -u auto-maintenance.service"
echo ""
echo "Disable automated maintenance:"
echo "  sudo systemctl disable --now auto-maintenance.timer"
echo ""
echo "Enable automated maintenance:"
echo "  sudo systemctl enable --now auto-maintenance.timer"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "You can also run maintenance manually anytime with:"
echo "  /usr/local/bin/auto-maintenance"
echo "═══════════════════════════════════════════════════════════════"
