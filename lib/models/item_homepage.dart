import 'package:flutter/material.dart';

/// Model data untuk satu tombol aksi di halaman utama.
///
/// Setiap item menyimpan [name] sebagai label tombol, [icon] sebagai ikon,
/// dan [color] sebagai warna latar kartu. Dengan menyimpan warna di model,
/// [ItemCard] cukup membaca `item.color` tanpa perlu percabangan if-else.
class ItemHomepage {
  /// Label tombol, juga dipakai di pesan SnackBar.
  final String name;

  /// Ikon yang ditampilkan di atas label.
  final IconData icon;

  /// Warna latar kartu tombol.
  final Color color;

  const ItemHomepage(this.name, this.icon, this.color);
}
