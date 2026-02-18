import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../app/api_constants.dart';
import '../utils/logger.dart';
import 'api_exception.dart';
import '../../services/auth_service.dart';
import '../../services/oyungrubu_auth_service.dart';
import '../../services/environment_service.dart';
import '../../models/environment_model.dart';
import '../../views/anaokulu/login/login_view.dart';
import '../../views/oyungrubu/login/oyungrubu_login_view.dart';
import '../services/navigation_service.dart';

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
    Map<String, File>? files,
  }) async {
    try {
      final combinedHeaders = _combineHeaders(headers);
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(combinedHeaders);

      if (body != null) {
        body.forEach((key, value) {
          request.fields[key] = value.toString();
        });
      }

      if (files != null) {
        for (var entry in files.entries) {
          final stream = http.ByteStream(entry.value.openRead());
          final length = await entry.value.length();
          final multipartFile = http.MultipartFile(
            entry.key,
            stream,
            length,
            filename: entry.value.path.split('/').last,
          );
          request.files.add(multipartFile);
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      _logResponse(response);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
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
    var body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      throw ApiException(
        'Sunucu cevabı çözümlenemedi',
        statusCode: response.statusCode,
      );
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        if (body is Map<String, dynamic> && body.containsKey('failure')) {
          final errorMsg = body['failure']?.toString() ?? 'Bir hata oluştu';
          if (errorMsg == 'User Key Hatalı!') {
            _handleAuthError();
          }
          throw ApiException(errorMsg, statusCode: response.statusCode);
        }
        return body;
      case 400:
        throw ApiException(body['message'] ?? 'Hatalı istek', statusCode: 400);
      case 401:
        _handleAuthError();
        throw UnauthorisedException(body['message'] ?? 'Yetkisiz erişim');
      case 422:
        throw ValidationException(body['message'] ?? 'Doğrulama hatası');
      case 500:
        throw ApiException('Sunucu hatası oluştu', statusCode: 500);
      default:
        throw ApiException('Bir hata oluştu', statusCode: response.statusCode);
    }
  }

  void _handleAuthError() {
    final currentEnv = EnvironmentService.currentConfig?.environment;
    if (currentEnv == AppEnvironment.oyunGrubu) {
      OyunGrubuAuthService.logout();
      NavigationService.pushNamedAndRemoveUntil(const OyunGrubuLoginView());
    } else {
      AuthService.logout();
      NavigationService.pushNamedAndRemoveUntil(const LoginView());
    }
  }

  void _logResponse(http.Response response) {
    final request = response.request;
    StringBuffer requestLog = StringBuffer();
    requestLog.writeln('${request?.method} ${request?.url}');
    requestLog.writeln('Headers: ${request?.headers}');

    if (request is http.Request) {
      if (request.body.isNotEmpty) {
        requestLog.writeln('Body: ${request.body}');
      }
    } else if (request is http.MultipartRequest) {
      if (request.fields.isNotEmpty) {
        requestLog.writeln('Fields: ${request.fields}');
      }
      if (request.files.isNotEmpty) {
        requestLog.writeln(
          'Files: ${request.files.map((f) => '${f.field}: ${f.filename}').toList()}',
        );
      }
    }

    AppLogger.request(requestLog.toString());
    AppLogger.response(
      'Status: ${response.statusCode}\nBody: ${response.body}',
    );
  }
}
