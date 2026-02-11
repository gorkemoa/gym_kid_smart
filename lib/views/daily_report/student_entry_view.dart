import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/ui_components/common_widgets.dart';
import '../../core/utils/app_translations.dart';
import '../../models/user_model.dart';
import '../../models/student_model.dart';
import '../../models/daily_student_model.dart';
import '../../viewmodels/student_entry_view_model.dart';
import '../../viewmodels/landing_view_model.dart';
import '../../core/network/api_result.dart';
import 'package:flutter/cupertino.dart';

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
      child: _StudentEntryContent(),
    );
  }
}

class _StudentEntryContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StudentEntryViewModel>();
    final locale = context.watch<LandingViewModel>().locale.languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: BaseAppBar(
        title: Text(
          AppTranslations.translate(viewModel.categoryId, locale),
          style: TextStyle(
            color: Colors.black,
            fontSize: SizeTokens.f16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(SizeTokens.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStudentHeader(context, viewModel.student),
            SizedBox(height: SizeTokens.p24),
            if (viewModel.categoryId == 'receiving')
              _buildReceivingForm(context, viewModel, locale)
            else if (viewModel.categoryId == 'activities')
              _buildActivityForm(context, viewModel, locale)
            else if (viewModel.categoryId == 'noteLogs')
              _buildNoteForm(context, viewModel, locale),
            SizedBox(height: SizeTokens.p32),
            ElevatedButton(
              onPressed: viewModel.isSaving
                  ? null
                  : () => _onSave(context, viewModel, locale),
              child: viewModel.isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(AppTranslations.translate('save', locale)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentHeader(BuildContext context, StudentModel student) {
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
      child: Row(
        children: [
          CircleAvatar(
            radius: SizeTokens.r24,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            backgroundImage: student.image != null && student.image!.isNotEmpty
                ? NetworkImage(student.image!)
                : null,
            child: student.image == null || student.image!.isEmpty
                ? Icon(Icons.person, color: Theme.of(context).primaryColor)
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
                    fontWeight: FontWeight.bold,
                    fontSize: SizeTokens.f16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivingForm(
    BuildContext context,
    StudentEntryViewModel viewModel,
    String locale,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: viewModel.recipientController,
          decoration: InputDecoration(
            labelText: AppTranslations.translate('recipient', locale),
            prefixIcon: const Icon(Icons.person_outline),
          ),
        ),
        SizedBox(height: SizeTokens.p16),
        TextField(
          controller: viewModel.timeController,
          readOnly: true,
          onTap: () => _selectTime(context, viewModel),
          decoration: InputDecoration(
            labelText: AppTranslations.translate('time', locale),
            prefixIcon: const Icon(Icons.access_time),
          ),
        ),
        SizedBox(height: SizeTokens.p16),
        TextField(
          controller: viewModel.noteController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: "Not",
            prefixIcon: const Icon(Icons.note_alt_outlined),
          ),
        ),
        if (viewModel.user.role == 'teacher' ||
            viewModel.user.role == 'superadmin') ...[
          SizedBox(height: SizeTokens.p16),
          _buildStatusToggle(context, viewModel, locale),
        ],
      ],
    );
  }

  Widget _buildActivityForm(
    BuildContext context,
    StudentEntryViewModel viewModel,
    String locale,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: viewModel.titleController,
          decoration: InputDecoration(
            labelText: AppTranslations.translate('title', locale),
            prefixIcon: const Icon(Icons.title),
          ),
        ),
        SizedBox(height: SizeTokens.p16),
        TextField(
          controller: viewModel.valueController,
          decoration: InputDecoration(
            labelText: AppTranslations.translate('value', locale),
            prefixIcon: const Icon(Icons.assessment_outlined),
          ),
        ),
        SizedBox(height: SizeTokens.p16),
        TextField(
          controller: viewModel.noteController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: AppTranslations.translate('note', locale),
            alignLabelWithHint: true,
            prefixIcon: const Icon(Icons.note_alt_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusToggle(
    BuildContext context,
    StudentEntryViewModel viewModel,
    String locale,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.p16,
        vertical: SizeTokens.p8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppTranslations.translate('status', locale),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeTokens.f14,
                ),
              ),
              Text(
                viewModel.receivingStatus == 1
                    ? AppTranslations.translate('ready_to_receive', locale)
                    : AppTranslations.translate('not_ready', locale),
                style: TextStyle(
                  color: viewModel.receivingStatus == 1
                      ? Colors.green
                      : Colors.orange,
                  fontSize: SizeTokens.f12,
                ),
              ),
            ],
          ),
          Switch(
            value: viewModel.receivingStatus == 1,
            onChanged: (val) => viewModel.setReceivingStatus(val ? 1 : 0),
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNoteForm(
    BuildContext context,
    StudentEntryViewModel viewModel,
    String locale,
  ) {
    return TextField(
      controller: viewModel.noteController,
      maxLines: 10,
      decoration: InputDecoration(
        hintText: AppTranslations.translate('enter_note', locale),
        alignLabelWithHint: true,
      ),
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    StudentEntryViewModel viewModel,
  ) async {
    final locale = context.read<LandingViewModel>().locale.languageCode;
    // Parse current time from controller or use now
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
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                initialDateTime: initial,
                onDateTimeChanged: (val) {
                  tempTime = val;
                },
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
        Navigator.pop(
          context,
          true,
        ); // Return true to indicate success for refresh
      } else if (result is Failure<bool>) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message), backgroundColor: Colors.red),
        );
      }
    }
  }
}
