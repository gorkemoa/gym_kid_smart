class PermissionControlModel {
  final int? id;
  final int? permissionId;
  final String? userKey;
  final int? status;
  final String? parentName;
  final String? parentSurname;
  final String? createdAt;

  PermissionControlModel({
    this.id,
    this.permissionId,
    this.userKey,
    this.status,
    this.parentName,
    this.parentSurname,
    this.createdAt,
  });

  factory PermissionControlModel.fromJson(Map<String, dynamic> json) {
    final parent = json['parent'] is Map<String, dynamic>
        ? json['parent']
        : null;
    return PermissionControlModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      permissionId: json['permission_id'] is int
          ? json['permission_id']
          : int.tryParse(json['permission_id']?.toString() ?? ''),
      userKey: json['user_key'],
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ??
                1, // Eğer listedeyse onaylamış demektir
      parentName: parent != null
          ? parent['name']
          : (json['name'] ?? json['parent_name']),
      parentSurname: parent != null
          ? parent['surname']
          : (json['surname'] ?? json['parent_surname']),
      createdAt: json['date'] ?? json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'permission_id': permissionId,
      'user_key': userKey,
      'status': status,
      'parent_name': parentName,
      'parent_surname': parentSurname,
      'created_at': createdAt,
    };
  }
}
