import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/ui_components/common_widgets.dart';
import '../../../core/utils/app_translations.dart';
import '../../../models/user_model.dart';
import '../../../models/student_model.dart';
import '../../../models/daily_student_model.dart';
import '../../../viewmodels/student_entry_view_model.dart';
import '../../../viewmodels/landing_view_model.dart';
import '../../../core/network/api_result.dart';
import 'widgets/student_header_widget.dart';
import 'widgets/receiving_form_widget.dart';
import 'widgets/activity_form_widget.dart';
import 'widgets/meal_form_widget.dart';
import 'widgets/social_form_widget.dart';
import 'widgets/medicament_form_widget.dart';
import 'widgets/note_form_widget.dart';

class StudentEntryView extends StatelessWidget {
  final UserModel user;
  final StudentModel student;
  final String categoryId;
  final String date;
  final DailyStudentModel? existingData;

  const StudentEntryView({
    super.key,
    required this.user,
    required this.student,
    required this.categoryId,
    required this.date,
    this.existingData,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentEntryViewModel()
        ..init(
          user: user,
          student: student,
          categoryId: categoryId,
          date: date,
          existingData: existingData,
        ),
      child: const _StudentEntryContent(),
    );
  }
}

class _StudentEntryContent extends StatelessWidget {
  const _StudentEntryContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StudentEntryViewModel>();
    final locale = context.watch<LandingViewModel>().locale.languageCode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: BaseAppBar(
        title: Text(
          AppTranslations.translate(viewModel.categoryId, locale).toUpperCase(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: SizeTokens.f16,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(SizeTokens.p20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StudentHeaderWidget(student: viewModel.student),
              SizedBox(height: SizeTokens.p24),
              _buildForm(context, viewModel, locale),
              SizedBox(height: SizeTokens.p40),
              _buildSaveButton(context, viewModel, locale),
              SizedBox(height: SizeTokens.p20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    StudentEntryViewModel viewModel,
    String locale,
  ) {
    switch (viewModel.categoryId) {
      case 'receiving':
        return ReceivingFormWidget(
          viewModel: viewModel,
          locale: locale,
          onTimeTap: () => _selectTime(context, viewModel),
        );
      case 'meals':
        return MealFormWidget(
          viewModel: viewModel,
          locale: locale,
          onAddValue: (context, vm, loc) => _showAddTemplateBottomSheet(
            context: context,
            viewModel: vm,
            locale: loc,
            type: 'value',
          ),
        );
      case 'activities':
        return ActivityFormWidget(
          viewModel: viewModel,
          locale: locale,
          onAddValue: (context, vm, loc) => _showAddTemplateBottomSheet(
            context: context,
            viewModel: vm,
            locale: loc,
            type: 'value',
          ),
          onAddTitle: (context, vm, loc) => _showAddTemplateBottomSheet(
            context: context,
            viewModel: vm,
            locale: loc,
            type: 'title',
          ),
        );
      case 'socials':
        return SocialFormWidget(
          viewModel: viewModel,
          locale: locale,
          onAddValue: (context, vm, loc) => _showAddTemplateBottomSheet(
            context: context,
            viewModel: vm,
            locale: loc,
            type: 'value',
          ),
          onAddTitle: (context, vm, loc) => _showAddTemplateBottomSheet(
            context: context,
            viewModel: vm,
            locale: loc,
            type: 'title',
          ),
        );
      case 'medicament':
        return MedicamentFormWidget(
          viewModel: viewModel,
          locale: locale,
          onTimeTap: () => _selectTime(context, viewModel),
        );
      case 'noteLogs':
        return NoteFormWidget(viewModel: viewModel, locale: locale);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSaveButton(
    BuildContext context,
    StudentEntryViewModel viewModel,
    String locale,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeTokens.r12),
        boxShadow: [
          if (!viewModel.isSaving)
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ElevatedButton(
        onPressed: viewModel.isSaving
            ? null
            : () => _onSave(context, viewModel, locale),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: SizeTokens.p16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeTokens.r12),
          ),
        ),
        child: viewModel.isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                AppTranslations.translate('save', locale).toUpperCase(),
                style: const TextStyle(
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  void _showAddTemplateBottomSheet({
    required BuildContext context,
    required StudentEntryViewModel viewModel,
    required String locale,
    required String type, // 'title' or 'value'
  }) {
    final controller = TextEditingController();
    final isTitle = type == 'title';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(SizeTokens.r24),
            ),
          ),
          padding: EdgeInsets.all(SizeTokens.p24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppTranslations.translate(
                      isTitle ? 'add_new_title' : 'add_new_value',
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
              SizedBox(height: SizeTokens.p16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: AppTranslations.translate(
                    isTitle ? 'title' : 'value',
                    locale,
                  ),
                  prefixIcon: Icon(
                    isTitle ? Icons.title : Icons.star_outline,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SizedBox(height: SizeTokens.p24),
              ElevatedButton(
                onPressed: () async {
                  if (controller.text.trim().isEmpty) return;

                  ApiResult result;
                  if (isTitle) {
                    // Temporarily set controller to save
                    final oldTitle = viewModel.titleController.text;
                    viewModel.titleController.text = controller.text.trim();
                    if (viewModel.categoryId == 'socials') {
                      result = await viewModel.saveSocialTitleAsTemplate();
                    } else {
                      result = await viewModel.saveTitleAsTemplate();
                    }
                    // Restore or clear? Clear is better for UX if they want to select it now
                    viewModel.titleController.text = oldTitle;
                  } else {
                    result = await viewModel.saveValueAsTemplate(
                      controller.text.trim(),
                    );
                  }

                  if (context.mounted) {
                    _showSnackBar(context, result, locale);
                    if (result is Success) Navigator.pop(context);
                  }
                },
                child: Text(AppTranslations.translate('save', locale)),
              ),
              SizedBox(height: SizeTokens.p12),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, ApiResult result, String locale) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result is Success
              ? AppTranslations.translate('save_success', locale)
              : (result as Failure).message,
        ),
        backgroundColor: result is Success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeTokens.r10),
        ),
        margin: EdgeInsets.all(SizeTokens.p16),
      ),
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    StudentEntryViewModel viewModel,
  ) async {
    final locale = context.read<LandingViewModel>().locale.languageCode;
    DateTime initial;
    try {
      final parts = viewModel.timeController.text.split(':');
      final now = DateTime.now();
      initial = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    } catch (e) {
      initial = DateTime.now();
    }

    DateTime tempTime = initial;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SizeTokens.r24),
        ),
      ),
      builder: (context) => SizedBox(
        height: 350,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(SizeTokens.p16),
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
                  Text(
                    AppTranslations.translate('time', locale),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeTokens.f18,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      viewModel.timeController.text =
                          "${tempTime.hour.toString().padLeft(2, '0')}:${tempTime.minute.toString().padLeft(2, '0')}";
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
            const Divider(height: 1),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                initialDateTime: initial,
                onDateTimeChanged: (val) => tempTime = val,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSave(
    BuildContext context,
    StudentEntryViewModel viewModel,
    String locale,
  ) async {
    final result = await viewModel.save();
    if (context.mounted) {
      if (result is Success<bool>) {
        Navigator.pop(context, true);
      } else if (result is Failure<bool>) {
        _showSnackBar(context, result, locale);
      }
    }
  }
}
