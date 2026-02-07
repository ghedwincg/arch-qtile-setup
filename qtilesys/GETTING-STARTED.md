# 🚀 GETTING STARTED - ARCH SYSTEM CLEANUP

## Quick Start (3 Steps to Clean System)

### 1️⃣ **IMMEDIATE CLEANUP** (Do this first!)

```bash
# Make scripts executable
chmod +x arch-cleanup.sh qtile-cleanup.sh

# Run full system cleanup
./arch-cleanup.sh
```

**What it does:**
- Cleans package cache
- Removes orphaned packages
- Cleans system logs
- Removes old kernels
- Frees up disk space

**Time required:** 5-10 minutes

---

### 2️⃣ **QTILE OPTIMIZATION**

```bash
# Optimize Qtile configuration
./qtile-cleanup.sh
```

**What it does:**
- Backs up your Qtile config
- Cleans Qtile cache
- Validates configuration
- Checks dependencies
- Provides performance tips

**Time required:** 2-3 minutes

---

### 3️⃣ **SECURITY HARDENING** (Optional but recommended)

```bash
# Harden system security
./security-hardening.sh
```

**What it does:**
- Configures firewall (UFW)
- Sets up fail2ban
- Hardens SSH
- Enables AppArmor
- Configures kernel security

**Time required:** 15-20 minutes

---

## 📊 What's in Each File?

### **arch-cleanup.sh** - Main System Cleanup
Interactive menu with 18 options:
1. Full system cleanup (recommended first run)
2. Clean package cache
3. Remove orphaned packages
4. Clean system logs
5. Clean user cache
6. Clean old kernels
7. Optimize pacman database
8. Update mirror list
9. Rebuild initramfs
10. Check system health
11. Security audit
12. Firewall setup
13. Enable auto-updates
14. Scan for rootkits
15. Check filesystem
16. Analyze disk usage
17. Fix broken packages
18. Generate system report

### **qtile-cleanup.sh** - Qtile Optimization
- Backs up configuration
- Validates config syntax
- Cleans Python cache
- Checks dependencies
- Optimizes autostart
- Generates minimal config template
- Performance recommendations

### **security-hardening.sh** - Security Setup
- Installs security tools (UFW, fail2ban, AppArmor)
- Configures firewall
- Hardens SSH configuration
- Enables audit daemon
- Kernel hardening (sysctl)
- File permission security
- Automatic update notifications
- ClamAV antivirus setup

### **auto-maintenance.sh** - Automated Weekly Tasks
- Checks for updates (notifies only)
- Cleans package cache
- Removes orphans
- Cleans logs
- Health check
- Auto-runs weekly

### **setup-auto-maintenance.sh** - Enable Automation
Sets up systemd timer for weekly automated maintenance

---

## 💡 Recommended Order

### First Time Setup
```bash
# 1. Make scripts executable
chmod +x *.sh

# 2. Full system cleanup
./arch-cleanup.sh
# Choose option: 1 (Full System Cleanup)

# 3. Optimize Qtile
./qtile-cleanup.sh

# 4. Security hardening (optional)
./security-hardening.sh

# 5. Setup automated maintenance
./setup-auto-maintenance.sh
```

### Weekly Maintenance (Manual)
```bash
./arch-cleanup.sh
# Choose option: 1 (Full System Cleanup)
```

### Weekly Maintenance (Automated)
```bash
# Set up once
./setup-auto-maintenance.sh

# Runs automatically every Sunday at 2 AM
# Check logs: ls ~/.local/share/maintenance-logs/
```

---

## 📋 Quick Commands Reference

### Must-Do Daily
```bash
# Check for updates
pacman -Qu

# Check disk space
df -h

# Check for errors
journalctl -p 3 -n 10
```

### Must-Do Weekly
```bash
# Update system
sudo pacman -Syu

# Clean package cache
sudo paccache -rk3

# Remove orphans
sudo pacman -Rns $(pacman -Qtdq)

# Clean logs
sudo journalctl --vacuum-time=3d
```

