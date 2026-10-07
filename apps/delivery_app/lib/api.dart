import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class ApiException implements Exception {
  final int status;
  final String message;
  const ApiException(this.status, this.message);
  @override
  String toString() => message;
}

class Api {
  late String _base = AppConfig.apiBase;
  String? _token;

  String get base => _base;

  void setBase(String base) => _base = base;

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<dynamic> _send(String method, String path, [Map<String, dynamic>? body]) async {
    final uri = Uri.parse('$_base$path');
    final request = http.Request(method, uri)..headers.addAll(_headers);
    if (body != null) {
      request.body = jsonEncode(body);
    }
    final streamed = await request.send().timeout(const Duration(seconds: 15));
    final raw = await streamed.stream.bytesToString();
    final decoded = raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw) as Map<String, dynamic>;
    if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
      if (decoded['data'] == null) {
        return decoded;
      }
      return decoded['data'];
    }
    throw ApiException(
      streamed.statusCode,
      (decoded['message'] as String?) ?? 'Request failed',
    );
  }

  Future<Map<String, dynamic>> get(String path) async => await _send('GET', path) as Map<String, dynamic>;
  Future<List<dynamic>> getList(String path) async => await _send('GET', path) as List<dynamic>;
  Future<dynamic> post(String path, [Map<String, dynamic>? body]) => _send('POST', path, body);
  Future<dynamic> put(String path, Map<String, dynamic> body) => _send('PUT', path, body);
}