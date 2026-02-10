import 'dart:convert';
import 'package:flutter/services.dart';

class AppTranslations {
  static Map<String, String> _localizedValues = {};

  static Future<void> load(String locale) async {
    String jsonString = await rootBundle.loadString('assets/lang/$locale.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedValues = jsonMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );
  }

  static String translate(String key, String locale) {
    // If locale changed and not loaded yet, we might need a fallback or sync trigger
    // But usually load() is called first.
    return _localizedValues[key] ?? key;
  }
}
