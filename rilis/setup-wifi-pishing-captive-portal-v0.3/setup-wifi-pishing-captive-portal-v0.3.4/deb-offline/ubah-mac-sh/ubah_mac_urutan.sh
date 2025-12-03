#!/bin/bash

# --- Konfigurasi ---
MAC_FILE="mac-address.txt"
INDEX_FILE=".last_mac_index"
INTERFACE="wlan0"
# -------------------

# Memeriksa keberadaan file utama
if [ ! -f "$MAC_FILE" ]; then
    echo "Error: File $MAC_FILE tidak ditemukan!"
    exit 1
fi

# Membaca total jumlah alamat MAC dalam file
total_macs=$(wc -l < "$MAC_FILE")

# Membaca indeks terakhir yang digunakan (default ke 0 jika file indeks tidak ada)
current_index=0
if [ -f "$INDEX_FILE" ]; then
    read current_index < "$INDEX_FILE"
fi

# Menentukan indeks berikutnya
next_index=$((current_index + 1))

# Cek apakah sudah mencapai akhir file
if [ "$next_index" -gt "$total_macs" ]; then
    echo "Sudah mencapai akhir daftar MAC address."
    read -p "Apakah Anda ingin mengulang dari awal? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        next_index=1 # Mulai dari baris pertama lagi
    else
        echo "Berhenti. Tidak ada perubahan MAC address yang dilakukan."
        exit 0
    fi
fi

# Mengambil alamat MAC yang sesuai dengan next_index
# Menggunakan sed untuk mengambil baris tertentu
new_mac=$(sed -n "${next_index}p" "$MAC_FILE")

echo "Alamat MAC yang akan digunakan (Baris $next_index/$total_macs): $new_mac"

# Memeriksa apakah pengguna menjalankan skrip sebagai root
if [ "$(id -u)" != "0" ]; then
   echo "Skrip ini harus dijalankan dengan sudo atau sebagai root." 1>&2
   exit 1
fi

# --- Proses Perubahan MAC Address ---

echo "Mengubah alamat MAC untuk $INTERFACE..."

# Menonaktifkan antarmuka
ifconfig "$INTERFACE" down
echo "$INTERFACE dinonaktifkan."

# Mengubah alamat MAC
macchanger -m "$new_mac" "$INTERFACE"
echo "Alamat MAC diubah."

# Mengaktifkan kembali antarmuka
ifconfig "$INTERFACE" up
echo "$INTERFACE diaktifkan kembali."

# Menampilkan konfigurasi akhir
echo "Konfigurasi $INTERFACE saat ini:"
ifconfig "$INTERFACE" | grep ether

# --- Update Indeks ---
# Menyimpan indeks yang baru digunakan ke file indeks untuk penggunaan berikutnya
echo "$next_index" > "$INDEX_FILE"
echo "Indeks terakhir yang digunakan ($next_index) telah disimpan."
