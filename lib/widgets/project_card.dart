import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';
import 'package:myportofolio_mobile/screens/achievement_list_screen.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

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

          // Navigate ke halaman yang sesuai. Navigator.push menaruh halaman
          // form di atas halaman utama, jadi tombol Back bisa kembali ke menu.
          final Widget? destination = switch (item.name) {
            "Lihat Achievement" => const AchievementListScreen(),
            "Tambah Proyek" => const ProjectFormPage(),
            "Tambah Pengalaman" => const ExperienceFormPage(),
            _ => null,
          };
          if (destination != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 30.0),
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
