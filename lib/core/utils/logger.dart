import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
  );

  static void info(String message) => _logger.i(message);
  static void error(String message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
  static void warning(String message) => _logger.w(message);
  static void debug(String message) => _logger.d(message);
  static void request(String message) => _logger.i('REQUEST: $message');
  static void response(String message) => _logger.i('RESPONSE: $message');
}
