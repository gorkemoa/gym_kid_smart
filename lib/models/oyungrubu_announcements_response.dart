import 'oyungrubu_announcement_model.dart';

class OyunGrubuAnnouncementsResponse {
  final String? success;
  final List<OyunGrubuAnnouncementModel>? data;

  OyunGrubuAnnouncementsResponse({this.success, this.data});

  factory OyunGrubuAnnouncementsResponse.fromJson(Map<String, dynamic> json) {
    return OyunGrubuAnnouncementsResponse(
      success: json['success'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map(
            (e) => OyunGrubuAnnouncementModel.fromJson(
              e as Map<String, dynamic>,
            ),
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
