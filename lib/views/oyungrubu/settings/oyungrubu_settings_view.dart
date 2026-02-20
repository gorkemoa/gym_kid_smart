import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../viewmodels/oyungrubu_settings_view_model.dart';
import '../../../viewmodels/splash_view_model.dart';
import '../../../core/utils/app_translations.dart';
import '../../environment_selection/environment_selection_view.dart';
import '../../../services/environment_service.dart';

class OyunGrubuSettingsView extends StatefulWidget {
  final bool isTab;
  const OyunGrubuSettingsView({super.key, this.isTab = false});

  @override
  State<OyunGrubuSettingsView> createState() => _OyunGrubuSettingsViewState();
}

class _OyunGrubuSettingsViewState extends State<OyunGrubuSettingsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OyunGrubuSettingsViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<OyunGrubuSettingsViewModel, SplashViewModel>(
      builder: (context, viewModel, splashVM, child) {
        final locale = splashVM.locale.languageCode;
        final primaryColor = Theme.of(context).colorScheme.primary;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            body: Column(
              children: [
                _buildHeader(context, locale, primaryColor),
                Expanded(
                  child: _buildBody(
                    context,
                    viewModel,
                    splashVM,
                    locale,
                    primaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, String locale, Color primaryColor) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
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
            Row(
              children: [
                if (!widget.isTab) ...[
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
                ],
                Expanded(
                  child: Text(
                    AppTranslations.translate('settings', locale),
                    style: TextStyle(
                      fontSize: SizeTokens.f20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
    OyunGrubuSettingsViewModel viewModel,
    SplashViewModel splashVM,
    String locale,
    Color primaryColor,
  ) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        SizeTokens.p24,
        SizeTokens.p32,
        SizeTokens.p24,
        SizeTokens.p24,
      ),
      children: [
        _buildSettingsSection(
          context,
          locale,
          primaryColor,
          title: AppTranslations.translate('settings', locale),
          items: [
            _SettingsItem(
              icon: Icons.language_rounded,
              title: AppTranslations.translate('language', locale),
              onTap: () =>
                  _showLanguageDialog(context, viewModel, splashVM, locale),
            ),
            _SettingsItem(
              icon: Icons.swap_horiz_rounded,
              title: AppTranslations.translate('change_section', locale),
              onTap: () => _showChangeSectionDialog(context, locale),
            ),
          ],
        ),
        SizedBox(height: SizeTokens.p24),
        _buildSettingsSection(
          context,
          locale,
          primaryColor,
          title: AppTranslations.translate('account', locale),
          items: [
            _SettingsItem(
              icon: Icons.logout_rounded,
              title: AppTranslations.translate('logout', locale),
              titleColor: Colors.red.shade600,
              iconColor: Colors.red.shade600,
              onTap: () => _showLogoutDialog(context, viewModel, locale),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String locale,
    Color primaryColor, {
    required String title,
    required List<_SettingsItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: SizeTokens.p4, bottom: SizeTokens.p12),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: SizeTokens.f12,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(SizeTokens.r16),
            border: Border.all(color: Colors.grey.shade100, width: 1),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(SizeTokens.r16),
                      onTap: item.onTap,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeTokens.p16,
                          vertical: SizeTokens.p16,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(SizeTokens.p8),
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: (item.iconColor ?? primaryColor)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  SizeTokens.r10,
                                ),
                              ),
                              child: Icon(
                                item.icon,
                                color: item.iconColor ?? primaryColor,
                                size: SizeTokens.i20,
                              ),
                            ),
                            SizedBox(width: SizeTokens.p16),
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  color: item.titleColor ?? Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: SizeTokens.f16,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.grey.shade400,
                              size: SizeTokens.i20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      indent: SizeTokens.p24,
                      color: Colors.grey.shade100,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    OyunGrubuSettingsViewModel viewModel,
    SplashViewModel splashVM,
    String locale,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeTokens.r16),
        ),
        title: Text(
          AppTranslations.translate('select_language', locale),
          style: TextStyle(
            fontSize: SizeTokens.f18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                AppTranslations.translate('turkish', locale),
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              leading: Radio<String>(
                value: 'tr',
                groupValue: locale,
                onChanged: (value) async {
                  Navigator.pop(dialogContext);
                  await viewModel.changeLanguage('tr', splashVM);
                },
              ),
              onTap: () async {
                Navigator.pop(dialogContext);
                await viewModel.changeLanguage('tr', splashVM);
              },
            ),
            ListTile(
              title: Text(
                AppTranslations.translate('english', locale),
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              leading: Radio<String>(
                value: 'en',
                groupValue: locale,
                onChanged: (value) async {
                  Navigator.pop(dialogContext);
                  await viewModel.changeLanguage('en', splashVM);
                },
              ),
              onTap: () async {
                Navigator.pop(dialogContext);
                await viewModel.changeLanguage('en', splashVM);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeSectionDialog(BuildContext context, String locale) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeTokens.r16),
        ),
        title: Text(
          AppTranslations.translate('change_section', locale),
          style: TextStyle(
            fontSize: SizeTokens.f18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          AppTranslations.translate('select_environment_subtitle', locale),
          style: TextStyle(fontSize: SizeTokens.f14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppTranslations.translate('cancel', locale)),
          ),
          ElevatedButton(
            onPressed: () async {
              await EnvironmentService.clearEnvironment();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const EnvironmentSelectionView(),
                  ),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              AppTranslations.translate('change_section', locale),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    OyunGrubuSettingsViewModel viewModel,
    String locale,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeTokens.r16),
        ),
        title: Text(
          AppTranslations.translate('logout', locale),
          style: TextStyle(
            fontSize: SizeTokens.f18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          AppTranslations.translate('logout_confirmation', locale),
          style: TextStyle(fontSize: SizeTokens.f14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppTranslations.translate('cancel', locale)),
          ),
          ElevatedButton(
            onPressed: () async {
              await viewModel.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const EnvironmentSelectionView(),
                  ),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
            ),
            child: Text(
              AppTranslations.translate('logout', locale),
              style: const TextStyle(color: Colors.white),
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
