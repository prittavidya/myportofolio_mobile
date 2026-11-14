import 'package:flutter/material.dart';

/// Kartu kecil yang menampilkan satu informasi profil pemilik portofolio,
/// misalnya NPM, nama, atau kelas.
class InfoCard extends StatelessWidget {
  /// Judul kartu (contoh: "NPM").
  final String title;

  /// Isi informasi yang ditampilkan di bawah judul.
  final String content;

  const InfoCard({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Container(
        // Lebar kartu menyesuaikan lebar layar agar tiga kartu muat sebaris.
        width: MediaQuery.of(context).size.width / 3.5,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(content),
          ],
        ),
      ),
    );
  }
}
