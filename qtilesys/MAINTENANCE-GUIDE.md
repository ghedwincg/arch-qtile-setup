# 🛡️ ARCH LINUX + QTILE SYSTEM MAINTENANCE GUIDE
## Complete Guide to Keep Your System Reliable, Secure, and Stable

---

## 📋 TABLE OF CONTENTS

1. [Quick Start](#quick-start)
2. [Daily Maintenance](#daily-maintenance)
3. [Weekly Maintenance](#weekly-maintenance)
4. [Monthly Maintenance](#monthly-maintenance)
5. [Security Best Practices](#security-best-practices)
6. [Performance Optimization](#performance-optimization)
7. [Troubleshooting](#troubleshooting)
8. [Emergency Recovery](#emergency-recovery)

---

## 🚀 QUICK START

### Initial System Cleanup

```bash
# 1. Make scripts executable
chmod +x arch-cleanup.sh qtile-cleanup.sh security-hardening.sh

# 2. Run full system cleanup
./arch-cleanup.sh
# Select option 1 (Full System Cleanup)

# 3. Run Qtile optimization
./qtile-cleanup.sh

# 4. Run security hardening (OPTIONAL - for maximum security)
./security-hardening.sh
```

### Immediate Actions (Do These First!)

1. **Update Your System**
   ```bash
   sudo pacman -Syu
   ```

2. **Clean Package Cache**
   ```bash
   sudo pacman -Sc
   ```

3. **Remove Orphaned Packages**
   ```bash
   sudo pacman -Rns $(pacman -Qtdq)
   ```

4. **Check for Errors**
   ```bash
   systemctl --failed
   journalctl -p 3 -xn 20
   ```

---

## 📅 DAILY MAINTENANCE

### Morning Routine (5 minutes)

```bash
# Check system updates
pacman -Qu

# Check system health
systemctl --failed
df -h

# View recent errors
journalctl -p 3 -xn 10
```

### Evening Routine (5 minutes)

```bash
# Clean user cache
rm -rf ~/.cache/thumbnails/*

# Empty trash
rm -rf ~/.local/share/Trash/*

# Check disk space
df -h / /home
```

---

## 📆 WEEKLY MAINTENANCE

### Sunday System Maintenance (30 minutes)

#### 1. System Updates
```bash
# Full system update
sudo pacman -Syu

# Update AUR packages (if using yay/paru)
yay -Syu
# or
paru -Syu
```

#### 2. Package Cleanup
```bash
# Clean package cache (keep last 3 versions)
sudo paccache -rk3

# Remove uninstalled package cache
sudo paccache -ruk0

# Remove orphaned packages
sudo pacman -Rns $(pacman -Qtdq)
```

#### 3. Log Cleanup
```bash
# Limit journal size
sudo journalctl --vacuum-time=3d
sudo journalctl --vacuum-size=100M
```

#### 4. Health Check
```bash
# Check failed services
systemctl --failed

# Check disk health (for SSD)
sudo smartctl -a /dev/sda

# Check filesystem
sudo btrfs scrub start / # For Btrfs
# or
sudo fsck -n /dev/sda1 # For ext4 (run from live USB)
```

---

## 🗓️ MONTHLY MAINTENANCE

### First Sunday of Month (1-2 hours)

#### 1. Full System Audit

```bash
# Run the cleanup script
./arch-cleanup.sh
# Select: 1) Full System Cleanup
#         10) Check System Health
#         18) Generate System Report

# Review the generated report
```

#### 2. Security Updates

```bash
# Check for security advisories
arch-audit

# Update all packages
sudo pacman -Syu

# Check open ports
sudo ss -tulpn

# Review firewall rules
sudo ufw status verbose
```

#### 3. Database Optimization

```bash
# Optimize pacman database
sudo pacman-optimize

# Rebuild package database
sudo pacman -Syy
```

#### 4. Kernel Updates

```bash
# Check current kernel
uname -r

# List installed kernels
pacman -Q | grep linux

# Remove old kernels (keep current + 1 previous)
# Be careful with this!
```

#### 5. Backup Configuration

```bash
# Backup important configs
mkdir -p ~/backups/$(date +%Y%m%d)

# Qtile config
cp -r ~/.config/qtile ~/backups/$(date +%Y%m%d)/

# Other configs
cp -r ~/.config/rofi ~/backups/$(date +%Y%m%d)/
cp ~/.bashrc ~/backups/$(date +%Y%m%d)/
cp ~/.zshrc ~/backups/$(date +%Y%m%d)/

# System configs (requires sudo)
sudo cp /etc/pacman.conf ~/backups/$(date +%Y%m%d)/
sudo cp /etc/fstab ~/backups/$(date +%Y%m%d)/
```

---

## 🔒 SECURITY BEST PRACTICES

### Essential Security Measures

#### 1. Firewall Configuration

```bash
# Install and enable UFW
sudo pacman -S ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
sudo systemctl enable ufw
```

#### 2. Automatic Security Updates Notification

```bash
# Create update checker
sudo tee /usr/local/bin/check-security-updates << 'EOF'
#!/bin/bash
pacman -Sy > /dev/null 2>&1
updates=$(pacman -Qu | wc -l)
if [ $updates -gt 0 ]; then
    notify-send -u critical "Security Updates" "$updates updates available"
fi
EOF

sudo chmod +x /usr/local/bin/check-security-updates

# Add to crontab
(crontab -l 2>/dev/null; echo "0 9 * * * /usr/local/bin/check-security-updates") | crontab -
```

#### 3. SSH Hardening (if using SSH)

```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Set these values:
# PermitRootLogin no
# PasswordAuthentication no
# PubkeyAuthentication yes
# Port 2222  # Change default port

# Restart SSH
sudo systemctl restart sshd
```

#### 4. Install Security Tools

```bash
sudo pacman -S \
    ufw \
    fail2ban \
    rkhunter \
    clamav \
    lynis
```

#### 5. Regular Security Audits

```bash
# Weekly security check
sudo lynis audit system

# Check for rootkits monthly
sudo rkhunter --update
sudo rkhunter --check --skip-keypress

# Antivirus scan (as needed)
sudo freshclam
sudo clamscan -r /home
```

---

## ⚡ PERFORMANCE OPTIMIZATION

### System-Wide Optimizations

#### 1. Enable Parallel Downloads (Pacman)

```bash
sudo nano /etc/pacman.conf

# Uncomment or add:
ParallelDownloads = 5
```

#### 2. Enable Multilib (for 32-bit support)

```bash
sudo nano /etc/pacman.conf

# Uncomment:
# [multilib]
# Include = /etc/pacman.d/mirrorlist
```

#### 3. Use Fastest Mirrors

```bash
sudo pacman -S reflector

sudo reflector --verbose \
    --latest 20 \
    --protocol https \
    --sort rate \
    --save /etc/pacman.d/mirrorlist

sudo pacman -Syy
```

#### 4. Optimize SSD (if using SSD)

```bash
# Enable TRIM
sudo systemctl enable fstrim.timer

# Check TRIM status
sudo systemctl status fstrim.timer
```

#### 5. Reduce Swappiness (for systems with 8GB+ RAM)

```bash
# Add to /etc/sysctl.d/99-swappiness.conf
echo "vm.swappiness=10" | sudo tee /etc/sysctl.d/99-swappiness.conf

# Apply immediately
sudo sysctl vm.swappiness=10
```

#### 6. Use zram (Compressed RAM)

```bash
sudo pacman -S zram-generator

sudo tee /etc/systemd/zram-generator.conf << EOF
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOF

sudo systemctl daemon-reload
```

### Qtile-Specific Optimizations

#### 1. Reduce Widget Update Intervals

Edit `~/.config/qtile/config.py`:

```python
# Before (frequent updates)
widget.Battery(update_interval=10)

# After (less frequent)
widget.Battery(update_interval=60)
```

#### 2. Minimize Layouts

```python
layouts = [
    layout.Columns(),  # Primary layout
    layout.Max(),      # Fullscreen
    # Remove unused layouts
]
```

#### 3. Optimize Compositor

Create `~/.config/picom/picom.conf`:

```conf
# Performance-optimized config
backend = "glx";
vsync = true;
glx-no-stencil = true;
glx-no-rebind-pixmap = true;

# Disable shadows/blur for performance
shadow = false;
blur-background = false;
```

#### 4. Clean Autostart

Edit `~/.config/qtile/autostart.sh`:

```bash
#!/bin/bash
# Only start essential services
picom -b &
dunst &
nm-applet &
# Remove unused applications
```

---

## 🔧 TROUBLESHOOTING

### Common Issues and Solutions

#### Issue: Pacman Database Locked

```bash
# Remove lock file
sudo rm /var/lib/pacman/db.lck

# If above doesn't work
sudo pacman -Syy
```

#### Issue: Package Signature Errors

```bash
# Update keyring
sudo pacman -Sy archlinux-keyring

# If still fails, refresh keys
sudo pacman-key --refresh-keys
sudo pacman-key --populate archlinux
```

#### Issue: Broken Dependencies

```bash
# Check and fix
sudo pacman -Dk

# Reinstall packages
sudo pacman -S $(pacman -Qnq)
```

#### Issue: Qtile Won't Start

```bash
# Check for syntax errors
python -m py_compile ~/.config/qtile/config.py

# View errors
cat ~/.local/share/qtile/qtile.log

# Start with minimal config
cp ~/.config/qtile/config_minimal.py ~/.config/qtile/config.py
```

#### Issue: High Memory Usage

```bash
# Check processes
htop

# Find memory hogs
ps aux --sort=-%mem | head

# Clear cache
sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
```

#### Issue: Slow Boot

```bash
# Analyze boot time
systemd-analyze blame

# Disable slow services
sudo systemctl disable <service-name>
```

---

## 🆘 EMERGENCY RECOVERY

### Boot Issues

#### 1. Boot to Recovery Mode

```bash
# At GRUB menu, select:
# Advanced options -> Recovery mode
```

#### 2. Fix Broken System from Live USB

```bash
# Boot from Arch live USB
# Mount your system
sudo mount /dev/sda2 /mnt
sudo mount /dev/sda1 /mnt/boot  # if separate boot partition
sudo arch-chroot /mnt

# Fix system
pacman -Syu
mkinitcpio -P
grub-mkconfig -o /boot/grub/grub.cfg

# Exit and reboot
exit
reboot
```

### Data Recovery

#### Backup Critical Data

```bash
# Before major changes, backup:
sudo tar -czf ~/backup-$(date +%Y%m%d).tar.gz \
    ~/.config \
    ~/Documents \
    ~/Pictures
```

#### Restore from Snapshot (Timeshift)

```bash
# Install Timeshift
sudo pacman -S timeshift

# Create snapshot before changes
sudo timeshift --create --comments "Before system update"

# Restore if needed
sudo timeshift --restore
```

---

## 📊 MONITORING COMMANDS

### Quick Status Checks

```bash
# Disk usage
df -h

# Memory usage
free -h

# CPU usage
htop

# Network usage
vnstat -d

# System logs
journalctl -xe

# Failed services
systemctl --failed

# Recent errors
journalctl -p 3 -xn 20

# Package statistics
pacman -Q | wc -l  # Total packages
pacman -Qe | wc -l # Explicitly installed
pacman -Qtd | wc -l # Orphaned packages
```

---

## 🎯 MAINTENANCE CHECKLIST

### Daily
- [ ] Check for critical errors: `journalctl -p 3 -xn 5`
- [ ] Monitor disk space: `df -h`

### Weekly
- [ ] Update system: `sudo pacman -Syu`
- [ ] Clean package cache: `sudo paccache -rk3`
- [ ] Remove orphans: `sudo pacman -Rns $(pacman -Qtdq)`
- [ ] Clean logs: `sudo journalctl --vacuum-time=3d`

### Monthly
- [ ] Run full cleanup script
- [ ] Check system health
- [ ] Update mirrors
- [ ] Security audit
- [ ] Backup configurations
- [ ] Review failed services
- [ ] Check disk health

### Quarterly
- [ ] Full security hardening review
- [ ] Clean old kernels
- [ ] Review installed packages
- [ ] Update documentation
- [ ] Test backup restore

---

## 📚 USEFUL RESOURCES

### Official Documentation
- Arch Wiki: https://wiki.archlinux.org/
- Qtile Docs: http://docs.qtile.org/
- Pacman Manual: `man pacman`

### Community
- Arch Forums: https://bbs.archlinux.org/
- Qtile GitHub: https://github.com/qtile/qtile
- r/archlinux: https://reddit.com/r/archlinux

### Security
- Arch Security: https://security.archlinux.org/
- CVE Database: https://cve.mitre.org/

---

## ⚠️ IMPORTANT NOTES

1. **Always backup before major changes**
2. **Read the Arch News before updating**: https://archlinux.org/news/
3. **Test updates in non-critical times**
4. **Keep a live USB handy for recovery**
5. **Document custom configurations**
6. **Review package changes during updates**

---

**Last Updated**: February 2026  
**System**: Arch Linux + Qtile  
**Maintenance**: Reliable • Secure • Stable
