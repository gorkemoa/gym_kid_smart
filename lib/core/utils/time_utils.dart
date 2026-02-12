class TimeUtils {
  static String formatTime(String? time) {
    if (time == null || time.isEmpty) return '';

    // Handle date-time: "2024-02-12 14:30:00" -> "14:30:00"
    if (time.contains(' ')) {
      time = time.split(' ').last;
    }

    // Check if it's a time string (HH:mm or HH:mm:ss)
    if (time.contains(':')) {
      final parts = time.split(':');
      if (parts.length >= 2) {
        return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
      }
    }

    return time;
  }

  static String formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '';

    // If it has both date and time
    if (dateTimeStr.contains(' ')) {
      final parts = dateTimeStr.split(' ');
      final datePart = parts[0];
      final timePart = formatTime(parts[1]);
      return '$datePart $timePart';
    }

    // If it's just time
    if (dateTimeStr.contains(':')) {
      return formatTime(dateTimeStr);
    }

    return dateTimeStr;
  }
}
