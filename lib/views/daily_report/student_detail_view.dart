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
import '../../core/network/api_result.dart';

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
          classId: student.classId,
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

    // Find current student from classmates
    StudentModel currentStudent = student;
    if (viewModel.classmates.isNotEmpty) {
      final match = viewModel.classmates
          .where((s) => s.id == viewModel.studentId)
          .toList();
      if (match.isNotEmpty) {
        currentStudent = match.first;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: BaseAppBar(
        title: Text(
          '${currentStudent.name} ${currentStudent.surname}',
          style: TextStyle(
            color: Colors.black,
            fontSize: SizeTokens.f16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [],
      ),
      body: _buildScrollableBody(context, viewModel, locale, currentStudent),
    );
  }

  // ─── CLASSMATES HORIZONTAL LIST ────────────────────────────────────
  Widget _buildClassmatesList(
    BuildContext context,
    StudentDetailViewModel viewModel,
    StudentModel currentStudent,
  ) {
    return Container(
      color: Colors.white,
      height: SizeTokens.h100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.p12,
          vertical: SizeTokens.p12,
        ),
        itemCount: viewModel.classmates.length,
        itemBuilder: (context, index) {
          final mate = viewModel.classmates[index];
          final isSelected = mate.id == viewModel.studentId;

          return GestureDetector(
            onTap: () => viewModel.switchStudent(mate.id!),
            child: Container(
              margin: EdgeInsets.only(right: SizeTokens.p16),
              width: SizeTokens.h52,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(isSelected ? 2 : 0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            )
                          : null,
                    ),
                    child: ClipOval(
                      child: SizedBox(
                        width: SizeTokens.h48,
                        height: SizeTokens.h48,
                        child: mate.image != null && mate.image!.isNotEmpty
                            ? Image.network(
                                mate.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildAvatarPlaceholder(SizeTokens.h48),
                              )
                            : _buildAvatarPlaceholder(SizeTokens.h48),
                      ),
                    ),
                  ),
                  SizedBox(height: SizeTokens.p4),
                  Text(
                    mate.name ?? '',
                    style: TextStyle(
                      fontSize: SizeTokens.f10,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w400,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarPlaceholder(double size) {
    return Container(
      color: Colors.grey[200],
      child: Icon(Icons.person, size: size * 0.5, color: Colors.grey[400]),
    );
  }

  // ─── STUDENT INFO CARD ─────────────────────────────────────────────
  Widget _buildStudentInfoCard(
    BuildContext context,
    StudentModel currentStudent,
  ) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        SizeTokens.p16,
        SizeTokens.p8,
        SizeTokens.p16,
        SizeTokens.p4,
      ),
      padding: EdgeInsets.all(SizeTokens.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: SizeTokens.h48,
              height: SizeTokens.h48,
              child:
                  currentStudent.image != null &&
                      currentStudent.image!.isNotEmpty
                  ? Image.network(
                      currentStudent.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildAvatarPlaceholder(SizeTokens.h48),
                    )
                  : _buildAvatarPlaceholder(SizeTokens.h48),
            ),
          ),
          SizedBox(width: SizeTokens.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${currentStudent.name ?? ''} ${currentStudent.surname ?? ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: SizeTokens.f16,
                    color: Colors.black87,
                  ),
                ),
                if (currentStudent.birthDate != null) ...[
                  SizedBox(height: SizeTokens.p4),
                  Row(
                    children: [
                      Icon(
                        Icons.cake_outlined,
                        size: SizeTokens.i16,
                        color: Colors.grey[400],
                      ),
                      SizedBox(width: SizeTokens.p4),
                      Text(
                        currentStudent.birthDate!,
                        style: TextStyle(
                          fontSize: SizeTokens.f12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── DATE SELECTOR ─────────────────────────────────────────────────
  Widget _buildDateSelector(
    BuildContext context,
    StudentDetailViewModel viewModel,
    String locale,
  ) {
    final date = DateTime.parse(viewModel.selectedDate);
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final selectedDay = DateTime(date.year, date.month, date.day);

    // Format readable date
    String formattedDate;
    if (selectedDay == DateTime(now.year, now.month, now.day)) {
      formattedDate = AppTranslations.translate('today', locale);
    } else if (selectedDay == yesterday) {
      formattedDate = AppTranslations.translate('yesterday', locale);
    } else if (selectedDay == tomorrow) {
      formattedDate = AppTranslations.translate('tomorrow', locale);
    } else {
      formattedDate = viewModel.selectedDate;
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: SizeTokens.p16,
        vertical: SizeTokens.p8,
      ),
      padding: EdgeInsets.symmetric(
        vertical: SizeTokens.p8,
        horizontal: SizeTokens.p8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous day button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(SizeTokens.r12),
              onTap: () {
                viewModel.setDate(date.subtract(const Duration(days: 1)));
              },
              child: Container(
                padding: EdgeInsets.all(SizeTokens.p8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chevron_left_rounded,
                      color: Theme.of(context).primaryColor,
                      size: SizeTokens.i24,
                    ),
                    Text(
                      _formatShortDate(
                        date.subtract(const Duration(days: 1)),
                        locale,
                      ),
                      style: TextStyle(
                        fontSize: SizeTokens.f12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Current date
          GestureDetector(
            onTap: () => _showDatePicker(context, viewModel, locale),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeTokens.p16,
                vertical: SizeTokens.p8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(SizeTokens.r8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: SizeTokens.i16,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: SizeTokens.p8),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeTokens.f14,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Next day button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(SizeTokens.r12),
              onTap: () {
                viewModel.setDate(date.add(const Duration(days: 1)));
              },
              child: Container(
                padding: EdgeInsets.all(SizeTokens.p8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatShortDate(
                        date.add(const Duration(days: 1)),
                        locale,
                      ),
                      style: TextStyle(
                        fontSize: SizeTokens.f12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Theme.of(context).primaryColor,
                      size: SizeTokens.i24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatShortDate(DateTime date, String locale) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);

    if (d == today) return AppTranslations.translate('today', locale);
    if (d == yesterday) return AppTranslations.translate('yesterday', locale);
    if (d == tomorrow) return AppTranslations.translate('tomorrow', locale);

    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
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

  // ─── Check if add button should show for a section ──────────────────
  bool _canAddToSection(String partId) {
    final role = user.role ?? '';
    if (partId == 'noteLogs') return true;
    if (partId == 'receiving') return true;
    if (partId == 'meals') return true;
    if ((partId == 'activities' || partId == 'socials') &&
        (role == 'teacher' || role == 'superadmin'))
      return true;
    if (partId == 'medicament' && (role == 'parent' || role == 'superadmin'))
      return true;
    return false;
  }

  // ─── ENTRY PAGE NAVIGATION ────────────────────────────────────────
  Future<void> _navigateToEntryPage(
    BuildContext context,
    StudentDetailViewModel viewModel,
    UserModel user, {
    DailyStudentModel? existingData,
  }) async {
    // Find current student
    StudentModel currentStudent = student;
    if (viewModel.classmates.isNotEmpty) {
      final match = viewModel.classmates
          .where((s) => s.id == viewModel.studentId)
          .toList();
      if (match.isNotEmpty) {
        currentStudent = match.first;
      }
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentEntryView(
          user: user,
          student: currentStudent,
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

  // ─── ACCORDION BODY ────────────────────────────────────────────────
  Widget _buildScrollableBody(
    BuildContext context,
    StudentDetailViewModel viewModel,
    String locale,
    StudentModel currentStudent,
  ) {
    final categories = [
      {
        'id': 'meals',
        'label': AppTranslations.translate('meals', locale),
        'icon': Icons.restaurant_menu_outlined,
      },
      {
        'id': 'socials',
        'label': AppTranslations.translate('socials', locale),
        'icon': Icons.people_outline,
      },
      {
        'id': 'activities',
        'label': AppTranslations.translate('activities', locale),
        'icon': Icons.sports_soccer_outlined,
      },
      {
        'id': 'medicament',
        'label': AppTranslations.translate('medicament', locale),
        'icon': Icons.medication_outlined,
      },
      {
        'id': 'receiving',
        'label': AppTranslations.translate('receiving', locale),
        'icon': Icons.badge_outlined,
      },
      {
        'id': 'noteLogs',
        'label': AppTranslations.translate('noteLogs', locale),
        'icon': Icons.notes_outlined,
      },
    ];

    // Build header items list
    final headerWidgets = <Widget>[];
    if (viewModel.classmates.length > 1) {
      headerWidgets.add(
        _buildClassmatesList(context, viewModel, currentStudent),
      );
    }
    headerWidgets.add(_buildStudentInfoCard(context, currentStudent));
    headerWidgets.add(_buildDateSelector(context, viewModel, locale));

    final totalItems = headerWidgets.length + categories.length;

    return RefreshIndicator(
      onRefresh: () async => viewModel.refresh(),
      child: ListView.builder(
        key: PageStorageKey('student_detail_${currentStudent.id}'),
        padding: EdgeInsets.only(bottom: SizeTokens.p16),
        itemCount: totalItems,
        itemBuilder: (context, index) {
          // Render header widgets first
          if (index < headerWidgets.length) {
            return headerWidgets[index];
          }

          // Then render accordion sections
          final catIndex = index - headerWidgets.length;
          final category = categories[catIndex];
          final partId = category['id'] as String;
          final label = category['label'] as String;
          final icon = category['icon'] as IconData;
          final isExpanded = viewModel.expandedSections.contains(partId);
          final isLoadingSection = viewModel.sectionLoading[partId] ?? false;
          final sectionData = viewModel.allSectionsData[partId] ?? [];

          return Padding(
            key: ValueKey('section_$partId'),
            padding: EdgeInsets.symmetric(horizontal: SizeTokens.p16),
            child: _buildAccordionSection(
              context: context,
              viewModel: viewModel,
              locale: locale,
              partId: partId,
              label: label,
              icon: icon,
              isExpanded: isExpanded,
              isLoading: isLoadingSection,
              data: sectionData,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccordionSection({
    required BuildContext context,
    required StudentDetailViewModel viewModel,
    required String locale,
    required String partId,
    required String label,
    required IconData icon,
    required bool isExpanded,
    required bool isLoading,
    required List<DailyStudentModel> data,
  }) {
    final showAdd = isExpanded && _canAddToSection(partId);

    return Container(
      margin: EdgeInsets.only(bottom: SizeTokens.p8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r8),
        border: Border.all(
          color: isExpanded
              ? Theme.of(context).primaryColor.withOpacity(0.3)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            borderRadius: isExpanded
                ? BorderRadius.vertical(top: Radius.circular(SizeTokens.r8))
                : BorderRadius.circular(SizeTokens.r8),
            onTap: () {
              viewModel.toggleSection(partId);
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeTokens.p12,
                vertical: SizeTokens.p12,
              ),
              decoration: BoxDecoration(
                color: isExpanded
                    ? Theme.of(context).primaryColor.withOpacity(0.04)
                    : Colors.white,
                borderRadius: isExpanded
                    ? BorderRadius.vertical(top: Radius.circular(SizeTokens.r8))
                    : BorderRadius.circular(SizeTokens.r8),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(SizeTokens.p8),
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(SizeTokens.r8),
                    ),
                    child: Icon(
                      icon,
                      size: SizeTokens.i20,
                      color: isExpanded
                          ? Theme.of(context).primaryColor
                          : Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: SizeTokens.p12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: SizeTokens.f14,
                        color: isExpanded
                            ? Theme.of(context).primaryColor
                            : Colors.black87,
                      ),
                    ),
                  ),
                  if (!isExpanded &&
                      _getSectionCount(partId, data, viewModel) > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeTokens.p8,
                        vertical: SizeTokens.p4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(SizeTokens.r4),
                      ),
                      child: Text(
                        '${_getSectionCount(partId, data, viewModel)}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: SizeTokens.f12,
                        ),
                      ),
                    ),
                  if (showAdd) ...[
                    SizedBox(width: SizeTokens.p8),
                    InkWell(
                      borderRadius: BorderRadius.circular(SizeTokens.r4),
                      onTap: () {
                        viewModel.setPart(partId);
                        _navigateToEntryPage(context, viewModel, user);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeTokens.p8,
                          vertical: SizeTokens.p4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(SizeTokens.r4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add,
                              size: SizeTokens.i16,
                              color: Colors.white,
                            ),
                            SizedBox(width: SizeTokens.p4),
                            Text(
                              AppTranslations.translate('add', locale),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: SizeTokens.f12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  SizedBox(width: SizeTokens.p8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isExpanded
                          ? Theme.of(context).primaryColor
                          : Colors.grey[400],
                      size: SizeTokens.i24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: _buildSectionContent(
              context: context,
              viewModel: viewModel,
              locale: locale,
              partId: partId,
              isLoading: isLoading,
              data: data,
            ),
          ),
        ],
      ),
    );
  }

  int _getSectionCount(
    String partId,
    List<DailyStudentModel> data,
    StudentDetailViewModel viewModel,
  ) {
    if (partId == 'medicament') return viewModel.medicaments.length;
    return data.length;
  }

  Widget _buildSectionContent({
    required BuildContext context,
    required StudentDetailViewModel viewModel,
    required String locale,
    required String partId,
    required bool isLoading,
    required List<DailyStudentModel> data,
  }) {
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.all(SizeTokens.p24),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    // Medicament section
    if (partId == 'medicament') {
      return Padding(
        padding: EdgeInsets.only(
          left: SizeTokens.p8,
          right: SizeTokens.p8,
          bottom: SizeTokens.p12,
        ),
        child: MedicamentTrackingWidget(user: user),
      );
    }

    if (data.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(SizeTokens.p24),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: SizeTokens.i32,
                color: Colors.grey[300],
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
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: SizeTokens.p12,
        right: SizeTokens.p12,
        bottom: SizeTokens.p12,
      ),
      child: Column(
        children: data.map((item) {
          return Padding(
            padding: EdgeInsets.only(top: SizeTokens.p8),
            child: StudentDetailCard(
              item: item,
              onEdit: () {
                viewModel.setPart(partId);
                _navigateToEntryPage(
                  context,
                  viewModel,
                  user,
                  existingData: item,
                );
              },
              onDelete: _canDelete(partId)
                  ? () => _showDeleteConfirmation(
                      context,
                      viewModel,
                      item,
                      locale,
                      partId,
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _canDelete(String partId) {
    final role = user.role ?? '';
    if (partId == 'socials' && (role == 'teacher' || role == 'superadmin')) {
      return true;
    }
    if (partId == 'activities' && (role == 'teacher' || role == 'superadmin')) {
      return true;
    }
    if (partId == 'meals') return true;
    return false;
  }

  void _showDeleteConfirmation(
    BuildContext context,
    StudentDetailViewModel viewModel,
    DailyStudentModel item,
    String locale,
    String partId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.translate('confirm_delete', locale)),
        content: Text(
          '${item.title} ${AppTranslations.translate('will_be_deleted', locale)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppTranslations.translate('cancel', locale)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              late ApiResult<bool> result;

              if (partId == 'socials') {
                result = await viewModel.deleteDailySocial(
                  title: item.title ?? '',
                  role: user.role ?? '',
                );
              } else if (partId == 'activities') {
                result = await viewModel.deleteDailyActivity(
                  title: item.title ?? '',
                  role: user.role ?? '',
                );
              } else if (partId == 'meals') {
                result = await viewModel.deleteDailyMeal(
                  title: item.title ?? '',
                );
              }

              if (context.mounted) {
                if (result is Success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppTranslations.translate('delete_success', locale),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (result is Failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text((result as Failure).message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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
}
