import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/size_tokens.dart';
import '../../viewmodels/settings_view_model.dart';
import '../utils/app_translations.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  const BaseAppBar({
    super.key,
    this.title,
    this.actions,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = context.watch<SettingsViewModel>();
    final logoUrl = settingsViewModel.logoFullUrl;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      title:
          title ??
          (logoUrl.isNotEmpty
              ? Image.network(
                  logoUrl,
                  height: SizeTokens.h32,
                  errorBuilder: (context, error, stackTrace) =>
                      const Text('GYBOREE'),
                )
              : Image.asset(
                  'assets/app-logo.jpg',
                  height: SizeTokens.h32,
                  errorBuilder: (context, error, stackTrace) =>
                      const Text('GYBOREE'),
                )),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}

class BaseBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const BaseBottomNavBar({super.key, this.currentIndex = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final locale = Localizations.localeOf(context).languageCode;

    return Container(
      height: SizeTokens.h80 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(SizeTokens.r32),
          topRight: Radius.circular(SizeTokens.r32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: SizeTokens.h80,
          padding: EdgeInsets.symmetric(horizontal: SizeTokens.p8),
          child: Row(
            children: [
              _buildNavItem(
                context,
                Icons.home_rounded,
                'home',
                currentIndex == 0,
                0,
                secondaryColor,
                locale,
              ),
              _buildNavItem(
                context,
                Icons.calendar_month_rounded,
                'calendar',
                currentIndex == 1,
                1,
                secondaryColor,
                locale,
              ),
              _buildNavItem(
                context,
                Icons.chat_bubble_rounded,
                'messages',
                currentIndex == 2,
                2,
                secondaryColor,
                locale,
              ),
              _buildNavItem(
                context,
                Icons.campaign_rounded,
                'announcements',
                currentIndex == 3,
                3,
                secondaryColor,
                locale,
              ),
              _buildNavItem(
                context,
                Icons.settings_rounded,
                'settings',
                currentIndex == 4,
                4,
                secondaryColor,
                locale,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
    int index,
    Color secondaryColor,
    String locale,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () => onTap?.call(index),
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(SizeTokens.p8),
              decoration: BoxDecoration(
                color: isActive ? secondaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(SizeTokens.r12),
              ),
              child: Icon(icon, color: Colors.white, size: SizeTokens.i24),
            ),
            SizedBox(height: SizeTokens.p4),
            Text(
              AppTranslations.translate(label, locale),
              style: TextStyle(
                fontSize: SizeTokens.f10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: Colors.white.withOpacity(isActive ? 1.0 : 0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class OyunGrubuBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const OyunGrubuBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // The main bar background
        Container(
          height: SizeTokens.h80 + MediaQuery.of(context).padding.bottom,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(SizeTokens.r32),
              topRight: Radius.circular(SizeTokens.r32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 25,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              height: SizeTokens.h80,
              padding: EdgeInsets.symmetric(horizontal: SizeTokens.p16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context,
                    index: 0,
                    icon: Icons.home_rounded,
                    label: 'home',
                    primaryColor: primaryColor,
                  ),
                  _buildNavItem(
                    context,
                    index: 1,
                    icon: Icons.school_rounded,
                    label: 'og_lessons',
                    primaryColor: primaryColor,
                  ),
                  // Space for the raised center button
                  const Expanded(child: SizedBox()),
                  _buildNavItem(
                    context,
                    index: 3,
                    icon: Icons.person_rounded,
                    label: 'profile',
                    primaryColor: primaryColor,
                  ),
                  _buildNavItem(
                    context,
                    index: 4,
                    icon: Icons.settings_rounded,
                    label: 'settings',
                    primaryColor: primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ),
        // The premium raised center button
        Positioned(
          top: -SizeTokens.p32,
          child: _buildCenterNavItem(
            context,
            index: 2,
            icon: Icons.qr_code_scanner_rounded,
            label: 'qr_scan',
            primaryColor: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCenterNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required Color primaryColor,
  }) {
    final isSelected = currentIndex == index;
    final locale = Localizations.localeOf(context).languageCode;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Outer "Glow" Circle
          Container(
            padding: EdgeInsets.all(SizeTokens.p6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: EdgeInsets.all(SizeTokens.p14),
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: SizeTokens.i28),
            ),
          ),
          SizedBox(height: SizeTokens.p4),
          Text(
            AppTranslations.translate(label, locale),
            style: TextStyle(
              fontSize: SizeTokens.f12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? primaryColor : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required Color primaryColor,
  }) {
    final isSelected = currentIndex == index;
    final locale = Localizations.localeOf(context).languageCode;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: primaryColor.withOpacity(0.1),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(SizeTokens.p8),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(SizeTokens.r12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade400,
                size: SizeTokens.i24,
              ),
            ),
            SizedBox(height: SizeTokens.p4),
            Text(
              AppTranslations.translate(label, locale),
              style: TextStyle(
                fontSize: SizeTokens.f12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? primaryColor : Colors.grey.shade500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
