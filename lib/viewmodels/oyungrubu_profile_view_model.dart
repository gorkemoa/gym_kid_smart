import 'package:flutter/material.dart';
import 'base_view_model.dart';
import '../core/network/api_result.dart';
import '../models/oyungrubu_profile_response.dart';
import '../models/oyungrubu_profile_model.dart';
import '../services/oyungrubu_auth_service.dart';

class OyunGrubuProfileViewModel extends BaseViewModel {
  final OyunGrubuAuthService _authService = OyunGrubuAuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  OyunGrubuProfileModel? _data;
  OyunGrubuProfileModel? get data => _data;

  Future<void> init() async {
    await fetchProfile();
  }

  void onRetry() {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.getProfile();

    _setLoading(false);

    if (result is Success<OyunGrubuProfileResponse>) {
      _data = result.data.data;
      notifyListeners();
    } else if (result is Failure<OyunGrubuProfileResponse>) {
      _errorMessage = result.message;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
