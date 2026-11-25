import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/achievement_form.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';

import 'test_helpers.dart';

// Backend palsu yang meniru endpoint Django: login, logout, dan achievements.
class _FakeBackend {
  _FakeBackend({this.createStatus = 201});

  final int createStatus;
  final requests = <http.Request>[];

  Future<http.Response> handle(http.Request request) async {
    requests.add(request);
    final path = request.url.path;

    if (path == '/api/v1/auth/token/') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      if (body['username'] == 'joanna' && body['password'] == 'benar') {
        return http.Response(jsonEncode({'token': 'token-joanna'}), 200);
      }
      return http.Response(
        jsonEncode({
          'non_field_errors': ['Unable to log in with provided credentials.'],
        }),
        400,
      );
    }
    if (path == '/api/v1/auth/logout/') {
      return http.Response('', 204);
    }
    if (path == '/api/v1/achievements/' && request.method == 'POST') {
      if (createStatus != 201) return http.Response('{}', createStatus);
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({
          ...body,
          'id': '3f9c1a52-0000-4000-8000-000000000001',
          'star_count': 0,
          'is_starred': false,
        }),
        201,
      );
    }
    return http.Response('[]', 200);
  }

  Iterable<http.Request> to(String path) =>
      requests.where((r) => r.url.path == path);
}

Finder _field(String label) => find.widgetWithText(TextFormField, label);

Future<void> _login(WidgetTester tester, {String password = 'benar'}) async {
  await tester.enterText(_field('Username'), 'joanna');
  await tester.enterText(_field('Password'), password);
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();
}

