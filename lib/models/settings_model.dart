class SettingsResponse {
  final String? success;
  final String? url;
  final SettingsData? data;

  SettingsResponse({this.success, this.url, this.data});

  factory SettingsResponse.fromJson(Map<String, dynamic> json) {
    return SettingsResponse(
      success: json['success'] as String?,
      url: json['url'] as String?,
      data: json['data'] != null
          ? SettingsData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'url': url, 'data': data?.toJson()};
  }
}

class SettingsData {
  final int? id;
  final String? name;
  final String? city;
  final String? district;
  final String? address;
  final String? logo;
  final String? mainColor;
  final String? otherColor;
  final int? status;
  final String? createdAt;

  SettingsData({
    this.id,
    this.name,
    this.city,
    this.district,
    this.address,
    this.logo,
    this.mainColor,
    this.otherColor,
    this.status,
    this.createdAt,
  });

  factory SettingsData.fromJson(Map<String, dynamic> json) {
    return SettingsData(
      id: json['id'] as int?,
      name: json['name'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      address: json['address'] as String?,
      logo: json['logo'] as String?,
      mainColor: json['main_color'] as String?,
      otherColor: json['other_color'] as String?,
      status: json['status'] as int?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'district': district,
      'address': address,
      'logo': logo,
      'main_color': mainColor,
      'other_color': otherColor,
      'status': status,
      'created_at': createdAt,
    };
  }

  String get logoUrl => logo != null
      ? 'https://smartkid.gymboreeizmir.com/images/schools/$logo'
      : '';
}
