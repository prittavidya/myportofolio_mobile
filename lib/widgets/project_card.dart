import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';
import 'package:myportofolio_mobile/screens/achievement_list_screen.dart';
import 'package:myportofolio_mobile/screens/achievement_form.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  void _showSnackBar(ScaffoldMessengerState messenger, {String? detail}) {
    // Sembunyikan SnackBar sebelumnya agar pesan tidak menumpuk
    // ketika tombol ditekan berkali-kali.
    messenger
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Kamu telah menekan tombol ${item.name}!",
                      style: const TextStyle(color: Colors.white),
                    ),
                    if (detail != null)
                      Text(
                        detail,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        // Samakan bentuk efek ripple dengan sudut kartu.
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final messenger = ScaffoldMessenger.of(context);

          // Logout menampilkan satu SnackBar berisi hasilnya sekaligus.
          // Menampilkan SnackBar kedua setelah request selesai tidak andal:
          // jika server membalas sangat cepat, SnackBar pertama belum sempat
          // beranimasi sehingga tidak bisa disembunyikan dan yang kedua
          // tertahan di antrean.
          if (item.name == "Logout") {
            final authState = context.read<AuthState>();
            final wasLoggedIn = authState.isLoggedIn;
            if (wasLoggedIn) await authState.logout();
            _showSnackBar(
              messenger,
              detail: wasLoggedIn ? 'Berhasil logout.' : 'Kamu belum login.',
            );
            return;
          }

          _showSnackBar(messenger);

          // Menambah achievement butuh token, jadi minta login terlebih dulu.
          if (item.name == "Tambah Achievement") {
            final loggedIn = await ensureLoggedIn(context);
            if (!loggedIn || !context.mounted) return;
          }

          // Navigate ke halaman yang sesuai. Navigator.push menaruh halaman
          // form di atas halaman utama, jadi tombol Back bisa kembali ke menu.
          final Widget? destination = switch (item.name) {
            "Lihat Achievement" => const AchievementListScreen(),
            "Tambah Achievement" => const AchievementFormPage(),
            "Tambah Pengalaman" => const ExperienceFormPage(),
            _ => null,
          };
          if (destination != null && context.mounted) {
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
