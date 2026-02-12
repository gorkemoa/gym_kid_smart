class UserModel {
  final int? id;
  final int? schoolId;
  final String? name;
  final String? surname;
  final String? image;
  final dynamic phone;
  final String? email;
  final String? role;
  final String? userKey;

  UserModel({
    this.id,
    this.schoolId,
    this.name,
    this.surname,
    this.image,
    this.phone,
    this.email,
    this.role,
    this.userKey,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      schoolId: json['school_id'],
      name: json['name'],
      surname: json['surname'],
      image: json['image'],
      phone: json['phone'],
      email: json['email'],
      role: json['role'],
      userKey: json['user_key'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'name': name,
      'surname': surname,
      'image': image,
      'phone': phone,
      'email': email,
      'role': role,
      'user_key': userKey,
    };
  }
}
