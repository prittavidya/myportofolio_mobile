import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/models/achievement.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

import 'test_helpers.dart';

const _achievementJson = {
  'id': '3f9c1a52-0000-4000-8000-000000000001',
  'name': 'Juara 1 Hackathon',
  'issuer': 'Fasilkom UI',
  'year': 2026,
  'description': '',
  'star_count': 0,
  'is_starred': false,
};

void main() {
  group('ApiClient', () {
    test(
      'getAchievements mengambil dan mem-parsing daftar achievement',
      () async {
        late http.Request sent;
        final api = fakeApiClient((request) async {
          sent = request;
          return http.Response(jsonEncode([_achievementJson]), 200);
        });

        final achievements = await api.getAchievements();

        expect(sent.method, 'GET');
        expect(sent.url.toString(), 'http://test.local/api/v1/achievements/');
        expect(sent.headers.containsKey('Authorization'), isFalse);
        expect(achievements.single.name, 'Juara 1 Hackathon');
      },
    );

    test('createAchievement mengirim token dan body JSON', () async {
      late http.Request sent;
      final api = fakeApiClient((request) async {
        sent = request;
        return http.Response(jsonEncode(_achievementJson), 201);
      });

      final created = await api.createAchievement(
        const Achievement(
          name: 'Juara 1 Hackathon',
          issuer: 'Fasilkom UI',
          year: 2026,
        ),
        token: 'abc123',
      );

      expect(sent.method, 'POST');
      expect(sent.url.path, '/api/v1/achievements/');
      expect(sent.headers['Authorization'], 'Token abc123');
      expect(sent.headers['Content-Type'], startsWith('application/json'));
      expect(jsonDecode(sent.body), {
        'name': 'Juara 1 Hackathon',
        'issuer': 'Fasilkom UI',
        'year': 2026,
        'description': '',
      });
      expect(created.id, _achievementJson['id']);
    });

    test('obtainToken mengembalikan token dari respons', () async {
      late http.Request sent;
      final api = fakeApiClient((request) async {
        sent = request;
        return http.Response(jsonEncode({'token': 'abc123'}), 200);
      });

      final token = await api.obtainToken('joanna', 'rahasia');

      expect(sent.url.path, '/api/v1/auth/token/');
      expect(jsonDecode(sent.body), {
        'username': 'joanna',
        'password': 'rahasia',
      });
      expect(token, 'abc123');
    });

    test('logout mengirim token ke endpoint logout', () async {
      late http.Request sent;
      final api = fakeApiClient((request) async {
        sent = request;
        return http.Response('', 204);
      });

      await api.logout(token: 'abc123');

      expect(sent.method, 'POST');
      expect(sent.url.path, '/api/v1/auth/logout/');
      expect(sent.headers['Authorization'], 'Token abc123');
    });

    test('status non-2xx dilempar sebagai ApiException', () async {
      final api = fakeApiClient(
        (_) async => http.Response('{"detail": "Invalid token."}', 401),
      );

      expect(
        api.createAchievement(
          const Achievement(name: 'A', issuer: 'B', year: 2026),
          token: 'salah',
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401)
              .having(
                (e) => e.friendlyMessage,
                'friendlyMessage',
                'Sesi berakhir, silakan login kembali.',
              ),
        ),
      );
    });
  });

  group('AuthState', () {
    test('login menyimpan token dan memberi tahu listener', () async {
      final auth = AuthState(
        fakeApiClient(
          (_) async => http.Response(jsonEncode({'token': 'abc123'}), 200),
        ),
      );
      var notified = 0;
      auth.addListener(() => notified++);

      await auth.login('joanna', 'rahasia');

      expect(auth.isLoggedIn, isTrue);
      expect(auth.token, 'abc123');
      expect(notified, 1);
    });

    test('login gagal tidak mengubah state', () async {
      final auth = AuthState(
        fakeApiClient(
          (_) async => http.Response('{"non_field_errors": []}', 400),
        ),
      );

      await expectLater(
        auth.login('joanna', 'salah'),
        throwsA(isA<ApiException>()),
      );
      expect(auth.isLoggedIn, isFalse);
    });

    test('logout menghapus token walaupun server menolak', () async {
      final auth = AuthState(
        fakeApiClient((_) async => http.Response('', 401)),
        initialToken: 'kedaluwarsa',
      );
      var notified = 0;
      auth.addListener(() => notified++);

      await auth.logout();

      expect(auth.isLoggedIn, isFalse);
      expect(notified, 1);
    });

    test('logout tanpa login tidak memanggil server', () async {
      var calls = 0;
      final auth = AuthState(
        fakeApiClient((_) async {
          calls++;
          return http.Response('', 204);
        }),
      );

      await auth.logout();

      expect(calls, 0);
    });
  });
}
