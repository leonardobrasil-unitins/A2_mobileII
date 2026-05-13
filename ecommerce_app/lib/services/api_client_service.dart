import 'dart:convert';

import 'package:ecommerce_app/core/config/api_config.dart';
import 'package:ecommerce_app/core/errors/app_exception.dart';
import 'package:http/http.dart' as http;

class ApiClientService {
  ApiClientService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<dynamic>> getList(String path) async {
    final response = await _client.get(_uri(path), headers: _headers);
    final data = _decodeResponse(response);

    if (data is List<dynamic>) {
      return data;
    }

    throw const AppException('Resposta inesperada da API.');
  }

  Future<Map<String, dynamic>> getMap(String path) async {
    final response = await _client.get(_uri(path), headers: _headers);
    final data = _decodeResponse(response);

    if (data is Map<String, dynamic>) {
      return data;
    }

    throw const AppException('Resposta inesperada da API.');
  }

  Future<Map<String, dynamic>> postMap(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final response = await _client.post(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body),
    );

    final data = _decodeResponse(response);

    if (data is Map<String, dynamic>) {
      return data;
    }

    throw const AppException('Resposta inesperada da API.');
  }

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Object? _decodeResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppException(
        'A API respondeu com erro (${response.statusCode}).',
      );
    }

    if (response.body.isEmpty) {
      return null;
    }

    return jsonDecode(response.body);
  }

  Map<String, String> get _headers => const {
        'Content-Type': 'application/json; charset=UTF-8',
      };
}
