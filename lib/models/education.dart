import 'package:json_annotation/json_annotation.dart';

part 'education.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Education {
  const Education({
    this.id,
    required this.institution,
    required this.degree,
    required this.startYear,
    this.endYear = 'Present',
    required this.description,
    this.starCount = 0,
    this.isStarred = false,
    this.starredByNames = '',
  });

  factory Education.fromJson(Map<String, dynamic> json) =>
      _$EducationFromJson(json);

  @JsonKey(includeToJson: false)
  final String? id;
  final String institution;
  final String degree;
  final String startYear;
  @JsonKey(defaultValue: 'Present')
  final String endYear;
  final String description;
  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;
  @JsonKey(includeToJson: false, defaultValue: false)
  final bool isStarred;
  @JsonKey(includeToJson: false)
  final String starredByNames;

  String get displayEndYear => endYear == 'Present' ? 'Sekarang' : endYear;

  Map<String, dynamic> toJson() => _$EducationToJson(this);
}
