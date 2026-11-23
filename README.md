### Tugas 7

1. Widget tree itu susunan widget yang bentuknya seperti pohon. Semua yang tampil di layar Flutter adalah widget, dan widget bisa berisi widget lain. Widget induk (parent) mengatur tempat dan batas ukuran untuk anaknya (child). Anak lalu menggambar dirinya di dalam batas itu. Contohnya, `Column` adalah induk yang menyusun anak-anaknya dari atas ke bawah. Data juga mengalir dari induk ke anak lewat parameter konstruktor.

2. Widget yang saya pakai:
   - `MaterialApp`: pembungkus utama aplikasi, mengatur tema dan halaman awal.
   - `Scaffold`: kerangka halaman (AppBar, body, dan lainnya).
   - `AppBar`: bar judul di bagian atas.
   - `Padding`: memberi jarak di sekitar widget.
   - `Column` / `Row`: menyusun widget secara vertikal / horizontal.
   - `Center`: menaruh widget di tengah.
   - `SizedBox`: memberi jarak kosong atau ukuran tetap.
   - `Text`: menampilkan tulisan.
   - `Card`: kotak dengan bayangan, dipakai di `InfoCard`.
   - `Container`: kotak untuk mengatur ukuran, padding, atau dekorasi.
   - `GridView.count`: menampilkan tombol dalam bentuk grid.
   - `SingleChildScrollView`: membuat isi halaman bisa di-scroll agar tidak overflow di layar kecil.
   - `IntrinsicHeight`: menyamakan tinggi ketiga `InfoCard` mengikuti kartu yang paling tinggi.
   - `Expanded`: membuat teks di dalam `SnackBar` mengisi sisa ruang di sebelah ikon.
   - `Material`: memberi warna latar dan sudut melengkung pada `ItemCard`.
   - `InkWell`: membuat kartu bisa ditekan dan memberi efek riak (ripple).
   - `Icon`: menampilkan ikon.
   - `SnackBar`: pesan singkat di bawah layar saat tombol ditekan.
   - `InfoCard` dan `ItemCard`: widget buatan sendiri untuk kartu info profil dan tombol aksi.
   

3. `MaterialApp` menyiapkan hal-hal dasar yang dibutuhkan aplikasi bergaya Material Design, seperti tema, warna, navigasi antarhalaman, dan halaman awal (`home`). Widget ini dipakai sebagai root karena banyak widget lain (misalnya `Scaffold`, `AppBar`, dan `SnackBar`) butuh pengaturan dari `MaterialApp` di atasnya supaya bisa berfungsi dengan benar.

4. `StatelessWidget` tampilannya tidak berubah setelah dibuat, karena hanya bergantung pada data yang diberikan dari luar. `StatefulWidget` punya *state* (data internal) yang bisa berubah, dan setiap kali `setState()` dipanggil, tampilannya digambar ulang. Pakai `StatelessWidget` untuk tampilan statis seperti teks, ikon, atau kartu info. Pakai `StatefulWidget` kalau tampilannya harus berubah karena interaksi atau data, misalnya counter, form input, atau checkbox.

5. `BuildContext` adalah "alamat" sebuah widget di dalam widget tree. Lewat context, widget bisa mengakses hal-hal dari widget di atasnya, misalnya tema (`Theme.of(context)`), ukuran layar (`MediaQuery.of(context)`), atau menampilkan SnackBar (`ScaffoldMessenger.of(context).showSnackBar(...)`). Di metode `build(BuildContext context)`, context ini otomatis diberikan oleh Flutter dan dipakai setiap kali kita butuh informasi dari luar widget itu.

6. Hot reload memasukkan perubahan kode ke aplikasi yang sedang berjalan tanpa menghapus state, jadi hasilnya langsung terlihat dalam hitungan detik. Hot restart menjalankan ulang aplikasi dari awal, sehingga semua state kembali ke kondisi awal. Hot reload tidak cukup kalau kita mengubah hal-hal yang hanya dijalankan sekali di awal, misalnya isi `main()`, `initState()`, variabel global atau static, atau mengubah StatelessWidget menjadi StatefulWidget. Untuk perubahan seperti ini perlu hot restart. Kalau mengubah kode native (Android/iOS), menambah package baru, atau mengubah aset tertentu, aplikasi harus dimatikan lalu dijalankan ulang sepenuhnya (full restart).

## AI Disclosure

Dalam mengerjakan tugas ini, saya menggunakan Claude (Anthropic) sebagai alat bantu. Claude saya pakai untuk membuat kerangka kode `main.dart` dan `menu.dart`, yang mencakup InfoCard, ItemCard, model ItemHomepage dengan atribut warna, dan SnackBar. Selain itu, Claude membantu menyusun panduan langkah pengerjaan dan contoh pesan commit. Saya mengirimkan teks soal tugas secara lengkap, lalu meminta panduan pengerjaan step by step. Setelah itu, saya melakukan beberapa penyesuaian seperti mengganti data contoh dengan NPM, nama, dan kelas saya sendiri. Saya juga menjalankan `flutter run` dan `flutter analyze` sendiri untuk memastikan aplikasi berjalan tanpa issue, lalu menyesuaikan daftar widget di jawaban nomor 2 dengan kode yang benar-benar saya pakai.

