import 'package:flutter/material.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../core/utils/app_translations.dart';
import '../../../../models/oyungrubu_student_model.dart';

class OyunGrubuStudentCard extends StatelessWidget {
  final OyunGrubuStudentModel student;
  final String locale;
  final VoidCallback? onEdit;

  const OyunGrubuStudentCard({
    super.key,
    required this.student,
    required this.locale,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: EdgeInsets.only(bottom: SizeTokens.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(SizeTokens.p16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAvatar(),
            SizedBox(width: SizeTokens.p12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${student.name ?? ''} ${student.surname ?? ''}',
                          style: TextStyle(
                            fontSize: SizeTokens.f16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onEdit != null)
                        GestureDetector(
                          onTap: onEdit,
                          child: Icon(
                            Icons.edit_rounded,
                            size: SizeTokens.i20,
                            color: Colors.grey.shade400,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: SizeTokens.p4),
                  _buildGroupInfo(),

                  // Health Badges
                  if (_hasHealthInfo()) ...[
                    SizedBox(height: SizeTokens.p8),
                    Wrap(
                      spacing: SizeTokens.p8,
                      runSpacing: SizeTokens.p4,
                      children: [
                        if (student.allergies != null &&
                            student.allergies!.isNotEmpty)
                          _buildAlertBadge(
                            '${AppTranslations.translate('allergy', locale)}: ${student.allergies}',
                            Colors.red.shade50,
                            Colors.red.shade700,
                          ),
                        if (student.medications != null &&
                            student.medications!.isNotEmpty)
                          _buildAlertBadge(
                            '${AppTranslations.translate('medicament', locale)}: ${student.medications}',
                            Colors.orange.shade50,
                            Colors.orange.shade800,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final hasPhoto =
        student.photo != null && student.photo != 'default_student.jpg';
    final isBoy = student.gender == 1;

    return Container(
      width: SizeTokens.i48,
      height: SizeTokens.i48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade100,
        image: hasPhoto
            ? DecorationImage(
                image: NetworkImage(student.photo!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: !hasPhoto
          ? Center(
              child: Text(
                (student.name != null && student.name!.isNotEmpty)
                    ? student.name![0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: SizeTokens.f20,
                  fontWeight: FontWeight.bold,
                  color: isBoy ? Colors.blue.shade400 : Colors.pink.shade400,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildGroupInfo() {
    return Row(
      children: [
        Icon(
          Icons.class_outlined,
          size: SizeTokens.i12,
          color: Colors.grey.shade500,
        ),
        SizedBox(width: SizeTokens.p4),
        Text(
          student.groupName ?? AppTranslations.translate('no_group', locale),
          style: TextStyle(
            fontSize: SizeTokens.f14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.p8,
        vertical: SizeTokens.p4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(SizeTokens.r8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: SizeTokens.f12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  bool _hasHealthInfo() {
    return (student.allergies != null && student.allergies!.isNotEmpty) ||
        (student.medications != null && student.medications!.isNotEmpty);
  }
}
