import 'dart:async';
import 'base_view_model.dart';

class SplashViewModel extends BaseViewModel {
  Future<void> init() async {
    // We can add any splash-time initialization here if needed
    // For now, it's just a placeholder to follow the MVVM pattern
    notifyListeners();
  }
}
