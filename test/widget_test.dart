import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/widgets/info_card.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('Halaman utama menampilkan identitas pemilik portofolio', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    expect(find.byType(InfoCard), findsNWidgets(3));
    expect(find.text('2506539265'), findsOneWidget);
    expect(find.text('Joanna Prittavidya Putri Arianto'), findsOneWidget);
    expect(find.text('PBP A'), findsOneWidget);
  });

  testWidgets('Setiap tombol aksi memiliki warna latar yang berbeda', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    final cards = tester.widgetList<ItemCard>(find.byType(ItemCard)).toList();
    expect(cards.length, 4);

    final colors = cards.map((card) => card.item.color).toSet();
    expect(colors.length, cards.length);
  });

  for (final name in [
    'Lihat Achievement',
    'Tambah Proyek',
    'Tambah Pengalaman',
    'Logout',
  ]) {
    testWidgets('Menekan tombol $name memunculkan SnackBar yang sesuai', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp());

      await tester.ensureVisible(find.text(name));
      await tester.tap(find.text(name));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Kamu telah menekan tombol $name!'), findsOneWidget);
    });
  }

  testWidgets('Tombol Tambah Proyek membuka halaman ProjectFormPage', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(find.text('Add Project Form'), findsOneWidget);
  });
}
