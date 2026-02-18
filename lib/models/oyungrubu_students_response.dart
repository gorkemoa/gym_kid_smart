import 'oyungrubu_student_model.dart';

class OyunGrubuStudentsResponse {
  final String? success;
  final List<OyunGrubuStudentModel>? data;

  OyunGrubuStudentsResponse({this.success, this.data});

  factory OyunGrubuStudentsResponse.fromJson(Map<String, dynamic> json) {
    return OyunGrubuStudentsResponse(
      success: json['success'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map(
            (e) => OyunGrubuStudentModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.map((v) => v.toJson()).toList(),
    };
  }
}
