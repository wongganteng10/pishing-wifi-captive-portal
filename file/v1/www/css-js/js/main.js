function kirim() {
  const username = document.getElementById("kode_login").value;
  const password = document.getElementById("password").value;

  const dataGabung = `USER=${username} PASS=${password}`;

  fetch("tulis.htm", {
    method: "POST",
    body: dataGabung,
  })
    .then((r) => r.text())
    .then((t) => alert(t))
    .catch((e) => alert("Terjadi error: " + e));
}
