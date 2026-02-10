import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../viewmodels/login_view_model.dart';
import '../../../core/utils/app_translations.dart';
import '../../../viewmodels/landing_view_model.dart';
import '../../../viewmodels/settings_view_model.dart';
import '../../home/home_view.dart';

class QuickLoginSection extends StatelessWidget {
  const QuickLoginSection({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.read<LandingViewModel>().locale.languageCode;
    final viewModel = context.watch<LoginViewModel>();

    final accounts = [
      {
        'email': 'b.sekman@smartmetrics.com.tr',
        'role': 'admin',
        'icon': Icons.admin_panel_settings_outlined,
        'label': AppTranslations.translate('admin', locale),
      },
      {
        'email': 'g.ozturk@smartmetrics.com.tr',
        'role': 'teacher',
        'icon': Icons.school_outlined,
        'label': AppTranslations.translate('teacher', locale),
      },
      {
        'email': 'noreply@smartmetrics.com.tr',
        'role': 'parent',
        'icon': Icons.family_restroom_outlined,
        'label': AppTranslations.translate('parent', locale),
      },
    ];

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: SizeTokens.p16),
          child: Row(
            children: [
              const Expanded(child: Divider(color: Colors.white24)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: SizeTokens.p16),
                child: Text(
                  AppTranslations.translate('quick_login', locale),
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: SizeTokens.f12,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: Colors.white24)),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: accounts.map((account) {
            return _QuickLoginCard(
              email: account['email'] as String,
              label: account['label'] as String,
              icon: account['icon'] as IconData,
              onTap: () =>
                  _handleLogin(context, viewModel, account['email'] as String),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _handleLogin(
    BuildContext context,
    LoginViewModel viewModel,
    String email,
  ) async {
    if (viewModel.isLoading) return;

    viewModel.emailController.text = email;
    viewModel.passwordController.text = '123123';

    final success = await viewModel.login();
    if (success && context.mounted) {
      // Fetch settings after successful login using the user's schoolId
      final schoolId = viewModel.data?.data?.schoolId;
      context.read<SettingsViewModel>().fetchSettings(schoolId: schoolId);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeView()),
      );
    }
  }
}

class _QuickLoginCard extends StatelessWidget {
  final String email;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickLoginCard({
    required this.email,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SizeTokens.r12),
      child: Container(
        width: SizeTokens.w100,
        padding: EdgeInsets.symmetric(
          vertical: SizeTokens.p12,
          horizontal: SizeTokens.p8,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(SizeTokens.r12),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(SizeTokens.p8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: SizeTokens.p20),
            ),
            SizedBox(height: SizeTokens.p8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: SizeTokens.f12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
