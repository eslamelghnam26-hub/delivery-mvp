import 'dart:io';

class AppConfig {
  static const _defined = String.fromEnvironment('API_BASE');

  static String get apiBase {
    if (_defined.isNotEmpty) return _defined;
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://localhost:8000/api';
  }
}