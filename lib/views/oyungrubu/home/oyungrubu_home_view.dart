import 'package:flutter/material.dart';
import '../../../models/oyungrubu_lesson_model.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/responsive/size_config.dart';
import '../../../core/utils/app_translations.dart';
import '../../../viewmodels/oyungrubu_home_view_model.dart';
import '../../../viewmodels/splash_view_model.dart';
import '../profile/oyungrubu_profile_view.dart';
import 'widgets/oyungrubu_home_header.dart';
import '../student_detail/oyungrubu_student_detail_view.dart';
import '../../../viewmodels/oyungrubu_student_history_view_model.dart';
import '../student_history/widgets/student_edit_bottom_sheet.dart';
import 'widgets/lesson_detail_bottom_sheet.dart';
import '../notifications/oyungrubu_notifications_view.dart';
import '../../../core/ui_components/common_widgets.dart';
import '../../../viewmodels/settings_view_model.dart';
import 'widgets/oyungrubu_student_card.dart';
import 'widgets/oyungrubu_class_section.dart';
import 'widgets/oyungrubu_timetable_section.dart';
import 'widgets/oyungrubu_lesson_section.dart';
import '../settings/oyungrubu_settings_view.dart';
import '../qr_scanner/oyungrubu_qr_scanner_view.dart';
import '../student_history/oyungrubu_student_history_view.dart';

class OyunGrubuHomeView extends StatefulWidget {
  const OyunGrubuHomeView({super.key});

  @override
  State<OyunGrubuHomeView> createState() => _OyunGrubuHomeViewState();
}

