class OyunGrubuNotificationModel {
  final int? id;
  final int? userId;
  final String? title;
  final String? message;
  final String? type;
  final String? data;
  int? isRead;
  final String? createdAt;

  OyunGrubuNotificationModel({
    this.id,
    this.userId,
    this.title,
    this.message,
    this.type,
    this.data,
    this.isRead,
    this.createdAt,
  });

  factory OyunGrubuNotificationModel.fromJson(Map<String, dynamic> json) {
    return OyunGrubuNotificationModel(
      id: json['id'] as int?,
      userId: json['user_id'] is int
          ? json['user_id'] as int?
          : int.tryParse(json['user_id'].toString()),
      title: json['title']?.toString(),
      message: json['message']?.toString(),
      type: json['type']?.toString(),
      data: json['data'] != null
          ? (json['data'] is String ? json['data'] as String : json['data'].toString())
          : null,
      isRead: json['is_read'] is int
          ? json['is_read'] as int?
          : int.tryParse(json['is_read'].toString()),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'data': data,
      'is_read': isRead,
      'created_at': createdAt,
    };
  }
}
