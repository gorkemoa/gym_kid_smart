class MealTitleModel {
  int? id;
  String? title;
  int? schoolId;

  MealTitleModel({this.id, this.title, this.schoolId});

  MealTitleModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id'].toString());
    title = json['title'];
    schoolId = int.tryParse(json['school_id'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['school_id'] = schoolId;
    return data;
  }
}