class _OyunGrubuHomeViewState extends State<OyunGrubuHomeView> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OyunGrubuHomeViewModel>().init();
      final settingsVM = context.read<SettingsViewModel>();
      if (settingsVM.settings == null) {
        settingsVM.fetchSettings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<OyunGrubuHomeViewModel, SplashViewModel>(
      builder: (context, viewModel, splashVM, child) {
        final locale = splashVM.locale.languageCode;
        final primaryColor = Theme.of(context).colorScheme.primary;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            body: _buildBody(viewModel, splashVM, locale, primaryColor),
            bottomNavigationBar: OyunGrubuBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    OyunGrubuHomeViewModel viewModel,
    SplashViewModel splashVM,
    String locale,
    Color primaryColor,
  ) {
    switch (_currentIndex) {
      case 0:
        return _buildHomeDashboard(viewModel, locale, primaryColor);
      case 1:
        return _OyunGrubuLessonsPage(viewModel: viewModel, locale: locale);
      case 2:
        return const OyunGrubuQRScannerView();
      case 3:
        return const OyunGrubuProfileView(isTab: true);
      case 4:
        return const OyunGrubuSettingsView(isTab: true);
      default:
        return const SizedBox.shrink();
    }
  }

  // ──────────────────────────────────────────
  // HOME DASHBOARD — Anaokulu-style layout
  // ──────────────────────────────────────────
  Widget _buildHomeDashboard(
    OyunGrubuHomeViewModel viewModel,
    String locale,
    Color primaryColor,
  ) {
    return Column(
      children: [
        // Zone 1 — Compact Header
        OyunGrubuHomeHeader(
          userName: viewModel.user?.name,
          locale: locale,
          studentCount: viewModel.students?.length ?? 0,
          classCount: viewModel.classes?.length ?? 0,
          unreadCount:
              viewModel.notifications?.where((n) => n.isRead == 0).length ?? 0,
          onNotificationsTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const OyunGrubuNotificationsView(isTab: false),
              ),
            );
          },
        ),

        // Zone 2 — Main Content
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return RefreshIndicator(
                onRefresh: () async => viewModel.refresh(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      maxHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeTokens.p20,
                        vertical: SizeTokens.p12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Section Title — Dersler
                          _buildSectionHeader(
                            context,
                            AppTranslations.translate('og_lessons', locale),
                          ),
                          SizedBox(height: SizeTokens.p16),

                          // Lessons horizontal scroll
                          Expanded(
                            flex: 32,
                            child: _buildLessonsSection(
                              viewModel,
                              locale,
                              primaryColor,
                            ),
                          ),

                          SizedBox(height: SizeTokens.p24),

                          // Section Title — Modüller
                          _buildSectionHeader(
                            context,
                            AppTranslations.translate('og_modules', locale),
                          ),
                          SizedBox(height: SizeTokens.p16),

                          // 4-Grid Modules
                          Expanded(
                            flex: 55,
                            child: _buildModulesGrid(
                              viewModel,
                              locale,
                              primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // Section Header (anaokulu-style)
  // ──────────────────────────────────────────
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: SizeTokens.r4,
          height: SizeTokens.h24,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(SizeTokens.r4),
          ),
        ),
        SizedBox(width: SizeTokens.p12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // Lessons Horizontal Section
  // ──────────────────────────────────────────
  Widget _buildLessonsSection(
    OyunGrubuHomeViewModel viewModel,
    String locale,
    Color primaryColor,
  ) {
    if (viewModel.isLoading) {
      return _buildLessonContainer(
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // Collect all upcoming lessons from all students
    final allLessons = <_LessonWithStudent>[];
    if (viewModel.students != null) {
      for (final student in viewModel.students!) {
        final lessons = viewModel.getStudentLessons(student.id ?? 0);
        if (lessons != null) {
          for (final lesson in lessons) {
            allLessons.add(
              _LessonWithStudent(lesson: lesson, studentId: student.id ?? 0),
            );
          }
        }
      }
    }

    if (allLessons.isEmpty) {
      return _buildLessonContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(SizeTokens.p12),
              child: Icon(
                Icons.school_outlined,
                size: SizeTokens.i32,
                color: primaryColor,
              ),
            ),
            SizedBox(height: SizeTokens.p8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeTokens.p16),
              child: Text(
                AppTranslations.translate('no_upcoming_lessons', locale),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                    // ignore: deprecated_member_use
                  ).textTheme.bodyLarge?.color?.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      itemCount: allLessons.length,
      padding: EdgeInsets.symmetric(vertical: SizeTokens.p4),
      itemBuilder: (context, index) {
        final item = allLessons[index];
        final lesson = item.lesson;

        return GestureDetector(
          onTap: () => _onLessonCardTap(viewModel, item, locale),
          child: Container(
            width: 310 / 390 * 100.w,
            margin: EdgeInsets.only(right: SizeTokens.p16),
            padding: EdgeInsets.all(SizeTokens.p20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(SizeTokens.r12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.school_rounded,
                      size: SizeTokens.i20,
                      color: primaryColor,
                    ),
                    SizedBox(width: SizeTokens.p12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.lessonTitle ?? lesson.groupName ?? '',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.color,
                                  fontSize: SizeTokens.f16,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            lesson.date ?? '',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SizeTokens.p16),
                Row(
                  children: [
                    if (lesson.startTime != null) ...[
                      Icon(
                        Icons.access_time_rounded,
                        size: SizeTokens.i14,
                        color: Colors.grey.shade500,
                      ),
                      SizedBox(width: SizeTokens.p4),
                      Text(
                        _formatTime(lesson.startTime),
                        style: TextStyle(
                          fontSize: SizeTokens.f12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (lesson.endTime != null) ...[
                      Text(
                        ' - ${_formatTime(lesson.endTime)}',
                        style: TextStyle(
                          fontSize: SizeTokens.f12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      AppTranslations.translate('lesson_detail', locale),
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: SizeTokens.f12,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: SizeTokens.i16,
                      color: primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLessonContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r24),
        border: Border.all(color: Colors.grey.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  // ──────────────────────────────────────────
  // 4-Grid Modules (anaokulu-style)
  // ──────────────────────────────────────────
  Widget _buildModulesGrid(
    OyunGrubuHomeViewModel viewModel,
    String locale,
    Color primaryColor,
  ) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              // Module 1: Çocuklarım
              Expanded(
                child: _buildModuleItem(
                  icon: Icons.child_care_rounded,
                  title: AppTranslations.translate('my_children', locale),
                  tdesc: AppTranslations.translate('my_children_tdesc', locale),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _OyunGrubuChildrenPage(
                          viewModel: viewModel,
                          locale: locale,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: SizeTokens.p16),
              // Module 2: Gruplar
              Expanded(
                child: _buildModuleItem(
                  icon: Icons.groups_rounded,
                  title: AppTranslations.translate('groups', locale),
                  tdesc: AppTranslations.translate('groups_tdesc', locale),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _OyunGrubuGroupsPage(
                          viewModel: viewModel,
                          locale: locale,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: SizeTokens.p16),
        Expanded(
          child: Row(
            children: [
              // Module 3: Dersler
              Expanded(
                child: _buildModuleItem(
                  icon: Icons.school_rounded,
                  title: AppTranslations.translate('og_lessons', locale),
                  tdesc: AppTranslations.translate('lessons_tdesc', locale),
                  onTap: () {
                    setState(() {
                      _currentIndex = 1;
                    });
                  },
                ),
              ),
              SizedBox(width: SizeTokens.p16),
              // Module 4: Paket Satın Al
              Expanded(
                child: _buildModuleItem(
                  icon: Icons.add_shopping_cart_rounded,
                  title: AppTranslations.translate('buy_package', locale),
                  tdesc: AppTranslations.translate(
                    'buy_new_package_desc',
                    locale,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _OyunGrubuSelectChildForPackagePage(
                          viewModel: viewModel,
                          locale: locale,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModuleItem({
    required IconData icon,
    required String title,
    String? tdesc,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(SizeTokens.p10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeTokens.r12),
          border: Border.all(color: Colors.grey.shade100, width: 1.2),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(SizeTokens.p12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(SizeTokens.r16),
              ),
              child: Icon(icon, color: Colors.white, size: SizeTokens.i20),
            ),
            SizedBox(height: SizeTokens.p6),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
            if (tdesc != null) ...[
              SizedBox(height: SizeTokens.p2),
              Text(
                tdesc,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                  fontSize: SizeTokens.f10,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ],
            SizedBox(height: SizeTokens.p2),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────

  String _formatTime(String? time) {
    if (time == null) return '';
    final parts = time.split(':');
    if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
    return time;
  }

  void _onLessonCardTap(
    OyunGrubuHomeViewModel viewModel,
    _LessonWithStudent item,
    String locale,
  ) async {
    final lesson = item.lesson;
    if (lesson.lessonId == null || lesson.date == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final detail = await viewModel.fetchLessonDetails(
      studentId: item.studentId,
      lessonId: lesson.lessonId!,
      date: lesson.date!,
    );

    if (context.mounted) {
      Navigator.pop(context);

      if (detail != null) {
        showModalBottomSheet(
          // ignore: use_build_context_synchronously
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => LessonDetailBottomSheet(
            detail: detail,
            locale: locale,
            studentId: item.studentId,
            startTime: lesson.startTime,
            onSubmitAttendance:
                ({
                  required int studentId,
                  required String date,
                  required String startTime,
                  required String status,
                  required int lessonId,
                  String? note,
                }) {
                  return viewModel.submitAttendance(
                    studentId: studentId,
                    date: date,
                    startTime: startTime,
                    status: status,
                    lessonId: lessonId,
                    note: note,
                  );
                },
          ),
        );
      }
    }
  }
}

// ──────────────────────────────────────────
// Helper class for lesson + student ID pair
// ──────────────────────────────────────────
class _LessonWithStudent {
  final OyunGrubuLessonModel lesson;
  final int studentId;

  _LessonWithStudent({required this.lesson, required this.studentId});
}

// ══════════════════════════════════════════
// FULL-SCREEN PAGES FOR GRID MODULES
// ══════════════════════════════════════════

// ──────────────────────────────────────────
// Children Page
// ──────────────────────────────────────────
class _OyunGrubuChildrenPage extends StatelessWidget {
  final OyunGrubuHomeViewModel viewModel;
  final String locale;

  const _OyunGrubuChildrenPage({required this.viewModel, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          AppTranslations.translate('my_children', locale),
          style: TextStyle(
            fontSize: SizeTokens.f18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<OyunGrubuHomeViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.errorMessage != null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(SizeTokens.p32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: SizeTokens.i64,
                      color: Colors.red.shade300,
                    ),
                    SizedBox(height: SizeTokens.p16),
                    Text(
                      AppTranslations.translate(vm.errorMessage!, locale),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: SizeTokens.f16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: SizeTokens.p24),
                    ElevatedButton.icon(
                      onPressed: vm.onRetry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(AppTranslations.translate('retry', locale)),
                    ),
                  ],
                ),
              ),
            );
          }

          if (vm.students == null || vm.students!.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(SizeTokens.p32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.child_care_rounded,
                      size: SizeTokens.i64,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(height: SizeTokens.p16),
                    Text(
                      AppTranslations.translate(
                        'no_students_registered',
                        locale,
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: SizeTokens.f16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([vm.fetchStudents(), vm.fetchClasses()]);
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: SizeTokens.p24,
                vertical: SizeTokens.p8,
              ),
              itemCount: vm.students!.length,
              itemBuilder: (context, index) {
                final student = vm.students![index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            OyunGrubuStudentDetailView(student: student),
                      ),
                    );
                  },
                  child: OyunGrubuStudentCard(
                    student: student,
                    locale: locale,
                    onEdit: () async {
                      context.read<OyunGrubuStudentHistoryViewModel>().init(
                        student,
                      );
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => StudentEditBottomSheet(locale: locale),
                      );
                      if (context.mounted) {
                        context.read<OyunGrubuHomeViewModel>().fetchStudents(
                          isSilent: true,
                        );
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────
// Select Child For Package Page
// ──────────────────────────────────────────
class _OyunGrubuSelectChildForPackagePage extends StatelessWidget {
  final OyunGrubuHomeViewModel viewModel;
  final String locale;

  const _OyunGrubuSelectChildForPackagePage({
    required this.viewModel,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          AppTranslations.translate('select_student_for_package', locale),
          style: TextStyle(
            fontSize: SizeTokens.f18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<OyunGrubuHomeViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.errorMessage != null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(SizeTokens.p32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: SizeTokens.i64,
                      color: Colors.red.shade300,
                    ),
                    SizedBox(height: SizeTokens.p16),
                    Text(
                      AppTranslations.translate(vm.errorMessage!, locale),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: SizeTokens.f16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: SizeTokens.p24),
                    ElevatedButton.icon(
                      onPressed: vm.onRetry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(AppTranslations.translate('retry', locale)),
                    ),
                  ],
                ),
              ),
            );
          }
          if (vm.students == null || vm.students!.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(SizeTokens.p32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.child_care_rounded,
                      size: SizeTokens.i64,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(height: SizeTokens.p16),
                    Text(
                      AppTranslations.translate(
                        'no_students_registered',
                        locale,
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: SizeTokens.f16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: SizeTokens.p24,
              vertical: SizeTokens.p16,
            ),
            itemCount: vm.students!.length,
            itemBuilder: (context, index) {
              final student = vm.students![index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          OyunGrubuStudentHistoryView(student: student),
                    ),
                  );
                },
                child: OyunGrubuStudentCard(
                  student: student,
                  locale: locale,
                  onEdit: () async {
                    context.read<OyunGrubuStudentHistoryViewModel>().init(
                      student,
                    );
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => StudentEditBottomSheet(locale: locale),
                    );
                    if (context.mounted) {
                      context.read<OyunGrubuHomeViewModel>().fetchStudents(
                        isSilent: true,
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────
// Groups Page
// ──────────────────────────────────────────
class _OyunGrubuGroupsPage extends StatelessWidget {
  final OyunGrubuHomeViewModel viewModel;
  final String locale;

  const _OyunGrubuGroupsPage({required this.viewModel, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          AppTranslations.translate('groups', locale),
          style: TextStyle(
            fontSize: SizeTokens.f18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<OyunGrubuHomeViewModel>(
        builder: (context, vm, _) {
          return RefreshIndicator(
            onRefresh: () async {
              await vm.fetchClasses();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Class groups
                  OyunGrubuClassSection(
                    classes: vm.classes,
                    isLoading: vm.isClassesLoading,
                    locale: locale,
                    selectedClass: vm.selectedClass,
                    onClassTap: (classItem) {
                      if (vm.selectedClass?.id == classItem.id) {
                        vm.clearSelectedClass();
                      } else {
                        vm.selectClassAndFetchTimetable(classItem);
                      }
                    },
                  ),

                  // Timetable (shown when a class is selected)
                  if (vm.selectedClass != null)
                    OyunGrubuTimetableSection(
                      selectedClass: vm.selectedClass,
                      timetable: vm.timetable,
                      isLoading: vm.isTimetableLoading,
                      locale: locale,
                      onClose: () => vm.clearSelectedClass(),
                    ),

                  SizedBox(height: SizeTokens.p32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────
// Lessons Page
// ──────────────────────────────────────────
class _OyunGrubuLessonsPage extends StatelessWidget {
  final OyunGrubuHomeViewModel viewModel;
  final String locale;

  const _OyunGrubuLessonsPage({required this.viewModel, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          AppTranslations.translate('og_lessons', locale),
          style: TextStyle(
            fontSize: SizeTokens.f18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<OyunGrubuHomeViewModel>(
        builder: (context, vm, _) {
          return RefreshIndicator(
            onRefresh: () async {
              await vm.fetchStudents();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: OyunGrubuLessonSection(
                students: vm.students,
                selectedStudentId: vm.selectedStudentIdForLessons,
                upcomingLessons: vm.selectedStudentIdForLessons != null
                    ? vm.getStudentLessons(vm.selectedStudentIdForLessons!)
                    : null,
                historyLessons: vm.selectedStudentIdForLessons != null
                    ? vm.getStudentHistoryLessons(
                        vm.selectedStudentIdForLessons!,
                      )
                    : null,
                isLoading: vm.isLessonsLoading,
                locale: locale,
                onStudentSelected: (studentId) {
                  vm.fetchLessonsForStudent(studentId);
                },
                onLessonTap: (lesson) async {
                  if (vm.selectedStudentIdForLessons == null ||
                      lesson.lessonId == null ||
                      lesson.date == null)
                    return;

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  final detail = await vm.fetchLessonDetails(
                    studentId: vm.selectedStudentIdForLessons!,
                    lessonId: lesson.lessonId!,
                    date: lesson.date!,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);

                    if (detail != null) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => LessonDetailBottomSheet(
                          detail: detail,
                          locale: locale,
                          studentId: vm.selectedStudentIdForLessons!,
                          startTime: lesson.startTime,
                          onSubmitAttendance:
                              ({
                                required int studentId,
                                required String date,
                                required String startTime,
                                required String status,
                                required int lessonId,
                                String? note,
                              }) {
                                return vm.submitAttendance(
                                  studentId: studentId,
                                  date: date,
                                  startTime: startTime,
                                  status: status,
                                  lessonId: lessonId,
                                  note: note,
                                );
                              },
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
