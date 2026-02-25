class ErrorMapper {
  static String mapMessage(Object e) {
    String message = e.toString().toLowerCase();

    // Specific API status or message mapping
    if (message.contains('mail veya şifre hatalı') ||
        message.contains('invalid credentials') ||
        message.contains('hatalı giriş')) {
      return 'E-posta veya şifre hatalı. Lütfen kontrol edip tekrar deneyin.';
    }

    if (message.contains('unauthorised') || message.contains('401')) {
      return 'Oturum süresi dolmuş veya yetkisiz erişim. Lütfen tekrar giriş yapın.';
    }

    if (message.contains('socketexception') ||
        message.contains('network') ||
        message.contains('bağlantı')) {
      return 'İnternet bağlantısı kurulamadı. Lütfen bağlantınızı kontrol edin.';
    }

    if (message.contains('timeout')) {
      return 'İstek zaman aşımına uğradı. Lütfen daha sonra tekrar deneyin.';
    }

    if (message.contains('user key hatalı')) {
      return 'Oturum anahtarı geçersiz. Lütfen tekrar giriş yapın.';
    }

    if (message.contains('500') || message.contains('server error')) {
      return 'Sunucu hatası oluştu. Lütfen teknik ekibe bildirin.';
    }

    if (message.contains('bulunamadı')) {
      return 'İstediğiniz kayıt bulunamadı.';
    }

    if (message.contains('already exists') || message.contains('kayıtlı')) {
      return 'Bu kayıt zaten mevcut.';
    }

    // Default messages based on known substrings or just clean the Exception string
    if (e is Exception) {
      // Remove "Exception: " or "ApiException: " prefix
      String cleanMessage = e
          .toString()
          .replaceAll(RegExp(r'^\w+Exception: '), '')
          .replaceAll(RegExp(r' \(Status: .*\)$'), '');

      // If the message is still just "Hata" or "error", return a default one
      if (cleanMessage.toLowerCase() == 'hata' ||
          cleanMessage.toLowerCase() == 'error') {
        return 'Bir hata oluştu. Lütfen tekrar deneyin.';
      }
      return cleanMessage;
    }

    return 'Bir hata oluştu. Lütfen tekrar deneyin.';
  }
}
