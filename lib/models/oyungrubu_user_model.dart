class OyunGrubuUserModel {
  final int? userId;
  final String? name;
  final String? surname;
  final String? email;
  final String? role;
  final String? userKey;

  OyunGrubuUserModel({
    this.userId,
    this.name,
    this.surname,
    this.email,
    this.role,
    this.userKey,
  });

  factory OyunGrubuUserModel.fromJson(Map<String, dynamic> json) {
    return OyunGrubuUserModel(
      userId: json['user_id'],
      name: json['name'],
      surname: json['surname'],
      email: json['email'],
      role: json['role'],
      userKey: json['user_key'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'surname': surname,
      'email': email,
      'role': role,
      'user_key': userKey,
    };
  }
}
