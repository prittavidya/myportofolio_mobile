import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

// ApiClient palsu untuk test: setiap request dijawab oleh [handler] tanpa
// menghubungi server sungguhan. Default-nya mengembalikan daftar kosong.
ApiClient fakeApiClient([MockClientHandler? handler]) {
  return ApiClient(
    baseUrl: 'http://test.local',
    client: MockClient(handler ?? (_) async => http.Response('[]', 200)),
  );
}

MyApp buildTestApp([MockClientHandler? handler]) =>
    MyApp(apiClient: fakeApiClient(handler));
