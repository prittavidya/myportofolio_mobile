import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';
import 'package:myportofolio_mobile/widgets/info_card.dart';
import 'package:myportofolio_mobile/widgets/item_card.dart';

/// Halaman utama aplikasi MyPortfolio.
///
/// Menampilkan tiga [InfoCard] berisi identitas pemilik portofolio dan
/// sebuah grid berisi [ItemCard] untuk setiap aksi portofolio.
/// Widget ini stateless karena seluruh datanya konstan.
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  final String npm = "2506539265";
  final String nama = "Joanna Prittavidya Putri Arianto";
  final String kelas = "PBP A";

  /// Daftar tombol aksi. Warna tiap tombol didefinisikan langsung di model
  /// sehingga [ItemCard] tidak perlu logika pewarnaan sendiri.
  final List<ItemHomepage> items = const [
    ItemHomepage("Lihat Proyek", Icons.folder, Colors.blue),
    ItemHomepage("Tambah Proyek", Icons.add_circle, Colors.green),
    ItemHomepage("Logout", Icons.logout, Colors.red),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      // SingleChildScrollView mencegah overflow pada layar kecil
      // atau saat orientasi landscape.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Baris kartu identitas pemilik portofolio. IntrinsicHeight +
            // stretch membuat ketiga kartu setinggi kartu tertinggi
            // (kartu Name bisa lebih tinggi karena nama yang panjang).
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InfoCard(title: 'NPM', content: npm),
                  InfoCard(title: 'Name', content: nama),
                  InfoCard(title: 'Class', content: kelas),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Selamat datang di MyPortfolio Mobile!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  // Grid tombol aksi, tiga kolom per baris. Scroll grid
                  // dimatikan karena sudah ditangani SingleChildScrollView.
                  GridView.count(
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    children: items.map((item) => ItemCard(item)).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
