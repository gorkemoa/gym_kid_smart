import 'oyungrubu_notification_model.dart';

class OyunGrubuNotificationsResponse {
  final String? success;
  final List<OyunGrubuNotificationModel>? data;

  OyunGrubuNotificationsResponse({this.success, this.data});

  factory OyunGrubuNotificationsResponse.fromJson(Map<String, dynamic> json) {
    return OyunGrubuNotificationsResponse(
      success: json['success'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map(
            (e) =>
                OyunGrubuNotificationModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data?.map((v) => v.toJson()).toList()};
  }
}
