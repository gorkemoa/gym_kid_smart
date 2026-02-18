import 'oyungrubu_activity_log_model.dart';
import 'oyungrubu_package_model.dart';

class OyunGrubuStudentHistoryResponse {
  final String? success;
  final List<OyunGrubuActivityLogModel>? activityLogs;
  final List<OyunGrubuPackageModel>? activePackages;
  final List<OyunGrubuPackageModel>? expiredPackages;
  final List<OyunGrubuPackageModel>? allPackages;

  OyunGrubuStudentHistoryResponse({
    this.success,
    this.activityLogs,
    this.activePackages,
    this.expiredPackages,
    this.allPackages,
  });

  factory OyunGrubuStudentHistoryResponse.fromJson(Map<String, dynamic> json) {
    return OyunGrubuStudentHistoryResponse(
      success: json['success'] as String?,
      activityLogs: (json['activity_logs'] as List<dynamic>?)
          ?.map(
            (e) =>
                OyunGrubuActivityLogModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      activePackages: (json['active_packages'] as List<dynamic>?)
          ?.map(
            (e) => OyunGrubuPackageModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      expiredPackages: (json['expired_packages'] as List<dynamic>?)
          ?.map(
            (e) => OyunGrubuPackageModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      allPackages: (json['all_packages'] as List<dynamic>?)
          ?.map(
            (e) => OyunGrubuPackageModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'activity_logs': activityLogs?.map((v) => v.toJson()).toList(),
      'active_packages': activePackages?.map((v) => v.toJson()).toList(),
      'expired_packages': expiredPackages?.map((v) => v.toJson()).toList(),
      'all_packages': allPackages?.map((v) => v.toJson()).toList(),
    };
  }
}
