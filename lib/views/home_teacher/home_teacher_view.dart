import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/login_view_model.dart';
import '../../viewmodels/landing_view_model.dart';
import '../../viewmodels/home_view_model.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/responsive/size_config.dart';
import '../../core/utils/app_translations.dart';
import '../../core/ui_components/common_widgets.dart';

class HomeTeacherView extends StatefulWidget {
  const HomeTeacherView({super.key});

  @override
  State<HomeTeacherView> createState() => _HomeTeacherViewState();
}

class _HomeTeacherViewState extends State<HomeTeacherView> {
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

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const BaseAppBar(automaticallyImplyLeading: false),
      body: RefreshIndicator(
        onRefresh: () => homeViewModel.refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(SizeTokens.p20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppTranslations.translate('upcoming_events', locale),
                style: TextStyle(
                  fontSize: SizeTokens.f16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A4A4A),
                ),
              ),
              SizedBox(height: SizeTokens.p16),
              _buildNoticeSection(homeViewModel, locale),
              SizedBox(height: SizeTokens.p32),
              Text(
                AppTranslations.translate('tracking_modules', locale),
                style: TextStyle(
                  fontSize: SizeTokens.f16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A4A4A),
                ),
              ),
              SizedBox(height: SizeTokens.p20),
              _buildModulesGrid(locale),
            ],
          ),
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeTokens.r24),
          border: Border.all(color: const Color(0xFFEEEEEE)),
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
          borderRadius: BorderRadius.circular(SizeTokens.r32),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Center(
          child: Text(
            AppTranslations.translate('no_notices', locale),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: SizeTokens.f14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF333333),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 180 / 844 * 100.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.notices.length,
        itemBuilder: (context, index) {
          final notice = viewModel.notices[index];
          return Container(
            width: 300 / 390 * 100.w,
            margin: EdgeInsets.only(right: SizeTokens.p12),
            padding: EdgeInsets.all(SizeTokens.p16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(SizeTokens.r24),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notice.title ?? '',
                  style: TextStyle(
                    fontSize: SizeTokens.f16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: SizeTokens.p8),
                Text(
                  notice.description ?? '',
                  style: TextStyle(fontSize: SizeTokens.f12),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Text(
                  notice.noticeDate ?? '',
                  style: TextStyle(
                    fontSize: SizeTokens.f10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModulesGrid(String locale) {
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
        ),
        _buildModuleItem(
          icon: Icons.star_border,
          title: AppTranslations.translate('calendar', locale),
          subtitle: AppTranslations.translate('calendar_desc', locale),
          color: const Color(0xFFF7941D),
        ),
        _buildModuleItem(
          icon: Icons.restaurant_menu,
          title: AppTranslations.translate('food_list', locale),
          subtitle: AppTranslations.translate('food_list_desc', locale),
          color: const Color(0xFFF7941D),
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
  }) {
    return Container(
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
            style: TextStyle(
              fontSize: SizeTokens.f14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: SizeTokens.p4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: SizeTokens.f10,
              color: const Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
