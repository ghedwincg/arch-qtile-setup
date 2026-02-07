#!/usr/bin/env bash

###############################################################################
# ROFI NETWORK MANAGER - Tailored for Arch + Qtile + NetworkManager
###############################################################################

# Rofi CMD
rofi_cmd() {
    rofi -dmenu \
        -p "Network" \
        -theme-str 'window {width: 500px; height: 400px;}' \
        -theme-str 'listview {columns: 1; lines: 12;}' \
        -i
}

# Options
wifi_on="📶  WiFi On"
wifi_off="📴  WiFi Off"
wifi_connect="🔗  Connect WiFi"
wifi_disconnect="❌  Disconnect WiFi"
ethernet="🔌  Ethernet Status"
vpn="🔒  VPN Status"
airplane="✈  Airplane Mode"
settings="⚙️  Network Settings"

# Main function
main() {
    # Show menu
    choice=$(echo -e "$wifi_connect\n$wifi_disconnect\n$wifi_on\n$wifi_off\n$ethernet\n$vpn\n$airplane\n$settings" | rofi_cmd)

    case $choice in
        "$wifi_on")
            nmcli radio wifi on
            notify-send "Network" "WiFi Enabled"
            ;;
        "$wifi_off")
            nmcli radio wifi off
            notify-send "Network" "WiFi Disabled"
            ;;
        "$wifi_connect")
            # List available networks
            network=$(nmcli -f SSID,SECURITY,SIGNAL device wifi list | tail -n +2 | rofi_cmd)
            if [[ -n "$network" ]]; then
                ssid=$(echo "$network" | awk '{print $1}')
                security=$(echo "$network" | awk '{print $2}')
                if [[ "$security" != "--" ]]; then
                    password=$(rofi -dmenu -password -p "Password for $ssid" \
                        -theme-str 'window {width: 400px; height: 100px;}' \
                        -theme-str 'listview {enabled: false;}')
                    if [[ -n "$password" ]]; then
                        nmcli device wifi connect "$ssid" password "$password"
                        notify-send "Network" "Connecting to $ssid..."
                    fi
                else
                    nmcli device wifi connect "$ssid"
                    notify-send "Network" "Connecting to $ssid..."
                fi
            fi
            ;;
        "$wifi_disconnect")
            # Disconnect active WiFi interface dynamically
            iface=$(nmcli device status | awk '/wifi/ {print $1; exit}')
            if [[ -n "$iface" ]]; then
                nmcli device disconnect "$iface"
                notify-send "Network" "WiFi Disconnected"
            else
                notify-send "Network" "No WiFi interface found"
            fi
            ;;
        "$ethernet")
            ethernet_status=$(nmcli device status | grep ethernet || echo "No ethernet device")
            notify-send "Ethernet Status" "$ethernet_status"
            ;;
        "$vpn")
            vpn_status=$(nmcli connection show --active | grep vpn)
            if [[ -n "$vpn_status" ]]; then
                notify-send "VPN Status" "Active:\n$vpn_status"
            else
                notify-send "VPN Status" "No active VPN connections"
            fi
            ;;
        "$airplane")
            current=$(nmcli radio all)
            if [[ "$current" == *"enabled"* ]]; then
                nmcli radio all off
                notify-send "Network" "Airplane Mode Enabled"
            else
                nmcli radio all on
                notify-send "Network" "Airplane Mode Disabled"
            fi
            ;;
        "$settings")
            if command -v nm-connection-editor &> /dev/null; then
                nm-connection-editor &
            else
                notify-send "Error" "Network Manager GUI not found"
            fi
            ;;
    esac
}

main
