import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/ui_components/common_widgets.dart';
import '../../core/utils/app_translations.dart';
import '../../models/user_model.dart';
import '../../models/student_model.dart';
import '../../models/daily_student_model.dart';
import '../../viewmodels/student_detail_view_model.dart';
import '../../viewmodels/landing_view_model.dart';
import '../../core/network/api_result.dart';
import 'package:flutter/cupertino.dart';

class StudentDetailView extends StatelessWidget {
  final UserModel user;
  final StudentModel student;

  const StudentDetailView({
    super.key,
    required this.user,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentDetailViewModel()
        ..init(
          schoolId: user.schoolId ?? 1,
          userKey: user.userKey ?? '',
          studentId: student.id!,
        ),
      child: _StudentDetailContent(user: user, student: student),
    );
  }
}

class _StudentDetailContent extends StatelessWidget {
  final UserModel user;
  final StudentModel student;

  const _StudentDetailContent({required this.user, required this.student});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StudentDetailViewModel>();
    final locale = context.watch<LandingViewModel>().locale.languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: BaseAppBar(
        title: Text(
          '${student.name} ${student.surname}', // Use correct fields
          style: TextStyle(
            color: Colors.black,
            fontSize: SizeTokens.f16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildDateSelector(context, viewModel, locale),
          _buildCategoryTabs(context, viewModel, locale),
          Expanded(child: _buildContent(context, viewModel, locale)),
        ],
      ),
      floatingActionButton:
          (viewModel.selectedPart == 'noteLogs' ||
              viewModel.selectedPart == 'receiving')
          ? FloatingActionButton(
              onPressed: () {
                if (viewModel.selectedPart == 'noteLogs') {
                  _showNoteDialog(context, viewModel, locale, user);
                } else {
                  _showReceivingDialog(context, viewModel, locale, user);
                }
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(
                viewModel.selectedPart == 'noteLogs'
                    ? Icons.add_comment
                    : Icons.person_add_alt_1,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  void _showReceivingDialog(
    BuildContext context,
    StudentDetailViewModel viewModel,
    String locale,
    UserModel user,
  ) {
    DailyStudentModel? existing;
    try {
      existing = viewModel.dailyData.firstWhere(
        (item) => item.recipient != null,
      );
    } catch (e) {
      existing = null;
    }

    final recipientController = TextEditingController(
      text: existing?.recipient ?? '',
    );
    final noteController = TextEditingController(text: existing?.note ?? '');
    final timeController = TextEditingController(
      text:
          existing?.time ??
          "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
    );
    int statusValue = existing?.status ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppTranslations.translate('receiving', locale)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: recipientController,
                  decoration: InputDecoration(
                    labelText: AppTranslations.translate('recipient', locale),
                  ),
                ),
                TextField(
                  controller: timeController,
                  decoration: InputDecoration(
                    labelText: AppTranslations.translate('time', locale),
                    hintText: "HH:mm",
                  ),
                ),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(labelText: "Not"),
                ),
                if (user.role == 'teacher' || user.role == 'superadmin')
                  SwitchListTile(
                    title: Text(AppTranslations.translate('status', locale)),
                    subtitle: Text(
                      statusValue == 1
                          ? AppTranslations.translate(
                              'ready_to_receive',
                              locale,
                            )
                          : AppTranslations.translate('not_ready', locale),
                    ),
                    value: statusValue == 1,
                    onChanged: (val) {
                      setState(() {
                        statusValue = val ? 1 : 0;
                      });
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppTranslations.translate('cancel', locale)),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await viewModel.saveReceiving(
                  time: timeController.text,
                  recipient: recipientController.text,
                  note: noteController.text,
                  status: statusValue,
                  userId: user.id ?? 0,
                  role: user.role ?? 'parent',
                );
                if (context.mounted) {
                  if (result is Success<bool>) {
                    Navigator.pop(context);
                  } else if (result is Failure<bool>) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(AppTranslations.translate('save', locale)),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteDialog(
    BuildContext context,
    StudentDetailViewModel viewModel,
    String locale,
    UserModel user,
  ) {
    // Find existing note logs if any
    DailyStudentModel? existingNote;
    try {
      existingNote = viewModel.dailyData.firstWhere(
        (item) => item.teacherNote != null || item.parentNote != null,
      );
    } catch (e) {
      existingNote = null;
    }

    String initialContent = '';
    if (user.role == 'teacher') {
      initialContent = existingNote?.teacherNote ?? '';
    } else if (user.role == 'parent') {
      initialContent = existingNote?.parentNote ?? '';
    } else {
      initialContent = existingNote?.teacherNote ?? '';
    }

    final controller = TextEditingController(text: initialContent);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.translate('add_note', locale)),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: AppTranslations.translate('enter_note', locale),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppTranslations.translate('cancel', locale)),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await viewModel.saveNote(
                content: controller.text,
                role: user.role ?? 'teacher',
              );
              if (context.mounted) {
                if (result is Success<bool>) {
                  Navigator.pop(context);
                } else if (result is Failure<bool>) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result.message,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(AppTranslations.translate('save', locale)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    StudentDetailViewModel viewModel,
    String locale,
  ) {
    final date = DateTime.parse(viewModel.selectedDate);
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        vertical: SizeTokens.p16,
        horizontal: SizeTokens.p24,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              viewModel.setDate(date.subtract(const Duration(days: 1)));
            },
            icon: Icon(
              Icons.chevron_left,
              color: Theme.of(context).primaryColor,
            ),
          ),
          GestureDetector(
            onTap: () => _showDatePicker(context, viewModel, locale),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeTokens.p12,
                vertical: SizeTokens.p8,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(SizeTokens.r12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: SizeTokens.i16,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: SizeTokens.p8),
                  Text(
                    viewModel.selectedDate,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeTokens.f16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              viewModel.setDate(date.add(const Duration(days: 1)));
            },
            icon: Icon(
              Icons.chevron_right,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(
    BuildContext context,
    StudentDetailViewModel viewModel,
    String locale,
  ) {
    final currentDate = DateTime.parse(viewModel.selectedDate);
    DateTime tempDate = currentDate;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SizeTokens.r24),
        ),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              // Header with Done button
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeTokens.p16,
                  vertical: SizeTokens.p8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
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
                        viewModel.setDate(tempDate);
                        Navigator.pop(context);
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
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: currentDate,
                  maximumDate: DateTime.now().add(const Duration(days: 365)),
                  minimumDate: DateTime(2020),
                  onDateTimeChanged: (val) {
                    tempDate = val;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryTabs(
    BuildContext context,
    StudentDetailViewModel viewModel,
    String locale,
  ) {
    final categories = [
      {'id': 'meals', 'label': AppTranslations.translate('meals', locale)},
      {'id': 'socials', 'label': AppTranslations.translate('socials', locale)},
      {
        'id': 'activities',
        'label': AppTranslations.translate('activities', locale),
      },
      {
        'id': 'medicament',
        'label': AppTranslations.translate('medicament', locale),
      },
      {
        'id': 'receiving',
        'label': AppTranslations.translate('receiving', locale),
      },
      {
        'id': 'mealMenu',
        'label': AppTranslations.translate('mealMenu', locale),
      },
      {
        'id': 'noteLogs',
        'label': AppTranslations.translate('noteLogs', locale),
      },
    ];

    return Container(
      height: SizeTokens.h52,
      margin: EdgeInsets.symmetric(vertical: SizeTokens.p16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: SizeTokens.p16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = viewModel.selectedPart == category['id'];

          return GestureDetector(
            onTap: () => viewModel.setPart(category['id'] as String),
            child: Container(
              margin: EdgeInsets.only(right: SizeTokens.p12),
              padding: EdgeInsets.symmetric(
                horizontal: SizeTokens.p16,
                vertical: SizeTokens.p8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(SizeTokens.r24),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                category['label']
                    as String, // You might want to translate these
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: SizeTokens.f14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    StudentDetailViewModel viewModel,
    String locale,
  ) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null && viewModel.dailyData.isEmpty) {
      // Only show error if no data, or maybe handle differently?
      // The API might return no data for some days which is fine.
      // Assuming empty array is success with no items.
      // But if error message is present, show error.
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              viewModel.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontSize: SizeTokens.f16),
            ),
            SizedBox(height: SizeTokens.p16),
            ElevatedButton(
              onPressed: viewModel.refresh,
              child: Text(AppTranslations.translate('retry', locale)),
            ),
          ],
        ),
      );
    }

    if (viewModel.dailyData.isEmpty) {
      return Center(
        child: Text(
          'Veri bulunamadı', // Should translate
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(SizeTokens.p16),
      itemCount: viewModel.dailyData.length,
      separatorBuilder: (context, index) => SizedBox(height: SizeTokens.p16),
      itemBuilder: (context, index) {
        final item = viewModel.dailyData[index];
        return _buildDetailCard(context, item);
      },
    );
  }

  Widget _buildDetailCard(BuildContext context, DailyStudentModel item) {
    final locale = context.read<LandingViewModel>().locale.languageCode;
    String displayTitle = item.title ?? '';
    String displayValue = item.value ?? '';

    if (item.medicamentId != null && displayTitle.isEmpty) {
      displayTitle = AppTranslations.translate('medicament', locale);
      displayValue = '#${item.medicamentId}';
    }

    // Handle Note Logs
    if (item.teacherNote != null || item.parentNote != null) {
      if (displayTitle.isEmpty) {
        displayTitle = AppTranslations.translate('noteLogs', locale);
      }
      displayValue = ''; // Clear value as we will show notes separately
    }

    // Handle Receiving (Teslim)
    if (item.recipient != null) {
      if (displayTitle.isEmpty) {
        displayTitle = AppTranslations.translate('receiving', locale);
      }
      displayValue = item.time ?? '';
    }

    return Container(
      padding: EdgeInsets.all(SizeTokens.p16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  displayTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: SizeTokens.f16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              if (item.status != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeTokens.p8,
                    vertical: SizeTokens.p4,
                  ),
                  decoration: BoxDecoration(
                    color: item.status == 1
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(SizeTokens.r8),
                  ),
                  child: Text(
                    item.status == 1 ? 'Hazır' : 'Bekleniyor',
                    style: TextStyle(
                      color: item.status == 1 ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: SizeTokens.f12,
                    ),
                  ),
                ),
            ],
          ),
          if (displayValue.isNotEmpty) ...[
            SizedBox(height: SizeTokens.p8),
            Text(
              displayValue,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
          if (item.recipient != null && item.recipient!.isNotEmpty) ...[
            SizedBox(height: SizeTokens.p8),
            Row(
              children: [
                Icon(Icons.person, size: SizeTokens.i16, color: Colors.grey),
                SizedBox(width: SizeTokens.p4),
                Text(
                  item.recipient!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                ),
              ],
            ),
          ],
          if (item.teacherNote != null && item.teacherNote!.isNotEmpty) ...[
            SizedBox(height: SizeTokens.p8),
            Text(
              '${AppTranslations.translate('teacher', locale)}: ${item.teacherNote}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
            ),
          ],
          if (item.parentNote != null && item.parentNote!.isNotEmpty) ...[
            SizedBox(height: SizeTokens.p8),
            Text(
              '${AppTranslations.translate('parent', locale)}: ${item.parentNote}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
            ),
          ],
          if (item.note != null && item.note!.isNotEmpty) ...[
            SizedBox(height: SizeTokens.p8),
            Text(
              'Not: ${item.note}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
          if (item.creator != null) ...[
            SizedBox(height: SizeTokens.p8),
            Divider(),
            SizedBox(height: SizeTokens.p4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.person_outline,
                  size: SizeTokens.i16,
                  color: Colors.grey,
                ),
                SizedBox(width: SizeTokens.p4),
                Text(
                  '${item.creator?.name ?? ''} ${item.creator?.surname ?? ''}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
