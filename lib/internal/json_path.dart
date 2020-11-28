import 'package:mikan_flutter/internal/logger.dart';

class JsonPath {
  static T parse<T>(Map<String, dynamic> json, String path, T defaultValue) {
    try {
      dynamic current = json;
      final segments = path.split(".");
      int index;
      for (String segment in segments) {
        if (current == null) {
          return defaultValue;
        }
        index = int.tryParse(segment);
        if (index != null && current is List<dynamic>) {
          current = current[index];
        } else if (current is Map<String, dynamic>) {
          current = current[segment];
        }
      }
      return (current as T) ?? defaultValue;
    } catch (e) {
      logd("parse path[$path] error: $e, use default value: $defaultValue");
      return defaultValue;
    }
  }
}
