import 'oyungrubu_package_info_model.dart';

class OyunGrubuPackageInfoResponse {
  final String? success;
  final int? packageCount;
  final List<OyunGrubuPackageInfoModel>? packages;
  final int? makeupBalance;

  OyunGrubuPackageInfoResponse({
    this.success,
    this.packageCount,
    this.packages,
    this.makeupBalance,
  });

  factory OyunGrubuPackageInfoResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return OyunGrubuPackageInfoResponse(
      success: json['success'] as String?,
      packageCount: data?['package_count'] as int?,
      packages: (data?['packages'] as List<dynamic>?)
          ?.map(
            (e) =>
                OyunGrubuPackageInfoModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      makeupBalance: data?['makeup_balance'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': {
        'package_count': packageCount,
        'packages': packages?.map((p) => p.toJson()).toList(),
        'makeup_balance': makeupBalance,
      },
    };
  }
}