### Must-Do Monthly
```bash
# Run full cleanup script
./arch-cleanup.sh

# Generate system report
# (option 18 in arch-cleanup.sh)

# Security audit
sudo lynis audit system
```

---

## 🎯 Expected Results

### After Running arch-cleanup.sh
- **Disk space freed:** 1-10 GB (depending on system)
- **Package cache:** Reduced by 50-90%
- **Logs:** Limited to last 3 days
- **Orphaned packages:** Removed
- **System health:** Checked and reported

### After Running qtile-cleanup.sh
- **Config validated:** No syntax errors
- **Cache cleaned:** Python __pycache__ removed
- **Backup created:** Safe to experiment
- **Performance:** Optimized for speed

### After Running security-hardening.sh
- **Firewall:** Enabled and configured
- **SSH:** Hardened (if applicable)
- **Kernel:** Security parameters set
- **Services:** Unnecessary ones disabled
- **Updates:** Auto-notification enabled

---

## ⚠️ Important Notes

### Before Running Scripts
1. **Close important applications**
2. **Have live USB ready** (just in case)
3. **Read Arch News** (https://archlinux.org/news/)
4. **Have time to troubleshoot** (if needed)

### Safety Features
- All scripts create backups
- No destructive actions without confirmation
- Detailed logging of all operations
- Can be interrupted safely (Ctrl+C)

### If Something Goes Wrong
1. Check the log files generated
2. Reboot and try again
3. Use Qtile backup: `~/.config/qtile-backup-*`
4. Consult MAINTENANCE-GUIDE.md
5. Boot from live USB for recovery

---

## 📚 Documentation Files

- **MAINTENANCE-GUIDE.md** - Complete maintenance guide
- **QUICK-REFERENCE.txt** - Command cheatsheet
- **README.md** - Rofi configuration (from earlier)
- **CHEATSHEET.txt** - Rofi quick reference

---

## 🆘 Emergency Commands

### System won't boot
```bash
# Boot from live USB
sudo mount /dev/sda2 /mnt
sudo arch-chroot /mnt
pacman -Syu
mkinitcpio -P
exit && reboot
```

### Qtile won't start
```bash
# Use minimal config
cp ~/.config/qtile/config_minimal.py ~/.config/qtile/config.py

# Or restore backup
cp -r ~/.config/qtile-backup-* ~/.config/qtile
```

### Broken packages
```bash
sudo pacman -Syy
sudo pacman -S $(pacman -Qnq)
```

---

## 📊 Monitoring Progress

### Check Disk Space Before/After
```bash
# Before
df -h

# Run cleanup
./arch-cleanup.sh

# After
df -h
```

### View Logs
```bash
# System logs
journalctl -xe

# Cleanup script logs
ls ~/.local/share/maintenance-logs/

# Qtile optimization log
ls ~/qtile_cleanup_*.log
```

---

## ✅ Success Checklist

After running all scripts, you should have:

- [ ] System updated to latest packages
- [ ] Package cache reduced
- [ ] No orphaned packages
- [ ] Logs limited to 3 days
- [ ] Disk space freed up
- [ ] Qtile config validated
- [ ] Qtile backup created
- [ ] Firewall enabled (if you ran security script)
- [ ] Automated maintenance scheduled
- [ ] System report generated
- [ ] No failed services

---

## 🎉 You're Done!

Your Arch + Qtile system is now:
- ✅ **Reliable** - Optimized and error-free
- ✅ **Secure** - Hardened and protected
- ✅ **Stable** - Clean and maintained

### Maintain It With:
- **Daily:** Quick health checks
- **Weekly:** Automated maintenance (if setup)
- **Monthly:** Full cleanup script

---

**Need Help?**
- Check MAINTENANCE-GUIDE.md for details
- Use QUICK-REFERENCE.txt for commands
- Arch Wiki: https://wiki.archlinux.org/
- Qtile Docs: http://docs.qtile.org/
