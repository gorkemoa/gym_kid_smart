import 'oyungrubu_profile_model.dart';

class OyunGrubuProfileResponse {
  final String? success;
  final OyunGrubuProfileModel? data;

  OyunGrubuProfileResponse({this.success, this.data});

  factory OyunGrubuProfileResponse.fromJson(Map<String, dynamic> json) {
    return OyunGrubuProfileResponse(
      success: json['success'] as String?,
      data: json['data'] != null
          ? OyunGrubuProfileModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
    };
  }
}
