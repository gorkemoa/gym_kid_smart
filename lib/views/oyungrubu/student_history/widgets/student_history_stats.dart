import 'package:flutter/material.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../core/utils/app_translations.dart';

class StudentHistoryStats extends StatelessWidget {
  final int attendedCount;
  final int absentCount;
  final int postponeCount;
  final int? makeupBalance;
  final String locale;

  const StudentHistoryStats({
    super.key,
    required this.attendedCount,
    required this.absentCount,
    required this.postponeCount,
    this.makeupBalance,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        SizeTokens.p16,
        SizeTokens.p16,
        SizeTokens.p16,
        SizeTokens.p8,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.check_circle_outline_rounded,
              value: attendedCount.toString(),
              label: AppTranslations.translate('attended', locale),
              color: const Color(0xFF4CAF50),
            ),
          ),
          SizedBox(width: SizeTokens.p8),
          Expanded(
            child: _buildStatItem(
              icon: Icons.cancel_outlined,
              value: absentCount.toString(),
              label: AppTranslations.translate('absent', locale),
              color: const Color(0xFFF44336),
            ),
          ),
          SizedBox(width: SizeTokens.p8),
          Expanded(
            child: _buildStatItem(
              icon: Icons.schedule_rounded,
              value: postponeCount.toString(),
              label: AppTranslations.translate('postponed', locale),
              color: primaryColor,
            ),
          ),
          if (makeupBalance != null && makeupBalance! > 0) ...[
            SizedBox(width: SizeTokens.p8),
            Expanded(
              child: _buildStatItem(
                icon: Icons.auto_fix_high_rounded,
                value: makeupBalance!.toString(),
                label: AppTranslations.translate('makeup_balance', locale),
                color: const Color(0xFF9C27B0),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: SizeTokens.p14,
        horizontal: SizeTokens.p8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(SizeTokens.p8),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: SizeTokens.i20),
          ),
          SizedBox(height: SizeTokens.p8),
          Text(
            value,
            style: TextStyle(
              fontSize: SizeTokens.f24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: SizeTokens.p4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: SizeTokens.f10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
