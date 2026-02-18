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
      margin: EdgeInsets.only(bottom: SizeTokens.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r20),
        border: Border.all(color: Colors.grey.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(SizeTokens.p16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar with Gender integrated
                _buildAvatarStack(primaryColor),
                SizedBox(width: SizeTokens.p16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${student.name ?? ''} ${student.surname ?? ''}',
                        style: TextStyle(
                          fontSize: SizeTokens.f16,
                          fontWeight: FontWeight.w700,
                          color: Colors.blueGrey.shade900,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: SizeTokens.p4),
                      _buildInfoRow(),
                      if ((student.allergies != null && student.allergies!.isNotEmpty) ||
                          (student.medications != null && student.medications!.isNotEmpty))
                        Padding(
                          padding: EdgeInsets.only(top: SizeTokens.p8),
                          child: Wrap(
                            spacing: SizeTokens.p8,
                            runSpacing: SizeTokens.p6,
                            children: [
                              if (student.allergies != null && student.allergies!.isNotEmpty)
                                _buildStatusBadge(
                                  icon: Icons.warning_amber_rounded,
                                  text: '${AppTranslations.translate('allergy', locale)}: ${student.allergies}',
                                  color: Colors.red.shade600,
                                ),
                              if (student.medications != null && student.medications!.isNotEmpty)
                                _buildStatusBadge(
                                  icon: Icons.medication_outlined,
                                  text: '${AppTranslations.translate('medicament', locale)}: ${student.medications}',
                                  color: Colors.orange.shade800,
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
          if (onEdit != null)
            Positioned(
              top: SizeTokens.p8,
              right: SizeTokens.p8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(SizeTokens.r100),
                  child: Container(
                    padding: EdgeInsets.all(SizeTokens.p8),
                    child: Icon(
                      Icons.edit_note_rounded,
                      color: Colors.grey.shade400,
                      size: SizeTokens.i20,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarStack(Color primaryColor) {
    final hasPhoto = student.photo != null && student.photo != 'default_student.jpg';
    final isBoy = student.gender == 1;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              // ignore: deprecated_member_use
              color: primaryColor.withOpacity(0.1),
              width: 3,
            ),
          ),
          child: CircleAvatar(
            radius: SizeTokens.r24,
            backgroundColor: Colors.grey.shade50,
            backgroundImage: hasPhoto ? NetworkImage(student.photo!) : null,
            child: !hasPhoto
                ? Icon(
                    Icons.child_care_rounded,
                    color: primaryColor.withOpacity(0.5),
                    size: SizeTokens.i24,
                  )
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(SizeTokens.p2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Icon(
              isBoy ? Icons.boy_rounded : Icons.girl_rounded,
              color: isBoy ? Colors.blue.shade400 : Colors.pink.shade300,
              size: SizeTokens.i12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow() {
    final hasGroup = student.groupName != null && student.groupName!.isNotEmpty;
    return Row(
      children: [
        Icon(Icons.groups_rounded, size: SizeTokens.i12, color: Colors.grey.shade400),
        SizedBox(width: SizeTokens.p4),
        Text(
          hasGroup ? student.groupName! : AppTranslations.translate('no_group', locale),
          style: TextStyle(
            fontSize: SizeTokens.f12,
            color: hasGroup ? Colors.blueGrey.shade600 : Colors.grey.shade400,
            fontWeight: hasGroup ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        if (student.birthDate != null) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeTokens.p6),
            child: Text('•', style: TextStyle(color: Colors.grey.shade300)),
          ),
          Icon(Icons.cake_rounded, size: SizeTokens.i10, color: Colors.grey.shade400),
          SizedBox(width: SizeTokens.p4),
          Text(
            student.birthDate!,
            style: TextStyle(
              fontSize: SizeTokens.f12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusBadge({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: SizeTokens.p8, vertical: SizeTokens.p4),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(SizeTokens.r8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: SizeTokens.i10, color: color),
          SizedBox(width: SizeTokens.p4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: SizeTokens.f10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }


  // Old helper methods can be removed if they are not used anymore.
  // _buildAvatar, _buildBadge are replaced.

}
