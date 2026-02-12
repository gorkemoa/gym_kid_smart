import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/services/navigation_service.dart';
import '../../core/utils/app_translations.dart';
import '../../services/auth_service.dart';
import '../../viewmodels/login_view_model.dart';
import '../../viewmodels/landing_view_model.dart';
import '../../viewmodels/settings_view_model.dart';
import '../login/login_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LandingViewModel>().locale.languageCode;
    final loginVM = context.watch<LoginViewModel>();
    final settingsVM = context.watch<SettingsViewModel>();
    final user = loginVM.data?.data;

    return SingleChildScrollView(
      padding: EdgeInsets.all(SizeTokens.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user != null) ...[
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: SizeTokens.r100 / 2,
                    backgroundImage: user.image != null
                        ? NetworkImage(user.image!)
                        : null,
                    child: user.image == null
                        ? Icon(Icons.person, size: SizeTokens.i48)
                        : null,
                  ),
                  SizedBox(height: SizeTokens.p16),
                  Text(
                    '${user.name} ${user.surname}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.email ?? '',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  SizedBox(height: SizeTokens.p8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeTokens.p12,
                      vertical: SizeTokens.p4,
                    ),
                    decoration: BoxDecoration(
                      color: settingsVM.themeData.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(SizeTokens.r20),
                    ),
                    child: Text(
                      AppTranslations.translate(user.role ?? 'parent', locale),
                      style: TextStyle(
                        color: settingsVM.themeData.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: SizeTokens.f12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: SizeTokens.p32),
          ],

          _buildSettingsSection(
            context,
            locale,
            title: AppTranslations.translate('account', locale),
            items: [
              _SettingsItem(
                icon: Icons.logout,
                title: AppTranslations.translate('logout', locale),
                titleColor: Colors.red,
                iconColor: Colors.red,
                onTap: () => _showLogoutDialog(context, locale),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String locale, {
    required String title,
    required List<_SettingsItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: SizeTokens.p4, bottom: SizeTokens.p8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: SizeTokens.f12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(SizeTokens.r12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(
                      item.icon,
                      color: item.iconColor ?? Colors.black87,
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        color: item.titleColor ?? Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: item.onTap,
                  ),
                  if (index < items.length - 1)
                    Divider(height: 1, indent: SizeTokens.p48),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, String locale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.translate('logout', locale)),
        content: Text(
          AppTranslations.translate('confirm_logout', locale),
        ), // Need to add this to JSON or use generic
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppTranslations.translate('cancel', locale)),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.logout();
              if (context.mounted) {
                NavigationService.pushNamedAndRemoveUntil(const LoginView());
              }
            },
            child: Text(
              AppTranslations.translate('logout', locale),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? titleColor;
  final Color? iconColor;

  _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.titleColor,
    this.iconColor,
  });
}
