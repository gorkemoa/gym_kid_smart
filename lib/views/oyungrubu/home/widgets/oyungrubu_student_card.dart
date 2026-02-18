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
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: EdgeInsets.only(bottom: SizeTokens.p16),
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
      child: Padding(
        padding: EdgeInsets.all(SizeTokens.p16),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(primaryColor),
            SizedBox(width: SizeTokens.p16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${student.name ?? ''} ${student.surname ?? ''}',
                    style: TextStyle(
                      fontSize: SizeTokens.f16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: SizeTokens.p6),
                  // Group badge
                  if (student.groupName != null && student.groupName!.isNotEmpty)
                    _buildBadge(
                      icon: Icons.groups_outlined,
                      text: student.groupName!,
                      // ignore: deprecated_member_use
                      bgColor: primaryColor.withOpacity(0.08),
                      textColor: primaryColor,
                    ),
                  if (student.groupName == null || student.groupName!.isEmpty)
                    _buildBadge(
                      icon: Icons.groups_outlined,
                      text: AppTranslations.translate('no_group', locale),
                      // ignore: deprecated_member_use
                      bgColor: Colors.grey.withOpacity(0.08),
                      textColor: Colors.grey.shade600,
                    ),
                  SizedBox(height: SizeTokens.p6),
                  // Birth date
                  if (student.birthDate != null)
                    Row(
                      children: [
                        Icon(
                          Icons.cake_outlined,
                          size: SizeTokens.i12,
                          color: Colors.grey.shade500,
                        ),
                        SizedBox(width: SizeTokens.p4),
                        Text(
                          student.birthDate!,
                          style: TextStyle(
                            fontSize: SizeTokens.f12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  // Allergies
                  if (student.allergies != null && student.allergies!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: SizeTokens.p6),
                      child: _buildBadge(
                        icon: Icons.warning_amber_rounded,
                        text: '${AppTranslations.translate('allergy', locale)}: ${student.allergies}',
                        // ignore: deprecated_member_use
                        bgColor: Colors.red.withOpacity(0.08),
                        textColor: Colors.red.shade600,
                      ),
                    ),
                  // Medications
                  if (student.medications != null && student.medications!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: SizeTokens.p6),
                      child: _buildBadge(
                        icon: Icons.medication_outlined,
                        text: '${AppTranslations.translate('medicament', locale)}: ${student.medications}',
                        // ignore: deprecated_member_use
                        bgColor: Colors.orange.withOpacity(0.08),
                        textColor: Colors.orange.shade700,
                      ),
                    ),
                ],
              ),
            ),

            // Gender icon & Edit
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(SizeTokens.p8),
                  decoration: BoxDecoration(
                    color: student.gender == 1
                        // ignore: deprecated_member_use
                        ? Colors.blue.withOpacity(0.08)
                        // ignore: deprecated_member_use
                        : Colors.pink.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    student.gender == 1 ? Icons.boy_rounded : Icons.girl_rounded,
                    color: student.gender == 1 ? Colors.blue : Colors.pink,
                    size: SizeTokens.i20,
                  ),
                ),
                if (onEdit != null) ...[
                  SizedBox(height: SizeTokens.p12),
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: EdgeInsets.all(SizeTokens.p8),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        color: Colors.grey.shade600,
                        size: SizeTokens.i16,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(Color primaryColor) {
    final hasPhoto = student.photo != null && student.photo != 'default_student.jpg';
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          // ignore: deprecated_member_use
          color: primaryColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: SizeTokens.r24,
        backgroundColor: Colors.grey.shade100,
        backgroundImage: hasPhoto ? NetworkImage(student.photo!) : null,
        child: !hasPhoto
            ? Icon(
                Icons.child_care_rounded,
                color: primaryColor,
                size: SizeTokens.i24,
              )
            : null,
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String text,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.p8,
        vertical: SizeTokens.p4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(SizeTokens.r8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: SizeTokens.i12, color: textColor),
          SizedBox(width: SizeTokens.p4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: SizeTokens.f10,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
