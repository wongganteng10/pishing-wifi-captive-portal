
# 🎣 WiFi Captive Portal Phishing Tool

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)



## ⚙️ paket yang harus di install untuk menjalankan config 

Instal paket-paket berikut sebelum menjalankan skrip:

```bash
# Update sistem terlebih dahulu
sudo apt update

# Install paket-paket utama
sudo apt install -y hostapd isc-dhcp-server dnsmasq lighttpd iptables dos2unix wireless-tools iw net-tools aircrack-ng procps
```
```bash
# Untuk monitoring jaringan (Opsional)
sudo apt install -y wireless-tools iw rfkill tcpdump netfilter-persistent iptables-persistent
```

* dhcpd.conf
* dnsmasq.conf
* hostapd.conf
* lighttpd.conf

## 🌟 Deskripsi Proyek

Proyek ini adalah sebuah skrip otomatisasi yang bertujuan untuk mengatur lingkungan **Evil Twin Access Point (AP)** dan **Captive Portal** menggunakan layanan jaringan standar Linux seperti `hostapd`, `dnsmasq`, `isc-dhcp-server` dan `lighttpd`.

Tujuan utamanya adalah untuk mendemonstrasikan kerentanan jaringan dengan meniru Access Point yang sah dan menangkap kredensial pengguna melalui halaman *login* palsu.

**⚠️ Peringatan:** Alat ini ditujukan semata-mata untuk **tujuan edukasi, penelitian keamanan, dan pengujian penetrasi etis** di lingkungan yang sah dan telah disetujui. Penggunaan alat ini untuk tujuan ilegal atau tanpa izin adalah **TANGGUNG JAWAB PENGGUNA SEPENUHNYA**.

---

## ⚙️ Persyaratan Sistem

Pastikan sistem Anda memenuhi persyaratan berikut:

* Sistem Operasi berbasis Linux (Debian/Ubuntu direkomendasikan).
* Kartu Jaringan Nirkabel (WiFi Adapter) yang mendukung mode **Access Point (AP) / Monitor Mode**.
* Akses root (`sudo`).

### 📦 Paket yang Dibutuhkan

Instal paket-paket berikut sebelum menjalankan skrip:

=> hostapd
=> isc-dhcp-server
=> dnsmasq
=> lighttpd
=> iptables
=> dos2unix
=> wireless-tools
=> iw
=> net-tools
=> aircrack-ng
=> procps


```bash
# Update sistem terlebih dahulu
sudo apt update

# Install paket-paket utama
sudo apt install -y hostapd isc-dhcp-server dnsmasq lighttpd iptables dos2unix wireless-tools iw net-tools aircrack-ng procps  

# Untuk monitoring jaringan (Opsional)
sudo apt install -y wireless-tools iw rfkill tcpdump netfilter-persistent iptables-persistent
```
