class OyunGrubuStudentModel {
  final int? id;
  final int? groupId;
  final String? name;
  final String? surname;
  final String? birthDate;
  final int? gender;
  final int? parentId;
  final String? photo;
  final int? status;
  final String? createdAt;
  final String? medications;
  final String? allergies;
  final String? groupName;

  OyunGrubuStudentModel({
    this.id,
    this.groupId,
    this.name,
    this.surname,
    this.birthDate,
    this.gender,
    this.parentId,
    this.photo,
    this.status,
    this.createdAt,
    this.medications,
    this.allergies,
    this.groupName,
  });

  factory OyunGrubuStudentModel.fromJson(Map<String, dynamic> json) {
    return OyunGrubuStudentModel(
      id: json['id'] as int?,
      groupId: json['group_id'] as int?,
      name: json['name'] as String?,
      surname: json['surname'] as String?,
      birthDate: json['birth_date'] as String?,
      gender: json['gender'] as int?,
      parentId: json['parent_id'] as int?,
      photo: json['photo'] as String?,
      status: json['status'] as int?,
      createdAt: json['created_at'] as String?,
      medications: json['medications'] as String?,
      allergies: json['allergies'] as String?,
      groupName: json['group_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'name': name,
      'surname': surname,
      'birth_date': birthDate,
      'gender': gender,
      'parent_id': parentId,
      'photo': photo,
      'status': status,
      'created_at': createdAt,
      'medications': medications,
      'allergies': allergies,
      'group_name': groupName,
    };
  }
}
