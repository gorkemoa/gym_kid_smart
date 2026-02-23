import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../core/utils/app_translations.dart';
import '../../../../models/oyungrubu_package_info_model.dart';
import 'buy_package_webview_view.dart';

class StudentPackageInfoSection extends StatelessWidget {
  final List<OyunGrubuPackageInfoModel> packages;
  final int packageCount;
  final int makeupBalance;
  final String locale;
  final String? userKey;

  const StudentPackageInfoSection({
    super.key,
    required this.packages,
    required this.packageCount,
    required this.makeupBalance,
    required this.locale,
    this.userKey,
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
          ...packages.map(
            (pkg) => _buildPackageInfoCard(context, pkg, primaryColor),
          ),

          // Buy new package banner (always visible)
          _buildBuyNewPackageBanner(context, primaryColor),

          SizedBox(height: SizeTokens.p8),
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
    BuildContext context,
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
                // Buy Package Button (per package)
                if (pkg.packageId != null)
                  _buildBuyButton(
                    context: context,
                    packageId: pkg.packageId!,
                    packageTitle: pkg.lessonTitle ?? '-',
                    primaryColor: primaryColor,
                    compact: true,
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
                  color: primaryColor,
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

  Widget _buildBuyButton({
    required BuildContext context,
    required int packageId,
    required String packageTitle,
    required Color primaryColor,
    bool compact = false,
  }) {
    return GestureDetector(
      onTap: () => _openBuyPackageWebView(
        context: context,
        packageId: packageId,
        packageTitle: packageTitle,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? SizeTokens.p10 : SizeTokens.p16,
          vertical: compact ? SizeTokens.p6 : SizeTokens.p12,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, primaryColor.withOpacity(0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(SizeTokens.r10),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: primaryColor.withOpacity(0.30),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_rounded,
              size: compact ? SizeTokens.i14 : SizeTokens.i18,
              color: Colors.white,
            ),
            if (!compact) SizedBox(width: SizeTokens.p6),
            if (!compact)
              Text(
                AppTranslations.translate('buy_package', locale),
                style: TextStyle(
                  fontSize: SizeTokens.f13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyNewPackageBanner(BuildContext context, Color primaryColor) {
    return GestureDetector(
      onTap: () => _openBuyPackageWebView(
        context: context,
        packageId: 0,
        packageTitle: AppTranslations.translate('buy_new_package', locale),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: SizeTokens.p16),
        padding: EdgeInsets.all(SizeTokens.p16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor,
              // ignore: deprecated_member_use
              primaryColor.withOpacity(0.80),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(SizeTokens.r16),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: primaryColor.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(SizeTokens.p10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                borderRadius: BorderRadius.circular(SizeTokens.r12),
              ),
              child: Icon(
                Icons.add_shopping_cart_rounded,
                size: SizeTokens.i24,
                color: Colors.white,
              ),
            ),
            SizedBox(width: SizeTokens.p14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppTranslations.translate('buy_new_package', locale),
                    style: TextStyle(
                      fontSize: SizeTokens.f14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: SizeTokens.p2),
                  Text(
                    AppTranslations.translate('buy_new_package_desc', locale),
                    style: TextStyle(
                      fontSize: SizeTokens.f10,
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: SizeTokens.i16,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openBuyPackageWebView({
    required BuildContext context,
    required int packageId,
    required String packageTitle,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? localUserKey = prefs.getString('oyungrubu_user_key');

    // Fallback if not saved separately but exists in user_data
    if (localUserKey == null || localUserKey.isEmpty) {
      final userDataStr = prefs.getString('oyungrubu_user_data');
      if (userDataStr != null) {
        try {
          final Map<String, dynamic> data = jsonDecode(userDataStr);
          localUserKey = data['user_key']?.toString();
        } catch (_) {}
      }
    }

    if (!context.mounted) return;

    if (localUserKey == null || localUserKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslations.translate('no_credentials', locale)),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BuyPackageWebViewView(
          userKey: localUserKey!,
          packageId: packageId,
          packageTitle: packageTitle,
          locale: locale,
        ),
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
