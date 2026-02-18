import 'package:flutter/material.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../core/utils/app_translations.dart';
import '../../../../models/oyungrubu_package_model.dart';

class StudentHistoryPackageCard extends StatelessWidget {
  final OyunGrubuPackageModel package;
  final String locale;
  final bool isActive;

  const StudentHistoryPackageCard({
    super.key,
    required this.package,
    required this.locale,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isActive
        ? const Color(0xFF4CAF50)
        : const Color(0xFF9E9E9E);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: EdgeInsets.only(bottom: SizeTokens.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r16),
        border: Border.all(
          // ignore: deprecated_member_use
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with group name & status
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeTokens.p16,
              vertical: SizeTokens.p12,
            ),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: statusColor.withOpacity(0.06),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(SizeTokens.r16),
                topRight: Radius.circular(SizeTokens.r16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(SizeTokens.p8),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(SizeTokens.r10),
                  ),
                  child: Icon(
                    Icons.inventory_2_rounded,
                    color: primaryColor,
                    size: SizeTokens.i20,
                  ),
                ),
                SizedBox(width: SizeTokens.p12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.groupName ??
                            AppTranslations.translate('no_group', locale),
                        style: TextStyle(
                          fontSize: SizeTokens.f16,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: SizeTokens.p2),
                      Text(
                        'ID: ${package.id ?? '-'}',
                        style: TextStyle(
                          fontSize: SizeTokens.f10,
                          color: Colors.grey.shade500,
                        ),
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
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(SizeTokens.r20),
                  ),
                  child: Text(
                    AppTranslations.translate(
                      isActive ? 'active' : 'expired',
                      locale,
                    ),
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

          // Details
          Padding(
            padding: EdgeInsets.all(SizeTokens.p16),
            child: Column(
              children: [
                // Lesson count & postponement
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.school_outlined,
                        label: AppTranslations.translate(
                            'lesson_count', locale),
                        value: '${package.lessonCount ?? 0}',
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(width: SizeTokens.p12),
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.schedule_outlined,
                        label: AppTranslations.translate(
                            'postponement_limit', locale),
                        value: '${package.postponementLimit ?? 0}',
                        color: const Color(0xFFFF9800),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SizeTokens.p12),

                // Date range
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(SizeTokens.p12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(SizeTokens.r12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range_rounded,
                        size: SizeTokens.i16,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: SizeTokens.p8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppTranslations.translate(
                                  'date_range', locale),
                              style: TextStyle(
                                fontSize: SizeTokens.f10,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: SizeTokens.p2),
                            Text(
                              '${package.startDate ?? '-'}  →  ${package.endDate ?? '-'}',
                              style: TextStyle(
                                fontSize: SizeTokens.f12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
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
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(SizeTokens.p12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(SizeTokens.r12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SizeTokens.p6),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: SizeTokens.i16, color: color),
          ),
          SizedBox(width: SizeTokens.p8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: SizeTokens.f10,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: SizeTokens.p2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: SizeTokens.f16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
