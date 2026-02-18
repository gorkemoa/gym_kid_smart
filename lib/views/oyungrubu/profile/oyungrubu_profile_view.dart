import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../viewmodels/oyungrubu_profile_view_model.dart';
import '../../../viewmodels/splash_view_model.dart';
import '../../../core/utils/app_translations.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Consumer<SplashViewModel>(
          builder: (context, splashVM, _) => Text(
            AppTranslations.translate('profile_title', splashVM.locale.languageCode),
          ),
        ),
      ),
      body: Consumer2<OyunGrubuProfileViewModel, SplashViewModel>(
        builder: (context, viewModel, splashVM, child) {
          final locale = splashVM.locale.languageCode;

          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppTranslations.translate(viewModel.errorMessage!, locale)),
                  SizedBox(height: SizeTokens.p16),
                  ElevatedButton(
                    onPressed: viewModel.onRetry,
                    child: Text(AppTranslations.translate('retry', locale)),
                  ),
                ],
              ),
            );
          }

          final profile = viewModel.data;
          if (profile == null) return const SizedBox.shrink();

          return SingleChildScrollView(
            padding: EdgeInsets.all(SizeTokens.p24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(profile, viewModel, locale),
                SizedBox(height: SizeTokens.p32),
                Text(
                  AppTranslations.translate('students', locale),
                  style: TextStyle(
                    fontSize: SizeTokens.f20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: SizeTokens.p16),
                ...?profile.students?.map((student) => _buildStudentCard(student, locale, viewModel)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(dynamic profile, OyunGrubuProfileViewModel viewModel, String locale) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => viewModel.updateImage(type: 'parent'),
          child: Stack(
            children: [
              CircleAvatar(
                radius: SizeTokens.r32,
                backgroundImage: profile.image != "dummy" && profile.image != null
                    ? NetworkImage(profile.image)
                    : null,
                child: profile.image == "dummy" || profile.image == null
                    ? Icon(Icons.person, size: SizeTokens.i32)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(SizeTokens.p4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt, size: SizeTokens.i12, color: Colors.grey),
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
                '${profile.name} ${profile.surname}',
                style: TextStyle(
                  fontSize: SizeTokens.f20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                profile.email ?? '',
                style: TextStyle(
                  fontSize: SizeTokens.f14,
                  color: Colors.grey,
                ),
              ),
              if (profile.phone != null)
                Text(
                  profile.phone.toString(),
                  style: TextStyle(
                    fontSize: SizeTokens.f14,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => _showEditProfileForm(context, viewModel, locale),
        ),
      ],
    );
  }

  void _showEditProfileForm(
    BuildContext context,
    OyunGrubuProfileViewModel viewModel,
    String locale,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(SizeTokens.r20)),
      ),
      builder: (context) => Padding(
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
            Text(
              AppTranslations.translate('update_profile', locale),
              style: TextStyle(
                fontSize: SizeTokens.f20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: SizeTokens.p24),
            TextField(
              controller: viewModel.nameController,
              decoration: InputDecoration(
                labelText: AppTranslations.translate('name', locale),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SizeTokens.r8),
                ),
              ),
            ),
            SizedBox(height: SizeTokens.p16),
            TextField(
              controller: viewModel.surnameController,
              decoration: InputDecoration(
                labelText: AppTranslations.translate('surname', locale),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SizeTokens.r8),
                ),
              ),
            ),
            SizedBox(height: SizeTokens.p16),
            TextField(
              controller: viewModel.phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: AppTranslations.translate('phone', locale),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SizeTokens.r8),
                ),
              ),
            ),
            SizedBox(height: SizeTokens.p32),
            ElevatedButton(
              onPressed: viewModel.isLoading
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
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, SizeTokens.h52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizeTokens.r12),
                ),
              ),
              child: viewModel.isLoading
                  ? SizedBox(
                      height: SizeTokens.h20,
                      width: SizeTokens.h20,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(AppTranslations.translate('save', locale)),
            ),
            SizedBox(height: SizeTokens.p32),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(dynamic student, String locale, OyunGrubuProfileViewModel viewModel) {
    return Card(
      margin: EdgeInsets.only(bottom: SizeTokens.p16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeTokens.r12),
      ),
      child: Padding(
        padding: EdgeInsets.all(SizeTokens.p16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => viewModel.updateImage(
                type: 'student',
                studentId: student.id?.toString(),
              ),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: SizeTokens.r24,
                    backgroundImage: student.photo != null
                        ? NetworkImage(student.photo)
                        : null,
                    child: student.photo == null 
                        ? Icon(Icons.child_care)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(SizeTokens.p2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.camera_alt, size: SizeTokens.f10, color: Colors.grey),
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
                    '${student.name} ${student.surname}',
                    style: TextStyle(
                      fontSize: SizeTokens.f16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (student.allergies != null && student.allergies.isNotEmpty)
                    Text(
                      '${AppTranslations.translate('allergy', locale)}: ${student.allergies}',
                      style: TextStyle(
                        fontSize: SizeTokens.f12,
                        color: Colors.red,
                      ),
                    ),
                  if (student.medications != null && student.medications.isNotEmpty)
                    Text(
                      '${AppTranslations.translate('medicament', locale)}: ${student.medications}',
                      style: TextStyle(
                        fontSize: SizeTokens.f12,
                        color: Colors.orange,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

