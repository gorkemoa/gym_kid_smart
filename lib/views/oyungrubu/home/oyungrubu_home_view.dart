import 'package:flutter/material.dart';
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
import '../student_history/oyungrubu_student_history_view.dart';
import '../../../viewmodels/oyungrubu_student_history_view_model.dart';
import '../student_history/widgets/student_edit_bottom_sheet.dart';

class OyunGrubuHomeView extends StatefulWidget {
  const OyunGrubuHomeView({super.key});

  @override
  State<OyunGrubuHomeView> createState() => _OyunGrubuHomeViewState();
}

class _OyunGrubuHomeViewState extends State<OyunGrubuHomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OyunGrubuHomeViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<OyunGrubuHomeViewModel, SplashViewModel>(
      builder: (context, viewModel, splashVM, child) {
        final locale = splashVM.locale.languageCode;
        final primaryColor = Theme.of(context).colorScheme.primary;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => viewModel.fetchStudents(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: OyunGrubuHomeHeader(
                      userName: viewModel.user?.name,
                      locale: locale,
                      onProfileTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OyunGrubuProfileView(),
                          ),
                        );
                      },
                      onLogoutTap: () => _showLogoutDialog(context, locale),
                    ),
                  ),

                  // Quick Stats
                  SliverToBoxAdapter(
                    child: _buildQuickStats(viewModel, locale, primaryColor),
                  ),

                  // Section Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeTokens.p24,
                        vertical: SizeTokens.p16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: SizeTokens.r4,
                            height: SizeTokens.h24,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(SizeTokens.r4),
                            ),
                          ),
                          SizedBox(width: SizeTokens.p12),
                          Text(
                            AppTranslations.translate('my_children', locale),
                            style: TextStyle(
                              fontSize: SizeTokens.f20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content
                  if (viewModel.isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (viewModel.errorMessage != null)
                    SliverFillRemaining(
                      child: _buildErrorState(viewModel, locale),
                    )
                  else if (viewModel.students == null || viewModel.students!.isEmpty)
                    SliverFillRemaining(
                      child: _buildEmptyState(locale),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: SizeTokens.p24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final student = viewModel.students![index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        OyunGrubuStudentHistoryView(
                                      student: student,
                                    ),
                                  ),
                                );
                              },
                              child: OyunGrubuStudentCard(
                                student: student,
                                locale: locale,
                                onEdit: () async {
                                  context
                                      .read<OyunGrubuStudentHistoryViewModel>()
                                      .init(student);
                                  await _showEditBottomSheet(context, locale);
                                  if (context.mounted) {
                                    context
                                        .read<OyunGrubuHomeViewModel>()
                                        .fetchStudents(isSilent: true);
                                  }
                                },
                              ),
                            );
                          },
                          childCount: viewModel.students!.length,
                        ),
                      ),
                    ),

                  // Bottom spacing
                  SliverToBoxAdapter(
                    child: SizedBox(height: SizeTokens.p32),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(
    OyunGrubuHomeViewModel viewModel,
    String locale,
    Color primaryColor,
  ) {
    final studentCount = viewModel.students?.length ?? 0;
    final groupNames = viewModel.students
            ?.where((s) => s.groupName != null && s.groupName!.isNotEmpty)
            .map((s) => s.groupName!)
            .toSet()
            .toList() ??
        [];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeTokens.p24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.child_care_rounded,
              value: studentCount.toString(),
              label: AppTranslations.translate('total_students', locale),
              color: primaryColor,
            ),
          ),
          SizedBox(width: SizeTokens.p16),
          Expanded(
            child: _buildStatCard(
              icon: Icons.groups_rounded,
              value: groupNames.isEmpty ? '-' : groupNames.length.toString(),
              label: AppTranslations.translate('groups', locale),
              color: const Color(0xFF6C63FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(SizeTokens.p20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(SizeTokens.p10),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(SizeTokens.r12),
            ),
            child: Icon(icon, color: color, size: SizeTokens.i24),
          ),
          SizedBox(height: SizeTokens.p12),
          Text(
            value,
            style: TextStyle(
              fontSize: SizeTokens.f28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: SizeTokens.p4),
          Text(
            label,
            style: TextStyle(
              fontSize: SizeTokens.f12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

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
