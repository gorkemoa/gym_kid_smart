class OyunGrubuTimetableModel {
  final int? id;
  final int? groupId;
  final int? lessonId;
  final int? weekday;
  final String? startTime;
  final String? endTime;
  final int? status;
  final String? createdAt;
  final String? updatedAt;
  final String? lessonTitle;
  final int? quota;
  final String? lessonStatus;

  OyunGrubuTimetableModel({
    this.id,
    this.groupId,
    this.lessonId,
    this.weekday,
    this.startTime,
    this.endTime,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.lessonTitle,
    this.quota,
    this.lessonStatus,
  });

  factory OyunGrubuTimetableModel.fromJson(Map<String, dynamic> json) {
    return OyunGrubuTimetableModel(
      id: json['id'] as int?,
      groupId: json['group_id'] as int?,
      lessonId: json['lesson_id'] as int?,
      weekday: json['weekday'] as int?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      status: json['status'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      lessonTitle: json['lesson_title'] as String?,
      quota: json['quota'] as int?,
      lessonStatus: json['lesson_status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'lesson_id': lessonId,
      'weekday': weekday,
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'lesson_title': lessonTitle,
      'quota': quota,
      'lesson_status': lessonStatus,
    };
  }
}
