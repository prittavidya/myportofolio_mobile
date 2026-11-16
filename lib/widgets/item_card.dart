import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        // Samakan bentuk efek ripple dengan sudut kartu.
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Sembunyikan SnackBar sebelumnya agar pesan tidak menumpuk
          // ketika tombol ditekan berkali-kali.
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                // Warna SnackBar mengikuti warna tombol agar umpan balik
                // terasa terhubung dengan tombol yang ditekan.
                backgroundColor: item.color,
                behavior: SnackBarBehavior.floating,
                content: Row(
                  children: [
                    Icon(item.icon, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Kamu telah menekan tombol ${item.name}!",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  color: Colors.white,
                  size: 30.0,
                ),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
