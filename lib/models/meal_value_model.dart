class MealValueModel {
  int? id;
  String? value;
  int? schoolId;

  MealValueModel({this.id, this.value, this.schoolId});

  MealValueModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id'].toString());
    value = json['value'];
    schoolId = int.tryParse(json['school_id'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['value'] = value;
    data['school_id'] = schoolId;
    return data;
  }
}
