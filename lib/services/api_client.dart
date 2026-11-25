import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/project.dart';

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;
}

class ApiClient {
  ApiClient({http.Client? client, String baseUrl = apiBaseUrl})
    : _client = client ?? http.Client(),
      _baseUri = Uri.parse(baseUrl);

  static const _timeout = Duration(seconds: 15);
  static const _accept = {'Accept': 'application/json'};
  static const _json = {
    ..._accept,
    'Content-Type': 'application/json; charset=UTF-8',
  };

  final http.Client _client;
  final Uri _baseUri;

  Uri _uri(String path) => _baseUri.resolve('/api/v1/$path');

  Future<List<Project>> getProjects() async {
    final response = await _client
        .get(_uri('projects/'), headers: _accept)
        .timeout(_timeout);
    _ensureSuccess(response);
    final projects = _decode(response) as List<dynamic>;
    return projects
        .map((item) => Project.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Project> createProject(
    Project project, {
    required String token,
  }) async {
    final response = await _client
        .post(
          _uri('projects/'),
          headers: {..._json, 'Authorization': 'Token $token'},
          body: jsonEncode(project.toJson()),
        )
        .timeout(_timeout);
    _ensureSuccess(response);
    return Project.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<String> obtainToken(String username, String password) async {
    final response = await _client
        .post(
          _uri('auth/token/'),
          headers: _json,
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(_timeout);
    _ensureSuccess(response);
    final body = _decode(response) as Map<String, dynamic>;
    final token = body['token'];
    if (token is! String || token.isEmpty) {
      throw const FormatException('Respons login tidak berisi token.');
    }
    return token;
  }

  Future<void> logout({required String token}) async {
    final response = await _client
        .post(
          _uri('auth/logout/'),
          headers: {..._accept, 'Authorization': 'Token $token'},
        )
        .timeout(_timeout);
    _ensureSuccess(response);
  }

  void close() => _client.close();

  Object? _decode(http.Response response) =>
      jsonDecode(utf8.decode(response.bodyBytes));

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, response.body);
    }
  }
}
