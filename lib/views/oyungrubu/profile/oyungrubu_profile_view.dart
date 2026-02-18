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
                _buildProfileHeader(profile),
                SizedBox(height: SizeTokens.p32),
                Text(
                  AppTranslations.translate('students', locale),
                  style: TextStyle(
                    fontSize: SizeTokens.f20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: SizeTokens.p16),
                ...?profile.students?.map((student) => _buildStudentCard(student, locale)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(dynamic profile) {
    return Row(
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
        SizedBox(width: SizeTokens.p16),
        Column(
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
          ],
        ),
      ],
    );
  }

  Widget _buildStudentCard(dynamic student, String locale) {
    return Card(
      margin: EdgeInsets.only(bottom: SizeTokens.p16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeTokens.r12),
      ),
      child: Padding(
        padding: EdgeInsets.all(SizeTokens.p16),
        child: Row(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