Chat AI: https://claude.ai/share/2d3c3989-db45-4d62-8b44-cf4b22b39493

### Tugas 8

1. Navigator.push() digunakan untuk membuka halaman baru di atas halaman yang sedang dibuka, sehingga halaman sebelumnya masih tersimpan di stack dan pengguna bisa kembali menggunakan tombol back. Sementara itu, Navigator.pushReplacement() digunakan untuk membuka halaman baru sekaligus menggantikan halaman sebelumnya, sehingga halaman lama tidak bisa dikembalikan menggunakan tombol back. Navigator.pop() kebalikannya, yaitu untuk menutup halaman yang sedang dibuka dan kembali ke halaman sebelumnya. Untuk membuka formulir dari kartu aksi, metode yang digunakan adalah Navigator.push(), karena setelah selesai mengisi formulir, pengguna masih bisa kembali ke halaman utama. Pada drawer, opsi Home menggunakan navigasi ke halaman utama agar pengguna bisa kembali ke halaman tersebut, terutama ketika sedang berada di halaman formulir.

2. Scaffold membantu menyediakan struktur dasar halaman, seperti AppBar, body, dan drawer. AppBar digunakan sebagai bagian atas halaman yang menampilkan judul atau tombol navigasi, sedangkan Drawer menyediakan menu untuk berpindah halaman. Dengan menggunakan struktur yang sama di beberapa halaman, tampilan aplikasi jadi lebih konsisten dan pengguna juga lebih mudah memahami navigasinya. Contohnya, warna AppBar dan warna tombol dapat menggunakan warna tema portofolio yang sama, baik di halaman utama maupun halaman formulir, sehingga keduanya tetap terlihat sebagai bagian dari aplikasi yang sama.

3. Layout formulir dibuat supaya input, label, dan tombol Simpan tersusun rapi serta mudah digunakan. Widget seperti Padding dan SizedBox membantu mengatur jarak antar elemen agar formulir tidak terlalu padat, sedangkan Column digunakan untuk menyusun elemen secara vertikal. Ketika ruang layar terbatas, misalnya saat aplikasi dibuka di layar yang lebih kecil atau keyboard muncul, SingleChildScrollView memungkinkan pengguna untuk menggulir halaman sehingga seluruh input dan tombol tetap bisa diakses tanpa terpotong.

4. GlobalKey<FormState> digunakan untuk mengakses dan mengelola state dari form, termasuk menjalankan validasi seluruh input yang ada di dalamnya. Setiap input memiliki validator yang berisi aturan untuk menentukan apakah nilai yang dimasukkan sudah sesuai atau belum. Ketika tombol Simpan ditekan, validate() akan memeriksa semua input. Jika ada input yang tidak valid, pesan kesalahan akan ditampilkan pada kolom terkait dan data tidak akan disimpan atau ditampilkan dalam dialog. Contohnya, input nama institusi yang hanya berisi spasi akan ditolak karena dianggap kosong. Meskipun jenis input atau keyboard sudah disesuaikan, hal tersebut belum tentu menjamin data yang dimasukkan benar, karena pengguna masih bisa memasukkan nilai yang tidak sesuai. Oleh karena itu, validasi tetap diperlukan untuk memastikan setiap input memenuhi aturan yang ditentukan.

## AI Disclosure

Dalam mengerjakan tugas ini, saya menggunakan Claude sebagai alat bantu. Claude saya gunakan untuk memahami instruksi tugas dan menyusun panduan pengerjaan step by step, mulai dari membuat halaman formulir edukasi, menambahkan navigasi melalui drawer dan kartu aksi, hingga mengimplementasikan validasi input dan dialog ringkasan. Saya mengirimkan instruksi tugas secara lengkap, lalu meminta Claude untuk merangkum tugas dan memberikan langkah pengerjaan beserta contoh kode yang bisa digunakan. Claude juga membantu menyusun jawaban reflektif berdasarkan konsep yang digunakan dalam implementasi, seperti navigasi menggunakan Navigator, struktur widget Flutter, layout formulir, dan validasi input. Saya menggunakan panduan tersebut sebagai acuan dalam mengerjakan tugas, menyesuaikan kode dengan struktur proyek saya, serta melakukan pengujian dan pengecekan ulang terhadap implementasi yang dibuat.

Chat AI: https://claude.ai/share/2d3c3989-db45-4d62-8b44-cf4b22b39493