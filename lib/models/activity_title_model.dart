class ActivityTitleModel {
  final int? id;
  final int? schoolId;
  final String? title;

  ActivityTitleModel({this.id, this.schoolId, this.title});

  factory ActivityTitleModel.fromJson(Map<String, dynamic> json) {
    return ActivityTitleModel(
      id: json['id'],
      schoolId: json['school_id'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'school_id': schoolId, 'title': title};
  }
}
