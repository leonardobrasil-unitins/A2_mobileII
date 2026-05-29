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
      throw AppException(_extractErrorMessage(response));
    }

    if (response.body.isEmpty) {
      return null;
    }

    return jsonDecode(response.body);
  }

  String _extractErrorMessage(http.Response response) {
    if (response.body.isNotEmpty) {
      try {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          final message = data['message'];

          if (message is String && message.trim().isNotEmpty) {
            return message;
          }
        }
      } catch (_) {
        // Fallback para a mensagem padrao abaixo.
      }
    }

    return 'A API respondeu com erro (${response.statusCode}).';
  }

  Map<String, String> get _headers => const {
        'Content-Type': 'application/json; charset=UTF-8',
      };
}
