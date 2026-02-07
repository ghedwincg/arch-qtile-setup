# Arch Linux Pro Security Hardening Suite - User Guide

## 🎯 What's New in Version 2.0

### Major Improvements Over Original

#### **1. Safety & Reliability**
- ✅ **Automatic backups** before ANY changes (keeps last 5)
- ✅ **Rollback capability** - restore any previous state
- ✅ **Dry-run mode** - preview all changes safely
- ✅ **Error handling** - script stops on errors, won't break your system
- ✅ **Configuration testing** - validates SSH config before applying

#### **2. Flexibility & Profiles**
- ✅ **Three security profiles**: minimal, standard, paranoid
- ✅ **Modular design** - run individual components
- ✅ **Interactive mode** - granular control over each step
- ✅ **Force mode** - for automation/scripting

#### **3. Better Configuration**
- ✅ **Profile-based hardening** - appropriate for your use case
- ✅ **SSH custom port** - option to change from default 22
- ✅ **Adaptive fail2ban** - ban times scale with profile
- ✅ **Modern crypto** - ChaCha20-Poly1305, Ed25519 keys
- ✅ **Network hardening** - comprehensive sysctl parameters

#### **4. Enhanced Monitoring**
- ✅ **Comprehensive audit rules** - tracks critical system changes
- ✅ **Better logging** - timestamped, leveled, persistent
- ✅ **Security reports** - HTML & text formats
- ✅ **Statistics tracking** - changes, warnings, errors

#### **5. Enterprise Features**
- ✅ **State management** - tracks what's been hardened
- ✅ **Manifest creation** - documents all backups
- ✅ **Lynis integration** - professional security auditing
- ✅ **USB restrictions** - optional device control

---

## 📋 Security Profiles Explained

### **Minimal Profile**
Best for: Desktop users, beginners, testing

**Includes:**
- Basic firewall (UFW)
- Fail2ban with moderate settings
- Essential kernel hardening
- Minimal service restrictions

**Characteristics:**
- Ban time: 1 hour
- Max retries: 5
- Least intrusive
- No functionality loss

### **Standard Profile** (Default)
Best for: Most users, workstations, development machines

**Includes:**
- Full firewall configuration
- Fail2ban with strict settings
- Comprehensive kernel hardening
- AppArmor enforcement
- Audit daemon
- SSH hardening
- Automatic update notifications

**Characteristics:**
- Ban time: 24 hours
- Max retries: 3
- Balanced security/usability
- Recommended for most

### **Paranoid Profile**
Best for: Servers, high-security environments, sensitive data

**Includes:**
- Everything from Standard, plus:
- ClamAV antivirus
- Maximum kernel hardening
- Ping disabled
- IPv6 disabled (optional)
- USB restrictions
- Custom SSH port option
- AIDE file integrity

**Characteristics:**
- Ban time: 1 week
- Max retries: 2
- Maximum security
- May impact usability

---

## 🚀 Quick Start Guide

### Installation
```bash
# Download script
chmod +x arch-security-hardening-pro.sh

# Run in dry-run mode first (SAFE - no changes)
./arch-security-hardening-pro.sh --dry-run --auto

# Run interactive mode
./arch-security-hardening-pro.sh
```

### Common Usage Patterns

#### **First-Time Setup (Recommended)**
```bash
# 1. Preview what will happen
./arch-security-hardening-pro.sh --dry-run --auto --profile standard

# 2. Run interactive mode to understand each step
./arch-security-hardening-pro.sh --interactive

# 3. Choose option 1 (Run full hardening)
```

#### **Quick Automatic Hardening**
```bash
# Standard profile (recommended)
./arch-security-hardening-pro.sh --auto

# Paranoid profile
./arch-security-hardening-pro.sh --auto --profile paranoid

# Minimal profile
./arch-security-hardening-pro.sh --auto --profile minimal
```

#### **Safe Testing**
```bash
# See exactly what would change WITHOUT making changes
./arch-security-hardening-pro.sh --dry-run --auto --profile paranoid
```

#### **Individual Components**
```bash
# Interactive menu lets you run individual steps
./arch-security-hardening-pro.sh --interactive

# Then choose:
# - Option 4: Configure firewall only
# - Option 5: Harden SSH only
# - Option 6: Configure kernel parameters only
```

---

## 📖 What Each Component Does

### 1. System Backup
**What it does:**
- Backs up all security-related config files
- Creates manifest documenting changes
- Saves current system state
- Keeps last 5 backups automatically

**Files backed up:**
- `/etc/ssh/sshd_config`
- `/etc/sysctl.d/`
- `/etc/ufw/`
- `/etc/fail2ban/`
- `/etc/security/`
- `/etc/audit/`

