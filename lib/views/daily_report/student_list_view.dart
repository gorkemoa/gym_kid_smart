import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/ui_components/common_widgets.dart';
import '../../core/utils/app_translations.dart';
import '../../models/user_model.dart';
import '../../viewmodels/student_list_view_model.dart';
import '../../viewmodels/landing_view_model.dart';
import '../../models/student_model.dart';
import 'package:gym_kid_smart/views/daily_report/daily_report_view.dart';
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

    final displayName = viewModel.selectedClassName.isNotEmpty
        ? viewModel.selectedClassName
        : className;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: BaseAppBar(
        title: GestureDetector(
          onTap: viewModel.classes.length > 1
              ? () => _showClassSwitcher(context, viewModel, locale)
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  displayName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: SizeTokens.f16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (viewModel.classes.length > 1) ...[
                SizedBox(width: SizeTokens.p4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Theme.of(context).primaryColor,
                  size: SizeTokens.i20,
                ),
              ],
            ],
          ),
        ),
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: IconButton(
              key: ValueKey(viewModel.isGridView),
              onPressed: viewModel.toggleViewMode,
              icon: Icon(
                viewModel.isGridView
                    ? Icons.view_list_rounded
                    : Icons.grid_view_rounded,
                color: Theme.of(context).primaryColor,
                size: SizeTokens.i24,
              ),
              tooltip: viewModel.isGridView
                  ? 'Liste Görünümü'
                  : 'Grid Görünümü',
            ),
          ),
        ],
      ),
      body: _buildBody(context, viewModel, locale),
    );
  }

  void _showClassSwitcher(
    BuildContext context,
    StudentListViewModel viewModel,
    String locale,
  ) {
    DailyReportBottomSheet.show(context, user);
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
        child: Padding(
          padding: EdgeInsets.all(SizeTokens.p32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: SizeTokens.i64,
                color: Colors.red[300],
              ),
              SizedBox(height: SizeTokens.p16),
              Text(
                viewModel.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: SizeTokens.f16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: SizeTokens.p24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: viewModel.refresh,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: SizeTokens.p12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SizeTokens.r12),
                    ),
                  ),
                  child: Text(
                    AppTranslations.translate('retry', locale),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeTokens.f14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (viewModel.students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(SizeTokens.p24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_outlined,
                size: SizeTokens.i64,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: SizeTokens.p24),
            Text(
              AppTranslations.translate('no_students_found', locale),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: SizeTokens.f18,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SizeTokens.p8),
            Text(
              AppTranslations.translate('no_data_found', locale),
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: SizeTokens.f14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => viewModel.refresh(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: viewModel.isGridView
            ? _buildGridView(context, viewModel)
            : _buildListView(context, viewModel),
      ),
    );
  }

  Widget _buildListView(BuildContext context, StudentListViewModel viewModel) {
    return ListView.separated(
      key: const ValueKey('list_view'),
      padding: EdgeInsets.all(SizeTokens.p16),
      itemCount: viewModel.students.length,
      separatorBuilder: (context, index) => SizedBox(height: SizeTokens.p16),
      itemBuilder: (context, index) {
        final student = viewModel.students[index];
        return _buildStudentListCard(context, student);
      },
    );
  }

  Widget _buildGridView(BuildContext context, StudentListViewModel viewModel) {
    return GridView.builder(
      key: const ValueKey('grid_view'),
      padding: EdgeInsets.all(SizeTokens.p16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: SizeTokens.p10,
        mainAxisSpacing: SizeTokens.p10,
        childAspectRatio: 0.75,
      ),
      itemCount: viewModel.students.length,
      itemBuilder: (context, index) {
        final student = viewModel.students[index];
        return _buildStudentGridCard(context, student);
      },
    );
  }

  Widget _buildStudentListCard(BuildContext context, StudentModel student) {
    return Container(
      padding: EdgeInsets.all(SizeTokens.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(context, student),
        child: Row(
          children: [
            _buildAvatar(student, SizeTokens.h60),
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

  Widget _buildStudentGridCard(BuildContext context, StudentModel student) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context, student),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeTokens.r8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAvatar(student, SizeTokens.h48),
            SizedBox(height: SizeTokens.p6),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeTokens.p4),
              child: Text(
                '${student.name ?? ''}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeTokens.f12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeTokens.p4),
              child: Text(
                '${student.surname ?? ''}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: SizeTokens.f10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            if (student.birthDate != null) ...[
              SizedBox(height: SizeTokens.p4),
              Text(
                student.birthDate!,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: SizeTokens.f10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(StudentModel student, double size) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: student.image != null && student.image!.isNotEmpty
            ? Image.network(
                student.image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(size),
              )
            : _buildPlaceholder(size),
      ),
    );
  }

  Widget _buildPlaceholder(double size) {
    return Container(
      color: Colors.grey[200],
      child: Icon(Icons.person, size: size * 0.5, color: Colors.grey[400]),
    );
  }

  void _navigateToDetail(BuildContext context, StudentModel student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentDetailView(user: user, student: student),
      ),
    );
  }
}
