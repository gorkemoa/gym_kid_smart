import 'package:flutter/material.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../core/utils/app_translations.dart';
import '../../../../models/oyungrubu_package_info_model.dart';

class StudentPackageInfoSection extends StatelessWidget {
  final List<OyunGrubuPackageInfoModel> packages;
  final int packageCount;
  final int makeupBalance;
  final String locale;

  const StudentPackageInfoSection({
    super.key,
    required this.packages,
    required this.packageCount,
    required this.makeupBalance,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeTokens.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: SizeTokens.p8),

          // Summary row: package count + makeup balance
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.inventory_2_rounded,
                  label: AppTranslations.translate('package_count', locale),
                  value: packageCount.toString(),
                  color: primaryColor,
                ),
              ),
              SizedBox(width: SizeTokens.p12),
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.auto_fix_high_rounded,
                  label: AppTranslations.translate('makeup_balance', locale),
                  value: makeupBalance.toString(),
                  color: const Color(0xFF9C27B0),
                ),
              ),
            ],
          ),
          SizedBox(height: SizeTokens.p16),

          // Package cards
          ...packages.map((pkg) => _buildPackageInfoCard(pkg, primaryColor)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(SizeTokens.p14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SizeTokens.p8),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: SizeTokens.i16),
          ),
          SizedBox(width: SizeTokens.p10),
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
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: SizeTokens.f20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageInfoCard(
    OyunGrubuPackageInfoModel pkg,
    Color primaryColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeTokens.p16),
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
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(SizeTokens.p16),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: primaryColor.withOpacity(0.06),
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
                    Icons.school_rounded,
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
                        pkg.lessonTitle ?? '-',
                        style: TextStyle(
                          fontSize: SizeTokens.f16,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: EdgeInsets.all(SizeTokens.p16),
            child: Column(
              children: [
                // Lesson progress
                _buildProgressRow(
                  label: AppTranslations.translate('lesson_usage', locale),
                  used: pkg.usedLessons ?? 0,
                  total: pkg.totalLessons ?? 0,
                  remaining: pkg.remainingLessons ?? 0,
                  remainingLabel: AppTranslations.translate(
                    'remaining_lessons',
                    locale,
                  ),
                  progress: pkg.lessonProgress,
                  color: primaryColor,
                ),
                SizedBox(height: SizeTokens.p16),

                // Postponement progress
                _buildProgressRow(
                  label: AppTranslations.translate(
                    'postponement_usage',
                    locale,
                  ),
                  used: pkg.postponementUsed ?? 0,
                  total: pkg.postponementLimit ?? 0,
                  remaining: pkg.remainingPostponements,
                  remainingLabel: AppTranslations.translate(
                    'remaining_postponements',
                    locale,
                  ),
                  progress: pkg.postponementProgress,
                  color: const Color(0xFFFF9800),
                ),
                SizedBox(height: SizeTokens.p16),

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
                              AppTranslations.translate('date_range', locale),
                              style: TextStyle(
                                fontSize: SizeTokens.f10,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: SizeTokens.p2),
                            Text(
                              '${pkg.startDate ?? '-'}  →  ${pkg.endDate ?? '-'}',
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

  Widget _buildProgressRow({
    required String label,
    required int used,
    required int total,
    required int remaining,
    required String remainingLabel,
    required double progress,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: SizeTokens.f12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              '$used / $total',
              style: TextStyle(
                fontSize: SizeTokens.f12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: SizeTokens.p8),
        ClipRRect(
          borderRadius: BorderRadius.circular(SizeTokens.r8),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: SizeTokens.p8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        SizedBox(height: SizeTokens.p6),
        Text(
          '$remainingLabel: $remaining',
          style: TextStyle(
            fontSize: SizeTokens.f10,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
