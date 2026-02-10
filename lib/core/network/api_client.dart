import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../app/api_constants.dart';
import '../utils/logger.dart';
import 'api_exception.dart';

class ApiClient {
  final http.Client _client = http.Client();

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    return _request(
      () => _client.get(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: _combineHeaders(headers),
      ),
    );
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _request(
      () => _client.post(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        body: jsonEncode(body),
        headers: _combineHeaders(headers),
      ),
    );
  }

  Map<String, String> _combineHeaders(Map<String, String>? extraHeaders) {
    final headers = ApiConstants.headers;
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  Future<dynamic> _request(Future<http.Response> Function() call) async {
    try {
      final response = await call();
      _logResponse(response);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);

    switch (response.statusCode) {
      case 200:
      case 201:
        return body;
      case 400:
        throw ApiException(body['message'] ?? 'Hatalı istek', statusCode: 400);
      case 401:
        throw UnauthorisedException(body['message'] ?? 'Yetkisiz erişim');
      case 422:
        throw ValidationException(body['message'] ?? 'Doğrulama hatası');
      case 500:
        throw ApiException('Sunucu hatası oluştu', statusCode: 500);
      default:
        throw ApiException('Bir hata oluştu', statusCode: response.statusCode);
    }
  }

  void _logResponse(http.Response response) {
    AppLogger.request('${response.request?.method} ${response.request?.url}');
    AppLogger.response('Status: ${response.statusCode} Body: ${response.body}');
  }
}
