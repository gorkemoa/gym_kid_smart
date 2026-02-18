class OyunGrubuActivityLogModel {
  final int? id;
  final int? packageId;
  final int? groupId;
  final int? lessonId;
  final String? activityType;
  final int? lessonQty;
  final int? pauseDays;
  final String? activityDate;
  final String? startTime;
  final String? note;
  final int? status;
  final String? createdAt;
  final String? lessonTitle;

  OyunGrubuActivityLogModel({
    this.id,
    this.packageId,
    this.groupId,
    this.lessonId,
    this.activityType,
    this.lessonQty,
    this.pauseDays,
    this.activityDate,
    this.startTime,
    this.note,
    this.status,
    this.createdAt,
    this.lessonTitle,
  });

  factory OyunGrubuActivityLogModel.fromJson(Map<String, dynamic> json) {
    return OyunGrubuActivityLogModel(
      id: json['id'] as int?,
      packageId: json['package_id'] as int?,
      groupId: json['group_id'] as int?,
      lessonId: json['lesson_id'] as int?,
      activityType: json['activity_type'] as String?,
      lessonQty: json['lesson_qty'] as int?,
      pauseDays: json['pause_days'] as int?,
      activityDate: json['activity_date'] as String?,
      startTime: json['start_time'] as String?,
      note: json['note'] as String?,
      status: json['status'] as int?,
      createdAt: json['created_at'] as String?,
      lessonTitle: json['lesson_title'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'package_id': packageId,
      'group_id': groupId,
      'lesson_id': lessonId,
      'activity_type': activityType,
      'lesson_qty': lessonQty,
      'pause_days': pauseDays,
      'activity_date': activityDate,
      'start_time': startTime,
      'note': note,
      'status': status,
      'created_at': createdAt,
      'lesson_title': lessonTitle,
    };
  }
}
