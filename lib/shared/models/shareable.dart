import '../internal/extension.dart';

class ShareTextBuilder {
  ShareTextBuilder();

  final StringBuffer _buffer = StringBuffer();

  void writeField(String label, String? value) {
    if (value.isNotBlank) {
      _buffer
        ..write(label)
        ..write(value)
        ..write('\n');
    }
  }

  void writeFieldIf(
    String label,
    String? value,
    bool Function(String) condition,
  ) {
    if (value != null && value.isNotBlank && condition(value)) {
      writeField(label, value);
    }
  }

  void writeBangumiUrl(String? id, String bangumiUrl) {
    if (id != null && id.isNotBlank) {
      _buffer
        ..write('番组地址：')
        ..write(bangumiUrl)
        ..write('/')
        ..write(id)
        ..write('\n');
    }
  }

  void writeKeyValue(Map<String, String> map) {
    if (map.isNotEmpty) {
      map.forEach((key, value) {
        _buffer
          ..write(key)
          ..write('：')
          ..write(value)
          ..write('\n');
      });
    }
  }

  void writeSubgroups(
    List<dynamic> subgroups,
    String separator,
  ) {
    if (subgroups.isNotEmpty) {
      _buffer
        ..write('字幕组：')
        ..write(subgroups.map((e) => e.name.toString()).join(separator))
        ..write('\n');
    }
  }

  void writeTags(List<String> tags, {String separator = '，'}) {
    if (tags.isNotEmpty) {
      _buffer
        ..write('标签：')
        ..write(tags.join(separator))
        ..write('\n');
    }
  }

  String build() => _buffer.toString();
}
