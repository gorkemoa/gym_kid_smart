import 'oyungrubu_student_model.dart';

class OyunGrubuProfileModel {
  final int? id;
  final String? name;
  final String? surname;
  final String? image;
  final dynamic phone;
  final String? email;
  final String? role;
  final int? status;
  final String? notificationKey;
  final int? loginAttempt;
  final String? createdAt;
  final String? fcmToken;
  final List<OyunGrubuStudentModel>? students;

  OyunGrubuProfileModel({
    this.id,
    this.name,
    this.surname,
    this.image,
    this.phone,
    this.email,
    this.role,
    this.status,
    this.notificationKey,
    this.loginAttempt,
    this.createdAt,
    this.fcmToken,
    this.students,
  });

  factory OyunGrubuProfileModel.fromJson(Map<String, dynamic> json) {
    return OyunGrubuProfileModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      surname: json['surname'] as String?,
      image: json['image'] as String?,
      phone: json['phone'],
      email: json['email'] as String?,
      role: json['role'] as String?,
      status: json['status'] as int?,
      notificationKey: json['notification_key'] as String?,
      loginAttempt: json['login_attempt'] as int?,
      createdAt: json['created_at'] as String?,
      fcmToken: json['fcm_token'] as String?,
      students: (json['students'] as List<dynamic>?)
          ?.map((e) => OyunGrubuStudentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'image': image,
      'phone': phone,
      'email': email,
      'role': role,
      'status': status,
      'notification_key': notificationKey,
      'login_attempt': loginAttempt,
      'created_at': createdAt,
      'fcm_token': fcmToken,
      'students': students?.map((v) => v.toJson()).toList(),
    };
  }
}
