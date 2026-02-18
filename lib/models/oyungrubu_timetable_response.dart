import 'oyungrubu_timetable_model.dart';

class OyunGrubuTimetableResponse {
  final String? success;
  final List<OyunGrubuTimetableModel>? data;

  OyunGrubuTimetableResponse({this.success, this.data});

  factory OyunGrubuTimetableResponse.fromJson(Map<String, dynamic> json) {
    return OyunGrubuTimetableResponse(
      success: json['success'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map(
            (e) => OyunGrubuTimetableModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data?.map((v) => v.toJson()).toList()};
  }
}
