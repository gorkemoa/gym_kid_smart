import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/utils/app_translations.dart';
import '../../../models/oyungrubu_student_model.dart';
import '../../../viewmodels/oyungrubu_student_history_view_model.dart';
import '../../../viewmodels/splash_view_model.dart';
import 'widgets/student_history_header.dart';
import 'widgets/student_history_info.dart';
import 'widgets/student_history_stats.dart';
import 'widgets/student_history_activity_card.dart';
import 'widgets/student_history_package_card.dart';
import 'widgets/student_edit_bottom_sheet.dart';

class OyunGrubuStudentHistoryView extends StatefulWidget {
  final OyunGrubuStudentModel student;

  const OyunGrubuStudentHistoryView({super.key, required this.student});

  @override
  State<OyunGrubuStudentHistoryView> createState() =>
      _OyunGrubuStudentHistoryViewState();
}

class _OyunGrubuStudentHistoryViewState
    extends State<OyunGrubuStudentHistoryView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<OyunGrubuStudentHistoryViewModel>().setTab(
              _tabController.index,
            );
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<OyunGrubuStudentHistoryViewModel>()
          .init(widget.student);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<OyunGrubuStudentHistoryViewModel, SplashViewModel>(
      builder: (context, viewModel, splashVM, child) {
        final locale = splashVM.locale.languageCode;
        final primaryColor = Theme.of(context).colorScheme.primary;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => viewModel.fetchHistory(),
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  // Header
                  SliverToBoxAdapter(
                    child: StudentHistoryHeader(
                      student: viewModel.student ?? widget.student,
                      locale: locale,
                      onBackTap: () => Navigator.pop(context),
                      onEditTap: () => _showEditBottomSheet(context, locale),
                    ),
                  ),

                  // Stats
                  if (!viewModel.isLoading && viewModel.errorMessage == null)
                    SliverToBoxAdapter(
                      child: StudentHistoryStats(
                        attendedCount: viewModel.attendedCount,
                        absentCount: viewModel.absentCount,
                        postponeCount: viewModel.postponeCount,
                        locale: locale,
                      ),
                    ),

                  // Profile Info
                  if (!viewModel.isLoading && viewModel.errorMessage == null)
                    SliverToBoxAdapter(
                      child: StudentHistoryInfo(
                        student: viewModel.student ?? widget.student,
                        locale: locale,
                      ),
                    ),

                  // Tab bar
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(
                      tabBar: TabBar(
                        controller: _tabController,
                        labelColor: primaryColor,
                        unselectedLabelColor: Colors.grey.shade500,
                        indicatorColor: primaryColor,
                        indicatorWeight: 3,
                        labelStyle: TextStyle(
                          fontSize: SizeTokens.f14,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontSize: SizeTokens.f14,
                          fontWeight: FontWeight.w400,
                        ),
                        tabs: [
                          Tab(
                            text: AppTranslations.translate(
                                'activity_logs', locale),
                          ),
                          Tab(
                            text: AppTranslations.translate(
                                'active_packages', locale),
                          ),
                          Tab(
                            text: AppTranslations.translate(
                                'expired_packages', locale),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                body: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.errorMessage != null
                        ? _buildErrorState(viewModel, locale)
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              // Activity logs tab
                              _buildActivityLogsTab(viewModel, locale),
                              // Active packages tab
                              _buildPackagesTab(
                                viewModel.activePackages,
                                locale,
                                primaryColor,
                                isActive: true,
                              ),
                              // Expired packages tab
                              _buildPackagesTab(
                                viewModel.expiredPackages,
                                locale,
                                primaryColor,
                                isActive: false,
                              ),
                            ],
                          ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityLogsTab(
    OyunGrubuStudentHistoryViewModel viewModel,
    String locale,
  ) {
    final logs = viewModel.activityLogs;
    if (logs == null || logs.isEmpty) {
      return _buildEmptyTabState(
        Icons.history_rounded,
        AppTranslations.translate('no_activity_logs', locale),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(SizeTokens.p16),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        return StudentHistoryActivityCard(
          log: logs[index],
          locale: locale,
        );
      },
    );
  }

  Widget _buildPackagesTab(
    List? packages,
    String locale,
    Color primaryColor, {
    required bool isActive,
  }) {
    if (packages == null || packages.isEmpty) {
      return _buildEmptyTabState(
        Icons.inventory_2_outlined,
        AppTranslations.translate(
          isActive ? 'no_active_packages' : 'no_expired_packages',
          locale,
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(SizeTokens.p16),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        return StudentHistoryPackageCard(
          package: packages[index],
          locale: locale,
          isActive: isActive,
        );
      },
    );
  }

  Widget _buildEmptyTabState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: SizeTokens.i64, color: Colors.grey.shade300),
          SizedBox(height: SizeTokens.p16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: SizeTokens.f16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    OyunGrubuStudentHistoryViewModel viewModel,
    String locale,
  ) {
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

  void _showEditBottomSheet(BuildContext context, String locale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StudentEditBottomSheet(locale: locale),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate({required this.tabBar});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(0xFFF5F6FA),
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
