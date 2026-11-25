import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/models/achievement.dart';

void main() {
  test('fromJson membaca respons DRF dengan kunci snake_case', () {
    final achievement = Achievement.fromJson({
      'id': '3f9c1a52-0000-4000-8000-000000000001',
      'name': 'Juara 1 Hackathon',
      'issuer': 'Fasilkom UI',
      'year': 2026,
      'description': 'Kompetisi tingkat fakultas.',
      'star_count': 3,
      'is_starred': true,
    });

    expect(achievement.id, '3f9c1a52-0000-4000-8000-000000000001');
    expect(achievement.name, 'Juara 1 Hackathon');
    expect(achievement.issuer, 'Fasilkom UI');
    expect(achievement.year, 2026);
    expect(achievement.description, 'Kompetisi tingkat fakultas.');
    expect(achievement.starCount, 3);
    expect(achievement.isStarred, isTrue);
  });

  test('fromJson memakai nilai default untuk field yang null atau hilang', () {
    final achievement = Achievement.fromJson({
      'name': "Dean's List",
      'issuer': 'Universitas Indonesia',
      'year': 2025,
      'description': null,
    });

    expect(achievement.id, isNull);
    expect(achievement.description, '');
    expect(achievement.starCount, 0);
    expect(achievement.isStarred, isFalse);
  });

  test('toJson hanya mengirim field yang boleh ditulis', () {
    const achievement = Achievement(
      id: 'tidak-boleh-dikirim',
      name: "Dean's List",
      issuer: 'Universitas Indonesia',
      year: 2025,
      starCount: 10,
      isStarred: true,
    );

    expect(achievement.toJson(), {
      'name': "Dean's List",
      'issuer': 'Universitas Indonesia',
      'year': 2025,
      'description': '',
    });
  });
}
