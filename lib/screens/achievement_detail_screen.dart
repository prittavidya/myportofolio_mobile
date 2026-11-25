import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/achievement.dart';

class AchievementDetailScreen extends StatelessWidget {
  const AchievementDetailScreen({required this.achievement, super.key});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Achievement Detail',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    achievement.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.apartment,
              label: 'Penyelenggara',
              value: achievement.issuer,
            ),
            _DetailRow(
              icon: Icons.calendar_today,
              label: 'Tahun',
              value: '${achievement.year}',
            ),
            _DetailRow(
              icon: Icons.star,
              label: 'Jumlah star',
              value: '${achievement.starCount}',
            ),
            const Divider(height: 32),
            Text('Deskripsi', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              achievement.description.isEmpty
                  ? 'Tidak ada deskripsi.'
                  : achievement.description,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
