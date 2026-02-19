import 'oyungrubu_lesson_detail_model.dart';

class OyunGrubuLessonDetailResponse {
  final String? success;
  final OyunGrubuLessonDetailModel? data;

  OyunGrubuLessonDetailResponse({this.success, this.data});

  factory OyunGrubuLessonDetailResponse.fromJson(Map<String, dynamic> json) {
    return OyunGrubuLessonDetailResponse(
      success: json['success'] as String?,
      data: json['data'] != null
          ? OyunGrubuLessonDetailModel.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data?.toJson()};
  }
}