**Location:**
```
/var/backups/security-hardening/backup_YYYYMMDD_HHMMSS/
```

### 2. System Update
**What it does:**
- Updates package database
- Offers to install all updates
- Ensures security patches are applied

**Why important:**
- Many vulnerabilities are fixed in updates
- Foundation for other hardening

### 3. Security Tools Installation
**Tools installed (based on profile):**

**Core (all profiles):**
- `ufw` - Uncomplicated Firewall
- `fail2ban` - Intrusion prevention
- `lynis` - Security auditing

**Standard adds:**
- `rkhunter` - Rootkit detection
- `firejail` - Application sandboxing
- `apparmor` - Mandatory Access Control
- `audit` - System auditing
- `arch-audit` - CVE scanner for Arch

**Paranoid adds:**
- `clamav` - Antivirus scanner
- `aide` - File integrity checker
- `tiger` - Security assessment tool

### 4. Firewall (UFW)
**Default rules:**
- Deny all incoming
- Allow all outgoing
- Deny routing (not a router)

**Optional ports:**
- SSH (22) - with rate limiting
- HTTP (80)
- HTTPS (443)

**Example UFW status after:**
```
Status: active
Logging: on (medium)

To                         Action      From
--                         ------      ----
22/tcp                     LIMIT       Anywhere
80/tcp                     ALLOW       Anywhere
443/tcp                    ALLOW       Anywhere
```

### 5. Fail2Ban
**What it monitors:**
- SSH login attempts
- SSH DDoS attempts

**Profile settings:**

| Setting | Minimal | Standard | Paranoid |
|---------|---------|----------|----------|
| Ban time | 1 hour | 24 hours | 1 week |
| Find time | 10 min | 10 min | 5 min |
| Max retry | 5 | 3 | 2 |

**After 3 failed SSH attempts (standard):**
```
# Attacker is banned for 24 hours
# You can check with:
sudo fail2ban-client status sshd
```

### 6. SSH Hardening
**Changes applied:**

**Security:**
- ✅ Disable root login
- ✅ Disable password authentication (key-only)
- ✅ Disable empty passwords
- ✅ Disable X11 forwarding
- ✅ Disable agent forwarding
- ✅ Disable TCP forwarding
- ✅ Protocol 2 only (no SSH-1)

**Crypto:**
- ✅ Modern ciphers (ChaCha20-Poly1305, AES-GCM)
- ✅ Strong MACs (SHA2-512, SHA2-256)
- ✅ Secure key exchange (Curve25519, DH-16/18)

**Logging:**
- ✅ Verbose logging for security events
- ✅ Login banner warning

**Custom port (paranoid only):**
- Option to change from port 22 to custom port

**CRITICAL: Before applying:**
1. ✅ Ensure you have SSH keys set up
2. ✅ Test key-based login works
3. ✅ Have physical/console access if remote
4. ✅ Keep existing session open while testing

### 7. AppArmor (MAC)
**What it does:**
- Mandatory Access Control system
- Confines programs to limited resources
- Prevents privilege escalation

**Enforcement levels:**
- **Minimal**: Not configured
- **Standard**: Critical profiles in enforce mode
- **Paranoid**: All profiles in enforce mode

**Check status:**
```bash
sudo aa-status
```

### 8. Audit Daemon
**What it monitors:**
- Password file changes (`/etc/passwd`, `/etc/shadow`)
- Sudo configuration changes
- SSH configuration changes
- Network configuration changes
- Kernel module loading/unloading
- Time changes
- Privileged command execution
- Login attempts

**View audit logs:**
```bash
# Recent events
sudo ausearch -ts recent

# Failed login attempts
sudo ausearch -m USER_LOGIN -sv no

# Sudo usage
sudo ausearch -k privileged_commands
```

### 9. Kernel Hardening (sysctl)
**Network security:**
- ✅ SYN cookies (DDoS protection)
- ✅ Ignore ICMP redirects
- ✅ Disable source routing
- ✅ Reverse path filtering
- ✅ Log martian packets

**Paranoid additions:**
- ✅ Disable ping (ICMP echo)
- ✅ Disable IPv6 (if not needed)

**Kernel protection:**
- ✅ Restrict dmesg access
- ✅ Hide kernel pointers
- ✅ Restrict ptrace (debugging)
- ✅ Disable kexec

**Filesystem:**
- ✅ Protected hardlinks
- ✅ Protected symlinks
- ✅ SUID dump disabled

**View current settings:**
```bash
sudo sysctl -a | grep -E "net.ipv4|kernel"
```

