import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/ui_components/common_widgets.dart';
import '../../core/utils/app_translations.dart';
import '../../models/user_model.dart';
import '../../viewmodels/student_list_view_model.dart';
import '../../viewmodels/landing_view_model.dart';
import 'package:flutter/cupertino.dart';
import '../../models/student_model.dart';
import 'student_detail_view.dart';

class StudentListView extends StatelessWidget {
  final UserModel user;
  final int classId;
  final String className;

  const StudentListView({
    super.key,
    required this.user,
    required this.classId,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          StudentListViewModel()
            ..init(user.schoolId ?? 1, user.userKey ?? '', classId),
      child: _StudentListContent(className: className, user: user),
    );
  }
}

class _StudentListContent extends StatelessWidget {
  final String className;
  final UserModel user;

  const _StudentListContent({required this.className, required this.user});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StudentListViewModel>();
    final locale = context.watch<LandingViewModel>().locale.languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: BaseAppBar(
        title: Text(
          className,
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
          Expanded(child: _buildBody(context, viewModel, locale)),
        ],
      ),
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    StudentListViewModel viewModel,
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
    StudentListViewModel viewModel,
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

  Widget _buildBody(
    BuildContext context,
    StudentListViewModel viewModel,
    String locale,
  ) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
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

    if (viewModel.students.isEmpty) {
      return Center(
        child: Text(
          AppTranslations.translate('no_students_found', locale),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => viewModel.refresh(),
      child: ListView.separated(
        padding: EdgeInsets.all(SizeTokens.p16),
        itemCount: viewModel.students.length,
        separatorBuilder: (context, index) => SizedBox(height: SizeTokens.p16),
        itemBuilder: (context, index) {
          final student = viewModel.students[index];
          return _buildStudentCard(context, student, viewModel);
        },
      ),
    );
  }

  Widget _buildStudentCard(
    BuildContext context,
    StudentModel student,
    StudentListViewModel viewModel,
  ) {
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentDetailView(
                user: user,
                student: student,
                initialDate: viewModel.selectedDate,
              ),
            ),
          );
        },
        child: Row(
          children: [
            ClipOval(
              child: SizedBox(
                width: SizeTokens.h60,
                height: SizeTokens.h60,
                child: student.image != null && student.image!.isNotEmpty
                    ? Image.network(
                        student.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            SizedBox(width: SizeTokens.p16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${student.name ?? ''} ${student.surname ?? ''}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeTokens.f16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: SizeTokens.p4),
                  if (student.birthDate != null)
                    Text(
                      student.birthDate!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontSize: SizeTokens.f12,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey, size: SizeTokens.i24),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Icon(Icons.person, size: SizeTokens.i32, color: Colors.grey[400]),
    );
  }
}
