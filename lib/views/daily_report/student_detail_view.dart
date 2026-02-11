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
import 'package:flutter/cupertino.dart';
import 'student_entry_view.dart';
import 'widgets/student_detail_card.dart';
import 'widgets/medicament_tracking_widget.dart';

class StudentDetailView extends StatelessWidget {
  final UserModel user;
  final StudentModel student;
  final String? initialDate;

  const StudentDetailView({
    super.key,
    required this.user,
    required this.student,
    this.initialDate,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentDetailViewModel()
        ..init(
          schoolId: user.schoolId ?? 1,
          userKey: user.userKey ?? '',
          studentId: student.id!,
          initialDate: initialDate,
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
          '${student.name} ${student.surname}',
          style: TextStyle(
            color: Colors.black,
            fontSize: SizeTokens.f16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [],
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
              viewModel.selectedPart == 'receiving' ||
              viewModel.selectedPart == 'meals' ||
              ((viewModel.selectedPart == 'activities' ||
                      viewModel.selectedPart == 'socials') &&
                  (user.role == 'teacher' || user.role == 'superadmin')) ||
              ((viewModel.selectedPart == 'medicament') &&
                  (user.role == 'parent' || user.role == 'superadmin')))
          ? FloatingActionButton(
              onPressed: () => _navigateToEntryPage(context, viewModel, user),
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(
                viewModel.selectedPart == 'noteLogs'
                    ? Icons.add_comment
                    : viewModel.selectedPart == 'receiving'
                    ? Icons.person_add_alt_1
                    : viewModel.selectedPart == 'socials'
                    ? Icons.people_outline
                    : viewModel.selectedPart == 'meals'
                    ? Icons.restaurant
                    : viewModel.selectedPart == 'medicament'
                    ? Icons.medication_outlined
                    : Icons.sports_soccer,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  Future<void> _navigateToEntryPage(
    BuildContext context,
    StudentDetailViewModel viewModel,
    UserModel user, {
    DailyStudentModel? existingData,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentEntryView(
          user: user,
          student: student,
          categoryId: viewModel.selectedPart,
          date: viewModel.selectedDate,
          existingData: existingData,
        ),
      ),
    );

    if (result == true) {
      viewModel.refresh();
    }
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

    if (viewModel.selectedPart == 'medicament') {
      return MedicamentTrackingWidget(user: user);
    }

    if (viewModel.errorMessage != null && viewModel.dailyData.isEmpty) {
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
          AppTranslations.translate('no_data_found', locale),
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
        return StudentDetailCard(
          item: item,
          onEdit: () => _navigateToEntryPage(
            context,
            viewModel,
            user,
            existingData: item,
          ),
        );
      },
    );
  }
}