### 10. File Permissions
**Secured files:**
- `/boot/grub/grub.cfg` → 600
- `/root` → 700
- `/etc/shadow` → 600
- `/etc/gshadow` → 600

**Scans for:**
- World-writable files (security risk)
- SUID binaries (privilege escalation risk)

**Results saved to:**
- `/tmp/world-writable-files.txt`
- `/tmp/suid-binaries.txt`

### 11. Service Management
**Potentially disabled:**
- `bluetooth.service` - If not using Bluetooth
- `cups.service` - If not printing
- `avahi-daemon.service` - If not using mDNS
- `ModemManager.service` - If not using modem

**Why disable?**
- Reduces attack surface
- Saves resources
- Prevents unauthorized access vectors

### 12. Update Notifications
**Creates:**
- Script: `/usr/local/bin/check-security-updates`
- Service: `check-security-updates.service`
- Timer: `check-security-updates.timer`

**What it does:**
- Runs daily (randomized time)
- Checks for available updates
- Counts security-related updates
- Sends desktop notification
- Logs to systemd journal

**View notifications:**
```bash
journalctl -t security-updates
```

### 13. ClamAV (Paranoid only)
**What it does:**
- Antivirus scanning
- Regular virus definition updates

**Usage:**
```bash
# Scan home directory
sudo clamscan -r /home

# Scan with reporting
sudo clamscan -r --infected /home

# Background scan
sudo clamscan -r -i /home &
```

### 14. USB Restrictions (Paranoid only)
**Default behavior:**
- Logs all USB device connections
- Does NOT block (safe default)

**To enable blocking:**
1. Edit `/etc/udev/rules.d/99-usb-restrict.rules`
2. Uncomment the blocking rule
3. Add your trusted devices to whitelist
4. Run `sudo udevadm control --reload-rules`

### 15. Security Report
**Generates comprehensive report with:**
- Firewall status
- Fail2Ban status
- AppArmor status
- Listening ports
- SUID binaries
- World-writable directories
- Active services
- SSH configuration
- Recent failed logins
- Available security updates

**Location:**
```
~/security_report_YYYYMMDD_HHMMSS.txt
```

---

## 🔄 Backup & Restore

### Creating Backups
```bash
# Automatic (during hardening)
./arch-security-hardening-pro.sh --auto

# Manual backup only
./arch-security-hardening-pro.sh --interactive
# Choose option 2
```

### Restoring from Backup
```bash
# Interactive restore
./arch-security-hardening-pro.sh --restore

# Or from menu
./arch-security-hardening-pro.sh --interactive
# Choose option 3
```

**Available backups:**
```
/var/backups/security-hardening/
├── backup_20260206_140523/
├── backup_20260206_150234/
└── backup_20260206_160845/
```

**Each backup contains:**
- All original config files
- MANIFEST.txt (what was backed up)
- system_state.conf (service states)

---

## 🎛️ Command-Line Options

### Basic Options
```bash
-h, --help           # Show help
-a, --auto           # Automatic mode (no prompts)
-i, --interactive    # Interactive menu (default)
-d, --dry-run        # Preview only, no changes
-f, --force          # Skip confirmations
-n, --no-backup      # Don't create backup (NOT recommended)
-r, --restore        # Restore from backup
--version            # Show version
```

### Profile Selection
```bash
-p, --profile PROFILE

# Examples:
-p minimal
-p standard  # default
-p paranoid
```

### Examples
```bash
# Preview paranoid hardening
./arch-security-hardening-pro.sh -d -a -p paranoid

# Quick standard hardening
./arch-security-hardening-pro.sh -a

# Force mode (automation)
./arch-security-hardening-pro.sh -a -f -p standard

# Restore from backup
./arch-security-hardening-pro.sh -r
```

---

## 🛡️ After Hardening Checklist

### Immediate (Before Reboot)
- [ ] Review security report in home directory
- [ ] Check firewall rules: `sudo ufw status`
- [ ] Verify SSH config: `sudo sshd -t`
- [ ] **CRITICAL**: Test SSH login from another terminal (if remote)
- [ ] Review logs: `/var/log/security-hardening/`

### After Reboot
- [ ] Verify all services started: `systemctl --failed`
- [ ] Check firewall: `sudo ufw status`
- [ ] Check fail2ban: `sudo fail2ban-client status`
- [ ] Check AppArmor: `sudo aa-status`
- [ ] Test SSH access (if using SSH)
- [ ] Test network connectivity
- [ ] Test USB devices (if paranoid profile)

