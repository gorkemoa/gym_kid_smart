import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/utils/app_translations.dart';
import '../../../models/oyungrubu_student_model.dart';
import '../../../viewmodels/oyungrubu_student_history_view_model.dart';
import '../../../viewmodels/splash_view_model.dart';
import '../student_history/widgets/student_history_header.dart';
import '../student_history/widgets/student_package_info_section.dart';
import '../student_history/widgets/student_history_package_card.dart';

class StudentPackageDetailView extends StatefulWidget {
  final OyunGrubuStudentModel student;

  const StudentPackageDetailView({super.key, required this.student});

  @override
  State<StudentPackageDetailView> createState() =>
      _StudentPackageDetailViewState();
}

class _StudentPackageDetailViewState extends State<StudentPackageDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        final currentStudent = viewModel.student ?? widget.student;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                // Gradient header
                SliverToBoxAdapter(
                  child: StudentHistoryHeader(
                    student: currentStudent,
                    locale: locale,
                    onBackTap: () => Navigator.pop(context),
                  ),
                ),

                // Package overview
                if (!viewModel.isLoading &&
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
                      child: Row(
                        children: [
                          Container(
                            width: SizeTokens.r4,
                            height: SizeTokens.h20,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C63FF),
                              borderRadius: BorderRadius.circular(
                                SizeTokens.r4,
                              ),
                            ),
                          ),
                          SizedBox(width: SizeTokens.p10),
                          Icon(
                            Icons.assignment_outlined,
                            size: SizeTokens.i18,
                            color: Colors.grey.shade700,
                          ),
                          SizedBox(width: SizeTokens.p8),
                          Text(
                            AppTranslations.translate(
                              'package_overview',
                              locale,
                            ),
                            style: TextStyle(
                              fontSize: SizeTokens.f16,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Package info section
                if (!viewModel.isLoading &&
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

                // Tab bar section title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      SizeTokens.p24,
                      SizeTokens.p24,
                      SizeTokens.p24,
                      SizeTokens.p8,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: SizeTokens.r4,
                          height: SizeTokens.h20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF),
                            borderRadius: BorderRadius.circular(SizeTokens.r4),
                          ),
                        ),
                        SizedBox(width: SizeTokens.p10),
                        Icon(
                          Icons.inventory_2_outlined,
                          size: SizeTokens.i18,
                          color: Colors.grey.shade700,
                        ),
                        SizedBox(width: SizeTokens.p8),
                        Text(
                          AppTranslations.translate('packages', locale),
                          style: TextStyle(
                            fontSize: SizeTokens.f16,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Styled tab bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StyledTabBarDelegate(
                    tabBar: TabBar(
                      controller: _tabController,
                      labelColor: primaryColor,
                      unselectedLabelColor: Colors.grey.shade500,
                      indicatorColor: primaryColor,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      dividerColor: Colors.grey.shade200,
                      labelStyle: TextStyle(
                        fontSize: SizeTokens.f14,
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: SizeTokens.f14,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: SizeTokens.i16,
                              ),
                              SizedBox(width: SizeTokens.p6),
                              Text(
                                AppTranslations.translate(
                                  'active_packages',
                                  locale,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.archive_outlined,
                                size: SizeTokens.i16,
                              ),
                              SizedBox(width: SizeTokens.p6),
                              Text(
                                AppTranslations.translate(
                                  'expired_packages',
                                  locale,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              body: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPackagesTab(
                          viewModel.activePackages,
                          locale,
                          isActive: true,
                        ),
                        _buildPackagesTab(
                          viewModel.expiredPackages,
                          locale,
                          isActive: false,
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPackagesTab(
    List? packages,
    String locale, {
    required bool isActive,
  }) {
    if (packages == null || packages.isEmpty) {
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
                Icons.inventory_2_outlined,
                size: SizeTokens.i48,
                color: Colors.grey.shade300,
              ),
            ),
            SizedBox(height: SizeTokens.p16),
            Text(
              AppTranslations.translate(
                isActive ? 'no_active_packages' : 'no_expired_packages',
                locale,
              ),
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
