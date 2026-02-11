class ActivityValueModel {
  final int? id;
  final int? schoolId;
  final String? value;

  ActivityValueModel({this.id, this.schoolId, this.value});

  factory ActivityValueModel.fromJson(Map<String, dynamic> json) {
    return ActivityValueModel(
      id: json['id'],
      schoolId: json['school_id'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'school_id': schoolId, 'value': value};
  }
}
