import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/achievement.dart';

// Dilempar ketika API mengembalikan status selain 2xx.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  // Pesan yang aman ditampilkan ke pengguna. response.body mentah tidak
  // ditampilkan karena bisa berisi halaman error HTML Django (DEBUG=True).
  String get friendlyMessage => switch (statusCode) {
    400 => 'Data yang dikirim tidak valid.',
    401 => 'Sesi berakhir, silakan login kembali.',
    403 => 'Kamu tidak berhak melakukan aksi ini.',
    404 => 'Data tidak ditemukan.',
    >= 500 => 'Terjadi kesalahan pada server.',
    _ => 'Permintaan gagal (status $statusCode).',
  };

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// Klien HTTP untuk backend Django REST Framework MyPortfolio.
//
// Header ditulis sebagai string biasa (bukan HttpHeaders dari dart:io)
// agar tetap bisa di-build untuk Flutter Web.
class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = apiBaseUrl})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _jsonHeaders({String? token}) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
    if (token != null) 'Authorization': 'Token $token',
  };

  Future<List<Achievement>> getAchievements() async {
    final response = await _client.get(
      _uri('/api/v1/achievements/'),
      headers: const {'Accept': 'application/json'},
    );
    _ensureSuccess(response);

    // utf8.decode agar karakter non-ASCII (mis. nama dengan aksen) terbaca
    // benar walaupun server tidak menyertakan charset di Content-Type.
    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return decoded
        .map((item) => Achievement.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Achievement> createAchievement(
    Achievement achievement, {
    required String token,
  }) async {
    final response = await _client.post(
      _uri('/api/v1/achievements/'),
      headers: _jsonHeaders(token: token),
      body: jsonEncode(achievement.toJson()),
    );
    _ensureSuccess(response);

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return Achievement.fromJson(decoded);
  }

  Future<String> obtainToken(String username, String password) async {
    final response = await _client.post(
      _uri('/api/v1/auth/token/'),
      headers: _jsonHeaders(),
      body: jsonEncode({'username': username, 'password': password}),
    );
    _ensureSuccess(response);

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return decoded['token'] as String;
  }

  Future<void> logout({required String token}) async {
    final response = await _client.post(
      _uri('/api/v1/auth/logout/'),
      headers: _jsonHeaders(token: token),
    );
    _ensureSuccess(response);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw ApiException(response.statusCode, response.body);
  }
}
