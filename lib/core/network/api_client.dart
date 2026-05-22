import 'dart:convert';

import 'package:finalyearproject/core/constants/util.dart';
import 'package:finalyearproject/core/network/api_response.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

class ApiClient {
  Future<Map<String, String>> _headers({bool auth = true, bool json = true}) async {
    final headers = <String, String>{};
    if (json) headers['Content-Type'] = 'application/json';
    if (auth) {
      final token = await getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$apiUrl/$normalized').replace(queryParameters: query);
  }

  Future<dynamic> get(
    String path, {
    Map<String, String>? query,
    bool auth = true,
  }) async {
    final res = await http.get(
      _uri(path, query),
      headers: await _headers(auth: auth),
    );
    return _handle(res);
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    bool auth = true,
  }) async {
    final res = await http.post(
      _uri(path),
      headers: await _headers(auth: auth),
      body: body == null ? null : json.encode(body),
    );
    return _handle(res);
  }

  Future<dynamic> put(
    String path, {
    Object? body,
    bool auth = true,
  }) async {
    final res = await http.put(
      _uri(path),
      headers: await _headers(auth: auth),
      body: body == null ? null : json.encode(body),
    );
    return _handle(res);
  }

  Future<dynamic> patch(
    String path, {
    Object? body,
    bool auth = true,
  }) async {
    final res = await http.patch(
      _uri(path),
      headers: await _headers(auth: auth),
      body: body == null ? null : json.encode(body),
    );
    return _handle(res);
  }

  Future<dynamic> delete(String path, {bool auth = true}) async {
    final res = await http.delete(
      _uri(path),
      headers: await _headers(auth: auth),
    );
    return _handle(res);
  }

  Future<dynamic> postMultipart(
    String path, {
    required Map<String, String> fields,
    String? fileField,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    final request = http.MultipartRequest('POST', _uri(path));
    final token = await getAccessToken();
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);
    if (fileField != null && fileBytes != null && fileName != null) {
      request.files.add(
        http.MultipartFile.fromBytes(fileField, fileBytes, filename: fileName),
      );
    }
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return _handle(res);
  }

  Future<dynamic> putMultipart(
    String path, {
    required Map<String, String> fields,
    String? fileField,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    final request = http.MultipartRequest('PUT', _uri(path));
    final token = await getAccessToken();
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);
    if (fileField != null && fileBytes != null && fileName != null) {
      request.files.add(
        http.MultipartFile.fromBytes(fileField, fileBytes, filename: fileName),
      );
    }
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return _handle(res);
  }

  dynamic _handle(http.Response res) {
    dynamic body;
    try {
      body = res.body.isNotEmpty ? json.decode(res.body) : null;
    } catch (_) {
      body = res.body;
    }
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return unwrapApiData(body);
    }
    throw ApiException(
      extractApiMessage(body, 'Request failed (${res.statusCode})'),
      statusCode: res.statusCode,
    );
  }
}
