import 'package:flutter/material.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../core/utils/app_translations.dart';
import '../../../../models/oyungrubu_activity_log_model.dart';

class StudentHistoryActivityCard extends StatelessWidget {
  final OyunGrubuActivityLogModel log;
  final String locale;

  const StudentHistoryActivityCard({
    super.key,
    required this.log,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final typeInfo = _getTypeInfo();

    return Container(
      margin: EdgeInsets.only(bottom: SizeTokens.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(SizeTokens.p16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type icon
            Container(
              padding: EdgeInsets.all(SizeTokens.p10),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: typeInfo.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(SizeTokens.r12),
              ),
              child: Icon(
                typeInfo.icon,
                color: typeInfo.color,
                size: SizeTokens.i24,
              ),
            ),
            SizedBox(width: SizeTokens.p12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type badge + date row
                  Row(
                    children: [
                      // Type badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeTokens.p8,
                          vertical: SizeTokens.p2,
                        ),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: typeInfo.color.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(SizeTokens.r8),
                        ),
                        child: Text(
                          typeInfo.label,
                          style: TextStyle(
                            fontSize: SizeTokens.f10,
                            fontWeight: FontWeight.w700,
                            color: typeInfo.color,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Date
                      if (log.activityDate != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: SizeTokens.i10,
                              color: Colors.grey.shade500,
                            ),
                            SizedBox(width: SizeTokens.p4),
                            Text(
                              log.activityDate!,
                              style: TextStyle(
                                fontSize: SizeTokens.f10,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: SizeTokens.p8),

                  // Lesson title
                  if (log.lessonTitle != null && log.lessonTitle!.isNotEmpty)
                    Text(
                      log.lessonTitle!,
                      style: TextStyle(
                        fontSize: SizeTokens.f14,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                    ),

                  // Time
                  if (log.startTime != null)
                    Padding(
                      padding: EdgeInsets.only(top: SizeTokens.p4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: SizeTokens.i12,
                            color: Colors.grey.shade500,
                          ),
                          SizedBox(width: SizeTokens.p4),
                          Text(
                            log.startTime!.substring(
                              0,
                              log.startTime!.length >= 5 ? 5 : log.startTime!.length,
                            ),
                            style: TextStyle(
                              fontSize: SizeTokens.f12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Note
                  if (log.note != null && log.note!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: SizeTokens.p8),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(SizeTokens.p10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6FA),
                          borderRadius:
                              BorderRadius.circular(SizeTokens.r8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.notes_rounded,
                              size: SizeTokens.i12,
                              color: Colors.grey.shade500,
                            ),
                            SizedBox(width: SizeTokens.p6),
                            Expanded(
                              child: Text(
                                log.note!,
                                style: TextStyle(
                                  fontSize: SizeTokens.f12,
                                  color: Colors.grey.shade700,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Lesson qty info
                  if (log.lessonQty != null && log.lessonQty! > 0)
                    Padding(
                      padding: EdgeInsets.only(top: SizeTokens.p6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: SizeTokens.i12,
                            color: Colors.grey.shade500,
                          ),
                          SizedBox(width: SizeTokens.p4),
                          Text(
                            '${AppTranslations.translate('lesson_count', locale)}: ${log.lessonQty}',
                            style: TextStyle(
                              fontSize: SizeTokens.f10,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _ActivityTypeInfo _getTypeInfo() {
    switch (log.activityType) {
      case 'attended':
        return _ActivityTypeInfo(
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF4CAF50),
          label: AppTranslations.translate('attended', locale),
        );
      case 'absent':
        return _ActivityTypeInfo(
          icon: Icons.cancel_rounded,
          color: const Color(0xFFF44336),
          label: AppTranslations.translate('absent', locale),
        );
      case 'postpone':
        return _ActivityTypeInfo(
          icon: Icons.schedule_rounded,
          color: const Color(0xFFFF9800),
          label: AppTranslations.translate('postponed', locale),
        );
      default:
        return _ActivityTypeInfo(
          icon: Icons.info_outline_rounded,
          color: Colors.grey,
          label: log.activityType ?? '-',
        );
    }
  }
}

class _ActivityTypeInfo {
  final IconData icon;
  final Color color;
  final String label;

  _ActivityTypeInfo({
    required this.icon,
    required this.color,
    required this.label,
  });
}
