import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

Finder _field(String label) => find.widgetWithText(TextFormField, label);

Future<void> _pumpForm(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));
}

Future<void> _tapSave(WidgetTester tester) async {
  final saveButton = find.widgetWithText(ElevatedButton, 'Simpan');
  await tester.ensureVisible(saveButton);
  await tester.tap(saveButton);
  await tester.pumpAndSettle();
}

// Memilih tanggal hari ini (initialDate date picker) sebagai tanggal mulai.
Future<void> _pickTodayAsStartDate(WidgetTester tester) async {
  await tester.tap(_field('Tanggal Mulai'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Future<void> _openDrawerAndTap(WidgetTester tester, String menu) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(menu));
  await tester.pumpAndSettle();
}

void main() {
  group('Navigasi ke ExperienceFormPage', () {
    testWidgets(
      'Kartu Tambah Pengalaman membuka form dan Back kembali ke menu',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());

        await tester.ensureVisible(find.text('Tambah Pengalaman'));
        await tester.tap(find.text('Tambah Pengalaman'));
        await tester.pumpAndSettle();

        expect(find.byType(ExperienceFormPage), findsOneWidget);

        // Navigator.push menyisakan halaman utama di bawah form, jadi tombol
        // Back bawaan perangkat (disimulasikan di sini) kembali ke menu.
        // AppBar form menampilkan ikon drawer, bukan panah back.
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(find.byType(ExperienceFormPage), findsNothing);
        expect(find.byType(MyHomePage), findsOneWidget);
      },
    );

    testWidgets(
      'Drawer membuka form, lalu opsi Home kembali ke halaman utama',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());

        await _openDrawerAndTap(tester, 'Add Experience');
        expect(find.byType(ExperienceFormPage), findsOneWidget);

        await _openDrawerAndTap(tester, 'Home');
        expect(find.byType(ExperienceFormPage), findsNothing);
        expect(find.byType(MyHomePage), findsOneWidget);
      },
    );
  });

  group('Validasi ExperienceFormPage', () {
    testWidgets(
      'Form kosong menampilkan pesan error dan tidak membuka dialog',
      (WidgetTester tester) async {
        await _pumpForm(tester);
        await _tapSave(tester);

        expect(
          find.text('Judul pengalaman tidak boleh kosong!'),
          findsOneWidget,
        );
        expect(find.text('Deskripsi tidak boleh kosong!'), findsOneWidget);
        expect(find.text('Tanggal mulai wajib dipilih!'), findsOneWidget);
        expect(
          find.text('Pilih tanggal selesai atau centang "Masih berlangsung"!'),
          findsOneWidget,
        );
        expect(find.byType(AlertDialog), findsNothing);
      },
    );

    testWidgets('Isian yang hanya berisi spasi ditolak', (
      WidgetTester tester,
    ) async {
      await _pumpForm(tester);

      await tester.enterText(_field('Judul Pengalaman'), '   ');
      await tester.enterText(_field('Deskripsi'), '   ');
      await _tapSave(tester);

      expect(find.text('Judul pengalaman tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Deskripsi tidak boleh kosong!'), findsOneWidget);
    });

    testWidgets('URL thumbnail yang tidak valid ditolak', (
      WidgetTester tester,
    ) async {
      await _pumpForm(tester);

      await tester.enterText(_field('URL Thumbnail (opsional)'), 'bukan-url');
      await _tapSave(tester);

      expect(
        find.text('Masukkan URL yang valid (diawali http:// atau https://)!'),
        findsOneWidget,
      );
    });

    testWidgets('Tanggal selesai sebelum tanggal mulai ditolak', (
      WidgetTester tester,
    ) async {
      await _pumpForm(tester);

      await _pickTodayAsStartDate(tester);

      // Pilih tanggal 15 bulan lalu sebagai tanggal selesai.
      await tester.tap(_field('Tanggal Selesai'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await _tapSave(tester);

      expect(
        find.text('Tanggal selesai tidak boleh sebelum tanggal mulai!'),
        findsOneWidget,
      );
    });
  });

  group('Dialog ringkasan ExperienceFormPage', () {
    testWidgets(
      'Input valid menampilkan ringkasan, OK menutup dan mereset form',
      (WidgetTester tester) async {
        await _pumpForm(tester);

        await tester.enterText(
          _field('Judul Pengalaman'),
          'Software Engineer Intern',
        );
        await tester.enterText(
          _field('Deskripsi'),
          'Membangun aplikasi mobile.',
        );
        await tester.enterText(
          _field('URL Thumbnail (opsional)'),
          'https://example.com/logo.png',
        );
        await _pickTodayAsStartDate(tester);
        await tester.tap(find.text('Masih berlangsung'));
        await tester.pump();

        await _tapSave(tester);

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Pengalaman berhasil ditambahkan!'), findsOneWidget);
        for (final value in [
          'Software Engineer Intern',
          'Membangun aplikasi mobile.',
          'Full-Time',
          'https://example.com/logo.png',
          'Masih berlangsung',
        ]) {
          expect(
            find.descendant(
              of: find.byType(AlertDialog),
              matching: find.textContaining(value, findRichText: true),
            ),
            findsOneWidget,
          );
        }

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Dialog tertutup, pengguna kembali ke form yang sudah dikosongkan.
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.byType(ExperienceFormPage), findsOneWidget);
        expect(find.text('Software Engineer Intern'), findsNothing);
      },
    );
  });
}
