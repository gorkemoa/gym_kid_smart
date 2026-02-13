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
import '../../core/network/api_result.dart';
import '../../models/user_model.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LandingViewModel>().locale.languageCode;
    final loginVM = context.watch<LoginViewModel>();
    final settingsVM = context.watch<SettingsViewModel>();
    final user = loginVM.data?.data;
    final isAuthorized =
        user?.role == 'teacher' ||
        user?.role == 'superadmin' ||
        user?.role == 'admin';

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
            title: AppTranslations.translate('settings', locale),
            items: [
              _SettingsItem(
                icon: Icons.language,
                title: AppTranslations.translate('language', locale),
                onTap: () => _showLanguageDialog(
                  context,
                  context.read<LandingViewModel>(),
                  locale,
                ),
              ),
            ],
          ),
          SizedBox(height: SizeTokens.p16),

          if (isAuthorized) ...[
            _buildSettingsSection(
              context,
              locale,
              title: AppTranslations.translate('activity_templates', locale),
              items: [
                _SettingsItem(
                  icon: Icons.title,
                  title: AppTranslations.translate('manage_titles', locale),
                  onTap: () => _showTemplateDialog(
                    context,
                    settingsVM,
                    user!,
                    locale,
                    'activity_title',
                  ),
                ),
                _SettingsItem(
                  icon: Icons.star_outline,
                  title: AppTranslations.translate('manage_values', locale),
                  onTap: () => _showTemplateDialog(
                    context,
                    settingsVM,
                    user!,
                    locale,
                    'activity_value',
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeTokens.p16),

            _buildSettingsSection(
              context,
              locale,
              title: AppTranslations.translate('social_templates', locale),
              items: [
                _SettingsItem(
                  icon: Icons.diversity_3_outlined,
                  title: AppTranslations.translate('manage_titles', locale),
                  onTap: () => _showTemplateDialog(
                    context,
                    settingsVM,
                    user!,
                    locale,
                    'social_title',
                  ),
                ),
                _SettingsItem(
                  icon: Icons.star_outline,
                  title: AppTranslations.translate('manage_values', locale),
                  onTap: () => _showTemplateDialog(
                    context,
                    settingsVM,
                    user!,
                    locale,
                    'social_value',
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeTokens.p16),
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

  void _showTemplateDialog(
    BuildContext context,
    SettingsViewModel viewModel,
    UserModel user,
    String locale,
    String type,
  ) {
    // Initial fetch
    viewModel.fetchTemplates(
      schoolId: user.schoolId ?? 1,
      userKey: user.userKey ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(SizeTokens.r24),
            ),
          ),
          padding: EdgeInsets.all(SizeTokens.p20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppTranslations.translate(
                      type == 'activity_title' || type == 'social_title'
                          ? 'manage_titles'
                          : 'manage_values',
                      locale,
                    ),
                    style: TextStyle(
                      fontSize: SizeTokens.f18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListenableBuilder(
                  listenable: viewModel,
                  builder: (context, _) {
                    if (viewModel.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    List items = [];
                    if (type == 'activity_title')
                      items = viewModel.activityTitles;
                    else if (type == 'activity_value')
                      items = viewModel.activityValues;
                    else if (type == 'social_title')
                      items = viewModel.socialTitles;

                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          AppTranslations.translate('no_data_found', locale),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final text =
                            (type == 'activity_value' || type == 'social_value')
                            ? item.value
                            : item.title;

                        return ListTile(
                          title: Text(text ?? ''),
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: SizeTokens.f12,
                              ),
                            ),
                          ),
                          trailing:
                              (user.role == 'superadmin' ||
                                  user.role == 'teacher')
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _showDeleteWarning(
                                    context,
                                    viewModel,
                                    user,
                                    item,
                                    type,
                                    locale,
                                  ),
                                )
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: _buildAddTemplateField(
                  context,
                  viewModel,
                  user,
                  locale,
                  type,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddTemplateField(
    BuildContext context,
    SettingsViewModel viewModel,
    UserModel user,
    String locale,
    String type,
  ) {
    final controller = TextEditingController();
    return Container(
      padding: EdgeInsets.only(top: SizeTokens.p12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: AppTranslations.translate('add', locale),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: SizeTokens.p16,
                ),
              ),
            ),
          ),
          SizedBox(width: SizeTokens.p8),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              ApiResult<bool> result;
              final schoolId = user.schoolId ?? 1;
              final userKey = user.userKey ?? '';

              if (type == 'activity_title') {
                result = await viewModel.saveActivityTitle(
                  schoolId: schoolId,
                  userKey: userKey,
                  title: controller.text,
                );
              } else if (type == 'activity_value' || type == 'social_value') {
                result = await viewModel.saveActivityValue(
                  schoolId: schoolId,
                  userKey: userKey,
                  value: controller.text,
                );
              } else if (type == 'social_title') {
                result = await viewModel.saveSocialTitle(
                  schoolId: schoolId,
                  userKey: userKey,
                  title: controller.text,
                );
              } else {
                result = Failure('Geçersiz tip');
              }

              if (context.mounted) {
                if (result is Success) {
                  controller.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text((result as Failure).message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 45),
              padding: EdgeInsets.symmetric(horizontal: SizeTokens.p16),
            ),
            child: Text(AppTranslations.translate('save', locale)),
          ),
        ],
      ),
    );
  }

  void _showDeleteWarning(
    BuildContext context,
    SettingsViewModel viewModel,
    UserModel user,
    dynamic item,
    String type,
    String locale,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.translate('confirm_delete', locale)),
        content: Text(AppTranslations.translate('delete_confirmation', locale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppTranslations.translate('cancel', locale)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              ApiResult<bool> result;
              final id = int.tryParse(item.id.toString()) ?? 0;
              final schoolId = user.schoolId ?? 1;
              final userKey = user.userKey ?? '';

              if (type == 'activity_title') {
                result = await viewModel.deleteActivityTitle(
                  schoolId: schoolId,
                  userKey: userKey,
                  id: id,
                );
              } else if (type == 'activity_value') {
                result = await viewModel.deleteActivityValue(
                  schoolId: schoolId,
                  userKey: userKey,
                  id: id,
                );
              } else if (type == 'social_title') {
                result = await viewModel.deleteSocialTitle(
                  schoolId: schoolId,
                  userKey: userKey,
                  id: id,
                );
              } else {
                result = await viewModel.deleteSocialValue(
                  schoolId: schoolId,
                  userKey: userKey,
                  id: id,
                );
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result is Success
                          ? AppTranslations.translate('delete_success', locale)
                          : (result as Failure).message,
                    ),
                    backgroundColor: result is Success
                        ? Colors.green
                        : Colors.red,
                  ),
                );
              }
            },
            child: Text(
              AppTranslations.translate('delete', locale),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    LandingViewModel landingVM,
    String locale,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.translate('select_language', locale)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(AppTranslations.translate('turkish', locale)),
              leading: Radio<String>(
                value: 'tr',
                groupValue: landingVM.locale.languageCode,
                onChanged: (value) {
                  landingVM.changeLanguage('tr');
                  Navigator.pop(context);
                },
              ),
              onTap: () {
                landingVM.changeLanguage('tr');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(AppTranslations.translate('english', locale)),
              leading: Radio<String>(
                value: 'en',
                groupValue: landingVM.locale.languageCode,
                onChanged: (value) {
                  landingVM.changeLanguage('en');
                  Navigator.pop(context);
                },
              ),
              onTap: () {
                landingVM.changeLanguage('en');
                Navigator.pop(context);
              },
            ),
          ],
        ),
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