### Weekly
- [ ] Check for updates: `pacman -Syu`
- [ ] Review fail2ban logs: `sudo fail2ban-client status sshd`
- [ ] Check audit logs: `sudo ausearch -ts recent`

### Monthly
- [ ] Run Lynis audit: `sudo lynis audit system`
- [ ] Review SUID binaries: `cat /tmp/suid-binaries.txt`
- [ ] Scan with ClamAV (if installed): `sudo clamscan -r /home`
- [ ] Review security report

---

## 🚨 Troubleshooting

### SSH: Can't Login After Hardening

**Symptoms:**
```
Permission denied (publickey)
```

**Solutions:**

1. **Check if you have SSH keys set up:**
```bash
ls -la ~/.ssh/
# Should see: id_rsa, id_rsa.pub or id_ed25519, id_ed25519.pub
```

2. **Generate keys if missing:**
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

3. **Copy key to server:**
```bash
ssh-copy-id user@server
```

4. **Restore SSH config from backup:**
```bash
./arch-security-hardening-pro.sh --restore
# Select the backup
# Copy only /etc/ssh/sshd_config
sudo systemctl restart sshd
```

### Firewall: Blocked from Accessing Service

**Symptoms:**
```
Connection refused
```

**Solutions:**

1. **Check UFW status:**
```bash
sudo ufw status verbose
```

2. **Allow specific port:**
```bash
sudo ufw allow 8080/tcp comment 'My Application'
sudo ufw reload
```

3. **Temporarily disable (testing):**
```bash
sudo ufw disable
# Test your service
sudo ufw enable
```

### Fail2Ban: Accidentally Banned Yourself

**Symptoms:**
```
ssh: connect to host X port 22: Connection refused
```

**Solutions:**

1. **From console/physical access:**
```bash
sudo fail2ban-client set sshd unbanip YOUR_IP
```

2. **Check banned IPs:**
```bash
sudo fail2ban-client status sshd
```

3. **Whitelist your IP permanently:**
```bash
sudo nano /etc/fail2ban/jail.local

# Add under [DEFAULT]:
ignoreip = 127.0.0.1/8 ::1 YOUR_IP
```

### Kernel Parameters: System Issues After Hardening

**Symptoms:**
- Network connectivity issues
- Application failures

**Solutions:**

1. **Check current parameters:**
```bash
sudo sysctl -a | grep -E "issue_keyword"
```

2. **Temporarily revert specific parameter:**
```bash
sudo sysctl -w net.ipv4.parameter_name=original_value
```

3. **Permanently revert:**
```bash
sudo nano /etc/sysctl.d/99-security-hardening.conf
# Comment out or modify the problematic line
sudo sysctl --system
```

### AppArmor: Application Won't Start

**Symptoms:**
```
Permission denied
audit: type=1400 denied
```

**Solutions:**

1. **Check AppArmor denials:**
```bash
sudo dmesg | grep -i apparmor
sudo ausearch -m AVC -ts recent
```

2. **Set profile to complain mode:**
```bash
sudo aa-complain /path/to/profile
```

3. **Disable specific profile:**
```bash
sudo aa-disable /path/to/profile
```

---

## 📊 Understanding Logs

### Main Log File
```bash
/var/log/security-hardening/hardening_YYYYMMDD_HHMMSS.log
```

**Log levels:**
- `[✓ OK]` - Success, everything good
- `[ℹ INFO]` - Informational message
- `[⚠ WARN]` - Warning, review recommended
- `[✗ ERROR]` - Error occurred
- `[⚙ CHANGE]` - Configuration change made
- `[⊘ SKIP]` - Step skipped

**Example log entry:**
```
[2026-02-06 14:05:23][CHANGE] Firewall configured and enabled
[2026-02-06 14:05:24][SUCCESS] SSH configuration test passed
[2026-02-06 14:05:25][WARN] Found 15 world-writable files
```

### System Logs
```bash
# Fail2Ban logs
sudo journalctl -u fail2ban

# UFW logs
sudo journalctl -u ufw

# SSH logs
sudo journalctl -u sshd

# Audit logs
sudo ausearch -ts recent

# Security update checks
journalctl -t security-updates
```

---

## 🔐 Security Best Practices

### SSH Key Management
```bash
# Generate strong Ed25519 key
ssh-keygen -t ed25519 -a 100 -C "description"

# Or RSA 4096-bit
ssh-keygen -t rsa -b 4096 -C "description"

# Protect your private key
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

### Regular Maintenance
```bash
# Weekly: Check for updates
sudo pacman -Syu

# Weekly: Scan for CVEs
arch-audit -u

# Monthly: Full security audit
sudo lynis audit system

