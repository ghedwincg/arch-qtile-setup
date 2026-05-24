#!/usr/bin/env python3

import sys, os, subprocess, psutil
from PyQt6.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QHBoxLayout, QPushButton,
    QSlider, QLabel, QFrame, QTextEdit, QLineEdit
)
from PyQt6.QtCore import Qt, QTimer

try:
    sys.path.append(os.path.expanduser("~/.config/qtile"))
    from theme_gen import colors
except ImportError:
    # Fallback if theme_gen isn't found
    colors = {'bg': '#1a1b26', 'fg': '#a9b1d6', 'acc': '#7aa2f7'}

STYLE = f"""
QWidget {{ background-color: {colors['bg']}; color: {colors['fg']}; font-family: "Ubuntu"; font-size: 12px; }}
QFrame#card {{ background-color: {colors['bg']}; border: 1px solid {colors['acc']}; border-radius: 12px; padding: 10px; }}
QPushButton {{ background-color: {colors['acc']}; border-radius: 8px; padding: 8px; border: none; color: {colors['bg']}; font-weight: bold; }}
QPushButton:hover {{ background-color: {colors['fg']}; color: {colors['bg']}; }}
QLineEdit {{ background-color: {colors['bg']}; border: 1px solid {colors['acc']}; border-radius: 5px; padding: 5px; color: {colors['fg']}; }}
QSlider::groove:horizontal {{ height: 6px; background: {colors['fg']}; border-radius: 3px; }}
QSlider::handle:horizontal {{ background: {colors['acc']}; width: 14px; margin: -4px 0; border-radius: 7px; }}
QLabel#header {{ font-weight: bold; color: {colors['acc']}; margin-top: 5px; }}
"""

class ControlCenter(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Control Center")
        self.setStyleSheet(STYLE)

        # Safe defaults
        self.last_net_io = psutil.net_io_counters() if hasattr(psutil, "net_io_counters") else None
        layout = QVBoxLayout(self)

        # Stats Card
        card = QFrame(); card.setObjectName("card"); layout.addWidget(card)
        stats_lay = QVBoxLayout(card)
        r1 = QHBoxLayout()
        self.cpu_l = QLabel("CPU: ?"); self.ram_l = QLabel("RAM: ?"); self.tmp_l = QLabel("?°C")
        r1.addWidget(self.cpu_l); r1.addWidget(self.ram_l); r1.addWidget(self.tmp_l); stats_lay.addLayout(r1)
        r2 = QHBoxLayout(); self.dn_l = QLabel("   ? KB/s"); self.up_l = QLabel("   ? KB/s")
        r2.addWidget(self.dn_l); r2.addWidget(self.up_l); stats_lay.addLayout(r2)

        # Update button
        btn_up = QPushButton("    System Update (yay)"); btn_up.setObjectName("update")
        btn_up.clicked.connect(lambda: subprocess.Popen(["alacritty", "-e", "yay", "-Syu"]))
        layout.addWidget(btn_up)

        # Connectivity
        conn = QHBoxLayout()
        self.btn_wifi = QPushButton("Wi-Fi")
        self.btn_wifi.clicked.connect(self.toggle_wifi)
        conn.addWidget(self.btn_wifi)
        conn.addWidget(QPushButton("Bluetooth", clicked=lambda: os.system("rfkill toggle bluetooth")))
        conn.addWidget(QPushButton("Packages", clicked=lambda: os.system("pamac-manager &")))
        layout.addLayout(conn)

        # Volume
        layout.addWidget(QLabel("   Volume", objectName="header"))
        self.vol = QSlider(Qt.Orientation.Horizontal); self.vol.setRange(0, 100)
        self.vol.valueChanged.connect(lambda v: os.system(f"pamixer --set-volume {v}"))
        layout.addWidget(self.vol)

        # Packages
        layout.addWidget(QLabel("   Packages", objectName="header"))
        self.search = QLineEdit(placeholderText="Filter...")
        self.search.textChanged.connect(self.filter_pkgs)
        layout.addWidget(self.search)
        self.display = QTextEdit(); self.display.setReadOnly(True); layout.addWidget(self.display)

        try:
            self.pkgs = subprocess.getoutput("pacman -Qqen && echo '--- AUR ---' && pacman -Qqem")
        except Exception:
            self.pkgs = "Package list unavailable"
        self.display.setText(self.pkgs)

        # Timers
        self.timer = QTimer(); self.timer.timeout.connect(self.refresh); self.timer.start(2000)
        self.refresh()

    def refresh(self):
        try:
            self.cpu_l.setText(f"CPU: {psutil.cpu_percent()}%")
        except Exception:
            self.cpu_l.setText("CPU: ?")

        try:
            self.ram_l.setText(f"RAM: {psutil.virtual_memory().percent}%")
        except Exception:
            self.ram_l.setText("RAM: ?")

        try:
            t = psutil.sensors_temperatures()
            ct = 0
            for n in t:
                if t[n]:
                    ct = t[n][0].current
                    break
            self.tmp_l.setText(f"{int(ct)}°C")
        except Exception:
            self.tmp_l.setText("?°C")

        try:
            if self.last_net_io:
                nio = psutil.net_io_counters()
                self.dn_l.setText(f"   {(nio.bytes_recv - self.last_net_io.bytes_recv)/2048:.1f} KB/s")
                self.up_l.setText(f"   {(nio.bytes_sent - self.last_net_io.bytes_sent)/2048:.1f} KB/s")
                self.last_net_io = nio
        except Exception:
            self.dn_l.setText("   ? KB/s"); self.up_l.setText("   ? KB/s")

        try:
            v = subprocess.getoutput("pamixer --get-volume")
            if v.isdigit():
                self.vol.blockSignals(True)
                self.vol.setValue(int(v))
                self.vol.blockSignals(False)
        except Exception:
            pass

        try:
            wifi_state = subprocess.getoutput("nmcli radio wifi")
            self.btn_wifi.setObjectName("active" if "enabled" in wifi_state else "")
        except Exception:
            self.btn_wifi.setObjectName("")

        self.setStyleSheet(STYLE)

    def filter_pkgs(self, t):
        try:
            self.display.setText("\n".join([l for l in self.pkgs.split("\n") if t.lower() in l.lower()]))
        except Exception:
            self.display.setText(self.pkgs)

    def toggle_wifi(self):
        try:
            s = subprocess.getoutput("nmcli radio wifi")
            os.system("nmcli radio wifi off" if "enabled" in s else "nmcli radio wifi on")
        except Exception:
            pass

if __name__ == "__main__":
    app = QApplication(sys.argv)
    w = ControlCenter()
    w.show()
    sys.exit(app.exec())
