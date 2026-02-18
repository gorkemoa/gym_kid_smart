import 'oyungrubu_lesson_model.dart';

class OyunGrubuLessonsResponse {
  final String? success;
  final List<OyunGrubuLessonModel>? data;

  OyunGrubuLessonsResponse({this.success, this.data});

  factory OyunGrubuLessonsResponse.fromJson(Map<String, dynamic> json) {
    return OyunGrubuLessonsResponse(
      success: json['success'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => OyunGrubuLessonModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data?.map((v) => v.toJson()).toList()};
  }
}
