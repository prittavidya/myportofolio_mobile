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