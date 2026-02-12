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
      appBar: const BaseAppBar(automaticallyImplyLeading: false),
      body: _currentIndex == 0
          ? RefreshIndicator(
              onRefresh: () => homeViewModel.refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(SizeTokens.p24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppTranslations.translate('upcoming_events', locale),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF4A4A4A),
                      ),
                    ),
                    SizedBox(height: SizeTokens.p16),
                    _buildNoticeSection(homeViewModel, locale),
                    SizedBox(height: SizeTokens.p32),
                    Text(
                      AppTranslations.translate('tracking_modules', locale),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF4A4A4A),
                      ),
                    ),
                    SizedBox(height: SizeTokens.p20),
                    _buildModulesGrid(locale, role),
                  ],
                ),
              ),
            )
          : _currentIndex == 1
          ? CalendarView(user: user, showAppBar: false)
          : Center(
              child: Text(
                AppTranslations.translate('messages', locale),
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

  Widget _buildNoticeSection(HomeViewModel viewModel, String locale) {
    if (viewModel.isLoading) {
      return Container(
        height: 180 / 844 * 100.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeTokens.r24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.notices.isEmpty) {
      return Container(
        height: 180 / 844 * 100.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeTokens.r24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(SizeTokens.p12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: SizeTokens.i32,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: SizeTokens.p12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeTokens.p16),
              child: Text(
                AppTranslations.translate('no_notices', locale),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A4A4A),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 190 / 844 * 100.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: viewModel.notices.length,
        itemBuilder: (context, index) {
          final notice = viewModel.notices[index];
          return Container(
            width: 300 / 390 * 100.w,
            margin: EdgeInsets.only(right: SizeTokens.p16),
            padding: EdgeInsets.all(SizeTokens.p20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(SizeTokens.r24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(SizeTokens.p8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(SizeTokens.r8),
                      ),
                      child: Icon(
                        Icons.event_note_rounded,
                        size: SizeTokens.i20,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(width: SizeTokens.p12),
                    Expanded(
                      child: Text(
                        notice.title ?? '',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF212121),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SizeTokens.p12),
                Text(
                  notice.description ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF616161),
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: SizeTokens.i16,
                      color: Colors.grey,
                    ),
                    SizedBox(width: SizeTokens.p4),
                    Text(
                      notice.noticeDate ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModulesGrid(String locale, String? role) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: SizeTokens.p16,
      crossAxisSpacing: SizeTokens.p16,
      childAspectRatio: 0.9,
      children: [
        _buildModuleItem(
          icon: Icons.assignment_outlined,
          title: AppTranslations.translate('daily_report', locale),
          subtitle: AppTranslations.translate('daily_report_desc', locale),
          color: const Color(0xFFF7941D),
          onTap: () {
            final user = context.read<LoginViewModel>().data?.data;
            if (user != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DailyReportView(user: user),
                ),
              );
            }
          },
        ),
        _buildModuleItem(
          icon: Icons.star_border,
          title: AppTranslations.translate('calendar', locale),
          subtitle: AppTranslations.translate('calendar_desc', locale),
          color: const Color(0xFFF7941D),
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
        _buildModuleItem(
          icon: Icons.restaurant_menu,
          title: AppTranslations.translate('food_list', locale),
          subtitle: AppTranslations.translate('food_list_desc', locale),
          color: const Color(0xFFF7941D),
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
        _buildModuleItem(
          icon: Icons.chat_bubble_outline,
          title: AppTranslations.translate('messages', locale),
          subtitle: AppTranslations.translate('messages_desc', locale),
          color: const Color(0xFFF7941D),
        ),
      ],
    );
  }

  Widget _buildModuleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(SizeTokens.p16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeTokens.r32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(SizeTokens.p12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: SizeTokens.i24),
            ),
            SizedBox(height: SizeTokens.p12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SizeTokens.p4),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF666666)),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
