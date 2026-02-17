class PermissionModel {
  final int? id;
  final int? schoolId;
  final String? title;
  final String? file;
  final String? classIds;
  final int? userId;
  final int? status;
  final String? dateAdded;

  PermissionModel({
    this.id,
    this.schoolId,
    this.title,
    this.file,
    this.classIds,
    this.userId,
    this.status,
    this.dateAdded,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      schoolId: json['school_id'] is int
          ? json['school_id']
          : int.tryParse(json['school_id']?.toString() ?? ''),
      title: json['title'],
      file: json['file'],
      classIds: json['class_ids']?.toString(),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? ''),
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? ''),
      dateAdded: json['date_added'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'title': title,
      'file': file,
      'class_ids': classIds,
      'user_id': userId,
      'status': status,
      'date_added': dateAdded,
    };
  }
}

/// Parent izin listesindeki her bir öğe
/// API'dan gelen yapı: { "permissionItem": {...}, "status": 0 }
class ParentPermissionModel {
  final PermissionModel permissionItem;
  final int? parentStatus; // Velinin onay durumu (0: onaylanmadı, 1: onaylandı)

  ParentPermissionModel({required this.permissionItem, this.parentStatus});

  factory ParentPermissionModel.fromJson(Map<String, dynamic> json) {
    return ParentPermissionModel(
      permissionItem: PermissionModel.fromJson(
        json['permissionItem'] ?? json['permission_item'] ?? {},
      ),
      parentStatus: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? ''),
    );
  }
}
