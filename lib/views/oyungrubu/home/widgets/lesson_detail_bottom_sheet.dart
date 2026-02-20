import 'package:flutter/material.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../core/utils/app_translations.dart';
import '../../../../models/oyungrubu_lesson_detail_model.dart';

class LessonDetailBottomSheet extends StatefulWidget {
  final OyunGrubuLessonDetailModel detail;
  final String locale;
  final int studentId;
  final String? startTime;
  final Future<bool> Function({
    required int studentId,
    required String date,
    required String startTime,
    required String status,
    required int lessonId,
    String? note,
  })
  onSubmitAttendance;

  const LessonDetailBottomSheet({
    super.key,
    required this.detail,
    required this.locale,
    required this.studentId,
    this.startTime,
    required this.onSubmitAttendance,
  });

  @override
  State<LessonDetailBottomSheet> createState() =>
      _LessonDetailBottomSheetState();
}

class _LessonDetailBottomSheetState extends State<LessonDetailBottomSheet> {
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;
  bool _showNoteField = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitAttendance(String status) async {
    final locale = widget.locale;
    final confirmKey = status == 'attend'
        ? 'attend_confirmation'
        : 'not_coming_confirmation';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeTokens.r16),
        ),
        title: Text(
          AppTranslations.translate(
            status == 'attend' ? 'will_attend' : 'will_not_attend',
            locale,
          ),
          style: TextStyle(
            fontSize: SizeTokens.f20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          AppTranslations.translate(confirmKey, locale),
          style: TextStyle(fontSize: SizeTokens.f14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppTranslations.translate('cancel', locale)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'attend'
                  ? Colors.green
                  : Colors.red.shade400,
            ),
            child: Text(
              AppTranslations.translate(
                status == 'attend' ? 'will_attend' : 'will_not_attend',
                locale,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSubmitting = true);

    final success = await widget.onSubmitAttendance(
      studentId: widget.studentId,
      date: widget.detail.date ?? '',
      startTime: widget.startTime ?? '',
      status: status,
      lessonId: widget.detail.id ?? 0,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppTranslations.translate('attendance_submitted', locale),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isPending = widget.detail.studentStatus == 'pending';

    return Container(
      padding: EdgeInsets.fromLTRB(
        SizeTokens.p24,
        SizeTokens.p8,
        SizeTokens.p24,
        MediaQuery.of(context).viewInsets.bottom + SizeTokens.p24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(SizeTokens.r24),
          topRight: Radius.circular(SizeTokens.r24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: SizeTokens.p40,
                height: SizeTokens.p4,
                margin: EdgeInsets.only(bottom: SizeTokens.p16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(SizeTokens.r4),
                ),
              ),
            ),

            // Title
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(SizeTokens.p10),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: primaryColor,
                    size: SizeTokens.i20,
                  ),
                ),
                SizedBox(width: SizeTokens.p12),
                Expanded(
                  child: Text(
                    AppTranslations.translate('lesson_detail', widget.locale),
                    style: TextStyle(
                      fontSize: SizeTokens.f20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade900,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeTokens.p24),

            // Content
            _buildDetailCard(
              context,
              title: widget.detail.title ?? '-',
              date: widget.detail.date ?? '-',
            ),
            SizedBox(height: SizeTokens.p16),

            // Status and Quota Info
            Row(
              children: [
                Expanded(
                  child: _buildInfoBox(
                    label: AppTranslations.translate(
                      'student_status',
                      widget.locale,
                    ),
                    value: AppTranslations.translate(
                      widget.detail.studentStatus == 'pending'
                          ? 'student_pending'
                          : (widget.detail.studentStatus ?? '-'),
                      widget.locale,
                    ),
                    icon: Icons.person_outline_rounded,
                    color: widget.detail.studentStatus == 'pending'
                        ? Colors.orange
                        : Colors.blue,
                  ),
                ),
                SizedBox(width: SizeTokens.p12),
                Expanded(
                  child: _buildInfoBox(
                    label: AppTranslations.translate(
                      'lesson_status',
                      widget.locale,
                    ),
                    value: AppTranslations.translate(
                      widget.detail.lessonStatus == 'pending'
                          ? 'lesson_pending'
                          : (widget.detail.lessonStatus ?? '-'),
                      widget.locale,
                    ),
                    icon: Icons.event_available_rounded,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            // Attendance Actions (only when student_status is pending)
            if (isPending) ...[
              SizedBox(height: SizeTokens.p24),
              _buildAttendanceSection(primaryColor),
            ],

            SizedBox(height: SizeTokens.p24),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: Colors.blueGrey.shade700,
                  elevation: 0,
                ),
                child: Text(AppTranslations.translate('done', widget.locale)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceSection(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Note field toggle & field
        if (_showNoteField) ...[
          Container(
            padding: EdgeInsets.all(SizeTokens.p12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(SizeTokens.r12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: AppTranslations.translate(
                  'attendance_note',
                  widget.locale,
                ),
                hintStyle: TextStyle(
                  fontSize: SizeTokens.f12,
                  color: Colors.grey.shade400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontSize: SizeTokens.f14,
                color: Colors.blueGrey.shade800,
              ),
            ),
          ),
          SizedBox(height: SizeTokens.p12),
        ],

        // Attend buttons
        if (_isSubmitting)
          const Center(child: CircularProgressIndicator())
        else
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: AppTranslations.translate(
                    'will_attend',
                    widget.locale,
                  ),
                  icon: Icons.check_circle_outline_rounded,
                  color: Colors.green,
                  onTap: () => _submitAttendance('attend'),
                ),
              ),
              SizedBox(width: SizeTokens.p12),
              Expanded(
                child: _buildActionButton(
                  label: AppTranslations.translate(
                    'will_not_attend',
                    widget.locale,
                  ),
                  icon: Icons.cancel_outlined,
                  color: Colors.red,
                  onTap: () {
                    if (!_showNoteField) {
                      setState(() => _showNoteField = true);
                    } else {
                      _submitAttendance('not_coming');
                    }
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.p12,
          vertical: SizeTokens.p14,
        ),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(SizeTokens.r12),
          border: Border.all(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: SizeTokens.i18, color: color),
            SizedBox(width: SizeTokens.p6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: SizeTokens.f12,
                  fontWeight: FontWeight.w700,
                  color: color,
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

  Widget _buildDetailCard(
    BuildContext context, {
    required String title,
    required String date,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeTokens.p16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(SizeTokens.r16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: SizeTokens.f16,
              fontWeight: FontWeight.w700,
              color: Colors.blueGrey.shade900,
            ),
          ),
          SizedBox(height: SizeTokens.p8),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: SizeTokens.i14,
                color: Colors.grey.shade500,
              ),
              SizedBox(width: SizeTokens.p6),
              Text(
                date,
                style: TextStyle(
                  fontSize: SizeTokens.f14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(SizeTokens.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: SizeTokens.i14, color: color),
              SizedBox(width: SizeTokens.p6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: SizeTokens.f10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: SizeTokens.p6),
          Text(
            value,
            style: TextStyle(
              fontSize: SizeTokens.f14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
