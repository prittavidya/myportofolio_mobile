import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/widgets/info_card.dart';
import 'package:myportofolio_mobile/widgets/item_card.dart';

void main() {
  testWidgets('Halaman utama menampilkan identitas pemilik portofolio',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(InfoCard), findsNWidgets(3));
    expect(find.text('2506539265'), findsOneWidget);
    expect(find.text('Joanna Prittavidya Putri Arianto'), findsOneWidget);
    expect(find.text('PBP A'), findsOneWidget);
  });

  testWidgets('Setiap tombol aksi memiliki warna latar yang berbeda',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(ItemCard), findsNWidgets(3));

    final colors = tester
        .widgetList<ItemCard>(find.byType(ItemCard))
        .map((card) => card.item.color)
        .toSet();
    expect(colors.length, 3);
  });

  for (final name in ['Lihat Proyek', 'Tambah Proyek', 'Logout']) {
    testWidgets('Menekan tombol $name memunculkan SnackBar yang sesuai',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.text(name));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Kamu telah menekan tombol $name!'), findsOneWidget);
    });
  }
}