// Logout tidak memicu animasi selama menunggu balasan server, sehingga
// pumpAndSettle bisa selesai lebih dulu. pump() memberi waktu agar future
// request selesai sebelum UI diperiksa.
Future<void> _settleAfterRequest(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

Future<void> _openDrawer(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
}

Future<void> _openFormLoggedIn(WidgetTester tester) async {
  await tester.tap(find.text('Tambah Achievement'));
  await tester.pumpAndSettle();
  await _login(tester);
}

Future<void> _fillForm(WidgetTester tester) async {
  await tester.enterText(_field('Nama Achievement'), 'Juara 1 Hackathon');
  await tester.enterText(_field('Penyelenggara'), 'Fasilkom UI');
  await tester.enterText(_field('Tahun'), '2026');
}

Future<void> _tapSave(WidgetTester tester) async {
  final save = find.widgetWithText(ElevatedButton, 'Save');
  await tester.ensureVisible(save);
  await tester.tap(save);
  await tester.pumpAndSettle();
}

void main() {
  group('Login', () {
    testWidgets('Field kosong ditolak validator', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.tap(find.text('Tambah Achievement'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.text('Username cannot be empty!'), findsOneWidget);
      expect(find.text('Password cannot be empty!'), findsOneWidget);
    });

    testWidgets('Password salah menampilkan SnackBar dan tetap di login', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp(_FakeBackend().handle));
      await tester.tap(find.text('Tambah Achievement'));
      await tester.pumpAndSettle();

      await _login(tester, password: 'salah');

      expect(find.text('Username atau password salah.'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Login berhasil lalu langsung membuka form', (tester) async {
      await tester.pumpWidget(buildTestApp(_FakeBackend().handle));

      await _openFormLoggedIn(tester);

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(AchievementFormPage), findsOneWidget);
    });

    testWidgets('Setelah login, form dibuka tanpa diminta login lagi', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp(_FakeBackend().handle));
      await _openFormLoggedIn(tester);

      // Kembali ke menu dengan tombol Back perangkat (AppBar form
      // menampilkan ikon drawer, bukan panah back).
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tambah Achievement'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(AchievementFormPage), findsOneWidget);
    });
  });

  group('Drawer', () {
    testWidgets('Opsi Login berganti menjadi Logout setelah login', (
      tester,
    ) async {
      final backend = _FakeBackend();
      await tester.pumpWidget(buildTestApp(backend.handle));

      await _openDrawer(tester);
      // Kartu Logout di halaman utama tetap ada, jadi cek ListTile drawer.
      expect(find.widgetWithText(ListTile, 'Login'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Logout'), findsNothing);

      await tester.tap(find.widgetWithText(ListTile, 'Login'));
      await tester.pumpAndSettle();
      await _login(tester);

      expect(find.text('Login berhasil.'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Logout'), findsOneWidget);

      await tester.tap(find.widgetWithText(ListTile, 'Logout'));
      await _settleAfterRequest(tester);

      expect(find.text('Berhasil logout.'), findsOneWidget);
      expect(
        backend.to('/api/v1/auth/logout/').single.headers['Authorization'],
        'Token token-joanna',
      );
    });

    testWidgets('Add Achievement di drawer dilindungi login', (tester) async {
      await tester.pumpWidget(buildTestApp(_FakeBackend().handle));
      await _openDrawer(tester);

      await tester.tap(find.text('Add Achievement'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);

      await _login(tester);
      expect(find.byType(AchievementFormPage), findsOneWidget);
    });
  });

  group('Kartu Logout', () {
    testWidgets('Mencabut token saat sudah login', (tester) async {
      final backend = _FakeBackend();
      await tester.pumpWidget(buildTestApp(backend.handle));
      await _openFormLoggedIn(tester);
      // Kembali ke menu dengan tombol Back perangkat (AppBar form
      // menampilkan ikon drawer, bukan panah back).
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Logout'));
      await tester.tap(find.text('Logout'));
      await _settleAfterRequest(tester);

      expect(backend.to('/api/v1/auth/logout/'), hasLength(1));
      expect(find.text('Berhasil logout.'), findsOneWidget);

      // Setelah logout, menambah achievement kembali meminta login.
      await tester.tap(find.text('Tambah Achievement'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  group('Form Tambah Achievement', () {
    testWidgets('Input tidak valid ditolak dan tidak dikirim ke server', (
      tester,
    ) async {
      final backend = _FakeBackend();
      await tester.pumpWidget(buildTestApp(backend.handle));
      await _openFormLoggedIn(tester);

      await tester.enterText(_field('Nama Achievement'), '   ');
      await tester.enterText(_field('Tahun'), '1800');
      await _tapSave(tester);

      expect(find.text('Nama achievement tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Penyelenggara tidak boleh kosong!'), findsOneWidget);
      expect(
        find.text('Tahun harus antara 1900 dan ${DateTime.now().year}!'),
        findsOneWidget,
      );
      expect(backend.to('/api/v1/achievements/'), isEmpty);
    });

    testWidgets('Input valid dikirim dengan token dan menampilkan dialog', (
      tester,
    ) async {
      final backend = _FakeBackend();
      await tester.pumpWidget(buildTestApp(backend.handle));
      await _openFormLoggedIn(tester);

      await _fillForm(tester);
      await _tapSave(tester);

      final post = backend.to('/api/v1/achievements/').single;
      expect(post.method, 'POST');
      expect(post.headers['Authorization'], 'Token token-joanna');
      expect(jsonDecode(post.body), {
        'name': 'Juara 1 Hackathon',
        'issuer': 'Fasilkom UI',
        'year': 2026,
        'description': '',
      });
      expect(find.text('Achievement berhasil ditambahkan!'), findsOneWidget);
      expect(find.text('Nama: Juara 1 Hackathon'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Respons 403 menampilkan pesan hak akses', (tester) async {
      await tester.pumpWidget(
        buildTestApp(_FakeBackend(createStatus: 403).handle),
      );
      await _openFormLoggedIn(tester);

      await _fillForm(tester);
      await _tapSave(tester);

      expect(
        find.text(
          'Hanya pemilik portofolio (superuser) yang bisa menambah achievement.',
        ),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Respons 401 menghapus sesi dan meminta login ulang', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(_FakeBackend(createStatus: 401).handle),
      );
      await _openFormLoggedIn(tester);

      await _fillForm(tester);
      await _tapSave(tester);

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
