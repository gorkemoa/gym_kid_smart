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

    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.p24,
        vertical: SizeTokens.p8,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeTokens.r20),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: primaryColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.fromLTRB(
                SizeTokens.p20,
                SizeTokens.p16,
                SizeTokens.p12,
                SizeTokens.p12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    // ignore: deprecated_member_use
                    primaryColor.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(SizeTokens.r20),
                  topRight: Radius.circular(SizeTokens.r20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    color: Colors.white,
                    size: SizeTokens.i20,
                  ),
                  SizedBox(width: SizeTokens.p10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${selectedClass!.groupName ?? '-'} - ${AppTranslations.translate('lesson_schedule', locale)}',
                          style: TextStyle(
                            fontSize: SizeTokens.f16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      padding: EdgeInsets.all(SizeTokens.p6),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(SizeTokens.r8),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: SizeTokens.i16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            if (isLoading)
              Padding(
                padding: EdgeInsets.all(SizeTokens.p24),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (timetable == null || timetable!.isEmpty)
              Padding(
                padding: EdgeInsets.all(SizeTokens.p24),
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
                padding: EdgeInsets.all(SizeTokens.p16),
                itemCount: timetable!.length,
                separatorBuilder: (_, __) => SizedBox(height: SizeTokens.p10),
                itemBuilder: (context, index) {
                  final item = timetable![index];
                  return _buildTimetableItem(context, item);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimetableItem(
    BuildContext context,
    OyunGrubuTimetableModel item,
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final weekdayKey = 'weekday_${item.weekday ?? 1}';
    final weekdayName = AppTranslations.translate(weekdayKey, locale);
    final timeRange = '${item.startTime ?? '-'} - ${item.endTime ?? '-'}';

    // Remove seconds from time format for cleaner display
    final cleanTimeRange = timeRange
        .replaceAll(':00:00', ':00')
        .replaceAll(RegExp(r':(\d{2}):00'), r':$1');

    final statusColor = _getStatusColor(item.lessonStatus);

    return Container(
      padding: EdgeInsets.all(SizeTokens.p14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(SizeTokens.r12),
        border: Border.all(
          // ignore: deprecated_member_use
          color: primaryColor.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          // Day circle
          Container(
            width: SizeTokens.h48,
            height: SizeTokens.h48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  // ignore: deprecated_member_use
                  primaryColor.withOpacity(0.15),
                  // ignore: deprecated_member_use
                  primaryColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(SizeTokens.r12),
            ),
            child: Center(
              child: Text(
                weekdayName.substring(
                  0,
                  weekdayName.length >= 3 ? 3 : weekdayName.length,
                ),
                style: TextStyle(
                  fontSize: SizeTokens.f12,
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(width: SizeTokens.p12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.lessonTitle ?? '-',
                  style: TextStyle(
                    fontSize: SizeTokens.f14,
                    fontWeight: FontWeight.w700,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
                SizedBox(height: SizeTokens.p4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: SizeTokens.i12,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: SizeTokens.p4),
                    Text(
                      cleanTimeRange,
                      style: TextStyle(
                        fontSize: SizeTokens.f12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeTokens.p10,
              vertical: SizeTokens.p4,
            ),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(SizeTokens.r8),
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
