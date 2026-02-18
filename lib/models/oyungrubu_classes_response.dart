import 'oyungrubu_class_model.dart';

class OyunGrubuClassesResponse {
  final String? success;
  final List<OyunGrubuClassModel>? data;

  OyunGrubuClassesResponse({this.success, this.data});

  factory OyunGrubuClassesResponse.fromJson(Map<String, dynamic> json) {
    return OyunGrubuClassesResponse(
      success: json['success'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => OyunGrubuClassModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data?.map((v) => v.toJson()).toList()};
  }
}
