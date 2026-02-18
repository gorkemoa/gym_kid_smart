import 'oyungrubu_user_model.dart';

class OyunGrubuLoginResponse {
  final String? success;
  final OyunGrubuUserModel? data;

  OyunGrubuLoginResponse({this.success, this.data});

  factory OyunGrubuLoginResponse.fromJson(Map<String, dynamic> json) {
    return OyunGrubuLoginResponse(
      success: json['success'],
      data: json['data'] != null
          ? OyunGrubuUserModel.fromJson(json['data'])
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
