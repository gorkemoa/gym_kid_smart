class StudentModel {
  final int? id;
  final int? schoolId;
  final String? name;
  final String? surname;
  final String? image;
  final String? birthDate;
  final int? classId;

  StudentModel({
    this.id,
    this.schoolId,
    this.name,
    this.surname,
    this.image,
    this.birthDate,
    this.classId,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: _toInt(json['id']),
      schoolId: _toInt(json['school_id']),
      name: json['name'],
      surname: json['surname'],
      image: json['image'],
      birthDate: json['birth_date'],
      classId: _toInt(json['class_id']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'name': name,
      'surname': surname,
      'image': image,
      'birth_date': birthDate,
      'class_id': classId,
    };
  }
}
