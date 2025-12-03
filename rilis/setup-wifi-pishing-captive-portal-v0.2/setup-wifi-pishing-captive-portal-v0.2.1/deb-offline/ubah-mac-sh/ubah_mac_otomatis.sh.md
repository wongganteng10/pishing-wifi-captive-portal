Skrip sebelumnya meminta input dari pengguna, skrip ini akan membaca daftar alamat MAC dari mac-address.txt, memilih alamat MAC secara acak dari daftar tersebut, dan menggunakannya untuk mengubah MAC address wlan0.
Skrip Bash (Baca dari File)
Berikut adalah isi file yang harus Anda simpan, misalnya dengan nama ubah_mac_otomatis.sh:
bash
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
Gunakan kode dengan hati-hati.

Cara Menggunakan Skrip Ini
Pastikan Anda memiliki mac-address.txt:
Pastikan file bernama mac-address.txt ada di direktori yang sama dengan skrip Anda dan berisi daftar alamat MAC Anda (satu per baris, seperti yang Anda berikan).
Buat file skrip:
Simpan kode di atas ke file bernama ubah_mac_otomatis.sh.
Berikan izin eksekusi:
bash
chmod +x ubah_mac_otomatis.sh
Gunakan kode dengan hati-hati.

Jalankan skrip:
Jalankan skrip menggunakan sudo:
bash
sudo ./ubah_mac_otomatis.sh
Gunakan kode dengan hati-hati.

Skrip akan memilih salah satu alamat MAC secara acak dari file, menonaktifkan wlan0, mengubah alamatnya, dan mengaktifkannya kembali.


