import 'package:flutter/material.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../core/utils/app_translations.dart';
import '../../../../models/oyungrubu_timetable_model.dart';
import '../../../../models/oyungrubu_class_model.dart';

class OyunGrubuTimetableSection extends StatelessWidget {
  final OyunGrubuClassModel? selectedClass;
  final List<OyunGrubuTimetableModel>? timetable;
  final bool isLoading;
  final String locale;
  final VoidCallback onClose;

  const OyunGrubuTimetableSection({
    super.key,
    required this.selectedClass,
    required this.timetable,
    required this.isLoading,
    required this.locale,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedClass == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.p24,
        vertical: SizeTokens.p8,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeTokens.r16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cleaner Header
            Padding(
              padding: EdgeInsets.fromLTRB(
                SizeTokens.p20,
                SizeTokens.p20,
                SizeTokens.p20,
                SizeTokens.p10,
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(SizeTokens.p10),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(SizeTokens.r12),
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: const Color(0xFF6C63FF),
                      size: SizeTokens.i20,
                    ),
                  ),
                  SizedBox(width: SizeTokens.p12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppTranslations.translate('lesson_schedule', locale),
                          style: TextStyle(
                            fontSize: SizeTokens.f16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade900,
                          ),
                        ),
                        Text(
                          selectedClass!.groupName ?? '-',
                          style: TextStyle(
                            fontSize: SizeTokens.f12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: onClose,
                    borderRadius: BorderRadius.circular(SizeTokens.r100),
                    child: Container(
                      padding: EdgeInsets.all(SizeTokens.p8),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.grey.shade400,
                        size: SizeTokens.i20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey.shade100, height: 1),

            // Content
            if (isLoading)
              Padding(
                padding: EdgeInsets.all(SizeTokens.p32),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (timetable == null || timetable!.isEmpty)
              Padding(
                padding: EdgeInsets.all(SizeTokens.p32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy_rounded,
                        size: SizeTokens.i32,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: SizeTokens.p8),
                      Text(
                        AppTranslations.translate(
                          'no_timetable_available',
                          locale,
                        ),
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
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: SizeTokens.p20,
                  vertical: SizeTokens.p12,
                ),
                itemCount: timetable!.length,
                separatorBuilder: (_, __) => Padding(
                  padding: EdgeInsets.symmetric(vertical: SizeTokens.p8),
                  child: Divider(color: Colors.grey.shade50, height: 1),
                ),
                itemBuilder: (context, index) {
                  final item = timetable![index];
                  return _buildTimetableItem(context, item);
                },
              ),
            SizedBox(height: SizeTokens.p12),
          ],
        ),
      ),
    );
  }

  Widget _buildTimetableItem(
    BuildContext context,
    OyunGrubuTimetableModel item,
  ) {
    // ignore: unused_local_variable
    // final primaryColor = Theme.of(context).colorScheme.primary;
    final weekdayKey = 'weekday_${item.weekday ?? 1}';
    final weekdayName = AppTranslations.translate(weekdayKey, locale);
    final timeRange = '${item.startTime ?? '-'} - ${item.endTime ?? '-'}';

    final cleanTimeRange = timeRange
        .replaceAll(':00:00', ':00')
        .replaceAll(RegExp(r':(\d{2}):00'), r':$1');

    final statusColor = _getStatusColor(item.lessonStatus);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time & Day Column
        SizedBox(
          width: SizeTokens.w100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weekdayName,
                style: TextStyle(
                  fontSize: SizeTokens.f14,
                  fontWeight: FontWeight.w700,
                  color: Colors.blueGrey.shade800,
                ),
              ),
              SizedBox(height: SizeTokens.p2),
              Text(
                cleanTimeRange,
                style: TextStyle(
                  fontSize: SizeTokens.f12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Vertical Line
        Container(
          width: 2,
          height: SizeTokens.h32, // Minimal height to connect
          margin: EdgeInsets.symmetric(horizontal: SizeTokens.p12),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(SizeTokens.r4),
          ),
        ),

        // Lesson Detail
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.lessonTitle ?? '-',
                style: TextStyle(
                  fontSize: SizeTokens.f14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade900,
                ),
              ),
              SizedBox(height: SizeTokens.p4),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeTokens.p8,
                  vertical: SizeTokens.p2,
                ),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SizeTokens.r4),
                ),
                child: Text(
                  _getStatusLabel(item.lessonStatus, locale),
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
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return Colors.green.shade600;
      case 'pending':
        return Colors.orange.shade600;
      default:
        return Colors.grey.shade500;
    }
  }

  String _getStatusLabel(String? status, String locale) {
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
