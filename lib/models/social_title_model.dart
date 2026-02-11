class SocialTitleModel {
  final int? id;
  final int? schoolId;
  final String? title;

  SocialTitleModel({this.id, this.schoolId, this.title});

  factory SocialTitleModel.fromJson(Map<String, dynamic> json) {
    return SocialTitleModel(
      id: _toInt(json['id']),
      schoolId: _toInt(json['school_id']),
      title: json['title'],
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'school_id': schoolId, 'title': title};
  }
}
