class NoticeModel {
  final int? id;
  final int? schoolId;
  final int? userId;
  final int? classId;
  final String? title;
  final String? description;
  final String? noticeDate;
  final int? status;
  final String? dateAdded;

  NoticeModel({
    this.id,
    this.schoolId,
    this.userId,
    this.classId,
    this.title,
    this.description,
    this.noticeDate,
    this.status,
    this.dateAdded,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: _toInt(json['id']),
      schoolId: _toInt(json['school_id']),
      userId: _toInt(json['user_id']),
      classId: _toInt(json['class_id']),
      title: json['title'],
      description: json['description'],
      noticeDate: json['notice_date'],
      status: _toInt(json['status']),
      dateAdded: json['date_added'],
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
      'user_id': userId,
      'class_id': classId,
      'title': title,
      'description': description,
      'notice_date': noticeDate,
      'status': status,
      'date_added': dateAdded,
    };
  }
}
