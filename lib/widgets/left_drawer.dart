import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/achievement_form.dart';
import 'package:myportofolio_mobile/screens/achievement_list_screen.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // watch: drawer di-rebuild setiap kali status login berubah, sehingga
    // opsi Login/Logout selalu sesuai.
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;

    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            // Tinggi DrawerHeader tetap, jadi judul diperkecil otomatis dan
            // deskripsi dipotong agar tidak overflow di layar sempit atau
            // saat ukuran font sistem diperbesar.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'My Portfolio',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Flexible(
                  child: Text(
                    'Explore personal projects and experiences!',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            // Navigasi ke halaman utama portofolio
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events_outlined),
            title: const Text('Achievements'),
            // Navigasi ke daftar achievement dari API (publik, tanpa login)
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AchievementListScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Achievement'),
            // Halaman tambah achievement dilindungi: wajib login dulu.
            onTap: () async {
              final loggedIn = await ensureLoggedIn(context);
              if (!loggedIn || !context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AchievementFormPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: const Text('Add Experience'),
            // Navigasi ke halaman tambah pengalaman
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExperienceFormPage(),
                ),
              );
            },
          ),
          const Divider(),
          if (isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                await context.read<AuthState>().logout();
                navigator.pop(); // tutup drawer
                messenger
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(content: Text('Berhasil logout.')),
                  );
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                final loggedIn = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
                if (loggedIn == true) {
                  messenger
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text('Login berhasil.')),
                    );
                }
              },
            ),
        ],
      ),
    );
  }
}
