import 'package:json_annotation/json_annotation.dart';

part 'fonts.g.dart';

@JsonSerializable()
class Font {
  Font({
    required this.id,
    required this.name,
    required this.files,
    required this.desc,
    required this.official,
    required this.license,
  });

  factory Font.fromJson(Map<String, dynamic> json) => _$FontFromJson(json);

  Map<String, dynamic> toJson() => _$FontToJson(this);

  String id;
  String name;
  List<String> files;
  String desc;
  String official;
  License license;
}

@JsonSerializable()
class License {
  License({
    this.url,
    this.name,
  });

  factory License.fromJson(Map<String, dynamic> json) =>
      _$LicenseFromJson(json);

  Map<String, dynamic> toJson() => _$LicenseToJson(this);

  String? url;
  String? name;
}
