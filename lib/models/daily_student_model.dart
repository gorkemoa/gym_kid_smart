class DailyStudentModel {
  final int? id;
  final String? title;
  final String? value;
  final String? note;
  final int? medicamentId;
  final CreatorModel? creator;

  // Note logs fields
  final String? teacherNote;
  final String? parentNote;
  final int? teacherStatus;
  final int? parentStatus;
  final String? dateAdded;

  // Receiving fields
  final String? recipient;
  final String? time;
  final int? status;

  DailyStudentModel({
    this.id,
    this.title,
    this.value,
    this.note,
    this.medicamentId,
    this.creator,
    this.teacherNote,
    this.parentNote,
    this.teacherStatus,
    this.parentStatus,
    this.dateAdded,
    this.recipient,
    this.time,
    this.status,
  });

  factory DailyStudentModel.fromJson(Map<String, dynamic> json) {
    return DailyStudentModel(
      id: json['id'],
      title: json['title'],
      value: json['value'],
      note: json['note'],
      medicamentId: json['medicament_id'],
      teacherNote: json['teacher_note'],
      parentNote: json['parent_note'],
      teacherStatus: json['teacher_status'],
      parentStatus: json['parent_status'],
      dateAdded: json['date_added'],
      recipient: json['recipient'],
      time: json['time'],
      status: json['status'],
      creator: json['creator'] != null
          ? CreatorModel.fromJson(json['creator'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'value': value,
      'note': note,
      'medicament_id': medicamentId,
      'teacher_note': teacherNote,
      'parent_note': parentNote,
      'teacher_status': teacherStatus,
      'parent_status': parentStatus,
      'date_added': dateAdded,
      'recipient': recipient,
      'time': time,
      'status': status,
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
