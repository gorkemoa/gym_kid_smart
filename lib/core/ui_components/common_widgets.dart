import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/size_config.dart';
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
                  'assets/smartmetrics-logo.png',
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
    return Container(
      height: 7.5.h + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        child: Row(
          children: [
            _buildNavItem(context, Icons.home, currentIndex == 0, 0),
            _buildNavItem(context, Icons.grid_view, currentIndex == 1, 1),
            _buildNavItem(
              context,
              Icons.chat_bubble_outline,
              currentIndex == 2,
              2,
            ),
            _buildNavItem(
              context,
              Icons.campaign_outlined,
              currentIndex == 3,
              3,
            ),
            _buildNavItem(
              context,
              Icons.settings_outlined,
              currentIndex == 4,
              4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    bool isActive,
    int index,
  ) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap?.call(index),
          child: Container(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.all(SizeTokens.p8),
              decoration: isActive
                  ? BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Icon(icon, color: Colors.white, size: SizeTokens.i28),
            ),
          ),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
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
                icon: Icons.notifications_rounded,
                label: 'notifications',
                primaryColor: primaryColor,
              ),
              _buildNavItem(
                context,
                index: 2,
                icon: Icons.person_rounded,
                label: 'profile',
                primaryColor: primaryColor,
              ),
            ],
          ),
        ),
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
              padding: EdgeInsets.symmetric(
                horizontal: SizeTokens.p16,
                vertical: SizeTokens.p6,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(SizeTokens.r20),
              ),
              child: Icon(
                icon,
                color: isSelected ? primaryColor : Colors.grey.shade400,
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
            ),
          ],
        ),
      ),
    );
  }
}
