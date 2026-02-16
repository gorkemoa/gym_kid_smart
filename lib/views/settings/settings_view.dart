import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
import '../../models/student_model.dart';

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

          if (user != null) ...[
            _buildSettingsSection(
              context,
              locale,
              title: AppTranslations.translate('receiving_management', locale),
              items: [
                _SettingsItem(
                  icon: Icons.badge_outlined,
                  title: AppTranslations.translate('receiving_add', locale),
                  onTap: () =>
                      _showReceivingDialog(context, settingsVM, user, locale),
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

  void _showReceivingDialog(
    BuildContext context,
    SettingsViewModel viewModel,
    UserModel user,
    String locale,
  ) {
    viewModel.fetchStudents(
      schoolId: user.schoolId ?? 1,
      userKey: user.userKey ?? '',
    );

    final recipientController = TextEditingController();
    final timeController = TextEditingController();
    final noteController = TextEditingController();
    int selectedStatus = 0;
    StudentModel? selectedStudent;

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
                      AppTranslations.translate('receiving_add', locale),
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
                      if (viewModel.isReceivingLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Student Picker
                            _buildReceivingSectionTitle(
                              context,
                              AppTranslations.translate(
                                'select_student',
                                locale,
                              ),
                            ),
                            SizedBox(height: SizeTokens.p8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: SizeTokens.p12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(
                                  SizeTokens.r8,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<StudentModel>(
                                  isExpanded: true,
                                  value: selectedStudent,
                                  hint: Text(
                                    AppTranslations.translate(
                                      'select_student',
                                      locale,
                                    ),
                                  ),
                                  items: viewModel.students
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(
                                            '${s.name ?? ''} ${s.surname ?? ''}',
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      selectedStudent = val;
                                    });
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: SizeTokens.p16),

                            // Recipient
                            _buildReceivingSectionTitle(
                              context,
                              AppTranslations.translate('recipient', locale),
                            ),
                            SizedBox(height: SizeTokens.p8),
                            TextField(
                              controller: recipientController,
                              decoration: InputDecoration(
                                hintText: AppTranslations.translate(
                                  'recipient',
                                  locale,
                                ),
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            SizedBox(height: SizeTokens.p16),

                            // Time
                            _buildReceivingSectionTitle(
                              context,
                              AppTranslations.translate('time', locale),
                            ),
                            SizedBox(height: SizeTokens.p8),
                            TextField(
                              controller: timeController,
                              readOnly: true,
                              onTap: () {
                                _showTimePicker(
                                  context,
                                  timeController,
                                  locale,
                                );
                              },
                              decoration: InputDecoration(
                                hintText: AppTranslations.translate(
                                  'time',
                                  locale,
                                ),
                                prefixIcon: Icon(
                                  Icons.access_time,
                                  color: Theme.of(context).primaryColor,
                                ),
                                suffixIcon: const Icon(Icons.arrow_drop_down),
                              ),
                            ),
                            SizedBox(height: SizeTokens.p16),

                            // Note
                            _buildReceivingSectionTitle(
                              context,
                              AppTranslations.translate('note', locale),
                            ),
                            SizedBox(height: SizeTokens.p8),
                            TextField(
                              controller: noteController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: AppTranslations.translate(
                                  'note',
                                  locale,
                                ),
                                prefixIcon: Icon(
                                  Icons.note_alt_outlined,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),

                            // Status toggle (teacher/superadmin)
                            if (user.role == 'teacher' ||
                                user.role == 'superadmin') ...[
                              SizedBox(height: SizeTokens.p24),
                              _buildReceivingStatusToggle(
                                context,
                                locale,
                                selectedStatus,
                                (val) {
                                  setState(() {
                                    selectedStatus = val ? 1 : 0;
                                  });
                                },
                              ),
                            ],
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
                        if (selectedStudent == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppTranslations.translate(
                                  'select_student',
                                  locale,
                                ),
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        if (recipientController.text.isEmpty) return;

                        final now = DateTime.now();
                        final dateStr =
                            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

                        final result = await viewModel.saveReceiving(
                          schoolId: user.schoolId ?? 1,
                          userKey: user.userKey ?? '',
                          studentId: selectedStudent!.id!,
                          date: dateStr,
                          time: timeController.text.isNotEmpty
                              ? timeController.text
                              : '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                          recipient: recipientController.text,
                          status: selectedStatus,
                          userId: user.id ?? 0,
                          note: noteController.text,
                        );

                        if (context.mounted) {
                          if (result is Success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppTranslations.translate(
                                    'receiving_save_success',
                                    locale,
                                  ),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
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

  Widget _buildReceivingSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildReceivingStatusToggle(
    BuildContext context,
    String locale,
    int status,
    ValueChanged<bool> onChanged,
  ) {
    final isReady = status == 1;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.p16,
        vertical: SizeTokens.p12,
      ),
      decoration: BoxDecoration(
        color: isReady
            // ignore: deprecated_member_use
            ? Colors.green.withOpacity(0.05)
            // ignore: deprecated_member_use
            : Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(SizeTokens.r12),
        border: Border.all(
          color: isReady
              // ignore: deprecated_member_use
              ? Colors.green.withOpacity(0.2)
              // ignore: deprecated_member_use
              : Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTranslations.translate('status', locale),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: SizeTokens.f14,
                    color: isReady
                        ? Colors.green.shade700
                        : Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  isReady
                      ? AppTranslations.translate('ready_to_receive', locale)
                      : AppTranslations.translate('not_ready', locale),
                  style: TextStyle(
                    color: isReady
                        ? Colors.green
                        : Theme.of(context).primaryColor,
                    fontSize: SizeTokens.f12,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isReady,
            onChanged: onChanged,
            // ignore: deprecated_member_use
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  void _showTimePicker(
    BuildContext context,
    TextEditingController controller,
    String locale,
  ) {
    DateTime tempTime = DateTime.now();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SizeTokens.r24),
        ),
      ),
      builder: (BuildContext ctx) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeTokens.p16,
                  vertical: SizeTokens.p8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        AppTranslations.translate('cancel', locale),
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: SizeTokens.f16,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        controller.text =
                            '${tempTime.hour.toString().padLeft(2, '0')}:${tempTime.minute.toString().padLeft(2, '0')}';
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        AppTranslations.translate('done', locale),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: SizeTokens.f16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: DateTime.now(),
                  onDateTimeChanged: (val) {
                    tempTime = val;
                  },
                ),
              ),
            ],
          ),
        );
      },
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
