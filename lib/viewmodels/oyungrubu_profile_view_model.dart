import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'base_view_model.dart';
import '../core/network/api_result.dart';
import '../models/oyungrubu_profile_response.dart';
import '../models/oyungrubu_profile_model.dart';
import '../services/oyungrubu_auth_service.dart';

class OyunGrubuProfileViewModel extends BaseViewModel {
  final OyunGrubuAuthService _authService = OyunGrubuAuthService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  OyunGrubuProfileModel? _data;
  OyunGrubuProfileModel? get data => _data;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

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
      if (_data != null) {
        nameController.text = _data!.name ?? '';
        surnameController.text = _data!.surname ?? '';
        phoneController.text = _data!.phone?.toString() ?? '';
      }
      notifyListeners();
    } else if (result is Failure<OyunGrubuProfileResponse>) {
      _errorMessage = result.message;
      notifyListeners();
    }
  }

  Future<bool> updateProfile() async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.updateParentProfile(
      name: nameController.text,
      surname: surnameController.text,
      phone: phoneController.text,
    );

    _setLoading(false);

    if (result is Success<bool>) {
      await fetchProfile(); // Refresh profile data after update
      return true;
    } else if (result is Failure<bool>) {
      _errorMessage = result.message;
      notifyListeners();
      return false;
    }
    return false;
  }

  Future<bool> updateImage({required String type, String? studentId}) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return false;

    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.updateProfileImage(
      image: File(image.path),
      type: type,
      studentId: studentId,
    );

    _setLoading(false);

    if (result is Success<bool>) {
      await fetchProfile(); // Refresh profile to see new image
      return true;
    } else if (result is Failure<bool>) {
      _errorMessage = result.message;
      notifyListeners();
      return false;
    }
    return false;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
