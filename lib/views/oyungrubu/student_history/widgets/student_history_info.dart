import 'package:flutter/material.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../core/utils/app_translations.dart';
import '../../../../models/oyungrubu_student_model.dart';

class StudentHistoryInfo extends StatelessWidget {
  final OyunGrubuStudentModel student;
  final String locale;

  const StudentHistoryInfo({
    super.key,
    required this.student,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeTokens.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  context,
                  icon: Icons.cake_rounded,
                  label: AppTranslations.translate('birth_date', locale),
                  value: student.birthDate ?? '-',
                  color: Colors.pink.shade400,
                ),
              ),
              SizedBox(width: SizeTokens.p12),
              Expanded(
                child: _buildInfoItem(
                  context,
                  icon: student.gender == 1 ? Icons.male_rounded : Icons.female_rounded,
                  label: AppTranslations.translate('gender', locale),
                  value: student.gender == 1
                      ? AppTranslations.translate('male', locale)
                      : AppTranslations.translate('female', locale),
                  color: student.gender == 1 ? Colors.blue.shade400 : Colors.pink.shade300,
                ),
              ),
            ],
          ),
          SizedBox(height: SizeTokens.p12),
          if ((student.allergies?.isNotEmpty ?? false) || (student.medications?.isNotEmpty ?? false))
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(SizeTokens.p16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(SizeTokens.r16),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (student.allergies?.isNotEmpty ?? false)
                    _buildLongInfoRow(
                      icon: Icons.warning_amber_rounded,
                      label: AppTranslations.translate('allergies', locale),
                      value: student.allergies!,
                      color: Colors.orange.shade700,
                    ),
                  if ((student.allergies?.isNotEmpty ?? false) && (student.medications?.isNotEmpty ?? false))
                    Divider(height: SizeTokens.p24, color: Colors.grey.shade100),
                  if (student.medications?.isNotEmpty ?? false)
                    _buildLongInfoRow(
                      icon: Icons.medical_services_outlined,
                      label: AppTranslations.translate('medications', locale),
                      value: student.medications!,
                      color: Colors.red.shade400,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(SizeTokens.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
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
                    fontSize: SizeTokens.f14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLongInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: SizeTokens.i20),
        SizedBox(width: SizeTokens.p12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: SizeTokens.f12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: SizeTokens.p4),
              Text(
                value,
                style: TextStyle(
                  fontSize: SizeTokens.f14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
