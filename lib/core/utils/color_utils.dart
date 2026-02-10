import 'package:flutter/material.dart';

class ColorUtils {
  static Color fromHex(String? hexString) {
    if (hexString == null || hexString.isEmpty) return Colors.transparent;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
