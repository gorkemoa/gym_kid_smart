import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/login_view_model.dart';
import '../../viewmodels/landing_view_model.dart';
import '../../viewmodels/home_view_model.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/responsive/size_config.dart';
import '../../core/utils/app_translations.dart';
import '../../core/ui_components/common_widgets.dart';
import '../daily_report/daily_report_view.dart';
import '../food_list/food_list_view.dart';
import '../calendar/calendar_view.dart';
import '../chat/chat_view.dart';
import '../notice_detail/notice_detail_view.dart';
import '../notice/notice_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<LoginViewModel>().data?.data;
      if (user != null) {
        context.read<HomeViewModel>().init(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LandingViewModel>().locale.languageCode;
    final homeViewModel = context.watch<HomeViewModel>();
    final user = context.read<LoginViewModel>().data?.data;
    final role = user?.role;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: BaseAppBar(
        automaticallyImplyLeading: false,
        title: _currentIndex == 0
            ? null // Show logo for home
            : Text(
                _getAppBarTitle(_currentIndex, locale),
                style: TextStyle(
                  fontSize: SizeTokens.f18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
      ),
      body: _currentIndex == 0
          ? LayoutBuilder(
              builder: (context, constraints) {
                return RefreshIndicator(
                  onRefresh: () => homeViewModel.refresh(),
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
                            _buildSectionHeader(
                              context,
                              AppTranslations.translate(
                                'upcoming_events',
                                locale,
                              ),
                            ),
                            SizedBox(height: SizeTokens.p16),
                            Expanded(
                              flex: 32,
                              child: _buildNoticeSection(homeViewModel, locale),
                            ),
                            SizedBox(height: SizeTokens.p24),
                            _buildSectionHeader(
                              context,
                              AppTranslations.translate(
                                'tracking_modules',
                                locale,
                              ),
                            ),
                            SizedBox(height: SizeTokens.p16),
                            Expanded(
                              flex: 55,
                              child: _buildModulesGrid(locale, role),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          : _currentIndex == 1
          ? CalendarView(user: user, showAppBar: false)
          : _currentIndex == 2
          ? ChatView(user: user!, id: homeViewModel.students.first.id ?? 0)
          : _currentIndex == 3
          ? NoticeView(user: user!, showAppBar: false)
          : Center(
              child: Text(
                'Settings (TBD)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
      bottomNavigationBar: BaseBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  String _getAppBarTitle(int index, String locale) {
    switch (index) {
      case 1:
        return AppTranslations.translate('calendar', locale);
      case 2:
        return AppTranslations.translate('messages', locale);
      case 3:
        return AppTranslations.translate('announcements', locale);
      default:
        return '';
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: SizeTokens.r4,
          height: SizeTokens.h24,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
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

  Widget _buildNoticeSection(HomeViewModel viewModel, String locale) {
    if (viewModel.isLoading) {
      return _buildNoticeContainer(
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.notices.isEmpty) {
      return _buildNoticeContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(SizeTokens.p12),
              child: Icon(
                Icons.notifications_none_rounded,
                size: SizeTokens.i32,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: SizeTokens.p8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeTokens.p16),
              child: Text(
                AppTranslations.translate('no_notices', locale),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.color?.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _buildNoticeSectionContent(viewModel, locale);
  }

  Widget _buildNoticeContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r24),
        border: Border.all(color: Colors.grey.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildNoticeSectionContent(HomeViewModel viewModel, String locale) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      itemCount: viewModel.notices.length,
      padding: EdgeInsets.symmetric(vertical: SizeTokens.p4),
      itemBuilder: (context, index) {
        final notice = viewModel.notices[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoticeDetailView(notice: notice),
              ),
            );
          },
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
                      Icons.campaign_rounded,
                      size: SizeTokens.i20,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    SizedBox(width: SizeTokens.p12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notice.title ?? '',
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
                            notice.noticeDate ?? '',
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
                Text(
                  notice.description ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.9),
                    height: 1.4,
                    fontSize: SizeTokens.f14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      AppTranslations.translate('read_more', locale),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: SizeTokens.f12,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: SizeTokens.i16,
                      color: Theme.of(context).primaryColor,
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

  Widget _buildModulesGrid(String locale, String? role) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildModuleItem(
                  icon: Icons.assignment_outlined,
                  title: AppTranslations.translate('daily_report', locale),
                  subtitle: AppTranslations.translate(
                    'daily_report_desc',
                    locale,
                  ),
                  onTap: () {
                    final user = context.read<LoginViewModel>().data?.data;
                    if (user != null) {
                      DailyReportBottomSheet.show(context, user);
                    }
                  },
                ),
              ),
              SizedBox(width: SizeTokens.p16),
              Expanded(
                child: _buildModuleItem(
                  icon: Icons.star_border,
                  title: AppTranslations.translate('calendar', locale),
                  subtitle: AppTranslations.translate('calendar_desc', locale),
                  onTap: () {
                    final user = context.read<LoginViewModel>().data?.data;
                    if (user != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CalendarView(user: user),
                        ),
                      );
                    }
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
              Expanded(
                child: _buildModuleItem(
                  icon: Icons.restaurant_menu,
                  title: AppTranslations.translate('food_list', locale),
                  subtitle: AppTranslations.translate('food_list_desc', locale),
                  onTap: () {
                    final user = context.read<LoginViewModel>().data?.data;
                    if (user != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodListView(user: user),
                        ),
                      );
                    }
                  },
                ),
              ),
              SizedBox(width: SizeTokens.p16),
              Expanded(
                child: _buildModuleItem(
                  icon: Icons.chat_bubble_outline,
                  title: AppTranslations.translate('messages', locale),
                  subtitle: AppTranslations.translate('messages_desc', locale),
                  onTap: () {
                    setState(() {
                      _currentIndex = 2;
                    });
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
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(SizeTokens.p16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeTokens.r12),
          border: Border.all(color: Colors.grey.shade100, width: 1.2),
          boxShadow: [
            BoxShadow(
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
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(SizeTokens.r16),
              ),
              child: Icon(icon, color: Colors.white, size: SizeTokens.i24),
            ),
            SizedBox(height: SizeTokens.p10),
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
            SizedBox(height: SizeTokens.p4),
            Flexible(
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
