class OyunGrubuLessonDetailModel {
  final int? id;
  final String? title;
  final int? quota;
  final String? lessonStatus;
  final int? remainingQuota;
  final int? totalQuota;
  final String? date;
  final String? studentStatus;

  OyunGrubuLessonDetailModel({
    this.id,
    this.title,
    this.quota,
    this.lessonStatus,
    this.remainingQuota,
    this.totalQuota,
    this.date,
    this.studentStatus,
  });

  factory OyunGrubuLessonDetailModel.fromJson(Map<String, dynamic> json) {
    return OyunGrubuLessonDetailModel(
      id: json['id'] as int?,
      title: json['title'] as String?,
      quota: json['quota'] is int
          ? json['quota'] as int?
          : int.tryParse(json['quota'].toString()),
      lessonStatus: json['lesson_status'] as String?,
      remainingQuota: json['remaining_quota'] is int
          ? json['remaining_quota'] as int?
          : int.tryParse(json['remaining_quota'].toString()),
      totalQuota: json['total_quota'] is int
          ? json['total_quota'] as int?
          : int.tryParse(json['total_quota'].toString()),
      date: json['date'] as String?,
      studentStatus: json['student_status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'quota': quota,
      'lesson_status': lessonStatus,
      'remaining_quota': remainingQuota,
      'total_quota': totalQuota,
      'date': date,
      'student_status': studentStatus,
    };
  }
}
