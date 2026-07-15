import 'package:hive_ce/hive.dart';

part 'fonts.g.dart';

@HiveType(typeId: 106)
class Font {
  Font({
    required this.id,
    required this.name,
    required this.files,
    required this.desc,
    required this.official,
    required this.license,
  });

  factory Font.fromJson(Map<String, dynamic> json) => Font(
    id: json['id'] as String,
    name: json['name'] as String,
    files: (json['files'] as List<dynamic>).cast<String>(),
    desc: json['desc'] as String,
    official: json['official'] as String,
    license: License.fromJson(json['license'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'files': files,
    'desc': desc,
    'official': official,
    'license': license.toJson(),
  };

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<String> files;

  @HiveField(3)
  String desc;

  @HiveField(4)
  String official;

  @HiveField(5)
  License license;
}

@HiveType(typeId: 107)
class License {
  License({required this.name, required this.url});

  factory License.fromJson(Map<String, dynamic> json) =>
      License(name: json['name'] as String, url: json['url'] as String);

  Map<String, dynamic> toJson() => {'name': name, 'url': url};

  @HiveField(0)
  String url;

  @HiveField(1)
  String name;
}
