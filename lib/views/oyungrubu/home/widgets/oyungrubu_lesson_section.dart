import 'package:flutter/material.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../core/utils/app_translations.dart';
import '../../../../models/oyungrubu_lesson_model.dart';
import '../../../../models/oyungrubu_student_model.dart';

class OyunGrubuLessonSection extends StatefulWidget {
  final List<OyunGrubuStudentModel>? students;
  final int? selectedStudentId;
  final List<OyunGrubuLessonModel>? upcomingLessons;
  final List<OyunGrubuLessonModel>? historyLessons;
  final bool isLoading;
  final String locale;
  final Function(int studentId) onStudentSelected;

  const OyunGrubuLessonSection({
    super.key,
    required this.students,
    required this.selectedStudentId,
    required this.upcomingLessons,
    required this.historyLessons,
    required this.isLoading,
    required this.locale,
    required this.onStudentSelected,
  });

  @override
  State<OyunGrubuLessonSection> createState() => _OyunGrubuLessonSectionState();
}

class _OyunGrubuLessonSectionState extends State<OyunGrubuLessonSection> {
  bool _showHistory = false;

  @override
  Widget build(BuildContext context) {
    final currentLessons = _showHistory
        ? widget.historyLessons
        : widget.upcomingLessons;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeTokens.p24,
            vertical: SizeTokens.p12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppTranslations.translate(
                  _showHistory ? 'lesson_history' : 'upcoming_lessons',
                  widget.locale,
                ),
                style: TextStyle(
                  fontSize: SizeTokens.f18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade900,
                ),
              ),

              if (widget.selectedStudentId != null)
                TextButton.icon(
                  onPressed: () => setState(() => _showHistory = !_showHistory),
                  icon: Icon(
                    _showHistory
                        ? Icons.history_rounded
                        : Icons.schedule_rounded,
                    size: SizeTokens.i16,
                    color: _showHistory
                        ? Colors.blueGrey
                        : const Color(0xFFFF9800),
                  ),
                  label: Text(
                    AppTranslations.translate(
                      _showHistory ? 'upcoming_lessons' : 'lesson_history',
                      widget.locale,
                    ).split(' ').first,
                    style: TextStyle(
                      fontSize: SizeTokens.f14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey.shade700,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeTokens.p12,
                      vertical: SizeTokens.p8,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SizeTokens.r20),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Student Selector
        if (widget.students != null && widget.students!.isNotEmpty)
          SizedBox(
            height: SizeTokens.h40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: SizeTokens.p24),
              itemCount: widget.students!.length,
              separatorBuilder: (_, __) => SizedBox(width: SizeTokens.p8),
              itemBuilder: (context, index) {
                final student = widget.students![index];
                final isSelected = widget.selectedStudentId == student.id;

                return GestureDetector(
                  onTap: () {
                    if (student.id != null) {
                      widget.onStudentSelected(student.id!);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeTokens.p16,
                      vertical: SizeTokens.p8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFF9800)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(SizeTokens.r20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFF9800)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${student.name ?? ''} ${student.surname ?? ''}'.trim(),
                        style: TextStyle(
                          fontSize: SizeTokens.f12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : Colors.blueGrey.shade600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        SizedBox(height: SizeTokens.p12),

        // Content
        if (widget.selectedStudentId == null)
          _buildEmptyState(
            icon: Icons.touch_app_rounded,
            message: AppTranslations.translate(
              'select_child_for_lessons',
              widget.locale,
            ),
          )
        else if (widget.isLoading)
          Padding(
            padding: EdgeInsets.symmetric(vertical: SizeTokens.p32),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (currentLessons == null || currentLessons.isEmpty)
          _buildEmptyState(
            icon: Icons.event_note_rounded,
            message: AppTranslations.translate(
              _showHistory ? 'no_history_lessons' : 'no_upcoming_lessons',
              widget.locale,
            ),
          )
        else
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeTokens.p24),
            child: Column(
              children: currentLessons.map((lesson) {
                return _buildLessonCard(context, lesson);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: SizeTokens.p24,
        vertical: SizeTokens.p10,
      ),
      padding: EdgeInsets.all(SizeTokens.p32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(icon, size: SizeTokens.i48, color: Colors.grey.shade200),
          SizedBox(height: SizeTokens.p12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: SizeTokens.f14,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, OyunGrubuLessonModel lesson) {
    final isCancelled = lesson.isCancelled == true;
    final statusColor = _getStatusColor(lesson.lessonStatus, isCancelled);
    final startTime = _formatTime(lesson.startTime);
    final endTime = _formatTime(lesson.endTime);

    return Container(
      margin: EdgeInsets.only(bottom: SizeTokens.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Simple Left Strip for Status
            Container(
              width: SizeTokens.w4,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(SizeTokens.r12),
                  bottomLeft: Radius.circular(SizeTokens.r12),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(SizeTokens.p12),
                child: Row(
                  children: [
                    // Date Column
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getDayFromDate(lesson.date),
                          style: TextStyle(
                            fontSize: SizeTokens.f18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade900,
                          ),
                        ),
                        Text(
                          _getMonthAbbr(lesson.date).toUpperCase(),
                          style: TextStyle(
                            fontSize: SizeTokens.f12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(width: SizeTokens.p16),

                    // Lesson Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            lesson.lessonTitle ?? '-',
                            style: TextStyle(
                              fontSize: SizeTokens.f14,
                              fontWeight: FontWeight.w600,
                              color: isCancelled
                                  ? Colors.grey.shade400
                                  : Colors.blueGrey.shade900,
                              decoration: isCancelled
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: SizeTokens.p4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: SizeTokens.i12,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(width: SizeTokens.p4),
                              Text(
                                '$startTime - $endTime',
                                style: TextStyle(
                                  fontSize: SizeTokens.f12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Status Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeTokens.p8,
                        vertical: SizeTokens.p4,
                      ),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(SizeTokens.r8),
                      ),
                      child: Text(
                        _getStatusLabel(
                          lesson.lessonStatus,
                          isCancelled,
                          widget.locale,
                        ),
                        style: TextStyle(
                          fontSize: SizeTokens.f10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
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
    final parts = time.split(':');
    if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
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
    if (isCancelled) return AppTranslations.translate('cancelled', locale);
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
