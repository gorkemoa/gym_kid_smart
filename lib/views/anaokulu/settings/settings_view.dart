import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/services/navigation_service.dart';
import '../../../core/utils/app_translations.dart';
import '../../../services/auth_service.dart';
import '../../../viewmodels/login_view_model.dart';
import '../../../viewmodels/landing_view_model.dart';
import '../../../viewmodels/settings_view_model.dart';
import '../../../viewmodels/permission_view_model.dart';
import '../login/login_view.dart';
import '../../../core/network/api_result.dart';
import '../../../models/user_model.dart';
import '../../../models/permission_model.dart';
import '../../environment_selection/environment_selection_view.dart';

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
                      // ignore: deprecated_member_use
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
              _SettingsItem(
                icon: Icons.swap_horiz,
                title: AppTranslations.translate('change_section', locale),
                onTap: () => _showChangeSectionDialog(context, locale),
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

          // Super admin: İzin Yönetimi
          if (user != null && user.role == 'superadmin') ...[
            _buildSettingsSection(
              context,
              locale,
              title: AppTranslations.translate('permission_management', locale),
              items: [
                _SettingsItem(
                  icon: Icons.add_circle_outline,
                  title: AppTranslations.translate('add_permission', locale),
                  onTap: () => _showAddPermissionDialog(
                    context,
                    context.read<PermissionViewModel>(),
                    user,
                    locale,
                  ),
                ),
                _SettingsItem(
                  icon: Icons.list_alt,
                  title: AppTranslations.translate('permission_list', locale),
                  onTap: () => _showPermissionListDialog(
                    context,
                    context.read<PermissionViewModel>(),
                    user,
                    locale,
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeTokens.p16),
          ],

          // Parent: İzinlerim
          if (user != null && user.role == 'parent') ...[
            _buildSettingsSection(
              context,
              locale,
              title: AppTranslations.translate('permissions', locale),
              items: [
                _SettingsItem(
                  icon: Icons.assignment_outlined,
                  title: AppTranslations.translate(
                    'parent_permissions',
                    locale,
                  ),
                  onTap: () => _showParentPermissionsDialog(
                    context,
                    context.read<PermissionViewModel>(),
                    user,
                    locale,
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
                    if (type == 'activity_title') {
                      items = viewModel.activityTitles;
                    } else if (type == 'activity_value')
                      // ignore: curly_braces_in_flow_control_structures
                      items = viewModel.activityValues;
                    else if (type == 'social_title')
                      // ignore: curly_braces_in_flow_control_structures
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
                              // ignore: deprecated_member_use
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

  void _showChangeSectionDialog(BuildContext context, String locale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.translate('change_section', locale)),
        content: Text(AppTranslations.translate('confirm_logout', locale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppTranslations.translate('cancel', locale)),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const EnvironmentSelectionView(),
                  ),
                  (route) => false,
                );
              }
            },
            child: Text(
              AppTranslations.translate('approve', locale),
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
                // ignore: deprecated_member_use
                groupValue: landingVM.locale.languageCode,
                // ignore: deprecated_member_use
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
                // ignore: deprecated_member_use
                groupValue: landingVM.locale.languageCode,
                // ignore: deprecated_member_use
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

  Widget _buildReceivingSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
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
                // ignore: deprecated_member_use
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

  // ==================== İZİN YÖNETİMİ DİALOGLARI ====================

  /// Super admin: İzin ekleme dialogu
  void _showAddPermissionDialog(
    BuildContext context,
    PermissionViewModel viewModel,
    UserModel user,
    String locale,
  ) {
    viewModel.fetchClasses(
      schoolId: user.schoolId ?? 1,
      userKey: user.userKey ?? '',
    );
    viewModel.clearSelectedClasses();
    viewModel.setSelectedFile(null);

    final titleController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => DraggableScrollableSheet(
          initialChildSize: 0.8,
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
                      AppTranslations.translate('add_permission', locale),
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

                      return SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Başlık
                            _buildReceivingSectionTitle(
                              context,
                              AppTranslations.translate(
                                'permission_title',
                                locale,
                              ),
                            ),
                            SizedBox(height: SizeTokens.p8),
                            TextField(
                              controller: titleController,
                              decoration: InputDecoration(
                                hintText: AppTranslations.translate(
                                  'enter_permission_title',
                                  locale,
                                ),
                                prefixIcon: Icon(
                                  Icons.title,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            SizedBox(height: SizeTokens.p16),

                            // Sınıf seçimi
                            _buildReceivingSectionTitle(
                              context,
                              AppTranslations.translate(
                                'select_classes',
                                locale,
                              ),
                            ),
                            SizedBox(height: SizeTokens.p4),
                            Text(
                              AppTranslations.translate(
                                'comma_separated_classes',
                                locale,
                              ),
                              style: TextStyle(
                                fontSize: SizeTokens.f12,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: SizeTokens.p8),
                            Wrap(
                              spacing: SizeTokens.p8,
                              runSpacing: SizeTokens.p8,
                              children: viewModel.classes.map((classModel) {
                                final isSelected = viewModel.selectedClasses
                                    .any((c) => c.id == classModel.id);
                                return FilterChip(
                                  label: Text(classModel.name ?? ''),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    viewModel.toggleClassSelection(classModel);
                                    setState(() {});
                                  },
                                  selectedColor: Theme.of(
                                    context,
                                    // ignore: deprecated_member_use
                                  ).primaryColor.withOpacity(0.2),
                                  checkmarkColor: Theme.of(
                                    context,
                                  ).primaryColor,
                                );
                              }).toList(),
                            ),
                            if (viewModel.selectedClasses.isNotEmpty) ...[
                              SizedBox(height: SizeTokens.p8),
                              Text(
                                '${AppTranslations.translate('selected_classes', locale)}: ${viewModel.selectedClasses.map((c) => c.name).join(', ')}',
                                style: TextStyle(
                                  fontSize: SizeTokens.f12,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            SizedBox(height: SizeTokens.p16),

                            // Dosya seçimi
                            _buildReceivingSectionTitle(
                              context,
                              AppTranslations.translate('select_file', locale),
                            ),
                            SizedBox(height: SizeTokens.p4),
                            Text(
                              AppTranslations.translate(
                                'only_pdf_docx',
                                locale,
                              ),
                              style: TextStyle(
                                fontSize: SizeTokens.f12,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: SizeTokens.p8),
                            InkWell(
                              onTap: () async {
                                final result = await FilePicker.platform
                                    .pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: ['pdf', 'docx'],
                                    );
                                if (result != null &&
                                    result.files.single.path != null) {
                                  viewModel.setSelectedFile(
                                    File(result.files.single.path!),
                                  );
                                  setState(() {});
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: SizeTokens.p16,
                                  vertical: SizeTokens.p12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: viewModel.selectedFile != null
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.secondary
                                        : Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    SizeTokens.r8,
                                  ),
                                  color: viewModel.selectedFile != null
                                      // ignore: deprecated_member_use
                                      ? Theme.of(context).colorScheme.secondary
                                            .withOpacity(0.05)
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      viewModel.selectedFile != null
                                          ? Icons.check_circle
                                          : Icons.upload_file,
                                      color: viewModel.selectedFile != null
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.secondary
                                          : Theme.of(context).primaryColor,
                                    ),
                                    SizedBox(width: SizeTokens.p12),
                                    Expanded(
                                      child: Text(
                                        viewModel.selectedFile != null
                                            ? viewModel.selectedFile!.path
                                                  .split('/')
                                                  .last
                                            : AppTranslations.translate(
                                                'select_file',
                                                locale,
                                              ),
                                        style: TextStyle(
                                          color: viewModel.selectedFile != null
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.secondary
                                              : Colors.grey.shade600,
                                          fontSize: SizeTokens.f14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: SizeTokens.p12,
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Validasyonlar
                        if (titleController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppTranslations.translate(
                                  'title_required',
                                  locale,
                                ),
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                          );
                          return;
                        }
                        if (viewModel.selectedClasses.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppTranslations.translate(
                                  'class_required',
                                  locale,
                                ),
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                          );
                          return;
                        }
                        if (viewModel.selectedFile == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppTranslations.translate(
                                  'file_required',
                                  locale,
                                ),
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                          );
                          return;
                        }

                        final classIds = viewModel.selectedClasses
                            .map((c) => c.id.toString())
                            .join(',');

                        final result = await viewModel.addPermission(
                          schoolId: user.schoolId ?? 1,
                          userKey: user.userKey ?? '',
                          classIds: classIds,
                          title: titleController.text,
                          file: viewModel.selectedFile!,
                        );

                        if (context.mounted) {
                          if (result is Success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppTranslations.translate(
                                    'permission_add_success',
                                    locale,
                                  ),
                                ),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.secondary,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text((result as Failure).message),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeTokens.p16,
                        ),
                      ),
                      child: Text(AppTranslations.translate('save', locale)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Super admin: İzin listesi dialogu
  void _showPermissionListDialog(
    BuildContext context,
    PermissionViewModel viewModel,
    UserModel user,
    String locale,
  ) {
    viewModel.fetchPermissionList(
      schoolId: user.schoolId ?? 1,
      userKey: user.userKey ?? '',
    );
    viewModel.fetchClasses(
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
                    AppTranslations.translate('permission_list', locale),
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

                    if (viewModel.permissions.isEmpty) {
                      return Center(
                        child: Text(
                          AppTranslations.translate(
                            'no_permission_found',
                            locale,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: viewModel.permissions.length,
                      itemBuilder: (context, index) {
                        final permission = viewModel.permissions[index];
                        return Card(
                          color: Colors.white,
                          margin: EdgeInsets.only(bottom: SizeTokens.p8),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(SizeTokens.r12),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                                // ignore: deprecated_member_use
                              ).primaryColor.withOpacity(0.1),
                              child: Icon(
                                Icons.description_outlined,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            title: Text(
                              permission.title ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: SizeTokens.f14,
                              ),
                            ),
                            subtitle: permission.classIds != null
                                ? Text(
                                    '${AppTranslations.translate('select_classes', locale)}: ${viewModel.getClassNamesByIds(permission.classIds)}',
                                    style: TextStyle(
                                      fontSize: SizeTokens.f12,
                                      color: Colors.grey,
                                    ),
                                  )
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (permission.file != null &&
                                    permission.file!.isNotEmpty)
                                  IconButton(
                                    icon: Icon(
                                      Icons.open_in_new,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    onPressed: () async {
                                      final fileUrl =
                                          '${viewModel.permissionsPath}/${permission.file}';
                                      final uri = Uri.parse(fileUrl);
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(
                                          uri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      }
                                    },
                                  ),
                                IconButton(
                                  icon: Icon(
                                    Icons.people_outline,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    _showPermissionControlDialog(
                                      context,
                                      viewModel,
                                      user,
                                      permission,
                                      locale,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Super admin: İzin kontrol dialogu (kimlerin onayladığı)
  void _showPermissionControlDialog(
    BuildContext context,
    PermissionViewModel viewModel,
    UserModel user,
    PermissionModel permission,
    String locale,
  ) {
    viewModel.fetchPermissionControl(
      schoolId: user.schoolId ?? 1,
      userKey: user.userKey ?? '',
      permissionId: permission.id ?? 0,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppTranslations.translate(
                            'permission_approvals',
                            locale,
                          ),
                          style: TextStyle(
                            fontSize: SizeTokens.f18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          permission.title ?? '',
                          style: TextStyle(
                            fontSize: SizeTokens.f12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
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
                    if (viewModel.isPermissionControlLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (viewModel.permissionControls.isEmpty) {
                      return Center(
                        child: Text(
                          AppTranslations.translate('no_data_found', locale),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: viewModel.permissionControls.length,
                      itemBuilder: (context, index) {
                        final control = viewModel.permissionControls[index];
                        final isApproved = control.status == 1;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isApproved
                                // ignore: deprecated_member_use
                                ? Theme.of(
                                    context,
                                  ).colorScheme.secondary.withOpacity(0.1)
                                // ignore: deprecated_member_use
                                : Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                            child: Icon(
                              isApproved
                                  ? Icons.check_circle
                                  : Icons.hourglass_empty,
                              color: isApproved
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                          title: Text(
                            '${control.parentName ?? ''} ${control.parentSurname ?? ''}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: SizeTokens.f14,
                            ),
                          ),
                          subtitle: Text(
                            '${isApproved ? AppTranslations.translate('approved', locale) : AppTranslations.translate('not_approved', locale)}${control.createdAt != null ? ' (${control.createdAt})' : ''}',
                            style: TextStyle(
                              color: isApproved
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).primaryColor,
                              fontSize: SizeTokens.f12,
                            ),
                          ),
                          trailing: Icon(
                            isApproved
                                ? Icons.verified
                                : Icons.pending_outlined,
                            color: isApproved
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).primaryColor,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Parent: İzinlerim dialogu
  void _showParentPermissionsDialog(
    BuildContext context,
    PermissionViewModel viewModel,
    UserModel user,
    String locale,
  ) {
    viewModel.fetchParentPermissions(
      schoolId: user.schoolId ?? 1,
      userKey: user.userKey ?? '',
    );
    viewModel.fetchClasses(
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
                    AppTranslations.translate('parent_permissions', locale),
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

                    if (viewModel.parentPermissions.isEmpty) {
                      return Center(
                        child: Text(
                          AppTranslations.translate(
                            'no_permission_found',
                            locale,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: viewModel.parentPermissions.length,
                      itemBuilder: (context, index) {
                        final parentPerm = viewModel.parentPermissions[index];
                        final permission = parentPerm.permissionItem;
                        final isApproved = parentPerm.parentStatus == 1;
                        return Card(
                          color: Colors.white,
                          margin: EdgeInsets.only(bottom: SizeTokens.p12),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(SizeTokens.r12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(SizeTokens.p12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: isApproved
                                          // ignore: deprecated_member_use
                                          ? Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withOpacity(0.1)
                                          : Theme.of(
                                              context,
                                              // ignore: deprecated_member_use
                                            ).primaryColor.withOpacity(0.1),
                                      child: Icon(
                                        isApproved
                                            ? Icons.check_circle
                                            : Icons.description_outlined,
                                        color: isApproved
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.secondary
                                            : Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    SizedBox(width: SizeTokens.p12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            permission.title ?? '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: SizeTokens.f14,
                                            ),
                                          ),
                                          SizedBox(height: SizeTokens.p4),
                                          Text(
                                            isApproved
                                                ? AppTranslations.translate(
                                                    'approved',
                                                    locale,
                                                  )
                                                : AppTranslations.translate(
                                                    'waiting',
                                                    locale,
                                                  ),
                                            style: TextStyle(
                                              color: isApproved
                                                  ? Theme.of(
                                                      context,
                                                    ).colorScheme.secondary
                                                  : Theme.of(
                                                      context,
                                                    ).primaryColor,
                                              fontSize: SizeTokens.f12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isApproved)
                                      Icon(
                                        Icons.verified,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                  ],
                                ),
                                SizedBox(height: SizeTokens.p12),
                                Row(
                                  children: [
                                    // Dosya görüntüleme butonu
                                    if (permission.file != null &&
                                        permission.file!.isNotEmpty)
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () async {
                                            final fileUrl =
                                                '${viewModel.permissionsPath}/${permission.file}';
                                            final uri = Uri.parse(fileUrl);
                                            if (await canLaunchUrl(uri)) {
                                              await launchUrl(
                                                uri,
                                                mode: LaunchMode
                                                    .externalApplication,
                                              );
                                            }
                                          },
                                          icon: Icon(
                                            Icons.open_in_new,
                                            size: 16,
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                          ),
                                          label: Text(
                                            AppTranslations.translate(
                                              'view_document',
                                              locale,
                                            ),
                                            style: TextStyle(
                                              fontSize: SizeTokens.f12,
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: const Size(0, 36),
                                            side: BorderSide(
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (permission.file != null &&
                                        permission.file!.isNotEmpty &&
                                        !isApproved)
                                      SizedBox(width: SizeTokens.p8),
                                    // Onay butonu
                                    if (!isApproved)
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            _showApproveConfirmDialog(
                                              context,
                                              viewModel,
                                              user,
                                              parentPerm,
                                              locale,
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.check,
                                            size: 16,
                                          ),
                                          label: Text(
                                            AppTranslations.translate(
                                              'approve',
                                              locale,
                                            ),
                                            style: TextStyle(
                                              fontSize: SizeTokens.f12,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: const Size(0, 36),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Parent: İzin onay confirm dialogu
  void _showApproveConfirmDialog(
    BuildContext context,
    PermissionViewModel viewModel,
    UserModel user,
    ParentPermissionModel parentPerm,
    String locale,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.translate('approve_permission', locale)),
        content: Text(
          AppTranslations.translate('confirm_approve_permission', locale),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppTranslations.translate('cancel', locale)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await viewModel.approvePermission(
                schoolId: user.schoolId ?? 1,
                userKey: user.userKey ?? '',
                permissionId: parentPerm.permissionItem.id ?? 0,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result is Success
                          ? AppTranslations.translate(
                              'permission_approved_success',
                              locale,
                            )
                          : (result as Failure).message,
                    ),
                    backgroundColor: result is Success
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            child: Text(
              AppTranslations.translate('approve', locale),
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
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
              style: TextStyle(color: Theme.of(context).colorScheme.error),
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
