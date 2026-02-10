import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../viewmodels/login_view_model.dart';
import '../../../core/utils/app_translations.dart';
import '../../../core/utils/color_utils.dart';
import '../../../viewmodels/landing_view_model.dart';
import '../../../viewmodels/settings_view_model.dart';
import '../../home_admin/home_admin_view.dart';
import '../../home_teacher/home_teacher_view.dart';
import '../../home_parent/home_parent_view.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<LoginViewModel, SettingsViewModel, LandingViewModel>(
      builder: (context, viewModel, settingsVM, landingVM, child) {
        final settings = settingsVM.settings;
        final primaryColor = ColorUtils.fromHex(
          settings?.mainColor ?? '#f9991c',
        );
        final locale = landingVM.locale.languageCode;

        return Column(
          children: [
            TextField(
              controller: viewModel.emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: AppTranslations.translate('email', locale),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
            SizedBox(height: SizeTokens.p16),
            TextField(
              controller: viewModel.passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: AppTranslations.translate('password', locale),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            if (viewModel.errorMessage != null) ...[
              SizedBox(height: SizeTokens.p16),
              Text(
                viewModel.errorMessage!,
                style: TextStyle(color: Colors.white, fontSize: SizeTokens.f12),
              ),
            ],
            SizedBox(height: SizeTokens.p24),
            ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () async {
                      final success = await viewModel.login();
                      if (success && context.mounted) {
                        // Fetch settings after successful login using the user's schoolId
                        final schoolId = viewModel.data?.data?.schoolId;
                        context.read<SettingsViewModel>().fetchSettings(
                          schoolId: schoolId,
                        );

                        final role = viewModel.data?.data?.role;

                        Widget targetView;
                        // Determine which view to navigate based on role
                        if (role == 'superadmin' || role == 'admin') {
                          targetView = const HomeAdminView();
                        } else if (role == 'teacher') {
                          targetView = const HomeTeacherView();
                        } else {
                          targetView = const HomeParentView();
                        }

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => targetView),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: Size(double.infinity, SizeTokens.h52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizeTokens.r12),
                ),
              ),
              child: viewModel.isLoading
                  ? SizedBox(
                      height: SizeTokens.h20,
                      width: SizeTokens.h20,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(AppTranslations.translate('login_button', locale)),
            ),
          ],
        );
      },
    );
  }
}
