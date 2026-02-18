import 'package:flutter/material.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../core/utils/app_translations.dart';
import '../../../../models/oyungrubu_lesson_model.dart';
import '../../../../models/oyungrubu_student_model.dart';

class OyunGrubuLessonSection extends StatelessWidget {
  final List<OyunGrubuStudentModel>? students;
  final int? selectedStudentId;
  final List<OyunGrubuLessonModel>? lessons;
  final bool isLoading;
  final String locale;
  final Function(int studentId) onStudentSelected;

  const OyunGrubuLessonSection({
    super.key,
    required this.students,
    required this.selectedStudentId,
    required this.lessons,
    required this.isLoading,
    required this.locale,
    required this.onStudentSelected,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeTokens.p24,
            vertical: SizeTokens.p12,
          ),
          child: Row(
            children: [
              Container(
                width: SizeTokens.r4,
                height: SizeTokens.h24,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800),
                  borderRadius: BorderRadius.circular(SizeTokens.r4),
                ),
              ),
              SizedBox(width: SizeTokens.p12),
              Text(
                AppTranslations.translate('upcoming_lessons', locale),
                style: TextStyle(
                  fontSize: SizeTokens.f20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),

        // Student selector chips
        if (students != null && students!.isNotEmpty)
          SizedBox(
            height: SizeTokens.h48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: SizeTokens.p24),
              itemCount: students!.length,
              itemBuilder: (context, index) {
                final student = students![index];
                final isSelected = selectedStudentId == student.id;

                return GestureDetector(
                  onTap: () {
                    if (student.id != null) {
                      onStudentSelected(student.id!);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: SizeTokens.p10),
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeTokens.p16,
                      vertical: SizeTokens.p10,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                const Color(0xFFFF9800),
                                // ignore: deprecated_member_use
                                const Color(0xFFFF9800).withOpacity(0.8),
                              ],
                            )
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(SizeTokens.r12),
                      border: isSelected
                          ? null
                          : Border.all(color: Colors.grey.shade200),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: const Color(
                                  0xFFFF9800,
                                ).withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.child_care_rounded,
                          size: SizeTokens.i16,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                        SizedBox(width: SizeTokens.p6),
                        Text(
                          '${student.name ?? ''} ${student.surname ?? ''}'
                              .trim(),
                          style: TextStyle(
                            fontSize: SizeTokens.f12,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : Colors.blueGrey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        SizedBox(height: SizeTokens.p12),

        // Lessons list
        if (selectedStudentId == null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeTokens.p24),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(SizeTokens.p20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(SizeTokens.r16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    size: SizeTokens.i32,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: SizeTokens.p8),
                  Text(
                    AppTranslations.translate(
                      'select_child_for_lessons',
                      locale,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: SizeTokens.f14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (isLoading)
          Padding(
            padding: EdgeInsets.symmetric(vertical: SizeTokens.p16),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (lessons == null || lessons!.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeTokens.p24),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(SizeTokens.p20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(SizeTokens.r16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.event_busy_rounded,
                    size: SizeTokens.i32,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: SizeTokens.p8),
                  Text(
                    AppTranslations.translate('no_upcoming_lessons', locale),
                    style: TextStyle(
                      fontSize: SizeTokens.f14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeTokens.p24),
            child: Column(
              children: lessons!.map((lesson) {
                return _buildLessonCard(context, lesson, primaryColor);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildLessonCard(
    BuildContext context,
    OyunGrubuLessonModel lesson,
    Color primaryColor,
  ) {
    final isCancelled = lesson.isCancelled == true;
    final statusColor = _getStatusColor(lesson.lessonStatus, isCancelled);

    // Format time neatly (remove seconds)
    final startTime = _formatTime(lesson.startTime);
    final endTime = _formatTime(lesson.endTime);

    return Container(
      margin: EdgeInsets.only(bottom: SizeTokens.p10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r16),
        border: Border.all(
          color: isCancelled
              // ignore: deprecated_member_use
              ? Colors.red.shade100
              : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(SizeTokens.p16),
        child: Row(
          children: [
            // Date block
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeTokens.p12,
                vertical: SizeTokens.p10,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isCancelled
                      ? [Colors.red.shade50, Colors.red.shade100]
                      : [
                          // ignore: deprecated_member_use
                          const Color(0xFFFF9800).withOpacity(0.1),
                          // ignore: deprecated_member_use
                          const Color(0xFFFF9800).withOpacity(0.18),
                        ],
                ),
                borderRadius: BorderRadius.circular(SizeTokens.r12),
              ),
              child: Column(
                children: [
                  Text(
                    _getDayFromDate(lesson.date),
                    style: TextStyle(
                      fontSize: SizeTokens.f20,
                      fontWeight: FontWeight.w900,
                      color: isCancelled
                          ? Colors.red.shade400
                          : const Color(0xFFFF9800),
                    ),
                  ),
                  Text(
                    _getMonthAbbr(lesson.date),
                    style: TextStyle(
                      fontSize: SizeTokens.f10,
                      fontWeight: FontWeight.w600,
                      color: isCancelled
                          ? Colors.red.shade300
                          // ignore: deprecated_member_use
                          : const Color(0xFFFF9800).withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: SizeTokens.p14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.lessonTitle ?? '-',
                    style: TextStyle(
                      fontSize: SizeTokens.f14,
                      fontWeight: FontWeight.w700,
                      color: isCancelled
                          ? Colors.grey.shade400
                          : Colors.blueGrey.shade800,
                      decoration: isCancelled
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  SizedBox(height: SizeTokens.p4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: SizeTokens.i12,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(width: SizeTokens.p4),
                      Text(
                        '$startTime - $endTime',
                        style: TextStyle(
                          fontSize: SizeTokens.f12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: SizeTokens.p10),
                      Icon(
                        Icons.groups_rounded,
                        size: SizeTokens.i12,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(width: SizeTokens.p4),
                      Flexible(
                        child: Text(
                          lesson.groupName ?? '-',
                          style: TextStyle(
                            fontSize: SizeTokens.f12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: SizeTokens.p6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: SizeTokens.i10,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(width: SizeTokens.p4),
                      Text(
                        lesson.dayName ?? '-',
                        style: TextStyle(
                          fontSize: SizeTokens.f10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeTokens.p10,
                vertical: SizeTokens.p6,
              ),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(SizeTokens.r8),
              ),
              child: Text(
                _getStatusLabel(lesson.lessonStatus, isCancelled, locale),
                style: TextStyle(
                  fontSize: SizeTokens.f10,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? time) {
    if (time == null) return '-';
    // Remove trailing :00 seconds
    final parts = time.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return time;
  }

  String _getDayFromDate(String? date) {
    if (date == null) return '-';
    try {
      return date.split('-').last;
    } catch (_) {
      return '-';
    }
  }

  String _getMonthAbbr(String? date) {
    if (date == null) return '';
    try {
      final month = int.parse(date.split('-')[1]);
      const months = [
        'Oca',
        'Şub',
        'Mar',
        'Nis',
        'May',
        'Haz',
        'Tem',
        'Ağu',
        'Eyl',
        'Eki',
        'Kas',
        'Ara',
      ];
      return months[month - 1];
    } catch (_) {
      return '';
    }
  }

  Color _getStatusColor(String? status, bool isCancelled) {
    if (isCancelled) return Colors.red.shade500;
    switch (status) {
      case 'completed':
        return Colors.green.shade600;
      case 'pending':
        return Colors.orange.shade600;
      default:
        return Colors.grey.shade500;
    }
  }

  String _getStatusLabel(String? status, bool isCancelled, String locale) {
    if (isCancelled) {
      return AppTranslations.translate('cancelled', locale);
    }
    switch (status) {
      case 'completed':
        return AppTranslations.translate('completed', locale);
      case 'pending':
        return AppTranslations.translate('pending', locale);
      default:
        return status ?? '-';
    }
  }
}
