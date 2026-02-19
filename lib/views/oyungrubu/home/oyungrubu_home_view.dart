import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/utils/app_translations.dart';
import '../../../viewmodels/oyungrubu_home_view_model.dart';
import '../../../viewmodels/splash_view_model.dart';
import '../profile/oyungrubu_profile_view.dart';
import '../../../services/oyungrubu_auth_service.dart';
import '../../../views/environment_selection/environment_selection_view.dart';
import 'widgets/oyungrubu_student_card.dart';
import 'widgets/oyungrubu_home_header.dart';
import 'widgets/oyungrubu_class_section.dart';
import 'widgets/oyungrubu_timetable_section.dart';
import 'widgets/oyungrubu_lesson_section.dart';
import '../student_detail/oyungrubu_student_detail_view.dart';
import '../../../viewmodels/oyungrubu_student_history_view_model.dart';
import '../student_history/widgets/student_edit_bottom_sheet.dart';
import 'widgets/lesson_detail_bottom_sheet.dart';
import '../notifications/oyungrubu_notifications_view.dart';

class OyunGrubuHomeView extends StatefulWidget {
  const OyunGrubuHomeView({super.key});

  @override
  State<OyunGrubuHomeView> createState() => _OyunGrubuHomeViewState();
}

class _OyunGrubuHomeViewState extends State<OyunGrubuHomeView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OyunGrubuHomeViewModel>().init();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            body: Column(
              children: [
                // Zone 1 — Compact Header
                OyunGrubuHomeHeader(
                  userName: viewModel.user?.name,
                  locale: locale,
                  studentCount: viewModel.students?.length ?? 0,
                  classCount: viewModel.classes?.length ?? 0,
                  unreadCount:
                      viewModel.notifications
                          ?.where((n) => n.isRead == 0)
                          .length ??
                      0,
                  onProfileTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OyunGrubuProfileView(),
                      ),
                    );
                  },
                  onLogoutTap: () => _showLogoutDialog(context, locale),
                  onNotificationsTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OyunGrubuNotificationsView(),
                      ),
                    );
                  },
                ),

                // Zone 2 — Tab Bar
                _buildTabBar(locale, primaryColor),

                // Zone 3 — Tab Content
                Expanded(
                  child: _buildTabContent(viewModel, locale, primaryColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar(String locale, Color primaryColor) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        SizeTokens.p24,
        SizeTokens.p16,
        SizeTokens.p24,
        SizeTokens.p8,
      ),
      padding: EdgeInsets.all(SizeTokens.p4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(SizeTokens.r12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeTokens.r10),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: primaryColor,
        unselectedLabelColor: Colors.grey.shade500,
        labelStyle: TextStyle(
          fontSize: SizeTokens.f12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: SizeTokens.f12,
          fontWeight: FontWeight.w500,
        ),
        labelPadding: EdgeInsets.zero,
        tabs: [
          Tab(
            height: SizeTokens.h32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.child_care_rounded, size: SizeTokens.i12),
                SizedBox(width: SizeTokens.p4),
                Flexible(
                  child: Text(
                    AppTranslations.translate('my_children', locale),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Tab(
            height: SizeTokens.h32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.groups_rounded, size: SizeTokens.i12),
                SizedBox(width: SizeTokens.p4),
                Flexible(
                  child: Text(
                    AppTranslations.translate('groups', locale),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Tab(
            height: SizeTokens.h32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school_rounded, size: SizeTokens.i12),
                SizedBox(width: SizeTokens.p4),
                Flexible(
                  child: Text(
                    AppTranslations.translate(
                      'upcoming_lessons',
                      locale,
                    ).split(' ').first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(
    OyunGrubuHomeViewModel viewModel,
    String locale,
    Color primaryColor,
  ) {
    return TabBarView(
      controller: _tabController,
      children: [
        // Tab 1 — My Children
        _buildChildrenTab(viewModel, locale, primaryColor),

        // Tab 2 — Groups & Schedule
        _buildGroupsTab(viewModel, locale),

        // Tab 3 — Lessons
        _buildLessonsTab(viewModel, locale),
      ],
    );
  }

  // ──────────────────────────────────────────
  // Tab 1: My Children
  // ──────────────────────────────────────────
  Widget _buildChildrenTab(
    OyunGrubuHomeViewModel viewModel,
    String locale,
    Color primaryColor,
  ) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return _buildErrorState(viewModel, locale);
    }

    if (viewModel.students == null || viewModel.students!.isEmpty) {
      return _buildEmptyState(locale);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          viewModel.fetchStudents(),
          viewModel.fetchClasses(),
        ]);
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.p24,
          vertical: SizeTokens.p8,
        ),
        itemCount: viewModel.students!.length,
        itemBuilder: (context, index) {
          final student = viewModel.students![index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OyunGrubuStudentDetailView(student: student),
                ),
              );
            },
            child: OyunGrubuStudentCard(
              student: student,
              locale: locale,
              onEdit: () async {
                context.read<OyunGrubuStudentHistoryViewModel>().init(student);
                await _showEditBottomSheet(context, locale);
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
  }

  // ──────────────────────────────────────────
  // Tab 2: Groups & Schedule
  // ──────────────────────────────────────────
  Widget _buildGroupsTab(OyunGrubuHomeViewModel viewModel, String locale) {
    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.fetchClasses();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Class groups
            OyunGrubuClassSection(
              classes: viewModel.classes,
              isLoading: viewModel.isClassesLoading,
              locale: locale,
              selectedClass: viewModel.selectedClass,
              onClassTap: (classItem) {
                if (viewModel.selectedClass?.id == classItem.id) {
                  viewModel.clearSelectedClass();
                } else {
                  viewModel.selectClassAndFetchTimetable(classItem);
                }
              },
            ),

            // Timetable (shown when a class is selected)
            if (viewModel.selectedClass != null)
              OyunGrubuTimetableSection(
                selectedClass: viewModel.selectedClass,
                timetable: viewModel.timetable,
                isLoading: viewModel.isTimetableLoading,
                locale: locale,
                onClose: () => viewModel.clearSelectedClass(),
              ),

            SizedBox(height: SizeTokens.p32),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // Tab 3: Lessons
  // ──────────────────────────────────────────
  Widget _buildLessonsTab(OyunGrubuHomeViewModel viewModel, String locale) {
    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.fetchStudents();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: OyunGrubuLessonSection(
          students: viewModel.students,
          selectedStudentId: viewModel.selectedStudentIdForLessons,
          upcomingLessons: viewModel.selectedStudentIdForLessons != null
              ? viewModel.getStudentLessons(
                  viewModel.selectedStudentIdForLessons!,
                )
              : null,
          historyLessons: viewModel.selectedStudentIdForLessons != null
              ? viewModel.getStudentHistoryLessons(
                  viewModel.selectedStudentIdForLessons!,
                )
              : null,
          isLoading: viewModel.isLessonsLoading,
          locale: locale,
          onStudentSelected: (studentId) {
            viewModel.fetchLessonsForStudent(studentId);
          },
          onLessonTap: (lesson) async {
            if (viewModel.selectedStudentIdForLessons == null ||
                lesson.lessonId == null ||
                lesson.date == null)
              return;

            // Show loading indicator
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );

            final detail = await viewModel.fetchLessonDetails(
              studentId: viewModel.selectedStudentIdForLessons!,
              lessonId: lesson.lessonId!,
              date: lesson.date!,
            );

            if (context.mounted) {
              Navigator.pop(context); // Remove loading

              if (detail != null) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) =>
                      LessonDetailBottomSheet(detail: detail, locale: locale),
                );
              }
            }
          },
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // Shared States
  // ──────────────────────────────────────────
  Widget _buildErrorState(OyunGrubuHomeViewModel viewModel, String locale) {
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
              AppTranslations.translate(viewModel.errorMessage!, locale),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SizeTokens.f16,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: SizeTokens.p24),
            ElevatedButton.icon(
              onPressed: viewModel.onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppTranslations.translate('retry', locale)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String locale) {
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
              AppTranslations.translate('no_students_registered', locale),
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

  void _showLogoutDialog(BuildContext context, String locale) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeTokens.r16),
        ),
        title: Text(
          AppTranslations.translate('logout', locale),
          style: TextStyle(
            fontSize: SizeTokens.f20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          AppTranslations.translate('logout_confirmation', locale),
          style: TextStyle(fontSize: SizeTokens.f14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppTranslations.translate('cancel', locale)),
          ),
          ElevatedButton(
            onPressed: () async {
              await OyunGrubuAuthService.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const EnvironmentSelectionView(),
                  ),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
            ),
            child: Text(AppTranslations.translate('logout', locale)),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditBottomSheet(BuildContext context, String locale) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StudentEditBottomSheet(locale: locale),
    );
  }
}
