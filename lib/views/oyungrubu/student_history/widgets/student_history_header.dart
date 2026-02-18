import 'package:flutter/material.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../core/utils/app_translations.dart';
import '../../../../models/oyungrubu_student_model.dart';

class StudentHistoryHeader extends StatelessWidget {
  final OyunGrubuStudentModel student;
  final String locale;
  final VoidCallback onBackTap;
  final VoidCallback? onEditTap;

  const StudentHistoryHeader({
    super.key,
    required this.student,
    required this.locale,
    required this.onBackTap,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final fullName = '${student.name ?? ''} ${student.surname ?? ''}'.trim();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            // ignore: deprecated_member_use
            primaryColor.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(SizeTokens.r32),
          bottomRight: Radius.circular(SizeTokens.r32),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          SizeTokens.p16,
          SizeTokens.p8,
          SizeTokens.p16,
          SizeTokens.p24,
        ),
        child: Column(
          children: [
            // Top row with back button
            Row(
              children: [
                GestureDetector(
                  onTap: onBackTap,
                  child: Container(
                    padding: EdgeInsets.all(SizeTokens.p8),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(SizeTokens.r12),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: SizeTokens.i20,
                    ),
                  ),
                ),
                SizedBox(width: SizeTokens.p12),
                Expanded(
                  child: Text(
                    AppTranslations.translate('student_history', locale),
                    style: TextStyle(
                      fontSize: SizeTokens.f20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (onEditTap != null)
                  GestureDetector(
                    onTap: onEditTap,
                    child: Container(
                      padding: EdgeInsets.all(SizeTokens.p8),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(SizeTokens.r12),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: SizeTokens.i20,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: SizeTokens.p20),

            // Student info row
            Row(
              children: [
                // Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.4),
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: SizeTokens.r32,
                    backgroundColor: Colors.white24,
                    backgroundImage: _hasPhoto()
                        ? NetworkImage(student.photo!)
                        : null,
                    child: !_hasPhoto()
                        ? Icon(
                            Icons.child_care_rounded,
                            color: Colors.white,
                            size: SizeTokens.i32,
                          )
                        : null,
                  ),
                ),
                SizedBox(width: SizeTokens.p16),

                // Name & group
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName.isNotEmpty
                            ? fullName
                            : AppTranslations.translate('student', locale),
                        style: TextStyle(
                          fontSize: SizeTokens.f20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: SizeTokens.p8),
                      Row(
                        children: [
                          if (student.groupName != null &&
                              student.groupName!.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: SizeTokens.p10,
                                vertical: SizeTokens.p4,
                              ),
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: Colors.white.withOpacity(0.2),
                                borderRadius:
                                    BorderRadius.circular(SizeTokens.r8),
                              ),
                              child: Text(
                                student.groupName!,
                                style: TextStyle(
                                  fontSize: SizeTokens.f12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (student.status != null) ...[
                            SizedBox(width: SizeTokens.p8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: SizeTokens.p10,
                                vertical: SizeTokens.p4,
                              ),
                              decoration: BoxDecoration(
                                color: student.status == 1
                                    // ignore: deprecated_member_use
                                    ? Colors.greenAccent.withOpacity(0.3)
                                    // ignore: deprecated_member_use
                                    : Colors.orangeAccent.withOpacity(0.3),
                                borderRadius:
                                    BorderRadius.circular(SizeTokens.r8),
                              ),
                              child: Text(
                                student.status == 1
                                    ? AppTranslations.translate('active', locale)
                                    : AppTranslations.translate('expired', locale),
                                style: TextStyle(
                                  fontSize: SizeTokens.f12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Gender icon
                Container(
                  padding: EdgeInsets.all(SizeTokens.p8),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    student.gender == 1
                        ? Icons.boy_rounded
                        : Icons.girl_rounded,
                    color: Colors.white,
                    size: SizeTokens.i20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _hasPhoto() {
    return student.photo != null && student.photo != 'default_student.jpg';
  }
}
