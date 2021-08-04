// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fonts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Font _$FontFromJson(Map<String, dynamic> json) {
  return Font(
    id: json['id'] as String,
    name: json['name'] as String,
    files: (json['files'] as List<dynamic>).map((e) => e as String).toList(),
    desc: json['desc'] as String,
    official: json['official'] as String,
    license: License.fromJson(json['license'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$FontToJson(Font instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'files': instance.files,
      'desc': instance.desc,
      'official': instance.official,
      'license': instance.license,
    };

License _$LicenseFromJson(Map<String, dynamic> json) {
  return License(
    name: json['name'] as String,
    url: json['url'] as String,
  );
}

Map<String, dynamic> _$LicenseToJson(License instance) => <String, dynamic>{
      'url': instance.url,
      'name': instance.name,
    };
