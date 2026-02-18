import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/utils/app_translations.dart';
import '../../../models/oyungrubu_student_model.dart';
import '../../../viewmodels/oyungrubu_student_history_view_model.dart';
import '../../../viewmodels/oyungrubu_home_view_model.dart';
import '../../../viewmodels/splash_view_model.dart';
import '../student_history/widgets/student_edit_bottom_sheet.dart';
import 'student_profile_detail_view.dart';
import 'student_package_detail_view.dart';
import 'student_activity_detail_view.dart';

class OyunGrubuStudentDetailView extends StatefulWidget {
  final OyunGrubuStudentModel student;

  const OyunGrubuStudentDetailView({super.key, required this.student});

  @override
  State<OyunGrubuStudentDetailView> createState() =>
      _OyunGrubuStudentDetailViewState();
}

class _OyunGrubuStudentDetailViewState
    extends State<OyunGrubuStudentDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<OyunGrubuStudentHistoryViewModel>()
          .init(widget.student);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<OyunGrubuStudentHistoryViewModel, SplashViewModel>(
      builder: (context, viewModel, splashVM, child) {
        final locale = splashVM.locale.languageCode;
        final primaryColor = Theme.of(context).colorScheme.primary;
        final student = viewModel.student ?? widget.student;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          body: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context, student, locale, primaryColor),

                // Grid Menu
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(SizeTokens.p24),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: SizeTokens.p16,
                      crossAxisSpacing: SizeTokens.p16,
                      childAspectRatio: 1.0,
                      children: [
                        _buildGridItem(
                          context,
                          icon: Icons.person_rounded,
                          label: AppTranslations.translate(
                              'profile_info', locale),
                          description: AppTranslations.translate(
                              'profile_info_desc', locale),
                          color: const Color(0xFF4CAF50),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StudentProfileDetailView(
                                  student: student,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildGridItem(
                          context,
                          icon: Icons.inventory_2_rounded,
                          label: AppTranslations.translate(
                              'package_info', locale),
                          description: AppTranslations.translate(
                              'package_info_desc', locale),
                          color: const Color(0xFF6C63FF),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StudentPackageDetailView(
                                  student: student,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildGridItem(
                          context,
                          icon: Icons.timeline_rounded,
                          label: AppTranslations.translate(
                              'activity_history', locale),
                          description: AppTranslations.translate(
                              'activity_history_desc', locale),
                          color: const Color(0xFFFF9800),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StudentActivityDetailView(
                                  student: student,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildGridItem(
                          context,
                          icon: Icons.edit_rounded,
                          label: AppTranslations.translate(
                              'edit_student', locale),
                          description: AppTranslations.translate(
                              'edit_student_desc', locale),
                          color: const Color(0xFFE91E63),
                          onTap: () async {
                            await _showEditBottomSheet(context, locale);
                            if (context.mounted) {
                              context
                                  .read<OyunGrubuStudentHistoryViewModel>()
                                  .fetchHistory(isSilent: true);
                              context
                                  .read<OyunGrubuHomeViewModel>()
                                  .fetchStudents(isSilent: true);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    OyunGrubuStudentModel student,
    String locale,
    Color primaryColor,
  ) {
    final fullName =
        '${student.name ?? ''} ${student.surname ?? ''}'.trim();

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
                  onTap: () => Navigator.pop(context),
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
                    AppTranslations.translate('student_menu', locale),
                    style: TextStyle(
                      fontSize: SizeTokens.f20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
                    backgroundImage: _hasPhoto(student)
                        ? NetworkImage(student.photo!)
                        : null,
                    child: !_hasPhoto(student)
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
                                    ? AppTranslations.translate(
                                        'active', locale)
                                    : AppTranslations.translate(
                                        'expired', locale),
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeTokens.r20),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.10),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(SizeTokens.p16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(SizeTokens.p14),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SizeTokens.r16),
                ),
                child: Icon(icon, color: color, size: SizeTokens.i32),
              ),
              SizedBox(height: SizeTokens.p12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeTokens.f14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: SizeTokens.p4),
              Text(
                description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: SizeTokens.f10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasPhoto(OyunGrubuStudentModel student) {
    return student.photo != null && student.photo != 'default_student.jpg';
  }

  Future<void> _showEditBottomSheet(
      BuildContext context, String locale) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StudentEditBottomSheet(locale: locale),
    );
  }
}
