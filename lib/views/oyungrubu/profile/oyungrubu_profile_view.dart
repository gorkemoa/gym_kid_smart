import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../viewmodels/oyungrubu_profile_view_model.dart';
import '../../../viewmodels/splash_view_model.dart';
import '../../../core/utils/app_translations.dart';
import '../student_history/widgets/student_edit_bottom_sheet.dart';
import '../../../viewmodels/oyungrubu_student_history_view_model.dart';

class OyunGrubuProfileView extends StatefulWidget {
  const OyunGrubuProfileView({super.key});

  @override
  State<OyunGrubuProfileView> createState() => _OyunGrubuProfileViewState();
}

class _OyunGrubuProfileViewState extends State<OyunGrubuProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OyunGrubuProfileViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<OyunGrubuProfileViewModel, SplashViewModel>(
      builder: (context, viewModel, splashVM, child) {
        final locale = splashVM.locale.languageCode;
        final primaryColor = Theme.of(context).colorScheme.primary;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            body: Column(
              children: [
                // Gradient header
                _buildHeader(context, viewModel, locale, primaryColor),

                // Content
                Expanded(
                  child: _buildBody(context, viewModel, locale, primaryColor),
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
    OyunGrubuProfileViewModel viewModel,
    String locale,
    Color primaryColor,
  ) {
    final profile = viewModel.data;
    final topPadding = MediaQuery.of(context).padding.top;

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
          topPadding + SizeTokens.p8,
          SizeTokens.p16,
          SizeTokens.p24,
        ),
        child: Column(
          children: [
            // Navigation bar
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
                    AppTranslations.translate('profile_title', locale),
                    style: TextStyle(
                      fontSize: SizeTokens.f20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (profile != null)
                  GestureDetector(
                    onTap: () =>
                        _showEditProfileForm(context, viewModel, locale),
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

            // Profile info row
            if (profile != null)
              Row(
                children: [
                  GestureDetector(
                    onTap: () => viewModel.updateImage(type: 'parent'),
                    child: Stack(
                      children: [
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
                            backgroundImage:
                                profile.image != "dummy" &&
                                    profile.image != null
                                ? NetworkImage(profile.image!)
                                : null,
                            child:
                                profile.image == "dummy" ||
                                    profile.image == null
                                ? Icon(
                                    Icons.person_rounded,
                                    color: Colors.white,
                                    size: SizeTokens.i32,
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(SizeTokens.p4),
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
                              Icons.camera_alt_rounded,
                              size: SizeTokens.i12,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: SizeTokens.p16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${profile.name ?? ''} ${profile.surname ?? ''}',
                          style: TextStyle(
                            fontSize: SizeTokens.f20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: SizeTokens.p6),
                        if (profile.email != null && profile.email!.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: SizeTokens.i12,
                                // ignore: deprecated_member_use
                                color: Colors.white.withOpacity(0.8),
                              ),
                              SizedBox(width: SizeTokens.p6),
                              Expanded(
                                child: Text(
                                  profile.email!,
                                  style: TextStyle(
                                    fontSize: SizeTokens.f12,
                                    // ignore: deprecated_member_use
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        if (profile.phone != null)
                          Padding(
                            padding: EdgeInsets.only(top: SizeTokens.p4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.phone_outlined,
                                  size: SizeTokens.i12,
                                  // ignore: deprecated_member_use
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                SizedBox(width: SizeTokens.p6),
                                Text(
                                  profile.phone.toString(),
                                  style: TextStyle(
                                    fontSize: SizeTokens.f12,
                                    // ignore: deprecated_member_use
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
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
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    OyunGrubuProfileViewModel viewModel,
    String locale,
    Color primaryColor,
  ) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(SizeTokens.p32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: SizeTokens.i64,
                color: Colors.red.shade300,
              ),
              SizedBox(height: SizeTokens.p16),
              Text(
                AppTranslations.translate(viewModel.errorMessage!, locale),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeTokens.f16,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: SizeTokens.p24),
              ElevatedButton.icon(
                onPressed: viewModel.onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(AppTranslations.translate('retry', locale)),
              ),
            ],
          ),
        ),
      );
    }

    final profile = viewModel.data;
    if (profile == null) return const SizedBox.shrink();

    final students = profile.students;
    if (students == null || students.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(SizeTokens.p32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.child_care_rounded,
                size: SizeTokens.i64,
                color: Colors.grey.shade300,
              ),
              SizedBox(height: SizeTokens.p16),
              Text(
                AppTranslations.translate('no_students_registered', locale),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeTokens.f16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        SizeTokens.p24,
        SizeTokens.p16,
        SizeTokens.p24,
        SizeTokens.p24,
      ),
      itemCount: students.length + 1, // +1 for section header
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: SizeTokens.p12),
            child: Row(
              children: [
                Container(
                  width: SizeTokens.r4,
                  height: SizeTokens.h20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF),
                    borderRadius: BorderRadius.circular(SizeTokens.r4),
                  ),
                ),
                SizedBox(width: SizeTokens.p10),
                Text(
                  AppTranslations.translate('students', locale),
                  style: TextStyle(
                    fontSize: SizeTokens.f16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          );
        }

        final student = students[index - 1];
        return _buildStudentCard(student, locale, viewModel, primaryColor);
      },
    );
  }

  Widget _buildStudentCard(
    dynamic student,
    String locale,
    OyunGrubuProfileViewModel viewModel,
    Color primaryColor,
  ) {
    final hasPhoto = student.photo != null;

    return Container(
      margin: EdgeInsets.only(bottom: SizeTokens.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r16),
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
      child: Padding(
        padding: EdgeInsets.all(SizeTokens.p14),
        child: Row(
          children: [
            // Avatar with camera overlay
            GestureDetector(
              onTap: () => viewModel.updateImage(
                type: 'student',
                studentId: student.id?.toString(),
              ),
              child: Stack(
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
                      backgroundImage: hasPhoto
                          ? NetworkImage(student.photo)
                          : null,
                      child: !hasPhoto
                          ? Icon(
                              Icons.child_care_rounded,
                              // ignore: deprecated_member_use
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
                        Icons.camera_alt_rounded,
                        size: SizeTokens.i10,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: SizeTokens.p12),

            // Info
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
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: SizeTokens.p4),
                  if ((student.allergies != null &&
                          student.allergies.isNotEmpty) ||
                      (student.medications != null &&
                          student.medications.isNotEmpty))
                    Wrap(
                      spacing: SizeTokens.p6,
                      runSpacing: SizeTokens.p4,
                      children: [
                        if (student.allergies != null &&
                            student.allergies.isNotEmpty)
                          _buildBadge(
                            Icons.warning_amber_rounded,
                            '${AppTranslations.translate('allergy', locale)}: ${student.allergies}',
                            Colors.red.shade600,
                          ),
                        if (student.medications != null &&
                            student.medications.isNotEmpty)
                          _buildBadge(
                            Icons.medication_outlined,
                            '${AppTranslations.translate('medicament', locale)}: ${student.medications}',
                            Colors.orange.shade800,
                          ),
                      ],
                    ),
                ],
              ),
            ),

            // Edit button
            GestureDetector(
              onTap: () async {
                context.read<OyunGrubuStudentHistoryViewModel>().init(student);
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => StudentEditBottomSheet(locale: locale),
                );
                if (context.mounted) {
                  // ignore: use_build_context_synchronously
                  context.read<OyunGrubuProfileViewModel>().fetchProfile(
                    isSilent: true,
                  );
                }
              },
              child: Container(
                padding: EdgeInsets.all(SizeTokens.p8),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(SizeTokens.r10),
                ),
                child: Icon(
                  Icons.edit_note_rounded,
                  color: primaryColor,
                  size: SizeTokens.i18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.p8,
        vertical: SizeTokens.p4,
      ),
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

  void _showEditProfileForm(
    BuildContext context,
    OyunGrubuProfileViewModel viewModel,
    String locale,
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(SizeTokens.r24),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: SizeTokens.p24,
          right: SizeTokens.p24,
          top: SizeTokens.p24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: SizeTokens.h48,
                height: SizeTokens.p4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(SizeTokens.r4),
                ),
              ),
            ),
            SizedBox(height: SizeTokens.p24),

            Text(
              AppTranslations.translate('update_profile', locale),
              style: TextStyle(
                fontSize: SizeTokens.f20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: SizeTokens.p24),

            TextField(
              controller: viewModel.nameController,
              decoration: InputDecoration(
                labelText: AppTranslations.translate('name', locale),
                prefixIcon: const Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SizeTokens.r12),
                ),
              ),
            ),
            SizedBox(height: SizeTokens.p16),
            TextField(
              controller: viewModel.surnameController,
              decoration: InputDecoration(
                labelText: AppTranslations.translate('surname', locale),
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SizeTokens.r12),
                ),
              ),
            ),
            SizedBox(height: SizeTokens.p16),
            TextField(
              controller: viewModel.phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: AppTranslations.translate('phone', locale),
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SizeTokens.r12),
                ),
              ),
            ),
            SizedBox(height: SizeTokens.p32),

            SizedBox(
              width: double.infinity,
              height: SizeTokens.h52,
              child: ElevatedButton(
                onPressed: viewModel.isUpdating
                    ? null
                    : () async {
                        final success = await viewModel.updateProfile();
                        if (success && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppTranslations.translate(
                                  'profile_updated_success',
                                  locale,
                                ),
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  SizeTokens.r12,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeTokens.r12),
                  ),
                  elevation: 0,
                ),
                child: viewModel.isUpdating
                    ? SizedBox(
                        height: SizeTokens.h20,
                        width: SizeTokens.h20,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        AppTranslations.translate('save', locale),
                        style: TextStyle(
                          fontSize: SizeTokens.f16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            SizedBox(height: SizeTokens.p32),
          ],
        ),
      ),
    );
  }
}
