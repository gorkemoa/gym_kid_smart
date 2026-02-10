class DailyStudentModel {
  final String? title;
  final String? value;
  final String? note;
  final CreatorModel? creator;

  DailyStudentModel({this.title, this.value, this.note, this.creator});

  factory DailyStudentModel.fromJson(Map<String, dynamic> json) {
    return DailyStudentModel(
      title: json['title'],
      value: json['value'],
      note: json['note'],
      creator: json['creator'] != null
          ? CreatorModel.fromJson(json['creator'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'value': value,
      'note': note,
      'creator': creator?.toJson(),
    };
  }
}

class CreatorModel {
  final int? id;
  final String? name;
  final String? surname;

  CreatorModel({this.id, this.name, this.surname});

  factory CreatorModel.fromJson(Map<String, dynamic> json) {
    return CreatorModel(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'surname': surname};
  }
}
