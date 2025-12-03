#!/bin/bash

# Pastikan file mac-address.txt ada
if [ ! -f mac-address.txt ]; then
    echo "Error: File mac-address.txt tidak ditemukan!"
    exit 1
fi

# Memilih alamat MAC acak dari file
# shuf -n 1 adalah perintah Linux untuk mengambil 1 baris acak dari input
new_mac=$(shuf -n 1 mac-address.txt)

# Memeriksa apakah alamat MAC berhasil diambil
if [ -z "$new_mac" ]; then
    echo "Error: Gagal membaca alamat MAC dari file."
    exit 1
fi

echo "Alamat MAC acak yang dipilih dari file: $new_mac"

# Memeriksa apakah pengguna menjalankan skrip sebagai root
if [ "$(id -u)" != "0" ]; then
   echo "Skrip ini harus dijalankan dengan sudo atau sebagai root." 1>&2
   exit 1
fi

# Antarmuka jaringan yang akan diubah
interface="wlan0"

echo "Mengubah alamat MAC untuk $interface menjadi $new_mac..."

# Menonaktifkan antarmuka
ifconfig "$interface" down
echo "$interface dinonaktifkan."

# Mengubah alamat MAC
macchanger -m "$new_mac" "$interface"
echo "Alamat MAC diubah."

# Mengaktifkan kembali antarmuka
ifconfig "$interface" up
echo "$interface diaktifkan kembali."

# Menampilkan konfigurasi akhir
echo "Konfigurasi $interface saat ini:"
ifconfig "$interface" | grep ether
