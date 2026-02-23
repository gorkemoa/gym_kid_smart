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
  final Function(OyunGrubuLessonModel lesson)? onLessonTap;

  const OyunGrubuLessonSection({
    super.key,
    required this.students,
    required this.selectedStudentId,
    required this.upcomingLessons,
    required this.historyLessons,
    required this.isLoading,
    required this.locale,
    required this.onStudentSelected,
    this.onLessonTap,
  });

  @override
  State<OyunGrubuLessonSection> createState() => _OyunGrubuLessonSectionState();
}

class _OyunGrubuLessonSectionState extends State<OyunGrubuLessonSection> {
  bool _showHistory = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final currentLessons = _showHistory
        ? widget.historyLessons
        : widget.upcomingLessons;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: SizeTokens.p12),

        // Student selector chips
        if (widget.students != null && widget.students!.isNotEmpty)
          SizedBox(
            height: SizeTokens.h48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: SizeTokens.p24),
              itemCount: widget.students!.length,
              itemBuilder: (context, index) {
                final student = widget.students![index];
                final isSelected = widget.selectedStudentId == student.id;

                return GestureDetector(
                  onTap: () {
                    if (student.id != null) {
                      widget.onStudentSelected(student.id!);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: EdgeInsets.only(right: SizeTokens.p10),
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeTokens.p20,
                      vertical: SizeTokens.p10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(SizeTokens.r100),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.grey.shade200,
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.face_retouching_natural_rounded,
                          size: SizeTokens.i14,
                          color: isSelected ? Colors.white : primaryColor,
                        ),
                        SizedBox(width: SizeTokens.p8),
                        Text(
                          '${student.name ?? ''} ${student.surname ?? ''}'
                              .trim(),
                          style: TextStyle(
                            fontSize: SizeTokens.f12,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
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

        SizedBox(height: SizeTokens.p16),

        // Toggle bar (upcoming / history)
        if (widget.selectedStudentId != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeTokens.p24),
            child: Container(
              padding: EdgeInsets.all(SizeTokens.p4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(SizeTokens.r12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildToggleButton(
                      label: AppTranslations.translate(
                        'upcoming_lessons',
                        widget.locale,
                      ),
                      icon: Icons.upcoming_rounded,
                      isActive: !_showHistory,
                      color: primaryColor,
                      onTap: () => setState(() => _showHistory = false),
                    ),
                  ),
                  Expanded(
                    child: _buildToggleButton(
                      label: AppTranslations.translate(
                        'lesson_history',
                        widget.locale,
                      ),
                      icon: Icons.history_rounded,
                      isActive: _showHistory,
                      color: Colors.blueGrey,
                      onTap: () => setState(() => _showHistory = true),
                    ),
                  ),
                ],
              ),
            ),
          ),

        SizedBox(height: SizeTokens.p16),

        // Lessons list
        if (widget.selectedStudentId == null)
          _buildInfoBox(
            icon: Icons.touch_app_rounded,
            text: AppTranslations.translate(
              'select_child_for_lessons',
              widget.locale,
            ),
          )
        else if (widget.isLoading)
          Padding(
            padding: EdgeInsets.symmetric(vertical: SizeTokens.p24),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (currentLessons == null || currentLessons.isEmpty)
          _buildInfoBox(
            icon: Icons.event_busy_rounded,
            text: AppTranslations.translate(
              _showHistory ? 'no_history_lessons' : 'no_upcoming_lessons',
              widget.locale,
            ),
          )
        else
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeTokens.p24),
            child: Column(
              children: currentLessons.map((lesson) {
                return GestureDetector(
                  onTap: () => widget.onLessonTap?.call(lesson),
                  child: _buildLessonCard(context, lesson, primaryColor),
                );
              }).toList(),
            ),
          ),

        SizedBox(height: SizeTokens.p16),
      ],
    );
  }

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: SizeTokens.p10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(SizeTokens.r10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: SizeTokens.i12,
              color: isActive ? color : Colors.grey.shade400,
            ),
            SizedBox(width: SizeTokens.p6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: SizeTokens.f12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? color : Colors.grey.shade500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox({required IconData icon, required String text}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeTokens.p24),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(SizeTokens.p32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeTokens.r24),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.02),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(SizeTokens.p16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: SizeTokens.i32,
                color: Colors.grey.shade300,
              ),
            ),
            SizedBox(height: SizeTokens.p16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SizeTokens.f14,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCard(
    BuildContext context,
    OyunGrubuLessonModel lesson,
    Color primaryColor,
  ) {
    final isCancelled = lesson.isCancelled == true;
    final statusColor = _getLessonStatusColor(lesson.lessonStatus, isCancelled);

    return Container(
      margin: EdgeInsets.only(bottom: SizeTokens.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r20),
        border: Border.all(
          color: isCancelled ? Colors.red.shade100 : Colors.grey.shade100,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SizeTokens.r20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Indicator Strip
              Container(width: 6, color: statusColor),

              // Date Box
              Container(
                width: SizeTokens.p48 + SizeTokens.p12,
                padding: EdgeInsets.symmetric(vertical: SizeTokens.p12),
                // ignore: deprecated_member_use
                color: statusColor.withOpacity(0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getDayFromDate(lesson.date),
                      style: TextStyle(
                        fontSize: SizeTokens.f24,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: SizeTokens.p2),
                    Text(
                      _getMonthAbbr(lesson.date).toUpperCase(),
                      style: TextStyle(
                        fontSize: SizeTokens.f12,
                        fontWeight: FontWeight.w800,
                        color: statusColor.withOpacity(0.7),
                      ),
                    ),
                    if (lesson.dayName != null) ...[
                      SizedBox(height: SizeTokens.p4),
                      Text(
                        lesson.dayName!.length > 3
                            ? lesson.dayName!.substring(0, 3)
                            : lesson.dayName!,
                        style: TextStyle(
                          fontSize: SizeTokens.f10,
                          fontWeight: FontWeight.w500,
                          color: Colors.blueGrey.shade300,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(SizeTokens.p16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        lesson.lessonTitle ?? '-',
                        style: TextStyle(
                          fontSize: SizeTokens.f16,
                          fontWeight: FontWeight.w700,
                          color: isCancelled
                              ? Colors.grey.shade400
                              : Colors.blueGrey.shade900,
                          decoration: isCancelled
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      SizedBox(height: SizeTokens.p8),
                      Row(
                        children: [
                          _buildDetailItem(
                            icon: Icons.access_time_filled_rounded,
                            text:
                                '${_formatTime(lesson.startTime)} - ${_formatTime(lesson.endTime)}',
                            color: Colors.blueGrey.shade400,
                          ),
                          SizedBox(width: SizeTokens.p12),
                          Expanded(
                            child: _buildDetailItem(
                              icon: Icons.groups_2_rounded,
                              text: lesson.groupName ?? '-',
                              color: Colors.blueGrey.shade400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: SizeTokens.p12),
                      Row(
                        children: [
                          _buildStatusBadge(
                            label: _getLessonStatusLabel(
                              lesson.lessonStatus,
                              isCancelled,
                              widget.locale,
                            ),
                            color: statusColor,
                            icon: _getLessonStatusIcon(
                              lesson.lessonStatus,
                              isCancelled,
                            ),
                          ),
                          if (lesson.studentStatus != null &&
                              lesson.studentStatus!.isNotEmpty) ...[
                            SizedBox(width: SizeTokens.p8),
                            _buildStatusBadge(
                              label: _getStudentStatusLabel(
                                lesson.studentStatus,
                                widget.locale,
                              ),
                              color: _getStudentStatusColor(
                                lesson.studentStatus,
                              ),
                              icon: _getStudentStatusIcon(lesson.studentStatus),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: SizeTokens.i14, color: color.withOpacity(0.6)),
        SizedBox(width: SizeTokens.p4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: SizeTokens.f12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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

  Widget _buildStatusBadge({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.p10,
        vertical: SizeTokens.p6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(SizeTokens.r8),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: SizeTokens.i12, color: color),
          SizedBox(width: SizeTokens.p4),
          Text(
            label,
            style: TextStyle(
              fontSize: SizeTokens.f10,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getLessonStatusIcon(String? status, bool isCancelled) {
    if (isCancelled) return Icons.cancel_rounded;
    switch (status) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.schedule_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  IconData _getStudentStatusIcon(String? status) {
    switch (status) {
      case 'pending':
        return Icons.help_outline_rounded;
      case 'attend':
        return Icons.check_circle_outline_rounded;
      case 'not_coming':
        return Icons.highlight_off_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  Color _getLessonStatusColor(String? status, bool isCancelled) {
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

  String _getLessonStatusLabel(
    String? status,
    bool isCancelled,
    String locale,
  ) {
    if (isCancelled) return AppTranslations.translate('cancelled', locale);
    switch (status) {
      case 'completed':
        return AppTranslations.translate('completed', locale);
      case 'pending':
        return AppTranslations.translate('lesson_pending', locale);
      default:
        return status ?? '-';
    }
  }

  Color _getStudentStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange.shade600;
      default:
        return Colors.blue.shade600;
    }
  }

  String _getStudentStatusLabel(String? status, String locale) {
    if (status == 'pending') {
      return AppTranslations.translate('student_pending', locale);
    }
    return AppTranslations.translate(status ?? '', locale);
  }
}
