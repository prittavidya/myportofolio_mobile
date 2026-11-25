import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/screens/achievement_detail_screen.dart';
import 'package:myportofolio_mobile/screens/achievement_list_screen.dart';

import 'test_helpers.dart';

final _achievements = [
  {
    'id': '3f9c1a52-0000-4000-8000-000000000001',
    'name': 'Juara 1 Hackathon',
    'issuer': 'Fasilkom UI',
    'year': 2026,
    'description': 'Kompetisi tingkat fakultas.',
    'star_count': 2,
    'is_starred': false,
  },
  {
    'id': '3f9c1a52-0000-4000-8000-000000000002',
    'name': "Dean's List",
    'issuer': 'Universitas Indonesia',
    'year': 2025,
    'description': '',
    'star_count': 0,
    'is_starred': false,
  },
];

Future<void> _openListFromHome(WidgetTester tester) async {
  await tester.tap(find.text('Lihat Achievement'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Daftar achievement diambil dari API dan ditampilkan', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp((_) async => http.Response(jsonEncode(_achievements), 200)),
    );
    await _openListFromHome(tester);

    expect(find.byType(AchievementListScreen), findsOneWidget);
    expect(find.text('Juara 1 Hackathon'), findsOneWidget);
    expect(find.text("Dean's List"), findsOneWidget);
  });

  testWidgets('Daftar kosong menampilkan pesan No achievements found.', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await _openListFromHome(tester);

    expect(find.text('No achievements found.'), findsOneWidget);
  });

  testWidgets('Error API menampilkan pesan dan tombol Retry memuat ulang', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      buildTestApp((_) async {
        calls++;
        return calls == 1
            ? http.Response('Server Error', 500)
            : http.Response(jsonEncode(_achievements), 200);
      }),
    );
    await _openListFromHome(tester);

    expect(
      find.textContaining('Terjadi kesalahan pada server.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.text('Juara 1 Hackathon'), findsOneWidget);
  });

  testWidgets('Gagal terhubung ke server menampilkan pesan koneksi', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        (_) async => throw http.ClientException('Connection refused'),
      ),
    );
    await _openListFromHome(tester);

    expect(
      find.textContaining('Tidak dapat terhubung ke server'),
      findsOneWidget,
    );
  });

  testWidgets('Menekan item membuka halaman detail achievement', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp((_) async => http.Response(jsonEncode(_achievements), 200)),
    );
    await _openListFromHome(tester);

    await tester.tap(find.text('Juara 1 Hackathon'));
    await tester.pumpAndSettle();

    expect(find.byType(AchievementDetailScreen), findsOneWidget);
    expect(find.text('Fasilkom UI'), findsOneWidget);
    expect(find.text('2026'), findsOneWidget);
    expect(find.text('Kompetisi tingkat fakultas.'), findsOneWidget);
  });

  testWidgets('Drawer Achievements membuka daftar achievement', (tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Achievements'));
    await tester.pumpAndSettle();

    expect(find.byType(AchievementListScreen), findsOneWidget);
  });
}
