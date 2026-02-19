import 'package:flutter/material.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../core/utils/app_translations.dart';
import '../../../../models/oyungrubu_lesson_detail_model.dart';

class LessonDetailBottomSheet extends StatelessWidget {
  final OyunGrubuLessonDetailModel detail;
  final String locale;

  const LessonDetailBottomSheet({
    super.key,
    required this.detail,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

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
                  AppTranslations.translate('lesson_detail', locale),
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
            title: detail.title ?? '-',
            date: detail.date ?? '-',
          ),
          SizedBox(height: SizeTokens.p16),

          // Status and Quota Info
          Row(
            children: [
              Expanded(
                child: _buildInfoBox(
                  label: AppTranslations.translate('student_status', locale),
                  value: AppTranslations.translate(
                    detail.studentStatus ?? '-',
                    locale,
                  ),
                  icon: Icons.person_outline_rounded,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: SizeTokens.p12),
              Expanded(
                child: _buildInfoBox(
                  label: AppTranslations.translate('lesson_status', locale),
                  value: AppTranslations.translate(
                    detail.lessonStatus ?? '-',
                    locale,
                  ),
                  icon: Icons.event_available_rounded,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: SizeTokens.p12),
          Row(
            children: [
              Expanded(
                child: _buildInfoBox(
                  label: AppTranslations.translate('total_quota', locale),
                  value: detail.totalQuota?.toString() ?? '0',
                  icon: Icons.groups_outlined,
                  color: Colors.orange,
                ),
              ),
              SizedBox(width: SizeTokens.p12),
              Expanded(
                child: _buildInfoBox(
                  label: AppTranslations.translate('remaining_quota', locale),
                  value: detail.remainingQuota?.toString() ?? '0',
                  icon: Icons.reduce_capacity_rounded,
                  color: (detail.remainingQuota ?? 0) <= 0
                      ? Colors.red
                      : Colors.purple,
                ),
              ),
            ],
          ),

          SizedBox(height: SizeTokens.p32),

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
              child: Text(AppTranslations.translate('done', locale)),
            ),
          ),
        ],
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
