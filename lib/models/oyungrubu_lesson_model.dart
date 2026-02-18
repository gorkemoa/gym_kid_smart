class OyunGrubuLessonModel {
  final String? date;
  final String? dayName;
  final String? startTime;
  final String? endTime;
  final String? lessonTitle;
  final int? lessonId;
  final String? groupName;
  final bool? isCancelled;
  final String? lessonStatus;

  OyunGrubuLessonModel({
    this.date,
    this.dayName,
    this.startTime,
    this.endTime,
    this.lessonTitle,
    this.lessonId,
    this.groupName,
    this.isCancelled,
    this.lessonStatus,
  });

  factory OyunGrubuLessonModel.fromJson(Map<String, dynamic> json) {
    return OyunGrubuLessonModel(
      date: json['date'] as String?,
      dayName: json['day_name'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      lessonTitle: json['lesson_title'] as String?,
      lessonId: json['lesson_id'] as int?,
      groupName: json['group_name'] as String?,
      isCancelled: json['is_cancelled'] as bool?,
      lessonStatus: json['lesson_status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day_name': dayName,
      'start_time': startTime,
      'end_time': endTime,
      'lesson_title': lessonTitle,
      'lesson_id': lessonId,
      'group_name': groupName,
      'is_cancelled': isCancelled,
      'lesson_status': lessonStatus,
    };
  }
}
