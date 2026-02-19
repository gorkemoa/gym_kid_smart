import 'package:flutter/material.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../core/utils/app_translations.dart';

class OyunGrubuQuickStats extends StatelessWidget {
  final int studentCount;
  final int classCount;
  final String locale;

  const OyunGrubuQuickStats({
    super.key,
    required this.studentCount,
    required this.classCount,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: SizeTokens.p24),
      padding: EdgeInsets.all(SizeTokens.p16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context,
              icon: Icons.child_care_rounded,
              value: studentCount.toString(),
              label: AppTranslations.translate('total_students', locale),
              color: Colors.orange.shade400,
            ),
          ),
          Container(
            height: SizeTokens.h32,
            width: 1,
            color: Colors.grey.shade100,
          ),
          Expanded(
            child: _buildStatItem(
              context,
              icon: Icons.groups_rounded,
              value: classCount.toString(),
              label: AppTranslations.translate('groups', locale),
              color: const Color(0xFF6C63FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(SizeTokens.p8),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(SizeTokens.r12),
          ),
          child: Icon(icon, color: color, size: SizeTokens.i20),
        ),
        SizedBox(width: SizeTokens.p12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: SizeTokens.f18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade900,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: SizeTokens.f12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
