import 'oyungrubu_activity_log_model.dart';

class OyunGrubuAttendanceHistoryResponse {
  final String? success;
  final List<OyunGrubuActivityLogModel>? data;

  OyunGrubuAttendanceHistoryResponse({
    this.success,
    this.data,
  });

  factory OyunGrubuAttendanceHistoryResponse.fromJson(
      Map<String, dynamic> json) {
    return OyunGrubuAttendanceHistoryResponse(
      success: json['success'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map(
            (e) =>
                OyunGrubuActivityLogModel.fromJson(e as Map<String, dynamic>),
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
