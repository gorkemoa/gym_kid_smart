class OyunGrubuPackageInfoModel {
  final int? packageId;
  final int? groupId;
  final String? lessonTitle;
  final int? totalLessons;
  final int? usedLessons;
  final int? remainingLessons;
  final int? postponementLimit;
  final int? postponementUsed;
  final String? startDate;
  final String? endDate;

  OyunGrubuPackageInfoModel({
    this.packageId,
    this.groupId,
    this.lessonTitle,
    this.totalLessons,
    this.usedLessons,
    this.remainingLessons,
    this.postponementLimit,
    this.postponementUsed,
    this.startDate,
    this.endDate,
  });

  factory OyunGrubuPackageInfoModel.fromJson(Map<String, dynamic> json) {
    return OyunGrubuPackageInfoModel(
      packageId: json['package_id'] as int?,
      groupId: json['group_id'] as int?,
      lessonTitle: json['lesson_title'] as String?,
      totalLessons: json['total_lessons'] as int?,
      usedLessons: json['used_lessons'] as int?,
      remainingLessons: json['remaining_lessons'] as int?,
      postponementLimit: json['postponement_limit'] as int?,
      postponementUsed: json['postponement_used'] as int?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'package_id': packageId,
      'group_id': groupId,
      'lesson_title': lessonTitle,
      'total_lessons': totalLessons,
      'used_lessons': usedLessons,
      'remaining_lessons': remainingLessons,
      'postponement_limit': postponementLimit,
      'postponement_used': postponementUsed,
      'start_date': startDate,
      'end_date': endDate,
    };
  }

  int get remainingPostponements =>
      (postponementLimit ?? 0) - (postponementUsed ?? 0);

  double get lessonProgress {
    if (totalLessons == null || totalLessons == 0) return 0;
    return (usedLessons ?? 0) / totalLessons!;
  }

  double get postponementProgress {
    if (postponementLimit == null || postponementLimit == 0) return 0;
    return (postponementUsed ?? 0) / postponementLimit!;
  }
}
