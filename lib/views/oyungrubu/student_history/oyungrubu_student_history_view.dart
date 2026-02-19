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
import 'widgets/student_package_info_section.dart';
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
      context.read<OyunGrubuStudentHistoryViewModel>().init(widget.student);
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
            top: false,
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  viewModel.fetchHistory(),
                  viewModel.fetchPackageInfo(),
                  viewModel.fetchAttendanceHistory(),
                ]);
              },
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
                        makeupBalance: viewModel.makeupBalance,
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

                  // Package Overview Header
                  if (!viewModel.isLoading &&
                      viewModel.errorMessage == null &&
                      viewModel.packageInfoList != null &&
                      (viewModel.packageInfoList!.isNotEmpty ||
                          viewModel.makeupBalance > 0))
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          SizeTokens.p24,
                          SizeTokens.p24,
                          SizeTokens.p24,
                          SizeTokens.p8,
                        ),
                        child: _buildSectionTitle(
                          Icons.assignment_outlined,
                          AppTranslations.translate('package_details', locale),
                          primaryColor,
                        ),
                      ),
                    ),

                  // Package Info Detail
                  if (!viewModel.isLoading &&
                      viewModel.errorMessage == null &&
                      viewModel.packageInfoList != null &&
                      (viewModel.packageInfoList!.isNotEmpty ||
                          viewModel.makeupBalance > 0))
                    SliverToBoxAdapter(
                      child: StudentPackageInfoSection(
                        packages: viewModel.packageInfoList!,
                        packageCount: viewModel.packageCount,
                        makeupBalance: viewModel.makeupBalance,
                        locale: locale,
                      ),
                    ),

                  // Activity title
                  if (!viewModel.isLoading && viewModel.errorMessage == null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          SizeTokens.p24,
                          SizeTokens.p24,
                          SizeTokens.p24,
                          SizeTokens.p8,
                        ),
                        child: _buildSectionTitle(
                          Icons.timeline_rounded,
                          AppTranslations.translate('activity_history', locale),
                          primaryColor,
                        ),
                      ),
                    ),

                  // Tab bar — Styled
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StyledTabBarDelegate(
                      tabBar: _buildStyledTabBar(locale, primaryColor),
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
                          _buildActivityLogsTab(viewModel, locale),
                          _buildPackagesTab(
                            viewModel.activePackages,
                            locale,
                            primaryColor,
                            isActive: true,
                          ),
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

  Widget _buildSectionTitle(IconData icon, String title, Color primaryColor) {
    return Row(
      children: [
        Container(
          width: SizeTokens.r4,
          height: SizeTokens.h20,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(SizeTokens.r4),
          ),
        ),
        SizedBox(width: SizeTokens.p10),
        Icon(icon, size: SizeTokens.i18, color: Colors.grey.shade700),
        SizedBox(width: SizeTokens.p8),
        Text(
          title,
          style: TextStyle(
            fontSize: SizeTokens.f16,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  TabBar _buildStyledTabBar(String locale, Color primaryColor) {
    return TabBar(
      controller: _tabController,
      labelColor: primaryColor,
      unselectedLabelColor: Colors.grey.shade500,
      indicatorColor: primaryColor,
      indicatorWeight: 3,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.grey.shade200,
      labelStyle: TextStyle(
        fontSize: SizeTokens.f12,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: SizeTokens.f12,
        fontWeight: FontWeight.w500,
      ),
      tabs: [
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_rounded, size: SizeTokens.i12),
              SizedBox(width: SizeTokens.p4),
              Flexible(
                child: Text(
                  AppTranslations.translate('activity_logs', locale),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline_rounded, size: SizeTokens.i12),
              SizedBox(width: SizeTokens.p4),
              Flexible(
                child: Text(
                  AppTranslations.translate('active_packages', locale),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.archive_outlined, size: SizeTokens.i12),
              SizedBox(width: SizeTokens.p4),
              Flexible(
                child: Text(
                  AppTranslations.translate('expired_packages', locale),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityLogsTab(
    OyunGrubuStudentHistoryViewModel viewModel,
    String locale,
  ) {
    final logs = viewModel.attendanceHistory ?? viewModel.activityLogs;
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
        return StudentHistoryActivityCard(log: logs[index], locale: locale);
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
          Container(
            padding: EdgeInsets.all(SizeTokens.p24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: SizeTokens.i48,
              color: Colors.grey.shade300,
            ),
          ),
          SizedBox(height: SizeTokens.p16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: SizeTokens.f14,
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

class _StyledTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StyledTabBarDelegate({required this.tabBar});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: const Color(0xFFF5F6FA), child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _StyledTabBarDelegate oldDelegate) => false;
}