# Monthly: Check fail2ban stats
sudo fail2ban-client status sshd

# Quarterly: Review SUID binaries
sudo find / -perm -4000 -type f 2>/dev/null
```

### Password Policy
```bash
# Force strong passwords (add to /etc/security/pwquality.conf)
minlen = 14
minclass = 3
maxrepeat = 2
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
```

### Monitoring
```bash
# Watch login attempts in real-time
sudo journalctl -u sshd -f

# Check recent security events
sudo ausearch -m AVC -ts today

# Monitor firewall blocks
sudo journalctl -u ufw -f
```

---

## 🎯 Profile Comparison

| Feature | Minimal | Standard | Paranoid |
|---------|---------|----------|----------|
| **Firewall** | ✅ Basic | ✅ Full | ✅ Full |
| **Fail2Ban** | ✅ Moderate | ✅ Strict | ✅ Maximum |
| **SSH Hardening** | ❌ | ✅ Yes | ✅ + Custom Port |
| **AppArmor** | ❌ | ✅ Yes | ✅ Enforce All |
| **Audit Daemon** | ❌ | ✅ Yes | ✅ Yes |
| **Kernel Hardening** | ✅ Basic | ✅ Full | ✅ Maximum |
| **ClamAV** | ❌ | ❌ | ✅ Yes |
| **USB Restrictions** | ❌ | ❌ | ✅ Yes |
| **Ban Time** | 1 hour | 24 hours | 1 week |
| **Max Retries** | 5 | 3 | 2 |
| **Ping Response** | ✅ | ✅ | ❌ |
| **IPv6** | ✅ | ✅ | ❌ (optional) |

---

## 💡 Tips & Tricks

### Test SSH Changes Safely
```bash
# Keep your current session open
ssh user@server

# In another terminal, test new connection
ssh user@server

# If it works, commit changes
# If not, fix in original session
```

### Whitelist Your IP in Fail2Ban
```bash
sudo nano /etc/fail2ban/jail.local

# Add your IP under [DEFAULT]
ignoreip = 127.0.0.1/8 ::1 192.168.1.100
```

### Custom Firewall Rules
```bash
# Allow specific application
sudo ufw allow from 192.168.1.0/24 to any port 8080 comment 'Local network'

# Allow specific IP only
sudo ufw allow from 203.0.113.0 to any port 22 comment 'Admin IP'

# Block specific IP
sudo ufw deny from 198.51.100.0
```

### Quick Security Check
```bash
# Create alias in ~/.bashrc
alias security-check='
echo "=== Firewall ==="; sudo ufw status;
echo -e "\n=== Fail2Ban ==="; sudo fail2ban-client status;
echo -e "\n=== Updates ==="; arch-audit -u;
echo -e "\n=== Failed Logins ==="; sudo journalctl -u sshd --since today | grep -i failed;
'
```

---

## 🆘 Emergency Recovery

### Locked Out Completely

1. **Boot from Arch USB**
2. **Mount your system:**
```bash
mount /dev/sdaX /mnt
arch-chroot /mnt
```

3. **Restore SSH config:**
```bash
cp /var/backups/security-hardening/backup_*/etc/ssh/sshd_config /etc/ssh/
```

4. **Or disable SSH hardening:**
```bash
nano /etc/ssh/sshd_config
# Set: PasswordAuthentication yes
```

5. **Reboot:**
```bash
exit
umount /mnt
reboot
```

### System Won't Boot

1. **Boot parameter:**
```
# At GRUB, press 'e' and add:
systemd.unit=rescue.target
```

2. **Or emergency mode:**
```
systemd.unit=emergency.target
```

3. **Disable problematic service:**
```bash
systemctl disable apparmor  # or other service
```

---

## 📚 Additional Resources

### Official Documentation
- UFW: https://wiki.archlinux.org/title/Uncomplicated_Firewall
- Fail2Ban: https://github.com/fail2ban/fail2ban
- AppArmor: https://wiki.archlinux.org/title/AppArmor
- SSH: https://wiki.archlinux.org/title/OpenSSH

### Security Guides
- Arch Security: https://wiki.archlinux.org/title/Security
- CIS Benchmarks: https://www.cisecurity.org/
- NIST Guidelines: https://csrc.nist.gov/

### Tools
- Lynis: https://cisofy.com/lynis/
- Arch Audit: https://github.com/ilpianista/arch-audit

---

**Version:** 2.0  
**Author:** Security Hardening Pro  
**License:** Use freely, stay secure  
**Last Updated:** 2026-02-06

**Remember:** Security is a process, not a destination. Keep your system updated!
