class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkException extends ApiException {
  NetworkException([String message = 'Bağlantı hatası oluştu'])
    : super(message);
}

class UnauthorisedException extends ApiException {
  UnauthorisedException([String message = 'Yetkisiz erişim'])
    : super(message, statusCode: 401);
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message, statusCode: 422);
}
