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
      child: _StudentDetailContent(student: student),
    );
  }
}

class _StudentDetailContent extends StatelessWidget {
  final StudentModel student;

  const _StudentDetailContent({required this.student});

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
          Text(
            viewModel.selectedDate,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: SizeTokens.f16,
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

  Widget _buildCategoryTabs(
    BuildContext context,
    StudentDetailViewModel viewModel,
    String locale,
  ) {
    final categories = [
      {'id': 'meals', 'label': 'Yemek'},
      {'id': 'social', 'label': 'Sosyal'},
      {'id': 'activities', 'label': 'Aktivite'},
      {'id': 'medicament', 'label': 'İlaç'},
      {'id': 'receiving', 'label': 'Teslim'},
      {'id': 'mealMenu', 'label': 'Menü'},
      {'id': 'noteLogs', 'label': 'Notlar'},
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
          Text(
            item.title ?? '',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: SizeTokens.f16,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: SizeTokens.p8),
          Text(
            item.value ?? '',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
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
