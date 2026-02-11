import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../viewmodels/settings_view_model.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final Widget? leading;

  const BaseAppBar({
    super.key,
    this.title,
    this.actions,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.leading,
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class BaseBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const BaseBottomNavBar({super.key, this.currentIndex = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.h + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home, currentIndex == 0, 0),
          _buildNavItem(context, Icons.grid_view, currentIndex == 1, 1),
          _buildNavItem(
            context,
            Icons.chat_bubble_outline,
            currentIndex == 2,
            2,
          ),
          _buildNavItem(context, Icons.campaign_outlined, currentIndex == 3, 3),
          _buildNavItem(context, Icons.settings_outlined, currentIndex == 4, 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    bool isActive,
    int index,
  ) {
    return GestureDetector(
      onTap: () => onTap?.call(index),
      child: Container(
        padding: EdgeInsets.all(SizeTokens.p8),
        decoration: isActive
            ? BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              )
            : null,
        child: Icon(icon, color: Colors.white, size: SizeTokens.i24),
      ),
    );
  }
}
