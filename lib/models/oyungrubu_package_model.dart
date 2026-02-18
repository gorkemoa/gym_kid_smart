class OyunGrubuPackageModel {
  final int? id;
  final int? studentId;
  final int? groupId;
  final dynamic lessonIds;
  final int? lessonCount;
  final int? postponementLimit;
  final String? startDate;
  final String? endDate;
  final int? status;
  final String? createdAt;
  final String? updatedAt;
  final String? groupName;

  OyunGrubuPackageModel({
    this.id,
    this.studentId,
    this.groupId,
    this.lessonIds,
    this.lessonCount,
    this.postponementLimit,
    this.startDate,
    this.endDate,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.groupName,
  });

  factory OyunGrubuPackageModel.fromJson(Map<String, dynamic> json) {
    return OyunGrubuPackageModel(
      id: json['id'] as int?,
      studentId: json['student_id'] as int?,
      groupId: json['group_id'] as int?,
      lessonIds: json['lesson_ids'],
      lessonCount: json['lesson_count'] as int?,
      postponementLimit: json['postponement_limit'] as int?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      status: json['status'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      groupName: json['group_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'group_id': groupId,
      'lesson_ids': lessonIds,
      'lesson_count': lessonCount,
      'postponement_limit': postponementLimit,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'group_name': groupName,
    };
  }

  bool get isActive => status == 1;
  bool get isExpired => status == 99;
}
