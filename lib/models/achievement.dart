import 'package:json_annotation/json_annotation.dart';

part 'achievement.g.dart';

// Achievement portofolio yang disinkronkan dengan AchievementSerializer di
// Django REST Framework (/api/v1/achievements/).
//
// FieldRename.snake memetakan field camelCase Dart (starCount) ke kunci
// snake_case dari DRF (star_count).
@JsonSerializable(fieldRename: FieldRename.snake)
class Achievement {
  const Achievement({
    required this.name,
    required this.issuer,
    required this.year,
    this.description = '',
    this.id,
    this.starCount = 0,
    this.isStarred = false,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);

  // UUID dibuat oleh Django, jadi tidak ikut dikirim saat POST.
  @JsonKey(includeToJson: false)
  final String? id;

  final String name;
  final String issuer;
  final int year;

  // Opsional di Django (blank=True), default '' jika kosong atau null.
  @JsonKey(defaultValue: '')
  final String description;

  // Field hasil hitungan server (SerializerMethodField), hanya dibaca.
  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;

  @JsonKey(includeToJson: false, defaultValue: false)
  final bool isStarred;

  Map<String, dynamic> toJson() => _$AchievementToJson(this);
}
