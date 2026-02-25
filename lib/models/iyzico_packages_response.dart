import 'iyzico_package_model.dart';

class IyzicoPackagesResponse {
  final String? success;
  final List<IyzicoPackageModel>? data;

  IyzicoPackagesResponse({this.success, this.data});

  factory IyzicoPackagesResponse.fromJson(Map<String, dynamic> json) {
    return IyzicoPackagesResponse(
      success: json['success'],
      data: json['data'] != null
          ? (json['data'] as List)
                .map((i) => IyzicoPackageModel.fromJson(i))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data?.map((i) => i.toJson()).toList()};
  }
}
